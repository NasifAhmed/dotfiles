#!/bin/bash

# Wrapper script to run the Search Index Builder with correct environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Check for virtual environment
if [ -f "venv/bin/python3" ]; then
    PYTHON_CMD="./venv/bin/python3"
else
    echo "Warning: Virtual environment not found. Using system python3."
    PYTHON_CMD="python3"
fi

echo "Running Search Index Builder..."
$PYTHON_CMD app/build_search_index.py "$@"
