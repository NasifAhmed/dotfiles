
import json
import os
from pathlib import Path
import pytesseract
from PIL import Image
import sys
import multiprocessing
from functools import partial

# Import exam parsing logic from main app
sys.path.append(str(Path(__file__).parent))
from question_cropper import parse_exam_folders, ExamInfo

BASE_DIR = Path(__file__).parent
PROGRESS_FILE = BASE_DIR / ".cropper_progress.json"
OUTPUT_DIR = BASE_DIR / "cropped_questions"
WEB_DATA_FILE = BASE_DIR / "web" / "data.js"

def process_single_crop(crop_data, exam_info_dict, tags_dict):
    """
    Worker function to process a single crop.
    Args are passed as a tuple or individual items?
    multiprocessing needs picklable args.
    
    exam_info_dict: dict of exam_id -> dict (simplified info)
    tags_dict: dict of exam_id -> dict of q_num -> tag
    """
    exam_folder = crop_data['exam_folder']
    q_num = crop_data['question_num']
    
    # Check if confirmed
    if not crop_data.get('confirmed'):
        return None

    img_path = OUTPUT_DIR / exam_folder / f"Q{q_num:02d}.png"
    if not img_path.exists():
        return None

    # Perform OCR
    text = ""
    try:
        text = pytesseract.image_to_string(Image.open(img_path))
        text = " ".join(text.split())
    except Exception as e:
        print(f"OCR Fail {exam_folder} Q{q_num}: {e}")

    # Metadata
    exam_tags = tags_dict.get(exam_folder, {})
    tag = exam_tags.get(str(q_num), "Uncategorized")
    
    info = exam_info_dict.get(exam_folder, {})
    
    record = {
        "id": f"{exam_folder}_Q{q_num:02d}",
        "exam_id": exam_folder,
        "year": info.get('year'),
        "term": info.get('term'),
        "type": info.get('type'),
        "q_num": q_num,
        "img_path": f"../cropped_questions/{exam_folder}/Q{q_num:02d}.png",
        "text": text,
        "tag": tag
    }
    return record

def build_index():
    print(f"Building index using OCR with {multiprocessing.cpu_count()} cores...")
    
    if not PROGRESS_FILE.exists():
        print("No progress file found.")
        return

    with open(PROGRESS_FILE) as f:
        progress_data = json.load(f)

    # Prepare Data Structures for Workers
    exams = parse_exam_folders()
    exam_map = {e.output_folder: e for e in exams}
    
    # Simplified Serializable Exam Info
    exam_info_dict = {}
    for eid, einfo in exam_map.items():
        exam_info_dict[eid] = {
            'year': einfo.year,
            'term': "Spring" if einfo.session == "S" else "Autumn",
            'type': "Morning" if einfo.exam_type == "A" else "Afternoon"
        }
    
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
             
    # Flatten work items
    work_items = []
    for exam_folder, crops in progress_data.items():
        if exam_folder not in exam_map: continue
        for crop in crops:
            # Inject exam folder into crop object for worker
            c = crop.copy()
            c['exam_folder'] = exam_folder
            work_items.append(c)

    print(f"Processing {len(work_items)} items...")
    
    # Multiprocessing
    # Fix: partial cannot pickle duplicate tags_dict easily if large, but it's small text.
    with multiprocessing.Pool() as pool:
        # Use partial to pass constant dicts
        func = partial(process_single_crop, exam_info_dict=exam_info_dict, tags_dict=tags_dict)
        results = pool.map(func, work_items)
        
    # Filter None results
    search_index = [r for r in results if r is not None]

    # Save
    js_output_path = BASE_DIR / "web" / "data.js"
    json_str = json.dumps(search_index, indent=2)
    with open(js_output_path, 'w') as f:
        f.write(f"window.SEARCH_DATA = {json_str};")
        
    print(f"Index built! {len(search_index)} questions indexed to web/data.js")

if __name__ == "__main__":
    build_index()
