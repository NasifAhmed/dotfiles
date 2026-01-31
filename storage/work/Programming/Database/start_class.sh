#!/bin/bash

# ============================================================
# UTILITY FUNCTIONS
# ============================================================

# Function to print section headers
print_header() {
    echo -e "\n\033[1;34m>>> $1\033[0m"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to get the local IP Address (Works on Mac, Linux, and Windows Git Bash)
get_ip_address() {
    # Try hostname -I (Linux)
    if command_exists hostname && [ -n "$(hostname -I 2>/dev/null)" ]; then
        hostname -I | awk '{print $1}'
        # Try ipconfig getifaddr en0 (Mac Wi-Fi)
    elif command_exists ipconfig && ipconfig getifaddr en0 >/dev/null 2>&1; then
        ipconfig getifaddr en0
        # Try ipconfig (Windows) - dirty parsing
    elif command_exists ipconfig; then
        ipconfig | grep -A 10 "Wi-Fi" | grep "IPv4" | head -n 1 | awk -F: '{print $2}' | xargs
    else
        echo "UNKNOWN_IP"
    fi
}

# ============================================================
# 1. PRE-FLIGHT CHECKS
# ============================================================
print_header "Step 1: Checking System Requirements..."

# Check if Docker is installed
if ! command_exists docker; then
    echo "❌ CRITICAL ERROR: Docker is not installed."
    echo "   Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker Daemon is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ CRITICAL ERROR: Docker is installed but NOT running."
    echo "   Please open Docker Desktop and wait for the whale icon to stop animating."
    exit 1
fi
echo "✅ Docker is up and running."

# ============================================================
# 2. NETWORK SETUP
# ============================================================
print_header "Step 2: Setting up Network..."

if docker network ls | grep -q "class-net"; then
    echo "   Network 'class-net' already exists. Skipping."
else
    echo "   Creating private network 'class-net'..."
    docker network create class-net
fi

# ============================================================
# 3. START MYSQL
# ============================================================
print_header "Step 3: Starting MySQL Database..."

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^mysql-class$"; then
    # Check if it is running
    if docker ps --format '{{.Names}}' | grep -q "^mysql-class$"; then
        echo "   MySQL is already running. Skipping."
    else
        echo "   Container exists but is stopped. Starting it..."
        docker start mysql-class
    fi
else
    # Check if port 3306 is free (basic check)
    echo "   Creating new MySQL container..."
    # Check for image existence locally to avoid long silence
    if ! docker image inspect mysql:latest >/dev/null 2>&1; then
        echo "   Downloading MySQL image (this may take a minute)..."
        docker pull mysql:latest
    fi

    docker run --name mysql-class \
        --network class-net \
        -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD=root \
        -d mysql:latest

    if [ $? -ne 0 ]; then
        echo "❌ FAILED to start MySQL. Port 3306 might be in use by another program."
        exit 1
    fi
fi

# ============================================================
# 4. START ADMINER
# ============================================================
print_header "Step 4: Starting Adminer Interface..."

if docker ps -a --format '{{.Names}}' | grep -q "^adminer$"; then
    if docker ps --format '{{.Names}}' | grep -q "^adminer$"; then
        echo "   Adminer is already running. Skipping."
    else
        echo "   Container exists but is stopped. Starting it..."
        docker start adminer
    fi
else
    echo "   Creating new Adminer container..."
    docker run --name adminer \
        --network class-net \
        -p 8080:8080 \
        -d adminer

    if [ $? -ne 0 ]; then
        echo "❌ FAILED to start Adminer. Port 8080 might be in use."
        exit 1
    fi
fi

# ============================================================
# 5. HEALTH CHECK
# ============================================================
print_header "Step 5: Waiting for Database to Initialize..."

echo -n "   Waiting for MySQL to accept connections"
# Loop until MySQL is ready (timeout after 60s)
for i in {1..30}; do
    if docker exec mysql-class mysqladmin -u root -proot ping >/dev/null 2>&1; then
        echo " ✅ Ready!"
        break
    fi
    echo -n "."
    sleep 2
    if [ $i -eq 30 ]; then
        echo " ❌ TIMEOUT. MySQL is taking too long."
        echo "    It might still work in a minute, but check logs with: docker logs mysql-class"
    fi
done

# ============================================================
# 6. FINAL SUMMARY
# ============================================================
MY_IP=$(get_ip_address)

echo "----------------------------------------------------------------"
echo -e "\033[1;32m🎉 CLASS ENVIRONMENT IS READY! \033[0m"
echo "----------------------------------------------------------------"
echo "1. TELL STUDENTS TO OPEN THIS URL:"
echo -e "   👉 \033[1;34mhttp://$MY_IP:8080\033[0m"
echo ""
echo "2. LOGIN DETAILS FOR STUDENTS:"
echo "   Server:   mysql-class"
echo "   Username: student1"
echo "   Password: student1"
echo "   Database: class_db"
echo ""
echo "   (Note: If 'student1' doesn't work yet, run ./reset_db.sh)"
echo "----------------------------------------------------------------"
