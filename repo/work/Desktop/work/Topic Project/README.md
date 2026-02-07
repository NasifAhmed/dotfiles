# FE Question Bank 🎓

A searchable question bank for **ITPEC Fundamental IT Engineer (FE) exam** preparation. Crop, organize, and search past exam questions by topic, year, and exam type.

![License](https://img.shields.io/badge/license-MIT-blue.svg)

## Features

- **🔍 Google-like Search** - Full-text search with OCR-extracted content
- **🎯 Smart Filters** - Filter by year range, term (Spring/Autumn), and exam type (Morning/Afternoon)
- **📱 Responsive Design** - Works on desktop and mobile
- **🐳 Docker Deployment** - One-command LAN hosting
- **⚡ Incremental Processing** - Only processes new/modified questions

---

## Quick Start

### Option 1: Run with Docker (Recommended)

```bash
# Start the server
./start_server.sh

# Access the website
# Local: http://localhost:8080
# LAN:   http://<your-ip>:8080 (printed after startup)

# Stop the server
./stop_server.sh
```

### Option 2: Open Directly

Simply open `web/index.html` in your browser. Note: Image paths may need adjustment.

---

## Project Structure

```
Topic Project/
├── web/                        # Website files
│   ├── index.html              # Main page
│   ├── css/style.css           # Styling
│   ├── js/app.js               # Search & filter logic
│   ├── data.js                 # Question index (auto-generated)
│   └── data.json               # JSON version of index
│
├── cropped_questions/          # Cropped question images (auto-generated)
│   └── 2024S_A/                # Example: Spring 2024 Morning
│       ├── Q01.png
│       ├── Q02.png
│       └── metadata.json       # Topic tags
│
├── Past Questions with Answers/ # Source PDF files
│   └── 2024SA/FE-2024S-am.pdf  # Example exam PDF
│
├── *.py                        # Python scripts (see below)
├── Dockerfile                  # Docker build config
├── docker-compose.yml          # Docker Compose config
├── start_server.sh             # Start Docker server
├── stop_server.sh              # Stop Docker server
├── install_deps.sh             # Install Python dependencies
└── requirements.txt            # Python package list
```

---

## Python Scripts

### 1. `question_cropper.py` - Crop Questions from PDFs

Interactive GUI tool to crop individual questions from exam PDFs.

```bash
python3 question_cropper.py
```

**Features:**
- Tab-based interface: Cropping → Tagging
- Auto-detects question positions
- Multi-page question support
- Progress saved in `.cropper_progress.json`

### 2. `build_search_index.py` - Build Search Index (OCR)

Performs OCR on cropped images to extract searchable text.

```bash
python3 build_search_index.py          # Incremental (only new/modified)
python3 build_search_index.py --force  # Force rebuild all
```

**Output:** `web/data.js` and `web/data.json`

### 3. `extract_index.py` - Extract Terms from Textbooks

Extracts index terms from the official FE textbook PDFs.

```bash
python3 extract_index.py          # Skips if already done
python3 extract_index.py --force  # Force re-extraction
```

**Output:** `raw_terms.txt`

### 4. `build_topics.py` - Build Topics Taxonomy

Creates hierarchical topic structure from extracted terms.

```bash
python3 build_topics.py          # Skips if already done
python3 build_topics.py --force  # Force rebuild
```

**Output:** `topics.json`

---

## Setup Guide

### Prerequisites

- **Docker** (for hosting) - [Install Docker](https://docs.docker.com/get-docker/)
- **Python 3.8+** (for scripts)
- **Tesseract OCR** (for text extraction)
- **Poppler** (for PDF processing)

### Installing Dependencies

```bash
# Make scripts executable
chmod +x *.sh

# Install Python dependencies (includes system dependency checks)
./install_deps.sh
```

If system dependencies are missing:
```bash
sudo apt update
sudo apt install tesseract-ocr poppler-utils
```

---

## Workflow: Adding New Exam Questions

### Step 1: Add PDF to Source Folder

Place the exam PDF in `Past Questions with Answers/` with proper naming:
- Format: `YYYY[S/A][AB]/FE-YYYYS-[am/pm]-questions.pdf`
- Example: `2025SA/FE-2025S-am-questions.pdf` (Spring 2025 Morning)

### Step 2: Crop Questions

```bash
python3 question_cropper.py
```

1. Select the new exam from the list
2. Adjust crop regions for each question
3. Click "Confirm" for each
4. (Optional) Tag questions in the Tagging tab

### Step 3: Rebuild Search Index

```bash
python3 build_search_index.py
```

This will only process the new questions (incremental).

### Step 4: Restart Server (if running)

```bash
./stop_server.sh
./start_server.sh
```

Or, since we use volume mounts, changes to `web/data.js` are reflected automatically!

---

## Configuration

### Change Server Port

```bash
PORT=3000 ./start_server.sh
```

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |

---

## Naming Conventions

### Exam Folder Names

| Pattern | Meaning |
|---------|---------|
| `2024S` | April (Spring) 2024 |
| `2024A` | October (Autumn) 2024 |
| `2024SA` | Spring 2024, Morning (A) Exam |
| `2024SB` | Spring 2024, Afternoon (B) Exam |

### Exam Types

| Code | Type | Description |
|------|------|-------------|
| `A` | Morning | 80 multiple choice questions |
| `B` | Afternoon | Algorithm/programming questions |

---

## Troubleshooting

### "No module named 'pytesseract'"
```bash
./install_deps.sh
```

### "tesseract not found"
```bash
sudo apt install tesseract-ocr
```

### "Cannot connect to Docker daemon"
```bash
sudo systemctl start docker
# or add user to docker group:
sudo usermod -aG docker $USER
```

### Images not loading in browser
Ensure you're using the Docker server or a local web server. Opening `index.html` directly may have CORS issues.

---

## License

MIT License - Feel free to use and modify for your FE exam preparation!
