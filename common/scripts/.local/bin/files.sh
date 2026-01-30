#!/bin/bash

# 1. Search for PDFs
# We use awk to print: "Filename <TAB> FullPath"
# fzf uses the TAB as a delimiter
# --with-nth=1 tells fzf to ONLY show the 1st column (Filename)
# --preview uses {2} to look up the file info using the hidden 2nd column (FullPath)

SELECTED_LINE=$(find "/home/nasif/Desktop/FE Exam/" -type f -name "*.pdf" | awk -F/ '{ print $NF "\t" $0 }' | fzf \
    --delimiter $'\t' \
    --with-nth 1 \
    --height=60% \
    --layout=reverse \
    --border \
    --prompt="Select PDF > " \
    --preview "ls -lh {2}" \
    --preview-window=right:40% \
    --preview "pdftotext {} - | head -n 20")

# 2. Open the file
if [ -n "$SELECTED_LINE" ]; then
    # Extract the full path (Column 2) from the selected line
    FILE_PATH=$(echo "$SELECTED_LINE" | cut -f2)

    echo "Opening: $FILE_PATH"

    # OS Detection for opening
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$FILE_PATH"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$FILE_PATH" &> /dev/null
    else
        echo "Could not detect a default opener."
    fi
fi
