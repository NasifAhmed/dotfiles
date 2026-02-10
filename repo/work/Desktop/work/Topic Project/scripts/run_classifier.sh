#!/bin/bash

# FE Question Bank - Classifier Runner
# Runs the Gemini API classifier in batches

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    FE Question Bank - Question Classifier  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check for API Key
if [ -z "$GOOGLE_API_KEY" ]; then
    echo -e "${RED}Error: GOOGLE_API_KEY environment variable is not set.${NC}"
    echo "Please set it with: export GOOGLE_API_KEY='your-api-key'"
    exit 1
fi

# Default batch size is 500 to stay well within the 1500 RPD free tier limit
# while leaving some room for tests and other uses.
BATCH_SIZE=${1:-500}
DELAY=4.5 # Slightly more than 4s to be safe with 15 RPM limit

echo -e "${YELLOW}Starting classification batch...${NC}"
echo -e "Batch size: ${BLUE}$BATCH_SIZE${NC}"
echo -e "RPM limit delay: ${BLUE}$DELAY seconds${NC}"
echo ""

# Use venv if it exists
if [ -f "venv/bin/python3" ]; then
    PYTHON_BIN="venv/bin/python3"
else
    PYTHON_BIN="python3"
fi

$PYTHON_BIN app/classify_questions.py --batch-size "$BATCH_SIZE" --delay "$DELAY"

echo -e "${YELLOW}Updating search index and web data...${NC}"
$PYTHON_BIN app/build_search_index.py
$PYTHON_BIN app/build_web_topics.py

echo ""
echo -e "${GREEN}✓ Classification batch and index update finished!${NC}"
echo -e "Progress is saved in data/state/.classifier_progress.json"
echo ""
