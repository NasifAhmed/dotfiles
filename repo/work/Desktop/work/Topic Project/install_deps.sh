#!/bin/bash

# FE Question Bank - Python Dependency Installer
# This script installs all Python dependencies needed for the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   FE Question Bank - Dependency Installer  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed.${NC}"
    echo "Please install Python 3.8 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo -e "Python version: ${GREEN}$PYTHON_VERSION${NC}"

# Check for pip
if ! python3 -m pip --version &> /dev/null; then
    echo -e "${RED}Error: pip is not installed.${NC}"
    echo "Install with: sudo apt install python3-pip"
    exit 1
fi

# Check system dependencies
echo ""
echo -e "${YELLOW}Checking system dependencies...${NC}"

MISSING_DEPS=()

# Check Poppler (pdftoppm) for PDF conversion
if ! command -v pdftoppm &> /dev/null; then
    MISSING_DEPS+=("poppler-utils")
    echo -e "  • Poppler Utils: ${RED}Not found${NC}"
else
    POPPLER_VERSION=$(pdftoppm -v 2>&1 | head -1)
    echo -e "  • Poppler Utils: ${GREEN}$POPPLER_VERSION${NC}"
fi

# Show missing dependencies warning
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠ Missing system dependencies:${NC}"
    echo ""
    echo -e "  Install with:"
    echo -e "    ${BLUE}sudo apt update && sudo apt install ${MISSING_DEPS[*]}${NC}"
    echo ""
    echo -e "${YELLOW}Note: The Python packages will be installed, but some scripts${NC}"
    echo -e "${YELLOW}may not work correctly without these system dependencies.${NC}"
    echo ""
fi

# Install Python packages
echo ""
echo -e "${YELLOW}Installing Python packages...${NC}"
echo ""

python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt

echo ""
echo -e "${GREEN}✓ Python dependencies installed successfully!${NC}"
echo ""

# Verification
echo -e "${YELLOW}Verifying installations...${NC}"
python3 -c "
import sys
packages = [
    ('PIL', 'Pillow'),
    ('fitz', 'PyMuPDF'),
    ('pdf2image', 'pdf2image'),
    ('pdfplumber', 'pdfplumber'),
]
all_ok = True
for module, name in packages:
    try:
        __import__(module)
        print(f'  • {name}: \033[0;32m✓\033[0m')
    except ImportError:
        print(f'  • {name}: \033[0;31m✗\033[0m')
        all_ok = False
        
if not all_ok:
    sys.exit(1)
"

echo ""
echo -e "${GREEN}✓ All dependencies verified!${NC}"
echo ""

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Remember to install system dependencies:${NC}"
    echo -e "  ${BLUE}sudo apt update && sudo apt install ${MISSING_DEPS[*]}${NC}"
    echo ""
fi

echo -e "You can now run the Python scripts:"
echo -e "  • ${BLUE}./run_cropper.sh${NC} - Crop questions & Extract text (PDF)"
echo -e "  • ${BLUE}./run_indexer.sh${NC} - Build search index (or python3 build_search_index.py)"
echo -e "  • ${BLUE}python3 extract_index.py${NC} - Extract terms from textbooks"
echo -e "  • ${BLUE}python3 build_topics.py${NC} - Build topics taxonomy"
echo ""
