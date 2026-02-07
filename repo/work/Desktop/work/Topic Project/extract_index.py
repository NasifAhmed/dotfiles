#!/usr/bin/env python3
"""
Extract Index Terms from FE Textbooks
This script extracts index terms from the official FE textbook PDFs.
Supports incremental processing - skips if output is up to date.
"""

import pdfplumber
import re
import os
from pathlib import Path

BASE_DIR = Path(__file__).parent
VOL1 = BASE_DIR / "New FE Textbook Vol1.pdf"
VOL2 = BASE_DIR / "New FE Textbook Vol2.pdf"
OUTPUT_FILE = BASE_DIR / "raw_terms.txt"


def get_source_mtime():
    """Get the most recent modification time of source PDFs."""
    mtimes = []
    if VOL1.exists():
        mtimes.append(VOL1.stat().st_mtime)
    if VOL2.exists():
        mtimes.append(VOL2.stat().st_mtime)
    return max(mtimes) if mtimes else 0


def is_up_to_date():
    """Check if output file is newer than all source PDFs."""
    if not OUTPUT_FILE.exists():
        return False
    
    output_mtime = OUTPUT_FILE.stat().st_mtime
    source_mtime = get_source_mtime()
    
    return output_mtime > source_mtime


def extract_from_pdf(pdf_path, start_page, end_page):
    terms = set()
    print(f"Processing {pdf_path.name}...")
    
    with pdfplumber.open(pdf_path) as pdf:
        for i in range(start_page - 1, end_page):  # 0-indexed
            if i >= len(pdf.pages):
                break
            
            page = pdf.pages[i]
            text = page.extract_text()
            if not text:
                continue
                
            lines = text.split('\n')
            for line in lines:
                # Regex to match "Term ····· 123" or "Term ... 123"
                # The textbooks use middle dots or dots for leaders
                # We want to capture the text BEFORE the leaders
                
                # Match lines ending with page numbers
                if not re.search(r'\d+$', line):
                    continue
                
                # Split by dots or special leader characters
                # Unicode for middle dot might be used
                parts = re.split(r'[·…\.]+', line)
                
                if len(parts) >= 2:
                    term = parts[0].strip()
                    # Filter logic
                    if len(term) > 2 and not term.isdigit():
                        # Remove page number artifacts if any remain
                        term = re.sub(r'\d+$', '', term).strip()
                        terms.add(term)
    
    return terms


def main(force=False):
    # Check if we need to do anything
    if not force and is_up_to_date():
        term_count = sum(1 for _ in open(OUTPUT_FILE)) if OUTPUT_FILE.exists() else 0
        print("✓ Term extraction already complete. Output is up to date.")
        print(f"  Output: {OUTPUT_FILE}")
        print(f"  Terms: {term_count}")
        return
    
    # Check if source PDFs exist
    if not VOL1.exists() and not VOL2.exists():
        print("Error: No textbook PDFs found.")
        print(f"  Expected: {VOL1}")
        print(f"  Expected: {VOL2}")
        return
    
    all_terms = set()
    
    # Vol 1 Index: 455 to 476
    if VOL1.exists():
        all_terms.update(extract_from_pdf(VOL1, 455, 477))
    else:
        print(f"Warning: {VOL1.name} not found, skipping...")
    
    # Vol 2 Index: 393 to 415
    if VOL2.exists():
        all_terms.update(extract_from_pdf(VOL2, 393, 416))
    else:
        print(f"Warning: {VOL2.name} not found, skipping...")
    
    print(f"✓ Extracted {len(all_terms)} unique terms.")
    
    with open(OUTPUT_FILE, 'w') as f:
        for term in sorted(all_terms):
            f.write(term + "\n")
    
    print(f"  Saved to {OUTPUT_FILE}")


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Extract index terms from FE textbooks")
    parser.add_argument("--force", "-f", action="store_true", 
                        help="Force re-extraction even if output is up to date")
    args = parser.parse_args()
    
    main(force=args.force)
