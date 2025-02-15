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

# Create default .versioningignore if it doesn't exist
VERSIONING_IGNORE="$WATCH_DIR/.versioningignore"
if [ ! -f "$VERSIONING_IGNORE" ]; then
    cat > "$VERSIONING_IGNORE" << 'EOL'
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
    echo "Created default .versioningignore file at: $VERSIONING_IGNORE"
fi

echo "Starting file versioning system..."
echo "Watching directory: $WATCH_DIR"
echo "Backup directory: $BACKUP_DIR"
echo "PID: $$"

# Function to check if a file should be ignored
should_ignore() {
    local file="$1"
    local ignore_file="$WATCH_DIR/.versioningignore"
    
    # If .versioningignore doesn't exist, don't ignore anything
    if [ ! -f "$ignore_file" ]; then
        return 1
    fi
    
    # Get the relative path of the file from the watch directory
    local rel_path="${file#$WATCH_DIR/}"
    
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

# Monitor the directory for file changes
inotifywait -m -r -e close_write "$WATCH_DIR" --format '%w%f' | while read FILE
do
    # Skip the backup directory itself and script files
    if [[ "$FILE" == *"/backups/"* ]] || [[ "$FILE" == *"file_versioning.sh"* ]] || [[ "$FILE" == *"check_versioning.sh"* ]]; then
        continue
    fi
    
    # Check if file should be ignored based on .versioningignore
    if should_ignore "$FILE"; then
        continue
    fi
    
    TIMESTAMP=$(date +%Y_%m_%d_%H:%M:%S)
    BACKUP_FILE="$BACKUP_DIR/$(basename "$FILE")_$TIMESTAMP"
    cp "$FILE" "$BACKUP_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup created: $BACKUP_FILE"
done
