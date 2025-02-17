#!/bin/bash

# Get current date and time
CURRENT_DATE=$(date +"%Y-%m-%d")
CURRENT_TIME=$(date +"%H:%M:%S")
FULL_DATETIME="$CURRENT_DATE $CURRENT_TIME"

# Repository directory - this is the current directory where the script is running
REPO_DIR="$(pwd)"

# Create/update the daily update file with time included
echo "Commiting on DAY $CURRENT_DATE at $CURRENT_TIME" > daily_update.txt

# Configure git (if needed)
git config user.name "Karamvir Singh"
git config user.email "karamvirh71@gmail.com"

# Add all files including the script and log for initial setup
git add daily_update.txt
git add update_commit.sh
git add script.log

# Commit changes with time included
git commit -m "Daily update: $FULL_DATETIME"

# Push to GitHub
git push origin main

# Log the execution with time
echo "Script executed on $FULL_DATETIME" >> "$REPO_DIR/script.log"
