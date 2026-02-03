#!/bin/bash

CONTAINER_NAME="mysql-class"

# 1. Check if the container is actually running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Error: The MySQL container ('$CONTAINER_NAME') is not running."
    echo "   👉 Run ./start_class.sh first."
    exit 1
fi

# 2. Enter the MySQL Shell directly
echo "🚀 Entering MySQL as ROOT..."
echo "   (Type 'exit' or Press Ctrl+D to quit)"
echo "-----------------------------------------------------"

# -it allows interactive mode
# -u root -proot logs in automatically
# class_db selects the database immediately
docker exec -it $CONTAINER_NAME mysql -u root -proot class_db
