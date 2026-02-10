#!/bin/bash

# Central management script for FE Question Bank Project

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Detect Python interpreter
PYTHON_CMD="python3"
if [ -f "venv/bin/python3" ]; then
    PYTHON_CMD="./venv/bin/python3"
fi

function show_menu() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    FE Question Bank - Management Menu      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo -e "${CYAN}1.${NC} ✂️  Crop Questions (GUI)"
    echo -e "${CYAN}2.${NC} 🤖 AI Classify Questions (Gemini API)"
    echo -e "${CYAN}3.${NC} 🔍 Build Search Index (OCR)"
    echo -e "${CYAN}4.${NC} 🌐 Rebuild Web Data (Topic Hierarchy)"
    echo -e "${CYAN}5.${NC} 🚀 Start Server (Docker)"
    echo -e "${CYAN}6.${NC} 🛑 Stop Server (Docker)"
    echo -e "${CYAN}7.${NC} 📖 Initial setup (Textbook Terms & Topics)"
    echo -e "${CYAN}8.${NC} 📦 Install Dependencies"
    echo -e "${CYAN}9.${NC} 🧹 Reset AI Classifier State"
    echo -e "${CYAN}0.${NC} ❌ Exit"
    echo -n "Select an option [0-9]: "
}

while true; do
    show_menu
    read choice

    case $choice in
        1)
            echo -e "\n${GREEN}Starting Question Cropper...${NC}"
            ./scripts/run_cropper.sh
            ;;
        2)
            echo -e "\n${GREEN}Running AI Classifier...${NC}"
            echo -n "Batch size (default 50): "
            read batch
            ./scripts/run_classifier.sh ${batch:-50}
            ;;
        3)
            echo -e "\n${GREEN}Building Search Index...${NC}"
            ./scripts/run_indexer.sh
            ;;
        4)
            echo -e "\n${GREEN}Rebuilding Web Data...${NC}"
            ./scripts/rebuild_web.sh
            ;;
        5)
            echo -e "\n${GREEN}Starting Server...${NC}"
            ./scripts/start_server.sh
            ;;
        6)
            echo -e "\n${GREEN}Stopping Server...${NC}"
            ./scripts/stop_server.sh
            ;;
        7)
            echo -e "\n${GREEN}Extracting Terms and Building Initial Taxonomy...${NC}"
            $PYTHON_CMD app/extract_index.py
            $PYTHON_CMD app/build_topics.py
            ;;
        8)
            echo -e "\n${GREEN}Installing Dependencies...${NC}"
            ./scripts/install_deps.sh
            ;;
        9)
            ./scripts/reset_classifier.sh
            ;;
        0)
            echo -e "\nGoodbye!"
            exit 0
            ;;
        *)
            echo -e "\n${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
    
    echo -e "\nPress Enter to return to menu..."
    read
done