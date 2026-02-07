
import pdfplumber
import re
from pathlib import Path

BASE_DIR = Path(__file__).parent
VOL1 = BASE_DIR / "New FE Textbook Vol1.pdf"
VOL2 = BASE_DIR / "New FE Textbook Vol2.pdf"

OUTPUT_FILE = BASE_DIR / "raw_terms.txt"

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

def main():
    all_terms = set()
    
    # Vol 1 Index: Approx 450 to 482
    # Adjust based on probe (450 seems to start D/A, so index starts earlier?)
    # Let's inspect page 445 just to be safe, but 450 is safe start for now based on 'D'
    # Actually, if 'D' is at 450, then A, B, C are earlier.
    # I should check where Index starts exactly. 
    # But for now let's use the ranges I probed.
    
    # Vol 1 Index: 455 to 476 (User specified)
    # Range is inclusive in python slice if I use end_page+1? 
    # extract_from_pdf uses range(start_page - 1, end_page) -> inclusive of start, exclusive of end
    # So I should use 477 to include 476.
    all_terms.update(extract_from_pdf(VOL1, 455, 477))
    
    # Vol 2 Index: 393 to 415 (User specified)
    # Use 416 to include 415.
    all_terms.update(extract_from_pdf(VOL2, 393, 416))
    
    print(f"Extracted {len(all_terms)} unique terms.")
    
    with open(OUTPUT_FILE, 'w') as f:
        for term in sorted(all_terms):
            f.write(term + "\n")
    
    print(f"Saved to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
