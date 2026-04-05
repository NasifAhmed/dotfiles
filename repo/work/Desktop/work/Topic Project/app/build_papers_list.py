import os
import json
import re


def build_papers_list():
    base_dir = "data/input/past_exams"

    if not os.path.exists(base_dir):
        print(f"Directory {base_dir} not found.")
        return

    papers = []

    for item in sorted(os.listdir(base_dir)):
        item_path = os.path.join(base_dir, item)
        if not os.path.isdir(item_path):
            continue

        year, term = parse_folder_name(item)
        if year == 0:
            print(f"  [SKIP] Could not parse folder: {item}")
            continue

        # Scan for PDFs
        am_question = None
        pm_question = None
        am_answer = None
        pm_answer = None

        for f in sorted(os.listdir(item_path)):
            f_lower = f.lower()
            if not f_lower.endswith('.pdf'):
                continue

            is_question = 'question' in f_lower
            is_answer = 'answer' in f_lower

            # Determine AM/PM (or FE-A/FE-B for 2024+)
            is_am = ('am' in f_lower and 'exam' not in f_lower) or 'fe-a' in f_lower
            is_pm = 'pm' in f_lower or 'fe-b' in f_lower

            rel_path = f"past_exams/{item}/{f}"

            if is_question and is_am:
                am_question = rel_path
            elif is_question and is_pm:
                pm_question = rel_path
            elif is_answer and is_am:
                am_answer = rel_path
            elif is_answer and is_pm:
                pm_answer = rel_path

        if am_question or pm_question:
            papers.append({
                "year": year,
                "term": term,
                "folder": item,
                "am_url": am_question,
                "pm_url": pm_question,
                "am_answer_url": am_answer,
                "pm_answer_url": pm_answer,
            })

    papers.sort(key=lambda x: (x["year"], 1 if x["term"] == "Autumn" else 0), reverse=True)

    output_path = "web/papers_data.js"
    json_data = json.dumps(papers, indent=2)
    js_content = f"window.PAPERS_DATA = {json_data};\n"

    with open(output_path, "w", encoding="utf-8") as out:
        out.write(js_content)

    print(f"Generated {output_path} with {len(papers)} papers.")
    for p in papers:
        flags = []
        if not p["am_url"]:
            flags.append("NO AM Q")
        if not p["pm_url"]:
            flags.append("NO PM Q")
        if not p["am_answer_url"]:
            flags.append("NO AM ANS")
        if not p["pm_answer_url"]:
            flags.append("NO PM ANS")
        status = ", ".join(flags) if flags else "OK"
        print(f"  {p['year']} {p['term']:8s} [{p['folder']}] — {status}")


def parse_folder_name(folder):
    """Parse year and term from various folder name formats."""

    # Format: 2023A_FE, 2023S_FE
    m = re.match(r'^(\d{4})([AS])_FE$', folder)
    if m:
        year = int(m.group(1))
        term = "Autumn" if m.group(2) == "A" else "Spring"
        return year, term

    # Format: 2013FeApr, 2012FeOct_000
    m = re.match(r'^(\d{4})Fe(Apr|Oct)', folder, re.IGNORECASE)
    if m:
        year = int(m.group(1))
        term = "Autumn" if m.group(2).lower() == "oct" else "Spring"
        return year, term

    # Format: FE2012April, FE2011October
    m = re.match(r'^FE(\d{4})(April|October)', folder, re.IGNORECASE)
    if m:
        year = int(m.group(1))
        term = "Autumn" if m.group(2).lower() == "october" else "Spring"
        return year, term

    # Format: FeApr2007, FeOct2010
    m = re.match(r'^Fe(Apr|Oct)(\d{4})$', folder, re.IGNORECASE)
    if m:
        year = int(m.group(2))
        term = "Autumn" if m.group(1).lower() == "oct" else "Spring"
        return year, term

    return 0, "Unknown"


if __name__ == "__main__":
    build_papers_list()
