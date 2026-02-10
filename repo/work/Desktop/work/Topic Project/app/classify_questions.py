#!/usr/bin/env python3
import os
import json
import time
import argparse
from pathlib import Path
from PIL import Image
import google.generativeai as genai

# Setup paths
BASE_DIR = Path(__file__).parent.parent
TOPICS_FILE = BASE_DIR / "data" / "output" / "topics.json"
QUESTIONS_DIR = BASE_DIR / "data" / "output" / "cropped_questions"
TAGS_FILE = BASE_DIR / "data" / "output" / "question_tags.json"
PROGRESS_FILE = BASE_DIR / "data" / "state" / ".classifier_progress.json"

# Gemini Configuration
# Ensure GOOGLE_API_KEY is set in environment
API_KEY = os.environ.get("GOOGLE_API_KEY")

def load_topics():
    if not TOPICS_FILE.exists():
        return {}
    with open(TOPICS_FILE, "r") as f:
        return json.load(f)

def save_topics(topics):
    with open(TOPICS_FILE, "w") as f:
        json.dump(topics, f, indent=2)

def load_tags():
    if not TAGS_FILE.exists():
        return {}
    with open(TAGS_FILE, "r") as f:
        return json.load(f)

def save_tags(tags):
    with open(TAGS_FILE, "w") as f:
        json.dump(tags, f, indent=2)

def load_progress():
    if not PROGRESS_FILE.exists():
        return {"completed": []}
    with open(PROGRESS_FILE, "r") as f:
        return json.load(f)

def save_progress(progress):
    with open(PROGRESS_FILE, "w") as f:
        json.dump(progress, f, indent=2)

def get_untagged_questions():
    progress = load_progress()
    completed = set(progress["completed"])
    
    # Load OCR text from cropper progress
    cropper_progress_file = BASE_DIR / "data" / "state" / ".cropper_progress.json"
    ocr_map = {}
    if cropper_progress_file.exists():
        with open(cropper_progress_file, "r") as f:
            cp_data = json.load(f)
            for exam_id, crops in cp_data.items():
                for crop in crops:
                    q_num = crop.get("question_num")
                    text = crop.get("extracted_text", "")
                    if q_num:
                        ocr_map[f"{exam_id}/Q{q_num:02d}.png"] = text

    untagged = []
    for exam_dir in sorted(QUESTIONS_DIR.iterdir()):
        if exam_dir.is_dir():
            for img_file in sorted(exam_dir.glob("*.png")):
                rel_path = f"{exam_dir.name}/{img_file.name}"
                if rel_path not in completed:
                    text = ocr_map.get(rel_path, "")
                    untagged.append((rel_path, img_file, text))
    return untagged

def format_topic_list(topics):
    """Formats the topic hierarchy for the prompt."""
    lines = []
    for domain, subdomains in topics.items():
        if domain == "Uncategorized": continue
        lines.append(f"- {domain}")
        for subdomain, subsubs in subdomains.items():
            lines.append(f"  - {subdomain}")
            for subsub in subsubs.keys():
                lines.append(f"    - {subsub}")
    return "\n".join(lines)

def classify_question(model, img_path, ocr_text, topic_list_str):
    img = Image.open(img_path)
    
    prompt = f"""
You are an expert IT Exam Classifier specializing in the ITPEC Fundamental IT Engineer (FE) Examination syllabus.
Your task is to categorize the provided exam question into the most appropriate topic.

### Inputs:
1. **Extracted Text (OCR):** 
{ocr_text}

2. **Question Image:** (Attached)

### Current Taxonomy:
{topic_list_str}

### Instructions:
- Analyze both the text and the image (diagrams, code, logic).
- Choose the **single** most specific topic that fits.
- **Priority:** Prefer existing topics in the taxonomy.
- **New Topics:** Only suggest a new 'topic' (Sub-subdomain) if the question is within the FE syllabus but clearly doesn't fit the current list.
- Return ONLY valid JSON.

### Output Format:
{{
  "category": "Domain (e.g. Computer Systems)",
  "subcategory": "Subdomain (e.g. Memory)",
  "topic": "Sub-subdomain (e.g. Cache)",
  "explanation": "Briefly explain why this topic was chosen based on the question content."
}}
"""
    
    response = model.generate_content([prompt, img])
    try:
        # Extract JSON from response (sometimes Gemini wraps it in ```json)
        text = response.text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
        
        return json.loads(text)
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        print(f"Raw response: {response.text}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Classify questions using Gemini API")
    parser.add_argument("--batch-size", type=int, default=50, help="Number of questions to process")
    parser.add_argument("--delay", type=float, default=4.0, help="Delay between requests in seconds")
    args = parser.parse_args()

    if not API_KEY:
        print("Error: GOOGLE_API_KEY environment variable not set.")
        return

    genai.configure(api_key=API_KEY)
    model = genai.GenerativeModel('gemini-flash-latest')

    topics = load_topics()
    topic_list_str = format_topic_list(topics)
    
    untagged = get_untagged_questions()
    if not untagged:
        print("All questions are already tagged!")
        return

    tags = load_tags()
    progress = load_progress()
    
    batch = untagged[:args.batch_size]
    print(f"Processing batch of {len(batch)} questions...")

    for i, (rel_path, img_file, ocr_text) in enumerate(batch):
        print(f"[{i+1}/{len(batch)}] Classifying {rel_path}...")
        
        try:
            result = classify_question(model, img_file, ocr_text, topic_list_str)
            if result:
                tags[rel_path] = result
                save_tags(tags)
                
                # Check if we need to add a new topic
                category = result.get("category")
                subcategory = result.get("subcategory")
                topic = result.get("topic")
                
                if category and subcategory and topic:
                    if category not in topics:
                        topics[category] = {}
                    if subcategory not in topics[category]:
                        topics[category][subcategory] = {}
                    if topic not in topics[category][subcategory]:
                        topics[category][subcategory][topic] = []
                        print(f"Added new topic: {category} > {subcategory} > {topic}")
                        save_topics(topics)
                        # Update topic list string for next requests
                        topic_list_str = format_topic_list(topics)

                progress["completed"].append(rel_path)
                save_progress(progress)
            
            if i < len(batch) - 1:
                time.sleep(args.delay)
        except Exception as e:
            if "429" in str(e) or "ResourceExhausted" in str(e):
                print(f"\n{'-'*40}")
                print("⚠️  QUOTA EXCEEDED (Daily or Minute limit)")
                print("Your current API key has hit its limit.")
                print(f"Progress saved up to {rel_path}")
                print(f"{'-'*40}\n")
                break
            else:
                print(f"Error processing {rel_path}: {e}")
                continue

    print("Batch processing complete.")

if __name__ == "__main__":
    main()
