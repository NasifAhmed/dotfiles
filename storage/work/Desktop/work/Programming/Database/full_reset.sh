#!/bin/bash

echo "💣 DESTROYING existing containers..."
docker rm -f mysql-class adminer 2>/dev/null

echo "🧹 Cleaning up network..."
docker network rm class-net 2>/dev/null

echo "🚀 Re-launching Infrastructure..."
./start_class.sh

echo "📝 Re-populating Database..."
./reset_db.sh

echo "✅ Full Factory Reset Complete."
