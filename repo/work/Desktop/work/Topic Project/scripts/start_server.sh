#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Configuration
PORT="${PORT:-8080}"
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== FE Question Bank Server ===${NC}"

# Check docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check docker daemon is running
if ! docker info &> /dev/null; then
    echo "Error: Docker daemon is not running."
    echo "Try: sudo systemctl start docker"
    exit 1
fi

echo "Building and starting container..."
docker compose up -d --build

# Get local IP
if command -v ip &> /dev/null; then
    LOCAL_IP=$(ip route get 1 | awk '{print $7;exit}')
else
    LOCAL_IP="localhost"
fi

echo -e "\n${GREEN}Server is running in background!${NC}"
echo -e "Local Access:   http://localhost:${PORT}"
echo -e "LAN Access:     http://${LOCAL_IP}:${PORT}"
echo -e "View logs with: docker compose logs -f"
