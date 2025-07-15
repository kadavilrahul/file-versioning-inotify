#!/bin/bash

# AI-Enhanced File Versioning System
# Comprehensive protection for AI code editor sessions

# Get the script's directory (for storing backups and PID file)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Use current working directory as the watch directory
WATCH_DIR="$(pwd)"

# Configuration
BACKUP_DIR="$SCRIPT_DIR/backups"
PID_FILE="$SCRIPT_DIR/.file_versioning.pid"
LOG_FILE="$SCRIPT_DIR/file_versioning.log"

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

# Ensure the backup directories exist
mkdir -p "$BACKUP_DIR/regular" "$BACKUP_DIR/ai-sessions" "$BACKUP_DIR/snapshots"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Create enhanced .versioningignore if it doesn't exist
VERSIONING_IGNORE="$WATCH_DIR/.versioningignore"
if [ ! -f "$VERSIONING_IGNORE" ]; then
    cat > "$VERSIONING_IGNORE" << 'EOL'
# AI-Enhanced .versioningignore file
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

# AI Editor specific files
.cursor/
.copilot/
.ai-session/
*.ai-backup
.continue/

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
    log_message "Created enhanced .versioningignore file at: $VERSIONING_IGNORE"
fi

log_message "=== AI-Enhanced File Versioning System Starting ==="
log_message "Watching directory: $WATCH_DIR"
log_message "Backup directory: $BACKUP_DIR"
log_message "PID: $$"

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

# Function to detect AI activity
detect_ai_activity() {
    local ai_processes=""
    pgrep -f "aider" >/dev/null 2>&1 && ai_processes="$ai_processes aider"
    pgrep -f "cursor" >/dev/null 2>&1 && ai_processes="$ai_processes cursor"
    pgrep -f "continue" >/dev/null 2>&1 && ai_processes="$ai_processes continue"
    pgrep -f "copilot" >/dev/null 2>&1 && ai_processes="$ai_processes copilot"
    echo "$ai_processes"
}

# Function to create smart backup with deduplication
create_smart_backup() {
    local file="$1"
    local event_type="$2"
    
    # Skip backup directories and scripts
    [[ "$file" == *"/backups/"* || "$file" == *"versioning.sh"* ]] && return
    
    # Check if file should be ignored
    should_ignore "$file" && return
    
    # Check if file exists and is readable
    [[ ! -f "$file" || ! -r "$file" ]] && return
    
    # Check for content changes (deduplication)
    local file_hash=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1)
    local last_backup=$(find "$BACKUP_DIR" -name "$(basename "$file")_*" -type f 2>/dev/null | sort | tail -1)
    
    if [[ -n "$last_backup" ]]; then
        local last_hash=$(md5sum "$last_backup" 2>/dev/null | cut -d' ' -f1)
        [[ "$file_hash" == "$last_hash" ]] && return  # No changes
    fi
    
    # Determine backup location based on AI activity
    local ai_activity=$(detect_ai_activity)
    local backup_subdir="regular"
    local mode="NORMAL"
    
    if [[ -n "$ai_activity" ]]; then
        backup_subdir="ai-sessions"
        mode="AI"
    fi
    
    # Create timestamped backup
    local timestamp=$(date +%Y_%m_%d_%H:%M:%S)
    local backup_file="$BACKUP_DIR/$backup_subdir/$(basename "$file")_${mode}_${event_type}_$timestamp"
    
    if cp "$file" "$backup_file" 2>/dev/null; then
        log_message "[$mode] Backup created [$event_type]: $(basename "$backup_file")"
    fi
}

# Enhanced monitoring with multiple events for AI editor protection
log_message "Monitoring events: CREATE, MODIFY, CLOSE_WRITE, MOVED_TO"
inotifywait -m -r -e create -e modify -e close_write -e moved_to "$WATCH_DIR" --format '%e %w%f' | while read EVENT FILE
do
    case "$EVENT" in
        "CREATE")
            # New file created - backup if it has content
            [[ -f "$FILE" && -s "$FILE" ]] && create_smart_backup "$FILE" "CREATE"
            ;;
        "MODIFY")
            # File being modified - useful for AI editors
            create_smart_backup "$FILE" "MODIFY"
            ;;
        "CLOSE_WRITE")
            # File closed after writing - most reliable backup point
            create_smart_backup "$FILE" "SAVE"
            ;;
        "MOVED_TO")
            # File moved/renamed - backup the new location
            create_smart_backup "$FILE" "MOVE"
            ;;
    esac
done