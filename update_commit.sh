#!/bin/bash

# Get current date
CURRENT_DATE=$(date +"%Y-%m-%d")

# Repository directory - this is the current directory where the script is running
REPO_DIR="$(pwd)"

# Create/update the daily update file
echo "Commiting on DAY $CURRENT_DATE" > daily_update.txt

# Configure git (if needed)
git config user.name "Karamvir Singh"
git config user.email "karamvirh71@gmail.com"

# Add all files including the script and log for initial setup
git add daily_update.txt
git add update_commit.sh
git add script.log

# Commit changes
git commit -m "Daily update: $CURRENT_DATE"

# Push to GitHub
git push origin main

# Log the execution
echo "Script executed on $CURRENT_DATE" >> "$REPO_DIR/script.log"
