#!/bin/bash

# Check Multi-Location File Versioning Status
# Shows status of multi-location versioning system

PID_FILE=".multi_versioning.pid"
LOG_FILE="multi_versioning.log"
LOCATIONS_FILE=".versioning_locations"

# Function to check if multi-versioning is running
check_status() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "✓ Multi-location file versioning is running"
            echo "  - PID: $pid"
            echo "  - Log file: $LOG_FILE"
            
            # Show monitored locations
            if [ -f "$LOCATIONS_FILE" ]; then
                echo "  - Monitored locations:"
                local count=0
                while IFS= read -r location || [ -n "$location" ]; do
                    # Skip empty lines and comments
                    [[ -z "$location" || "$location" =~ ^[[:space:]]*# ]] && continue
                    
                    count=$((count + 1))
                    location=$(echo "$location" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [ -d "$location" ]; then
                        echo "    $count. $location ✓"
                    else
                        echo "    $count. $location ✗ (not found)"
                    fi
                done < "$LOCATIONS_FILE"
                
                if [ $count -eq 0 ]; then
                    echo "    No locations configured"
                fi
            else
                echo "    No locations file found"
            fi
            
            # Show recent log entries
            if [ -f "$LOG_FILE" ]; then
                echo "  - Recent activity:"
                tail -5 "$LOG_FILE" | sed 's/^/    /'
            fi
            
            return 0
        else
            echo "✗ Multi-location file versioning is not running (stale PID file)"
            rm -f "$PID_FILE"
            return 1
        fi
    else
        echo "✗ Multi-location file versioning is not running"
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [status|start|stop|restart|locations]"
    echo ""
    echo "Commands:"
    echo "  status      - Show current status (default)"
    echo "  start       - Start multi-location versioning"
    echo "  stop        - Stop multi-location versioning"
    echo "  restart     - Restart multi-location versioning"
    echo "  locations   - Show monitored locations"
}

# Function to start multi-versioning
start_versioning() {
    if check_status > /dev/null 2>&1; then
        echo "Multi-location file versioning is already running"
        return 0
    fi
    
    # Check if locations file exists and has content
    if [ ! -f "$LOCATIONS_FILE" ]; then
        echo "Error: No locations file found. Please use manage_locations.sh to add directories to monitor."
        return 1
    fi
    
    if [ ! -s "$LOCATIONS_FILE" ]; then
        echo "Error: Locations file is empty. Please use manage_locations.sh to add directories to monitor."
        return 1
    fi
    
    echo "Starting multi-location file versioning..."
    nohup bash multi_location_versioning.sh > /dev/null 2>&1 &
    sleep 2
    check_status
}

# Function to stop multi-versioning
stop_versioning() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "Stopping multi-location file versioning (PID: $pid)..."
            kill "$pid"
            sleep 2
            if ps -p "$pid" > /dev/null 2>&1; then
                echo "Force killing process..."
                kill -9 "$pid"
            fi
            rm -f "$PID_FILE"
            echo "Multi-location file versioning stopped"
        else
            echo "Process not running, cleaning up PID file"
            rm -f "$PID_FILE"
        fi
    else
        echo "Multi-location file versioning is not running"
    fi
}

# Function to restart versioning
restart_versioning() {
    stop_versioning
    sleep 1
    start_versioning
}

# Function to show locations
show_locations() {
    bash manage_locations.sh list
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
        restart_versioning
        ;;
    "locations")
        show_locations
        ;;
    "status"|"")
        check_status
        ;;
    *)
        show_usage
        exit 1
        ;;
esac