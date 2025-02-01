#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_FILE="$SCRIPT_DIR/.file_versioning.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✓ File versioning is running"
        echo "  - PID: $PID"
        echo "  - Watching directory: $SCRIPT_DIR"
        echo "  - Backup directory: $SCRIPT_DIR/backups"
        echo "  - Log file: file_versioning.log"
    else
        rm -f "$PID_FILE"
        echo "✗ File versioning is not running (stale PID file removed)"
    fi
else
    echo "✗ File versioning is not running"
fi
