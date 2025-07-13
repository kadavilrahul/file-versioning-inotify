#!/bin/bash

# Multi-Location File Versioning System
# Manages file versioning across multiple directories

# Configuration file to store locations
LOCATIONS_FILE=".versioning_locations"
PID_FILE=".multi_versioning.pid"
LOG_FILE="multi_versioning.log"

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

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if a file should be ignored
should_ignore() {
    local file="$1"
    local watch_dir="$2"
    local ignore_file="$watch_dir/.versioningignore"
    
    # If .versioningignore doesn't exist, don't ignore anything
    if [ ! -f "$ignore_file" ]; then
        return 1
    fi
    
    # Get the relative path of the file from the watch directory
    local rel_path="${file#$watch_dir/}"
    
    # Check each pattern in .versioningignore
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        # Skip empty lines and comments
        [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
        
        # Trim whitespace
        pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        # Convert glob pattern to regex
        regex=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/[^\/]*/g' | sed 's/\?/[^\/]/g')
        
        # If pattern ends with /, it's a directory pattern
        if [[ "$pattern" == */ ]]; then
            regex="^${regex}.*"
        else
            regex="^${regex}$"
        fi
        
        # Check if file matches the pattern
        if [[ "$rel_path" =~ $regex ]]; then
            return 0
        fi
    done < "$ignore_file"
    
    return 1
}

# Function to create backup
create_backup() {
    local file="$1"
    local watch_dir="$2"
    local backup_dir="$watch_dir/backups"
    
    # Skip if file should be ignored
    if should_ignore "$file" "$watch_dir"; then
        return
    fi
    
    # Skip backup directory itself and script files
    if [[ "$file" == *"/backups/"* ]] || [[ "$file" == *"versioning.sh"* ]]; then
        return
    fi
    
    # Ensure backup directory exists
    mkdir -p "$backup_dir"
    
    # Create timestamped backup
    local timestamp=$(date +%Y_%m_%d_%H:%M:%S)
    local backup_file="$backup_dir/$(basename "$file")_$timestamp"
    
    if cp "$file" "$backup_file" 2>/dev/null; then
        log_message "Backup created: $backup_file (from $watch_dir)"
    else
        log_message "Failed to backup: $file (from $watch_dir)"
    fi
}

# Function to monitor a single directory
monitor_directory() {
    local watch_dir="$1"
    
    log_message "Starting monitoring for: $watch_dir"
    
    # Create default .versioningignore if it doesn't exist
    local ignore_file="$watch_dir/.versioningignore"
    if [ ! -f "$ignore_file" ]; then
        cat > "$ignore_file" << 'EOL'
# Default .versioningignore file
# Add patterns of files and directories to ignore during versioning

# System and temporary files
.DS_Store
*.tmp
*.temp
*.swp
*~
*cache.db*
.aider*
.file_versioning.pid*
.multi_versioning.pid*
.versioningignore*

# Common build and dependency directories
node_modules/
build/
dist/
target/
__pycache__/
*.pyc

# IDE and editor directories
.idea/
.vscode/
.settings/

# Log files
*.log
logs/

# Version control directories
.git/
.svn/

# Add your custom ignore patterns below this line
EOL
    fi
    
    # Monitor the directory for file changes
    inotifywait -m -r -e close_write "$watch_dir" --format '%w%f' | while read FILE
    do
        create_backup "$FILE" "$watch_dir"
    done &
}

# Read locations from file and start monitoring
if [ ! -f "$LOCATIONS_FILE" ]; then
    log_message "No locations file found. Please use manage_locations.sh to add directories to monitor."
    exit 1
fi

# Check if the locations file has content
if [ ! -s "$LOCATIONS_FILE" ]; then
    log_message "Locations file is empty. Please use manage_locations.sh to add directories to monitor."
    exit 1
fi

log_message "Starting multi-location file versioning system..."
log_message "PID: $$"

# Start monitoring each location
while IFS= read -r location || [ -n "$location" ]; do
    # Skip empty lines and comments
    [[ -z "$location" || "$location" =~ ^[[:space:]]*# ]] && continue
    
    # Trim whitespace
    location=$(echo "$location" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    # Check if directory exists
    if [ -d "$location" ]; then
        monitor_directory "$location"
        log_message "Monitoring started for: $location"
    else
        log_message "Warning: Directory does not exist: $location"
    fi
done < "$LOCATIONS_FILE"

# Wait for all background processes
wait