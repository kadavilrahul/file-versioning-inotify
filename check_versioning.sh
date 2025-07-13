#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PID_FILE="$SCRIPT_DIR/.file_versioning.pid"

# Function to check status
check_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "✓ File versioning is running"
            echo "  - PID: $PID"
            echo "  - Watching directory: $(pwd)"
            echo "  - Backup directory: $SCRIPT_DIR/backups"
            echo "  - Log file: file_versioning.log"
            return 0
        else
            rm -f "$PID_FILE"
            echo "✗ File versioning is not running (stale PID file removed)"
            return 1
        fi
    else
        echo "✗ File versioning is not running"
        return 1
    fi
}

# Function to start versioning
start_versioning() {
    if check_status > /dev/null 2>&1; then
        echo "File versioning is already running"
        return 0
    fi
    
    echo "Starting file versioning..."
    nohup bash file_versioning.sh > /dev/null 2>&1 &
    sleep 2
    check_status
}

# Function to stop versioning
stop_versioning() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "Stopping file versioning (PID: $PID)..."
            kill "$PID"
            sleep 2
            if ps -p "$PID" > /dev/null 2>&1; then
                echo "Force killing process..."
                kill -9 "$PID"
            fi
            rm -f "$PID_FILE"
            echo "File versioning stopped"
        else
            echo "Process not running, cleaning up PID file"
            rm -f "$PID_FILE"
        fi
    else
        echo "File versioning is not running"
    fi
}

# Main script logic
case "$1" in
    "start")
        start_versioning
        ;;
    "stop")
        stop_versioning
        ;;
    "restart")
        stop_versioning
        sleep 1
        start_versioning
        ;;
    "status"|"")
        check_status
        ;;
    *)
        echo "Usage: $0 [start|stop|restart|status]"
        exit 1
        ;;
esac
