#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Use venv if it exists
if [ -f "venv/bin/python3" ]; then
    PYTHON_BIN="venv/bin/python3"
else
    PYTHON_BIN="python3"
fi

echo "Rebuilding all web data..."
$PYTHON_BIN app/build_search_index.py
$PYTHON_BIN app/build_web_topics.py
echo "✓ Done!"
