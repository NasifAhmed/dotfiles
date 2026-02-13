# FE Question Bank 🎓

A comprehensive, searchable, and AI-categorized question bank for the **ITPEC Fundamental IT Engineer (FE) exam**.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Features

- **🤖 AI Classification** - Automatic topic tagging using Gemini 1.5/2.0 Flash API.
- **📚 Hierarchical Browsing** - Navigate questions by Category → Subcategory → Topic.
- **🔍 Advanced Search** - Full-text search across all questions with OCR-extracted content.
- **🎯 Smart Filters** - Filter by year, exam term (Spring/Autumn), and type (Morning/Afternoon).
- **🐳 Docker Ready** - One-command local/LAN hosting.
- **⚡ Incremental Workflow** - Only process what's new.

---

## Quick Start

### 1. Installation
```bash
./scripts/install_deps.sh
```

### 2. Setup Gemini API (Required for AI Tagging)
You can use a single API key or a collection for automatic rotation.

**Option A: Single Key**
```bash
export GOOGLE_API_KEY='your-api-key'
```

**Option B: Multiple Keys (Auto-rotation)**
Create a file named `.api_collection` in the project root and add one API key per line:
```bash
# .api_collection
key_1
key_2
key_3
```
The classifier will automatically switch to the next key when the current one hits its daily quota.

### 3. Launch Manager
Everything you need is in the central management script:
```bash
./manage.sh
```

---

## 🛠 Project Workflow

### General Usage
1.  **Start Server**: Option `5` in `./manage.sh`. Open `http://localhost:8080`.
2.  **Browse Topics**: Click the **"Topics"** tab on the website to see the hierarchical view.
3.  **Search**: Use the **"Search"** tab for full-text queries (e.g., `*SQL* & *Join*`).

### Adding New Exams
When a new past exam is released:
1.  **Add PDF**: Place the PDF in `data/input/past_exams/YYYY[S/A]/`.
2.  **Crop**: Run `./manage.sh` → Option `1`. Crop and confirm each question.
3.  **AI Classify**: Run `./manage.sh` → Option `2`. This uses Gemini to tag new questions.
4.  **Sync Web**: Run `./manage.sh` → Option `4`. This rebuilds the website data files.

---

## 🐍 Python Scripts Deep-Dive

### 🤖 AI Classifier (`app/classify_questions.py`)
Uses Gemini API to analyze question images and OCR text.
-   **Safe Rate Limits**: Defaults to 50 questions/batch with a 4.5s delay (Free Tier friendly).
-   **Context Aware**: Feeds both the image and the extracted text to Gemini for high accuracy.
-   **Self-Improving**: Automatically adds new topics to `topics.json` if suggested by AI.

### 🔍 Search Indexer (`app/build_search_index.py`)
Builds the `web/data.js` file used for searching.
-   Performs incremental OCR on confirmed crops.
-   Links AI-generated tags to search records.

### ✂️ Question Cropper (`app/question_cropper.py`)
A custom GUI tool for manual verification of question boundaries.
-   Supports multi-page questions.
-   Tracks progress in `data/state/.cropper_progress.json`.

---

## 📂 Data Structure

```
Topic Project/
├── app/                # Core Python logic
├── data/
│   ├── input/          # Source PDFs (Exams & Textbooks)
│   ├── output/         # Generated crops, topics.json, and AI tags
│   └── state/          # Progress trackers (.cropper_progress, .classifier_progress)
├── scripts/            # Shell helper wrappers
├── web/                # Searchable website (Serverless Frontend)
└── manage.sh           # Interactive CLI Manager
```

---

## Troubleshooting

### API Quota Exceeded (429 Error)
If you hit the free tier limit (1,500 requests/day), the classifier will save your progress and exit. Simply run it again the next day.

### Images Not Loading
Ensure you are accessing the site via the Docker server (`./scripts/start_server.sh`) or a local web server. Opening `index.html` directly from the file system often triggers CORS security blocks.

### Resetting Progress
If you want to re-run AI classification for all questions:
```bash
./scripts/reset_classifier.sh
```

---

## License
MIT - Created for ITPEC candidates worldwide.