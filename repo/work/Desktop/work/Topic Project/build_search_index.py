#!/usr/bin/env python3
"""
Build Search Index for FE Question Bank
This script builds a search index from cropped questions.
It uses text extracted directly from PDFs (via question_cropper statistics).
"""

import json
import os
import sys
import hashlib
from pathlib import Path
from dataclasses import dataclass

# Import crop logic for fallback extraction
sys.path.append(str(Path(__file__).parent))
from question_cropper import parse_exam_folders, extract_text_from_crop

BASE_DIR = Path(__file__).parent
PROGRESS_FILE = BASE_DIR / ".cropper_progress.json"
OUTPUT_DIR = BASE_DIR / "cropped_questions"
WEB_DATA_FILE = BASE_DIR / "web" / "data.js"
STATE_FILE = BASE_DIR / ".search_index_state.json"

@dataclass
class CropWrapper:
    """Wrapper to make dict look like QuestionCrop object for extraction."""
    question_num: int
    page_num: int
    x1: int
    y1: int
    x2: int
    y2: int
    extra_pages: list

    @classmethod
    def from_dict(cls, data):
        return cls(
            question_num=data['question_num'],
            page_num=data['page_num'],
            x1=data['x1'],
            y1=data['y1'],
            x2=data['x2'],
            y2=data['y2'],
            extra_pages=data.get('extra_pages', [])
        )

def get_file_hash(filepath):
    """Get MD5 hash of a file for change detection."""
    if not filepath.exists():
        return None
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def load_state():
    """Load previous processing state."""
    if STATE_FILE.exists():
        try:
            with open(STATE_FILE) as f:
                return json.load(f)
        except:
            pass
    return {"processed": {}, "index": []}

def save_state(state):
    """Save processing state."""
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f, indent=2)

def build_index(force=False):
    """Build search index."""
    
    if not PROGRESS_FILE.exists():
        print("No progress file found. Run question_cropper.py first.")
        return

    print("Loading progress data...")
    with open(PROGRESS_FILE) as f:
        progress_data = json.load(f)

    # Load previous state
    state = load_state()
    processed_hashes = state.get("processed", {})
    existing_index = {r["id"]: r for r in state.get("index", [])}
    
    # Prepare Data Structures
    exams = parse_exam_folders()
    exam_map = {e.output_folder: e for e in exams}
    
    # Pre-load all tags
    tags_dict = {}
    for eid in exam_map.keys():
        meta_path = OUTPUT_DIR / eid / "metadata.json"
        if meta_path.exists():
            try:
                with open(meta_path) as f:
                    tags_dict[eid] = json.load(f)
            except:
                tags_dict[eid] = {}
        else:
             tags_dict[eid] = {}
             
    # Prepare list of items
    items_to_keep = set()
    new_index = []
    
    updated_count = 0
    
    for exam_folder, crops in progress_data.items():
        if exam_folder not in exam_map: 
            continue
            
        exam_info = exam_map[exam_folder]
        
        for crop_data in crops:
            if not crop_data.get('confirmed'):
                continue
                
            q_num = crop_data['question_num']
            item_id = f"{exam_folder}_Q{q_num:02d}"
            img_path = OUTPUT_DIR / exam_folder / f"Q{q_num:02d}.png"
            
            # Verify image exists
            if not img_path.exists():
                continue
            
            items_to_keep.add(item_id)
            
            # Check if we need to process (re-extract text or tags changed)
            # Use image hash as a proxy for "something changed"
            # But mostly we care if text is missing
            
            current_hash = get_file_hash(img_path)
            # Tag lookup
            exam_tags = tags_dict.get(exam_folder, {})
            tag = exam_tags.get(str(q_num), "Uncategorized")
            
            # Logic:
            # 1. If force=True, re-process
            # 2. If item not in index, process
            # 3. If image hash changed, re-process
            # 4. If text is missing in existing index, re-process
            
            needs_update = False
            if force or item_id not in existing_index:
                needs_update = True
            elif existing_index[item_id].get('_hash') != current_hash:
                needs_update = True
            elif not existing_index[item_id].get('text'):
                needs_update = True
            elif existing_index[item_id].get('tag') != tag:
                # Just update tag, no need to re-extract text
                existing_index[item_id]['tag'] = tag
                new_index.append(existing_index[item_id])
                continue
                
            if not needs_update:
                new_index.append(existing_index[item_id])
                continue
                
            # Process Item
            # 1. Get text
            text = crop_data.get('extracted_text', "")
            
            # Fallback: Extract from PDF if missing
            if not text:
                print(f"Extracting text for {item_id} from PDF...")
                try:
                    crop_obj = CropWrapper.from_dict(crop_data)
                    text = extract_text_from_crop(exam_info.pdf_path, crop_obj)
                    if not text:
                        text = ""
                except Exception as e:
                    print(f"Failed extraction fallback for {item_id}: {e}")
            
            # 2. Build record
            record = {
                "id": item_id,
                "exam_id": exam_folder,
                "year": exam_info.year,
                "term": "Spring" if exam_info.session == "S" else "Autumn",
                "type": "Morning" if exam_info.exam_type == "A" else "Afternoon",
                "q_num": q_num,
                "img_path": f"../cropped_questions/{exam_folder}/Q{q_num:02d}.png",
                "text": text,
                "tag": tag,
                "_hash": current_hash
            }
            
            new_index.append(record)
            existing_index[item_id] = record
            processed_hashes[item_id] = current_hash
            updated_count += 1
            
            if updated_count % 10 == 0:
                print(f"Processed {updated_count} items...", end='\r')

    print(f"\nTotal items processed/verified: {len(new_index)}")

    # Sort
    new_index.sort(key=lambda x: (-x.get('year', 0), x.get('q_num', 0)))
    
    # Save JS
    # Remove internal fields for output
    output_index = []
    for item in new_index:
        c = item.copy()
        c.pop('_hash', None)
        output_index.append(c)
        
    json_str = json.dumps(output_index, indent=2)
    with open(WEB_DATA_FILE, 'w') as f:
        f.write(f"window.SEARCH_DATA = {json_str};")
        
    # Save JSON
    with open(BASE_DIR / "web" / "data.json", 'w') as f:
        json.dump(output_index, f, indent=2)
        
    # Save State
    state = {
        "processed": processed_hashes,
        "index": new_index
    }
    save_state(state)
    
    print(f"✓ Index built successfully! {len(output_index)} items.")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", "-f", action="store_true", help="Force rebuild")
    args = parser.parse_args()
    build_index(force=args.force)
