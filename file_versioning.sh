#!/bin/bash

# Get the script's directory (for storing backups and PID file)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Use current working directory as the watch directory
WATCH_DIR="$(pwd)"

# Configuration
BACKUP_DIR="$SCRIPT_DIR/backups"       # Directory for backups
PID_FILE="$SCRIPT_DIR/.file_versioning.pid"

# Create PID file
echo $$ > "$PID_FILE"

# Cleanup PID file on exit
trap "rm -f $PID_FILE" EXIT

# Check for inotify-tools
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "Error: inotify-tools is not installed. Please install it first:"
    echo "Ubuntu/Debian: sudo apt-get install inotify-tools"
    echo "CentOS/RHEL: sudo yum install inotify-tools"
    exit 1
fi

# Ensure the backup directory exists
mkdir -p "$BACKUP_DIR"

echo "Starting file versioning system..."
echo "Watching directory: $WATCH_DIR"
echo "Backup directory: $BACKUP_DIR"
echo "PID: $$"

# Monitor the directory for file changes
inotifywait -m -e close_write "$WATCH_DIR" --format '%w%f' | while read FILE
do
    # Skip the backup directory itself and script files
    if [[ "$FILE" == *"/backups/"* ]] || [[ "$FILE" == *"file_versioning.sh"* ]] || [[ "$FILE" == *"check_versioning.sh"* ]]; then
        continue
    fi
    
    TIMESTAMP=$(date +%Y_%m_%d_%H:%M:%S)
    BACKUP_FILE="$BACKUP_DIR/$(basename "$FILE")_$TIMESTAMP"
    cp "$FILE" "$BACKUP_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup created: $BACKUP_FILE"
done
