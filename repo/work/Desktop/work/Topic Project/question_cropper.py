#!/usr/bin/env python3
"""
FE Exam Question Cropper
Interactive tool for cropping individual questions from ITPEC FE exam PDFs.
"""

import os
import re
import json
import tkinter as tk
from tkinter import ttk, messagebox
from pathlib import Path
from dataclasses import dataclass, asdict
from typing import Optional
import pdfplumber
from pdf2image import convert_from_path
from PIL import Image, ImageTk

# Configuration
BASE_DIR = Path(__file__).parent
QUESTIONS_DIR = BASE_DIR / "Past Questions with Answers"
OUTPUT_DIR = BASE_DIR / "cropped_questions"
PROGRESS_FILE = BASE_DIR / ".cropper_progress.json"
TOPICS_FILE = BASE_DIR / "topics.json"
DPI = 150  # Resolution for PDF conversion


@dataclass
class PageRegion:
    """Represents a crop region on a single page."""
    page_num: int
    x1: int
    y1: int
    x2: int
    y2: int


@dataclass
class QuestionCrop:
    """Represents a cropped question region (can span multiple pages)."""
    question_num: int
    page_num: int  # First page of the question
    x1: int
    y1: int
    x2: int
    y2: int
    confirmed: bool = False
    # For multi-page questions: list of additional page regions
    extra_pages: list = None  # List of dicts with page_num, y1, y2
    
    def __post_init__(self):
        if self.extra_pages is None:
            self.extra_pages = []


@dataclass
class ExamInfo:
    """Information about an exam."""
    folder_name: str
    year: int
    session: str  # 'S' for Spring/April, 'A' for Autumn/October
    exam_type: str  # 'A' for morning, 'B' for afternoon
    pdf_path: Path
    
    @property
    def output_folder(self) -> str:
        return f"{self.year}{self.session}_{self.exam_type}"
    
    @property
    def display_name(self) -> str:
        session_name = "April" if self.session == "S" else "October"
        exam_name = "Morning" if self.exam_type == "A" else "Afternoon"
        return f"{self.year} {session_name} - {exam_name}"


def parse_exam_folders() -> list[ExamInfo]:
    """Parse all exam folders and return list of ExamInfo objects."""
    exams = []
    
    for folder in sorted(QUESTIONS_DIR.iterdir()):
        if not folder.is_dir():
            continue
            
        # Parse folder name patterns
        # Patterns: 2025S_FE, 2024A_FE, FeApr2007, FeOct2007, FE2011October, etc.
        name = folder.name
        
        # Try new format: 2025S_FE, 2024A_FE
        match = re.match(r'(\d{4})([SA])_FE', name)
        if match:
            year = int(match.group(1))
            session = match.group(2)
        else:
            # Try old formats
            match = re.match(r'Fe(Apr|Oct)(\d{4})', name)
            if match:
                session = 'S' if match.group(1) == 'Apr' else 'A'
                year = int(match.group(2))
            else:
                match = re.match(r'FE(\d{4})(April|October)', name)
                if match:
                    year = int(match.group(1))
                    session = 'S' if match.group(2) == 'April' else 'A'
                else:
                    match = re.match(r'(\d{4})Fe(Apr|Oct)', name)
                    if match:
                        year = int(match.group(1))
                        session = 'S' if match.group(2) == 'Apr' else 'A'
                    else:
                        continue
        
        # Find question PDFs in folder (handle both 'Questions' and 'Question' naming)
        # Use set to avoid duplicates when 'Questions' matches both patterns
        pdf_files = set(folder.glob("*Question*.pdf"))
        for pdf_file in pdf_files:
            filename = pdf_file.name
            
            # Determine exam type from filename patterns
            if "_AM_" in filename or "_AM." in filename:
                exam_type = "A"  # Morning
            elif "_PM_" in filename or "_PM." in filename:
                exam_type = "B"  # Afternoon
            elif "_A_" in filename or "-A_" in filename or "FE-A" in filename:
                exam_type = "A"
            elif "_B_" in filename or "-B_" in filename or "FE-B" in filename:
                exam_type = "B"
            else:
                continue
            
            # Skip afternoon exams before April 2024 (2024S)
            # 'S' = Spring/April, 'A' = Autumn/October
            # Include: 2024S (Apr 2024), 2024A (Oct 2024), 2025S, etc.
            # Skip: 2023A, 2023S, and all earlier years
            if exam_type == "B":
                if year < 2024:
                    continue
            
            exams.append(ExamInfo(
                folder_name=name,
                year=year,
                session=session,
                exam_type=exam_type,
                pdf_path=pdf_file
            ))
    
    return sorted(exams, key=lambda e: (e.year, e.session, e.exam_type))


def detect_question_positions(pdf_path: Path) -> list[tuple[int, int, float]]:
    """
    Detect question positions in PDF.
    Returns list of (question_num, page_num, y_position).
    """
    questions = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            words = page.extract_words()
            
            for i, word in enumerate(words):
                text = word['text']
                # Match Q1., Q2., etc.
                match = re.match(r'^Q(\d+)\.$', text)
                if match:
                    q_num = int(match.group(1))
                    y_pos = word['top']
                    questions.append((q_num, page_num, y_pos))
    
    return sorted(questions, key=lambda x: (x[0]))


def detect_page_number_positions(pdf_path: Path) -> dict[int, float]:
    """
    Detect page number Y positions for each page.
    Returns dict mapping page_num -> y_position of page number.
    Page numbers are typically at the bottom center, formatted like '-23-' or '- 23 -'.
    """
    page_num_positions = {}
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages):
            words = page.extract_words()
            
            # Look for page number patterns at the bottom of the page
            # They are usually in the bottom 10% of the page
            bottom_threshold = page.height * 0.90
            
            for word in words:
                if word['top'] > bottom_threshold:
                    text = word['text']
                    # Match patterns like '-23-', '- 23 -', or just numbers at bottom
                    if re.match(r'^-?\d+-?$', text.replace(' ', '')):
                        page_num_positions[page_num] = word['top']
                        break
    
    return page_num_positions


def trim_whitespace_bottom(img: Image.Image, threshold: int = 245, min_content_rows: int = 5) -> Image.Image:
    """
    Trim whitespace from the bottom of an image.
    
    Args:
        img: PIL Image to trim
        threshold: Pixel brightness threshold (0-255), pixels above this are "white"
        min_content_rows: Minimum consecutive non-white rows to consider as content
    
    Returns:
        Trimmed image
    """
    import numpy as np
    
    # Convert to grayscale numpy array
    gray = img.convert('L')
    pixels = np.array(gray)
    
    # Find rows that have content (not all white)
    # Use stricter threshold to avoid cutting light text
    row_has_content = np.any(pixels < threshold, axis=1)
    
    # Find the last row with content
    content_rows = np.where(row_has_content)[0]
    if len(content_rows) == 0:
        return img  # All white, return as-is
    
    last_content_row = content_rows[-1]
    
    # Add generous padding to ensure text isn't cut
    new_height = min(last_content_row + 70, img.height)
    
    # Only crop if there's substantial whitespace (more than 60 pixels)
    if img.height - new_height > 60:
        return img.crop((0, 0, img.width, new_height))
    
    return img


def trim_whitespace_top(img: Image.Image, threshold: int = 245) -> Image.Image:
    """Trim whitespace from the top of an image."""
    import numpy as np
    
    gray = img.convert('L')
    pixels = np.array(gray)
    
    row_has_content = np.any(pixels < threshold, axis=1)
    content_rows = np.where(row_has_content)[0]
    
    if len(content_rows) == 0:
        return img
    
    first_content_row = content_rows[0]
    
    # Keep a small margin at the top
    new_top = max(0, first_content_row - 10)
    
    if new_top > 30:
        return img.crop((0, new_top, img.width, img.height))
    
    return img


def combine_multipage_crop(page_images: list[Image.Image], crop: 'QuestionCrop') -> Image.Image:
    """
    Combine crops from multiple pages into a single image.
    
    Args:
        page_images: List of page images
        crop: QuestionCrop with optional extra_pages
    
    Returns:
        Combined image with all page segments vertically concatenated
    """
    # Crop the first page
    first_page = page_images[crop.page_num]
    first_crop = first_page.crop((crop.x1, crop.y1, crop.x2, crop.y2))
    # Trim whitespace from bottom of first page
    first_crop = trim_whitespace_bottom(first_crop)
    images = [first_crop]
    
    # Crop extra pages if any
    if crop.extra_pages:
        for ep in crop.extra_pages:
            page_img = page_images[ep['page_num']]
            # Use same x coordinates as first page
            cropped = page_img.crop((crop.x1, ep['y1'], crop.x2, ep['y2']))
            # Trim whitespace from top and bottom of each additional page segment
            cropped = trim_whitespace_top(cropped)
            cropped = trim_whitespace_bottom(cropped)
            images.append(cropped)
    
    if len(images) == 1:
        return images[0]
    
    # Calculate total height
    total_height = sum(img.height for img in images)
    max_width = max(img.width for img in images)
    
    # Create combined image
    combined = Image.new('RGB', (max_width, total_height), (255, 255, 255))
    
    y_offset = 0
    for img in images:
        combined.paste(img, (0, y_offset))
        y_offset += img.height
    
    return combined


class QuestionCropperApp:
    """Main application for cropping questions."""
    
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("FE Question Cropper")
        self.root.geometry("1400x900")
        
        # State
        self.exams = parse_exam_folders()
        self.current_exam_idx = 0
        self.current_question_idx = 0
        self.page_images: list[Image.Image] = []
        self.question_positions: list[tuple[int, int, float]] = []
        self.crops: list[QuestionCrop] = []
        self.crops: list[QuestionCrop] = []
        self.progress: dict = self.load_progress()
        
        # Tagging state
        self.topics = self.load_topics()
        self.current_tags = {}  # QuestionNum -> Topic
        
        # Crop adjustment state
        self.dragging = None
        self.drag_start = None
        
        self.setup_ui()
        self.load_exam(0)
    
    def load_topics(self) -> dict:
        """Load topics from JSON file."""
        if TOPICS_FILE.exists():
            try:
                with open(TOPICS_FILE) as f:
                    return json.load(f)
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load topics: {e}")
        return {}
    
    def setup_ui(self):
        """Setup the user interface with tabs."""
        # Main container
        main_frame = ttk.Frame(self.root, padding=10)
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Top bar - exam selector (Shared)
        top_frame = ttk.Frame(main_frame)
        top_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(top_frame, text="Exam:").pack(side=tk.LEFT)
        self.exam_var = tk.StringVar()
        self.exam_combo = ttk.Combobox(
            top_frame, 
            textvariable=self.exam_var,
            values=[e.display_name for e in self.exams],
            state="readonly",
            width=40
        )
        self.exam_combo.pack(side=tk.LEFT, padx=5)
        self.exam_combo.bind("<<ComboboxSelected>>", self.on_exam_selected)
        
        self.progress_label = ttk.Label(top_frame, text="")
        self.progress_label.pack(side=tk.RIGHT)
        
        # Notebook for Tabs
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)
        self.notebook.bind("<<NotebookTabChanged>>", self.on_tab_changed)
        
        # Cropping Tab
        self.cropping_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.cropping_frame, text="Cropping")
        self.setup_cropping_ui(self.cropping_frame)
        
        # Tagging Tab
        self.tagging_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.tagging_frame, text="Tagging")
        self.setup_tagging_ui(self.tagging_frame)

    def setup_cropping_ui(self, parent):
        """Setup the cropping interface."""
        # Main content area
        content_frame = ttk.Frame(parent)
        content_frame.pack(fill=tk.BOTH, expand=True)
        
        # Left panel - question list
        left_frame = ttk.Frame(content_frame, width=200)
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))
        left_frame.pack_propagate(False)
        
        ttk.Label(left_frame, text="Questions", font=("", 12, "bold")).pack()
        
        self.question_listbox = tk.Listbox(left_frame, font=("", 11))
        self.question_listbox.pack(fill=tk.BOTH, expand=True, pady=5)
        self.question_listbox.bind("<<ListboxSelect>>", self.on_question_selected)
        
        # Center panel - image canvas
        center_frame = ttk.Frame(content_frame)
        center_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Canvas with scrollbars
        canvas_frame = ttk.Frame(center_frame)
        canvas_frame.pack(fill=tk.BOTH, expand=True)
        
        self.canvas = tk.Canvas(canvas_frame, bg='gray90', cursor="crosshair")
        self.v_scroll = ttk.Scrollbar(canvas_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        self.h_scroll = ttk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        
        self.canvas.configure(yscrollcommand=self.v_scroll.set, xscrollcommand=self.h_scroll.set)
        
        self.v_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        self.h_scroll.pack(side=tk.BOTTOM, fill=tk.X)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Canvas events
        self.canvas.bind("<Button-1>", self.on_canvas_click)
        self.canvas.bind("<B1-Motion>", self.on_canvas_drag)
        self.canvas.bind("<ButtonRelease-1>", self.on_canvas_release)
        self.canvas.bind("<MouseWheel>", self.on_mousewheel)
        self.canvas.bind("<Button-4>", lambda e: self.canvas.yview_scroll(-1, "units"))
        self.canvas.bind("<Button-5>", lambda e: self.canvas.yview_scroll(1, "units"))
        
        # Bottom panel - controls
        bottom_frame = ttk.Frame(parent)
        bottom_frame.pack(fill=tk.X, pady=(10, 0))
        
        ttk.Button(bottom_frame, text="◀ Prev (←)", command=self.prev_question).pack(side=tk.LEFT, padx=2)
        ttk.Button(bottom_frame, text="Skip", command=self.skip_question).pack(side=tk.LEFT, padx=2)
        
        self.confirm_btn = ttk.Button(bottom_frame, text="✓ Confirm & Save (Enter)", command=self.confirm_crop)
        self.confirm_btn.pack(side=tk.LEFT, padx=10)
        
        ttk.Button(bottom_frame, text="Next (→) ▶", command=self.next_question).pack(side=tk.LEFT, padx=2)
        
        ttk.Separator(bottom_frame, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=20)
        
        ttk.Button(bottom_frame, text="Reset Crop", command=self.reset_crop).pack(side=tk.LEFT, padx=2)
        ttk.Button(bottom_frame, text="Extend to Page Bottom", command=self.extend_to_bottom).pack(side=tk.LEFT, padx=2)
        
        ttk.Separator(bottom_frame, orient=tk.VERTICAL).pack(side=tk.LEFT, fill=tk.Y, padx=20)
        
        ttk.Button(bottom_frame, text="⚡ Auto-Generate All (A)", command=self.auto_generate_all).pack(side=tk.LEFT, padx=2)
        
        # Status bar
        self.status_var = tk.StringVar(value="Ready")
        ttk.Label(bottom_frame, textvariable=self.status_var).pack(side=tk.RIGHT)
        
        # Keyboard bindings - restrict to when these make sense? For now keep global
        self.root.bind("<Return>", lambda e: self.confirm_crop())
        self.root.bind("<Left>", lambda e: self.prev_question())
        self.root.bind("<Right>", lambda e: self.next_question())
        self.root.bind("<Escape>", lambda e: self.reset_crop())
        self.root.bind("a", lambda e: self.auto_generate_all())
        self.root.bind("A", lambda e: self.auto_generate_all())

    def setup_tagging_ui(self, parent):
        """Setup the tagging interface."""
        # Top: Content
        content_frame = ttk.Frame(parent, padding=10)
        content_frame.pack(fill=tk.BOTH, expand=True)
        
        # Left: Questions
        left_frame = ttk.Frame(content_frame, width=200)
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))
        
        ttk.Label(left_frame, text="Cropped Questions", font=("", 12, "bold")).pack(anchor=tk.W)
        self.tag_listbox = tk.Listbox(left_frame, font=("", 11))
        self.tag_listbox.pack(fill=tk.BOTH, expand=True, pady=5)
        self.tag_listbox.bind("<<ListboxSelect>>", self.on_tag_question_selected)
        
        # Center: Image Preview (Scrollable)
        center_frame = ttk.Frame(content_frame)
        center_frame.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        canvas_frame = ttk.Frame(center_frame)
        canvas_frame.pack(fill=tk.BOTH, expand=True)
        
        self.tag_canvas = tk.Canvas(canvas_frame, bg='gray90')
        v_scroll = ttk.Scrollbar(canvas_frame, orient=tk.VERTICAL, command=self.tag_canvas.yview)
        h_scroll = ttk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL, command=self.tag_canvas.xview)
        
        self.tag_canvas.configure(yscrollcommand=v_scroll.set, xscrollcommand=h_scroll.set)
        
        v_scroll.pack(side=tk.RIGHT, fill=tk.Y)
        h_scroll.pack(side=tk.BOTTOM, fill=tk.X)
        self.tag_canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        # Canvas items
        self.tag_image_id = self.tag_canvas.create_image(0, 0, anchor=tk.NW)
        self.tag_start_text_id = self.tag_canvas.create_text(
            400, 300, text="Select a question to tag", font=("", 14), fill="gray50"
        )
        
        # Right: Tag Controls
        right_frame = ttk.Frame(content_frame, width=300)
        right_frame.pack(side=tk.RIGHT, fill=tk.Y, padx=(10, 0))
        
        ttk.Label(right_frame, text="Assign Topic", font=("", 12, "bold")).pack(anchor=tk.W)
        
        # Flatten topics (Recursive)
        self.all_topic_values = []
        
        def flatten_dict(d, parent_key=''):
            for k, v in d.items():
                new_key = f"{parent_key} > {k}" if parent_key else k
                if isinstance(v, dict):
                    # It's a category/subdomain
                    # Optionally add the category itself as a general tag?
                    # self.all_topic_values.append(new_key + " (General)")
                    flatten_dict(v, new_key)
                elif isinstance(v, list):
                    # Leaf topics
                    for item in v:
                        self.all_topic_values.append(f"{new_key} > {item}")
        
        flatten_dict(self.topics)
        self.all_topic_values.sort()
        
        self.tag_var = tk.StringVar()
        self.tag_combo = ttk.Combobox(right_frame, textvariable=self.tag_var, values=self.all_topic_values, width=40)
        self.tag_combo.pack(fill=tk.X, pady=5)
        self.tag_combo.bind("<<ComboboxSelected>>", self.save_current_tag)
        
        ttk.Label(right_frame, text="Current Tag:", font=("", 10, "bold")).pack(anchor=tk.W, pady=(20, 0))
        self.current_tag_display = ttk.Label(right_frame, text="None", font=("", 10))
        self.current_tag_display.pack(anchor=tk.W)
        
        ttk.Button(right_frame, text="Delete Tag", command=self.delete_current_tag).pack(pady=10, anchor=tk.W)
    
    def load_progress(self) -> dict:
        """Load progress from file."""
        if PROGRESS_FILE.exists():
            try:
                with open(PROGRESS_FILE) as f:
                    content = f.read().strip()
                    if content:
                        return json.loads(content)
            except (json.JSONDecodeError, OSError):
                pass  # Return empty dict on error
        return {}
    
    def save_progress(self):
        """Save current progress to file."""
        with open(PROGRESS_FILE, 'w') as f:
            json.dump(self.progress, f, indent=2)
    
    def load_exam(self, idx: int):
        """Load an exam's PDF and detect questions."""
        if idx < 0 or idx >= len(self.exams):
            return
        
        self.current_exam_idx = idx
        exam = self.exams[idx]
        self.exam_combo.set(exam.display_name)
        
        self.status_var.set(f"Loading {exam.display_name}...")
        self.root.update()
        
        # Convert PDF to images
        self.page_images = convert_from_path(str(exam.pdf_path), dpi=DPI)
        
        # Detect question positions
        self.question_positions = detect_question_positions(exam.pdf_path)
        
        # Detect page number positions (to exclude them from crops)
        self.page_num_positions = detect_page_number_positions(exam.pdf_path)
        
        # Scale factor from PDF points to image pixels
        scale = DPI / 72.0
        
        # Initialize crops
        self.crops = []
        for i, (q_num, page_num, y_pos) in enumerate(self.question_positions):
            # Calculate crop region
            page_height = self.page_images[page_num].height
            page_width = self.page_images[page_num].width
            
            # y1: Start a bit above the "Q" text
            y1 = int(y_pos * scale) - 10
            
            # Determine where the next question starts
            if i + 1 < len(self.question_positions):
                next_q = self.question_positions[i + 1]
                next_q_page = next_q[1]
                next_q_y = int(next_q[2] * scale) - 15
            else:
                # Last question - use end of last page, but check for page number
                next_q_page = len(self.page_images) - 1
                if next_q_page in self.page_num_positions:
                    next_q_y = int(self.page_num_positions[next_q_page] * scale) - 20
                else:
                    next_q_y = self.page_images[next_q_page].height - 50
            
            extra_pages = []
            
            if next_q_page == page_num:
                # Same page - simple case
                y2 = next_q_y
            elif next_q_page == page_num + 1:
                # Next page - single page break
                # First page: crop to page number or page bottom
                if page_num in self.page_num_positions:
                    page_num_y = int(self.page_num_positions[page_num] * scale) - 20
                    y2 = min(page_num_y, page_height - 50)
                else:
                    y2 = page_height - 50
                    
                # Second page: from top to next question
                next_page_height = self.page_images[next_q_page].height
                extra_pages.append({
                    'page_num': next_q_page,
                    'y1': 50,  # Start below header
                    'y2': next_q_y
                })
            else:
                # Multi-page question (spans 3+ pages)
                # First page: crop to page number
                if page_num in self.page_num_positions:
                    page_num_y = int(self.page_num_positions[page_num] * scale) - 20
                    y2 = min(page_num_y, page_height - 50)
                else:
                    y2 = page_height - 50
                
                # Middle pages: full page (minus header/footer)
                for mid_page in range(page_num + 1, next_q_page):
                    mid_page_height = self.page_images[mid_page].height
                    if mid_page in self.page_num_positions:
                        mid_page_num_y = int(self.page_num_positions[mid_page] * scale) - 20
                        mid_y2 = min(mid_page_num_y, mid_page_height - 50)
                    else:
                        mid_y2 = mid_page_height - 50
                    extra_pages.append({
                        'page_num': mid_page,
                        'y1': 50,
                        'y2': mid_y2
                    })
                
                # Last page: from top to next question
                extra_pages.append({
                    'page_num': next_q_page,
                    'y1': 50,
                    'y2': next_q_y
                })
            
            self.crops.append(QuestionCrop(
                question_num=q_num,
                page_num=page_num,
                x1=30,
                y1=max(0, y1),
                x2=page_width - 30,
                y2=min(page_height, y2),
                confirmed=False,
                extra_pages=extra_pages
            ))
        
        # Load saved progress for this exam
        exam_key = exam.output_folder
        if exam_key in self.progress:
            for saved_crop in self.progress[exam_key]:
                for crop in self.crops:
                    if crop.question_num == saved_crop['question_num']:
                        crop.x1 = saved_crop['x1']
                        crop.y1 = saved_crop['y1']
                        crop.x2 = saved_crop['x2']
                        crop.y2 = saved_crop['y2']
                        crop.confirmed = saved_crop['confirmed']
                        break
        
        # Update question list
        self.update_question_list()
        
        # Go to first unconfirmed question
        self.current_question_idx = 0
        for i, crop in enumerate(self.crops):
            if not crop.confirmed:
                self.current_question_idx = i
                break
        
        self.show_current_question()
        self.update_progress_label()
        self.status_var.set("Ready")
    
    def update_question_list(self):
        """Update the question listbox."""
        self.question_listbox.delete(0, tk.END)
        for crop in self.crops:
            status = "✓" if crop.confirmed else "○"
            self.question_listbox.insert(tk.END, f"{status} Q{crop.question_num}")
        
        if self.crops:
            self.question_listbox.selection_set(self.current_question_idx)
    
    def update_progress_label(self):
        """Update the progress label."""
        if not self.crops:
            self.progress_label.config(text="")
            return
        
        confirmed = sum(1 for c in self.crops if c.confirmed)
        total = len(self.crops)
        pct = int(confirmed / total * 100) if total > 0 else 0
        self.progress_label.config(text=f"Progress: {confirmed}/{total} ({pct}%)")
    
    def show_current_question(self):
        """Display the current question on the canvas."""
        if not self.crops or self.current_question_idx >= len(self.crops):
            return
        
        crop = self.crops[self.current_question_idx]
        page_img = self.page_images[crop.page_num]
        
        # Store reference to prevent garbage collection
        self.current_photo = ImageTk.PhotoImage(page_img)
        
        # Clear and setup canvas
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.current_photo)
        self.canvas.configure(scrollregion=(0, 0, page_img.width, page_img.height))
        
        # Draw crop rectangle
        self.draw_crop_rect()
        
        # Scroll to show the crop region
        scroll_y = max(0, crop.y1 - 50) / page_img.height
        self.canvas.yview_moveto(scroll_y)
        
        # Update listbox selection
        self.question_listbox.selection_clear(0, tk.END)
        self.question_listbox.selection_set(self.current_question_idx)
        self.question_listbox.see(self.current_question_idx)
    
    def draw_crop_rect(self):
        """Draw the crop rectangle on canvas."""
        self.canvas.delete("crop_rect")
        
        if not self.crops:
            return
        
        crop = self.crops[self.current_question_idx]
        
        # Main rectangle
        color = "green" if crop.confirmed else "blue"
        self.canvas.create_rectangle(
            crop.x1, crop.y1, crop.x2, crop.y2,
            outline=color, width=3, tags="crop_rect"
        )
        
        # Resize handles
        handle_size = 10
        handles = [
            ("nw", crop.x1, crop.y1),
            ("ne", crop.x2, crop.y1),
            ("sw", crop.x1, crop.y2),
            ("se", crop.x2, crop.y2),
            ("n", (crop.x1 + crop.x2) // 2, crop.y1),
            ("s", (crop.x1 + crop.x2) // 2, crop.y2),
            ("w", crop.x1, (crop.y1 + crop.y2) // 2),
            ("e", crop.x2, (crop.y1 + crop.y2) // 2),
        ]
        
        for name, x, y in handles:
            self.canvas.create_rectangle(
                x - handle_size//2, y - handle_size//2,
                x + handle_size//2, y + handle_size//2,
                fill=color, tags=("crop_rect", f"handle_{name}")
            )
        
        # Question label
        self.canvas.create_text(
            crop.x1 + 10, crop.y1 - 15,
            text=f"Q{crop.question_num}", 
            font=("", 14, "bold"),
            fill=color,
            anchor=tk.W,
            tags="crop_rect"
        )
    
    def on_canvas_click(self, event):
        """Handle canvas click - start dragging."""
        x = self.canvas.canvasx(event.x)
        y = self.canvas.canvasy(event.y)
        
        if not self.crops:
            return
        
        crop = self.crops[self.current_question_idx]
        handle_size = 15
        
        # Check if clicking on a handle
        if abs(x - crop.x1) < handle_size and abs(y - crop.y1) < handle_size:
            self.dragging = "nw"
        elif abs(x - crop.x2) < handle_size and abs(y - crop.y1) < handle_size:
            self.dragging = "ne"
        elif abs(x - crop.x1) < handle_size and abs(y - crop.y2) < handle_size:
            self.dragging = "sw"
        elif abs(x - crop.x2) < handle_size and abs(y - crop.y2) < handle_size:
            self.dragging = "se"
        elif abs(y - crop.y1) < handle_size and crop.x1 < x < crop.x2:
            self.dragging = "n"
        elif abs(y - crop.y2) < handle_size and crop.x1 < x < crop.x2:
            self.dragging = "s"
        elif abs(x - crop.x1) < handle_size and crop.y1 < y < crop.y2:
            self.dragging = "w"
        elif abs(x - crop.x2) < handle_size and crop.y1 < y < crop.y2:
            self.dragging = "e"
        elif crop.x1 < x < crop.x2 and crop.y1 < y < crop.y2:
            self.dragging = "move"
        else:
            self.dragging = None
        
        self.drag_start = (x, y, crop.x1, crop.y1, crop.x2, crop.y2)
    
    def on_canvas_drag(self, event):
        """Handle canvas drag - resize crop region."""
        if not self.dragging or not self.drag_start:
            return
        
        x = self.canvas.canvasx(event.x)
        y = self.canvas.canvasy(event.y)
        
        crop = self.crops[self.current_question_idx]
        start_x, start_y, orig_x1, orig_y1, orig_x2, orig_y2 = self.drag_start
        
        dx = int(x - start_x)
        dy = int(y - start_y)
        
        if self.dragging == "move":
            crop.x1 = orig_x1 + dx
            crop.y1 = orig_y1 + dy
            crop.x2 = orig_x2 + dx
            crop.y2 = orig_y2 + dy
        elif self.dragging == "nw":
            crop.x1 = orig_x1 + dx
            crop.y1 = orig_y1 + dy
        elif self.dragging == "ne":
            crop.x2 = orig_x2 + dx
            crop.y1 = orig_y1 + dy
        elif self.dragging == "sw":
            crop.x1 = orig_x1 + dx
            crop.y2 = orig_y2 + dy
        elif self.dragging == "se":
            crop.x2 = orig_x2 + dx
            crop.y2 = orig_y2 + dy
        elif self.dragging == "n":
            crop.y1 = orig_y1 + dy
        elif self.dragging == "s":
            crop.y2 = orig_y2 + dy
        elif self.dragging == "w":
            crop.x1 = orig_x1 + dx
        elif self.dragging == "e":
            crop.x2 = orig_x2 + dx
        
        # Ensure valid bounds
        page_img = self.page_images[crop.page_num]
        crop.x1 = max(0, min(crop.x1, crop.x2 - 50))
        crop.y1 = max(0, min(crop.y1, crop.y2 - 50))
        crop.x2 = min(page_img.width, max(crop.x2, crop.x1 + 50))
        crop.y2 = min(page_img.height, max(crop.y2, crop.y1 + 50))
        
        self.draw_crop_rect()
    
    def on_canvas_release(self, event):
        """Handle mouse release."""
        self.dragging = None
        self.drag_start = None
    
    def on_mousewheel(self, event):
        """Handle mouse wheel scrolling."""
        self.canvas.yview_scroll(-1 * (event.delta // 120), "units")
    
    def on_exam_selected(self, event):
        """Handle exam selection from combo box."""
        idx = self.exam_combo.current()
        if idx != self.current_exam_idx:
            self.load_exam(idx)
    
    def on_question_selected(self, event):
        """Handle question selection from listbox."""
        selection = self.question_listbox.curselection()
        if selection:
            self.current_question_idx = selection[0]
            self.show_current_question()
    
    def confirm_crop(self):
        """Confirm and save the current crop."""
        if not self.crops:
            return
        
        crop = self.crops[self.current_question_idx]
        exam = self.exams[self.current_exam_idx]
        
        # Create output directory
        output_dir = OUTPUT_DIR / exam.output_folder
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Crop and save image (handles multi-page questions)
        cropped = combine_multipage_crop(self.page_images, crop)
        
        # Trim whitespace from bottom
        cropped = trim_whitespace_bottom(cropped)
        
        output_path = output_dir / f"Q{crop.question_num:02d}.png"
        cropped.save(output_path, "PNG")
        
        # Mark as confirmed
        crop.confirmed = True
        
        # Save progress
        exam_key = exam.output_folder
        self.progress[exam_key] = [asdict(c) for c in self.crops]
        self.save_progress()
        
        # Update UI
        self.update_question_list()
        self.update_progress_label()
        self.status_var.set(f"Saved Q{crop.question_num} to {output_path.name}")
        
        # Move to next question
        self.next_question()
    
    def skip_question(self):
        """Skip to next question without confirming."""
        self.next_question()
    
    def next_question(self):
        """Go to next question."""
        if self.current_question_idx < len(self.crops) - 1:
            self.current_question_idx += 1
            self.show_current_question()
        elif self.current_exam_idx < len(self.exams) - 1:
            # Ask to move to next exam
            if messagebox.askyesno("Next Exam", "All questions reviewed. Move to next exam?"):
                self.load_exam(self.current_exam_idx + 1)
    
    def prev_question(self):
        """Go to previous question."""
        if self.current_question_idx > 0:
            self.current_question_idx -= 1
            self.show_current_question()
    
    def reset_crop(self):
        """Reset crop to auto-detected bounds."""
        if not self.crops or not self.question_positions:
            return
        
        idx = self.current_question_idx
        q_num, page_num, y_pos = self.question_positions[idx]
        
        page_img = self.page_images[page_num]
        scale = DPI / 72.0
        y1 = int(y_pos * scale) - 10
        
        if idx + 1 < len(self.question_positions):
            next_q = self.question_positions[idx + 1]
            if next_q[1] == page_num:
                y2 = int(next_q[2] * scale) - 15
            else:
                y2 = page_img.height - 50
        else:
            y2 = page_img.height - 50
        
        crop = self.crops[idx]
        crop.x1 = 30
        crop.y1 = max(0, y1)
        crop.x2 = page_img.width - 30
        crop.y2 = min(page_img.height, y2)
        crop.confirmed = False
        
        self.draw_crop_rect()
        self.update_question_list()
    
    def extend_to_bottom(self):
        """Extend crop region to page bottom."""
        if not self.crops:
            return
        
        crop = self.crops[self.current_question_idx]
        page_img = self.page_images[crop.page_num]
        crop.y2 = page_img.height - 30
        
        self.draw_crop_rect()
    
    def auto_generate_all(self):
        """Auto-generate all remaining unconfirmed questions in current exam."""
        if not self.crops:
            return
        
        # Count remaining
        remaining = [c for c in self.crops if not c.confirmed]
        if not remaining:
            messagebox.showinfo("Done", "All questions in this exam are already confirmed!")
            return
        
        # Confirm with user
        if not messagebox.askyesno(
            "Auto-Generate All", 
            f"This will auto-crop {len(remaining)} remaining questions using detected boundaries.\n\n"
            "You can review and re-crop any later if needed.\n\n"
            "Continue?"
        ):
            return
        
        exam = self.exams[self.current_exam_idx]
        output_dir = OUTPUT_DIR / exam.output_folder
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Process all remaining
        for i, crop in enumerate(self.crops):
            if crop.confirmed:
                continue
            
            # Update status
            self.status_var.set(f"Auto-generating Q{crop.question_num}... ({i+1}/{len(self.crops)})")
            self.root.update()
            
            # Crop and save (handles multi-page questions)
            cropped = combine_multipage_crop(self.page_images, crop)
            
            # Trim whitespace from bottom
            cropped = trim_whitespace_bottom(cropped)
            
            output_path = output_dir / f"Q{crop.question_num:02d}.png"
            cropped.save(output_path, "PNG")
            
            # Mark as confirmed
            crop.confirmed = True
        
        # Save progress
        exam_key = exam.output_folder
        self.progress[exam_key] = [asdict(c) for c in self.crops]
        self.save_progress()
        
        # Update UI
        self.update_question_list()
        self.update_progress_label()
        self.status_var.set(f"Auto-generated {len(remaining)} questions!")
        
        messagebox.showinfo(
            "Complete", 
            "You can click any question in the list to review/re-crop if needed."
        )

    def on_tab_changed(self, event):
        """Handle tab switching."""
        selected_tab = self.notebook.select()
        if not selected_tab:
            return
        tab_text = self.notebook.tab(selected_tab, "text")
        
        if tab_text == "Tagging":
            self.load_exam_tags()
            self.refresh_tag_question_list()

    def get_exam_metadata_file(self) -> Optional[Path]:
        """Get path to metadata.json for current exam."""
        if self.current_exam_idx >= len(self.exams):
            return None
        exam = self.exams[self.current_exam_idx]
        output_dir = OUTPUT_DIR / exam.output_folder
        output_dir.mkdir(parents=True, exist_ok=True)
        return output_dir / "metadata.json"

    def load_exam_tags(self):
        """Load tags for current exam from metadata.json."""
        self.current_tags = {}
        meta_file = self.get_exam_metadata_file()
        if meta_file and meta_file.exists():
            try:
                with open(meta_file) as f:
                    self.current_tags = json.load(f)
            except Exception:
                pass
        
        # Clear current selection display if in tagging tab
        if hasattr(self, 'current_tag_display'):
            self.current_tag_display.config(text="None")
            self.tag_var.set("")
            self.tag_var.set("")
            if hasattr(self, 'tag_canvas'):
                self.tag_canvas.itemconfig(self.tag_image_id, image='')
                self.tag_canvas.image = None
                self.tag_canvas.itemconfigure(self.tag_start_text_id, state='normal')

    def save_exam_tags(self):
        """Save current tags to metadata.json."""
        meta_file = self.get_exam_metadata_file()
        if meta_file:
            with open(meta_file, 'w') as f:
                json.dump(self.current_tags, f, indent=2)

    def refresh_tag_question_list(self):
        """Refresh the list of cropped questions in the Tagging tab."""
        self.tag_listbox.delete(0, tk.END)
        
        if self.current_exam_idx >= len(self.exams):
            return
            
        exam = self.exams[self.current_exam_idx]
        output_dir = OUTPUT_DIR / exam.output_folder
        
        if not output_dir.exists():
            return
            
        # List PNG files Q01-Q99
        questions = []
        for file in sorted(output_dir.glob("Q*.png")):
            # Extract number
            match = re.match(r"Q(\d+)\.png", file.name)
            if match:
                q_num = int(match.group(1))
                questions.append(f"Q{q_num:02d}")
        
        for q in questions:
            self.tag_listbox.insert(tk.END, q)

    def on_tag_question_selected(self, event):
        """Handle selection of a question in the Tagging tab."""
        selection = self.tag_listbox.curselection()
        if not selection:
            return
            
        q_text = self.tag_listbox.get(selection[0])
        q_num = int(q_text[1:])
        
        # Load Image
        exam = self.exams[self.current_exam_idx]
        img_path = OUTPUT_DIR / exam.output_folder / f"{q_text}.png"
        
        if img_path.exists():
            img = Image.open(img_path)
            # Resize for preview if too large (keep aspect ratio)
            max_h = 600
            if img.height > max_h:
                scale = max_h / img.height
                new_w = int(img.width * scale)
                img = img.resize((new_w, max_h), Image.Resampling.LANCZOS)
            
            photo = ImageTk.PhotoImage(img)
            self.tag_canvas.itemconfig(self.tag_image_id, image=photo)
            self.tag_canvas.image = photo
            self.tag_canvas.config(scrollregion=self.tag_canvas.bbox(tk.ALL))
            self.tag_canvas.itemconfigure(self.tag_start_text_id, state='hidden')
        
        # Load Tag
        # Keys in json are strings "1", "2"...
        tag = self.current_tags.get(str(q_num), "")
        if tag:
            self.current_tag_display.config(text=tag)
            self.tag_var.set(tag)
        else:
            self.current_tag_display.config(text="None")
            self.tag_var.set("")

    def save_current_tag(self, event=None):
        """Save selected tag for current question."""
        selection = self.tag_listbox.curselection()
        if not selection:
            return
        
        q_text = self.tag_listbox.get(selection[0])
        q_num_str = str(int(q_text[1:]))  # Key as string "1", "2"...
        
        tag = self.tag_var.get()
        if tag:
            self.current_tags[q_num_str] = tag
            self.current_tag_display.config(text=tag)
            self.save_exam_tags()
    
    def delete_current_tag(self):
        """Delete tag for current question."""
        selection = self.tag_listbox.curselection()
        if not selection:
            return
        
        q_text = self.tag_listbox.get(selection[0])
        q_num_str = str(int(q_text[1:]))
        
        if q_num_str in self.current_tags:
            del self.current_tags[q_num_str]
            self.save_exam_tags()
            self.current_tag_display.config(text="None")
            self.tag_var.set("")


def main():
    """Main entry point."""
    # Ensure output directory exists
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    # Check for exams
    exams = parse_exam_folders()
    if not exams:
        print(f"No exam PDFs found in {QUESTIONS_DIR}")
        print("Make sure 'Past Questions with Answers' folder exists with exam subfolders.")
        return
    
    print(f"Found {len(exams)} exam PDFs to process")
    for exam in exams:
        print(f"  - {exam.display_name}: {exam.pdf_path.name}")
    
    # Launch GUI
    root = tk.Tk()
    app = QuestionCropperApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
