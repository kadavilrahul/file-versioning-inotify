#!/bin/bash

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Start single location monitoring in background
echo "Starting single location file versioning..."
nohup bash file_versioning.sh > file_versioning.log 2>&1 &

# Wait a moment for single location to initialize
sleep 2

# Start multi-location monitoring if locations file exists and has content
if [ -f ".versioning_locations" ] && [ -s ".versioning_locations" ]; then
    echo "Starting multi-location file versioning..."
    nohup bash multi_location_versioning.sh > multi_versioning.log 2>&1 &
else
    echo "No multi-location directories configured - skipping multi-location monitoring"
fi

# Keep the service running
wait
