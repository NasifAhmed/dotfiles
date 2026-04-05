#!/usr/bin/env python3
import json
import os
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
TAGS_FILE = BASE_DIR / "data" / "output" / "question_tags.json"
TOPICS_FILE = BASE_DIR / "data" / "output" / "topics.json"
OUTPUT_FILE = BASE_DIR / "web" / "topics_data.js"

def build_web_topics():
    if not TAGS_FILE.exists():
        print("No question_tags.json found. Run classifier first.")
        return

    with open(TAGS_FILE, "r") as f:
        tags = json.load(f)

    # Structure: { Category: { Subcategory: { Topic: [item_ids] } } }
    hierarchy = {}

    for img_rel_path, info in tags.items():
        # Convert "2007A_A/Q01.png" to "2007A_A_Q01" to match SEARCH_DATA IDs
        item_id = img_rel_path.replace(".png", "").replace("/", "_")
        
        category = info.get("category", "Uncategorized")
        subcategory = info.get("subcategory", "General")
        topic = info.get("topic", "General")

        if category not in hierarchy:
            hierarchy[category] = {}
        if subcategory not in hierarchy[category]:
            hierarchy[category][subcategory] = {}
        if topic not in hierarchy[category][subcategory]:
            hierarchy[category][subcategory][topic] = []
        
        hierarchy[category][subcategory][topic].append(item_id)

    # Sort the IDs within each topic (newest first based on year in ID)
    for cat in hierarchy:
        for sub in hierarchy[cat]:
            for top in hierarchy[cat][sub]:
                hierarchy[cat][sub][top].sort(reverse=True)

    json_str = json.dumps(hierarchy, indent=2)
    with open(OUTPUT_FILE, "w") as f:
        f.write(f"window.TOPICS_DATA = {json_str};")
    
    print(f"✓ Web topics data built! Saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    build_web_topics()
