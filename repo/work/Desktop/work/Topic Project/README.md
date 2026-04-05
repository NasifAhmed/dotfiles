# FE Question Bank 🎓

A searchable, AI-categorized question bank for the **ITPEC Fundamental IT Engineer (FE) exam**. Covers every past exam from 2007–2025 with full-text search, topic browsing, and downloadable papers.

---

## Features

| Feature | Description |
|---------|-------------|
| 🔍 **Search** | Full-text search across all questions with fuzzy matching, wildcards, and boolean operators |
| 📚 **Topics** | Browse questions hierarchically: Category → Subcategory → Topic |
| 📄 **Papers** | Download past exam PDFs (questions + answers) organized by year |
| 🤖 **AI Tagging** | Automatic topic classification using Gemini API |
| ✂️ **Cropper** | GUI tool to crop individual questions from exam PDFs |
| 🐳 **Docker** | One-command local/LAN hosting via nginx |

---

## Prerequisites

- **Python 3.8+** with pip
- **Docker & Docker Compose** (for the web server)
- **System packages**: `poppler-utils` (for PDF conversion)

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt update && sudo apt install poppler-utils
```

---

## Quick Start

```bash
# 1. Install Python dependencies
./scripts/install_deps.sh

# 2. Start the web server
./scripts/start_server.sh

# 3. Open in browser
#    Local:  http://localhost:8080
#    LAN:    http://<your-ip>:8080
```

Or use the interactive management menu:

```bash
./manage.sh
```

---

## Management Menu (`./manage.sh`)

The central hub for all operations:

| Option | Command | Description |
|--------|---------|-------------|
| **1** | Crop Questions | Opens the GUI cropper to extract individual questions from exam PDFs |
| **2** | AI Classify | Runs Gemini API to auto-tag questions with topics (asks for batch size) |
| **3** | Build Search Index | Runs OCR and builds the search index (`web/data.js`) |
| **4** | Rebuild Web Data | Regenerates search index + topic hierarchy + papers list |
| **5** | Start Server | Builds and starts the Docker container |
| **6** | Stop Server | Stops the Docker container |
| **7** | Initial Setup | Extracts terms from textbooks and builds the topic taxonomy |
| **8** | Install Dependencies | Installs all Python packages from `requirements.txt` |
| **9** | Reset Classifier | Deletes all AI tags and classifier progress (asks for confirmation) |

---

## Adding a New Exam

When a new past exam is released, follow these steps:

### Step 1: Add the PDF files

Create a folder under `data/input/past_exams/` with this naming convention:

```
data/input/past_exams/<YEAR><S or A>_FE/
```

- `S` = Spring exam, `A` = Autumn exam

Place the question and answer PDFs inside. File names should contain `Question` or `Answer` and `AM`/`PM` (or `FE-A`/`FE-B` for 2024+ format):

```
data/input/past_exams/2025A_FE/
├── 2025A_FE-A_Questions.pdf    # Morning questions
├── 2025A_FE-A_Answers.pdf      # Morning answers
├── 2025A_FE-B_Questions.pdf    # Afternoon questions
└── 2025A_FE-B_Answers.pdf      # Afternoon answers
```

### Step 2: Crop the questions

```bash
./manage.sh   # → Option 1 (Crop Questions)
```

This opens a GUI where you review and confirm the cropped boundaries for each question. Crops are saved to `data/output/cropped_questions/`.

### Step 3: AI-classify the questions

```bash
# Set API key first
export GOOGLE_API_KEY='your-gemini-api-key'

# Or use multiple keys (auto-rotation on quota exhaustion)
# Create .api_collection with one key per line

./manage.sh   # → Option 2 (AI Classify)
```

### Step 4: Rebuild web data

```bash
./manage.sh   # → Option 4 (Rebuild Web Data)
```

This regenerates:
- `web/data.js` — search index with OCR text and tags
- `web/topics_data.js` — topic hierarchy for the Topics tab
- `web/papers_data.js` — papers list for the Papers tab

### Step 5: Done

Refresh the browser. Since the `web/` folder is volume-mounted in Docker, changes are live immediately — no container restart needed.

---

## Direct Commands Reference

If you prefer running scripts directly instead of using `manage.sh`:

```bash
# Individual pipeline steps
./scripts/run_cropper.sh                   # Step 1: Crop questions (GUI)
./scripts/run_classifier.sh [batch_size]   # Step 2: AI classify (default: 500)
./scripts/run_indexer.sh                   # Step 3: Build search index only
./scripts/rebuild_web.sh                   # Step 4: Rebuild ALL web data

# Server
./scripts/start_server.sh                  # Start Docker (port 8080)
./scripts/stop_server.sh                   # Stop Docker

# Setup & maintenance
./scripts/install_deps.sh                  # Install Python deps
./scripts/reset_classifier.sh              # Reset all AI tags

# Individual Python scripts
python3 app/question_cropper.py            # Crop questions
python3 app/classify_questions.py          # AI classifier
python3 app/build_search_index.py          # Search index builder
python3 app/build_web_topics.py            # Topics hierarchy builder
python3 app/build_papers_list.py           # Papers list builder
python3 app/extract_index.py               # Extract terms from textbooks
python3 app/build_topics.py                # Build topic taxonomy
```

---

## Project Structure

```
fe-question-bank/
├── manage.sh                  # Interactive management menu
│
├── app/                       # Python scripts
│   ├── question_cropper.py    # GUI tool to crop questions from PDFs
│   ├── classify_questions.py  # Gemini API classifier
│   ├── build_search_index.py  # OCR + search index builder
│   ├── build_web_topics.py    # Topic hierarchy → topics_data.js
│   ├── build_papers_list.py   # Past exam PDFs → papers_data.js
│   ├── extract_index.py       # Extract terms from textbook PDFs
│   └── build_topics.py        # Build initial topic taxonomy
│
├── scripts/                   # Shell wrappers
│   ├── install_deps.sh        # Dependency installer
│   ├── run_cropper.sh         # Run cropper
│   ├── run_classifier.sh      # Run classifier + rebuild web
│   ├── run_indexer.sh         # Run search index builder
│   ├── rebuild_web.sh         # Rebuild all web data (index + topics + papers)
│   ├── start_server.sh        # Docker start
│   ├── stop_server.sh         # Docker stop
│   └── reset_classifier.sh    # Delete all AI tags
│
├── data/
│   ├── input/
│   │   ├── past_exams/        # Source PDFs: exam questions & answers
│   │   └── pdfs/              # Textbook PDFs (for term extraction)
│   ├── output/
│   │   ├── cropped_questions/  # Cropped question images (PNG)
│   │   ├── question_tags.json  # AI-generated tags per question
│   │   ├── topics.json         # Topic taxonomy
│   │   └── raw_terms.txt       # Extracted textbook terms
│   └── state/
│       ├── .cropper_progress.json     # Cropper progress tracker
│       ├── .classifier_progress.json  # Classifier progress tracker
│       └── .search_index_state.json   # Search index state
│
├── web/                       # Frontend (served by nginx)
│   ├── index.html             # Main page
│   ├── css/style.css          # Styles
│   ├── js/app.js              # Application logic
│   ├── data.js                # Search index (auto-generated)
│   ├── topics_data.js         # Topic hierarchy (auto-generated)
│   └── papers_data.js         # Papers list (auto-generated)
│
├── config/
│   └── nginx.conf             # Nginx configuration
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Docker Compose config
└── requirements.txt           # Python dependencies
```

---

## Gemini API Setup

The AI classifier requires a Google Gemini API key.

**Option A — Single key:**
```bash
export GOOGLE_API_KEY='your-key-here'
```

**Option B — Multiple keys with auto-rotation:**

Create `.api_collection` in the project root with one key per line:
```
key_aaaaaaa
key_bbbbbbb
key_ccccccc
```
The classifier automatically rotates to the next key when the current one hits its daily quota (1,500 requests/day on the free tier).

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **API Quota Exceeded (429)** | Progress is auto-saved. Run the classifier again the next day, or add more keys to `.api_collection` |
| **Images not loading** | Access the site through Docker (`localhost:8080`), not by opening `index.html` directly (CORS blocks file:// access) |
| **Papers tab empty** | Run `python3 app/build_papers_list.py` to regenerate `web/papers_data.js` |
| **Docker won't start** | Ensure Docker daemon is running: `sudo systemctl start docker` |
| **Poppler not found** | Install with `sudo apt install poppler-utils` |
| **Want to re-classify all questions** | Run `./scripts/reset_classifier.sh` then re-run the classifier |

---

## License

MIT — Created for ITPEC candidates worldwide.