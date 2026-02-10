#!/bin/bash
# Reset FE Question Classifier Progress

read -p "Are you sure you want to delete all AI-generated tags and restart? [y/N] " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    echo "Resetting classifier state..."
    rm -f data/output/question_tags.json
    rm -f data/state/.classifier_progress.json
    echo "✓ Progress and tags cleared."
    
    echo "Note: data/output/topics.json may still contain AI-suggested topics."
    echo "If you want to reset the topic list as well, run: python3 app/build_topics.py --force"
    
    echo "Rebuilding web data (will show 0 tags)..."
    ./scripts/rebuild_web.sh
    
    echo "Ready to start fresh!"
else
    echo "Reset cancelled."
fi
