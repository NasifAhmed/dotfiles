#!/usr/bin/env python3
import os
import json
import time
import argparse
import re
from pathlib import Path
from PIL import Image
import google.generativeai as genai

# Setup paths
BASE_DIR = Path(__file__).parent.parent
TOPICS_FILE = BASE_DIR / "data" / "output" / "topics.json"
QUESTIONS_DIR = BASE_DIR / "data" / "output" / "cropped_questions"
TAGS_FILE = BASE_DIR / "data" / "output" / "question_tags.json"
PROGRESS_FILE = BASE_DIR / "data" / "state" / ".classifier_progress.json"
API_COLLECTION_FILE = BASE_DIR / ".api_collection"

class ApiKeyManager:
    def __init__(self, key_file):
        self.key_file = Path(key_file)
        self.keys = []
        self.current_index = 0
        self.load_keys()

    def load_keys(self):
        if self.key_file.exists():
            with open(self.key_file, "r") as f:
                self.keys = [line.strip() for line in f if line.strip() and not line.startswith("#")]
        
        env_key = os.environ.get("GOOGLE_API_KEY")
        if env_key and env_key not in self.keys:
            self.keys.append(env_key)
        
        return len(self.keys) > 0

    def get_current_key(self):
        return self.keys[self.current_index] if self.keys else None

    def switch_to_next_key(self):
        if self.current_index + 1 < len(self.keys):
            self.current_index += 1
            return True
        return False

    def get_status_str(self):
        return f"API Key {self.current_index + 1}/{len(self.keys)}"

def load_json(file_path, default):
    if not file_path.exists():
        return default
    with open(file_path, "r") as f:
        try:
            return json.load(f)
        except json.JSONDecodeError:
            return default

def save_json(file_path, data):
    with open(file_path, "w") as f:
        json.dump(data, f, indent=2)

def get_untagged_questions():
    progress = load_json(PROGRESS_FILE, {"completed": []})
    completed = set(progress["completed"])
    
    cropper_progress_file = BASE_DIR / "data" / "state" / ".cropper_progress.json"
    ocr_map = {}
    if cropper_progress_file.exists():
        cp_data = load_json(cropper_progress_file, {})
        for exam_id, crops in cp_data.items():
            for crop in crops:
                q_num = crop.get("question_num")
                text = crop.get("extracted_text", "")
                if q_num:
                    ocr_map[f"{exam_id}/Q{q_num:02d}.png"] = text

    untagged = []
    if not QUESTIONS_DIR.exists(): return []
    
    for exam_dir in sorted(QUESTIONS_DIR.iterdir()):
        if exam_dir.is_dir():
            for img_file in sorted(exam_dir.glob("*.png")):
                rel_path = f"{exam_dir.name}/{img_file.name}"
                if rel_path not in completed:
                    text = ocr_map.get(rel_path, "")
                    untagged.append((rel_path, img_file, text))
    return untagged

def format_topic_list(topics):
    lines = []
    for category, subcategories in topics.items():
        lines.append(f"- {category}")
        for subcategory, specific_topics in subcategories.items():
            lines.append(f"  - {subcategory}")
            # Optionally list specific topics if needed, but keeping it high-level helps token usage
            # and encourages the model to find the best fit within the subcategory.
            # for topic in specific_topics.keys():
            #     lines.append(f"    - {topic}")
    return "\n".join(lines)

def classify_question(model, img_path, ocr_text, topic_list_str):
    img = Image.open(img_path)
    
    prompt = f"""
You are an expert IT Exam Classifier for the FE (Fundamental IT Engineer) Examination.
Classify the question based *strictly* on the official FE Textbook structure.

### Taxonomy Structure (Chapter > Section):
{topic_list_str}

### Input:
- Question Text: {ocr_text}
- Image: (Attached)

### Instructions:
1. **Analyze** the question content (text + image).
2. **Categorize** it into exactly ONE "Category" (Chapter) and ONE "Subcategory" (Section) from the list above.
3. **Specific Topic:** Provide a short, specific topic name (2-4 words) that fits under the subcategory. Use existing topics if they fit, or suggest a new accurate one.
4. **Reasoning:** Briefly explain your choice.

### Output JSON Format:
{{
  "category": "Exact Chapter Name from list",
  "subcategory": "Exact Section Name from list",
  "topic": "Specific Topic Name",
  "explanation": "One sentence reason."
}}
"""
    
    response = model.generate_content([prompt, img])
    try:
        text = response.text.strip()
        match = re.search(r'\{.*\}', text, re.DOTALL)
        if match:
            return json.loads(match.group())
        return None
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Classify questions using Gemini API")
    parser.add_argument("--batch-size", type=int, default=20, help="Number of questions to process")
    parser.add_argument("--delay", type=float, default=2.0, help="Delay between requests")
    args = parser.parse_args()

    api_manager = ApiKeyManager(API_COLLECTION_FILE)
    if not api_manager.load_keys():
        print("Error: No API keys found.")
        return

    def setup_model(key):
        genai.configure(api_key=key)
        return genai.GenerativeModel('gemini-flash-latest')

    model = setup_model(api_manager.get_current_key())
    topics = load_json(TOPICS_FILE, {})
    tags = load_json(TAGS_FILE, {})
    progress = load_json(PROGRESS_FILE, {"completed": []})
    
    untagged = get_untagged_questions()
    if not untagged:
        print("No untagged questions found.")
        return

    batch = untagged[:args.batch_size]
    print(f"Processing {len(batch)} questions with {api_manager.get_status_str()}...")

    for i, (rel_path, img_file, ocr_text) in enumerate(batch):
        print(f"[{i+1}/{len(batch)}] {rel_path}...", end=" ", flush=True)
        
        retry_count = 0
        while retry_count < 2:
            try:
                topic_list_str = format_topic_list(topics)
                result = classify_question(model, img_file, ocr_text, topic_list_str)
                
                if result:
                    tags[rel_path] = result
                    save_json(TAGS_FILE, tags)
                    
                    # Update local topics if Gemini suggested something new and valid
                    cat = result.get("category")
                    sub = result.get("subcategory")
                    top = result.get("topic", "General")
                    
                    if cat and sub:
                        if cat not in topics: topics[cat] = {}
                        if sub not in topics[cat]: topics[cat][sub] = {}
                        if top not in topics[cat][sub]:
                            topics[cat][sub][top] = []
                            save_json(TOPICS_FILE, topics)
                    
                    progress["completed"].append(rel_path)
                    save_json(PROGRESS_FILE, progress)
                    print("✅")
                    break
                else:
                    print("❌ (Parse Error)", end=" ")
                    retry_count += 1
            except Exception as e:
                if "429" in str(e) or "ResourceExhausted" in str(e):
                    print("\n⚠️ Quota exceeded.", end=" ")
                    if api_manager.switch_to_next_key():
                        print(f"Switching to {api_manager.get_status_str()}...")
                        model = setup_model(api_manager.get_current_key())
                        continue
                    else:
                        print("No more keys. Stopping.")
                        return
                else:
                    print(f"❌ ({e})", end=" ")
                    retry_count += 1
        
        if i < len(batch) - 1:
            time.sleep(args.delay)

    print("Done.")

if __name__ == "__main__":
    main()
