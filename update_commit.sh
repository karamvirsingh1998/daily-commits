#!/bin/bash

# Set PATH
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Get current date and time
CURRENT_DATE=$(/bin/date +"%Y-%m-%d")
CURRENT_TIME=$(/bin/date +"%H:%M:%S")
FULL_DATETIME="$CURRENT_DATE $CURRENT_TIME"

# Use absolute path for repository directory
REPO_DIR="/Users/karamvirsingh/Downloads/daily-commits/daily-commits"
cd "$REPO_DIR"

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
git commit -m "Daily update: $FULL_DATETIME at $CURRENT_TIME"

# Push to GitHub
git push origin main

# Log the execution with time
echo "Script executed on $FULL_DATETIME at $CURRENT_TIME" >> "$REPO_DIR/script.log"
