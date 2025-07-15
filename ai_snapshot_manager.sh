#!/bin/bash

# AI Snapshot Manager - Create and restore snapshots for AI editing protection
# Integrated with the main file versioning system

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WATCH_DIR="$(pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
SNAPSHOT_DIR="$BACKUP_DIR/snapshots"
LOG_FILE="$SCRIPT_DIR/file_versioning.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to check if a file should be ignored
should_ignore() {
    local file="$1"
    local ignore_file="$WATCH_DIR/.versioningignore"
    
    [[ ! -f "$ignore_file" ]] && return 1
    
    local rel_path="${file#$WATCH_DIR/}"
    
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        [[ -z "$pattern" || "$pattern" =~ ^[[:space:]]*# ]] && continue
        
        pattern=$(echo "$pattern" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        regex=$(echo "$pattern" | sed 's/\./\\./g' | sed 's/\*/[^\/]*/g' | sed 's/\?/[^\/]/g')
        
        [[ "$pattern" == */ ]] && regex="^${regex}.*" || regex="^${regex}$"
        
        [[ "$rel_path" =~ $regex ]] && return 0
    done < "$ignore_file"
    
    return 1
}

# Function to create snapshot of all existing files
create_snapshot() {
    local snapshot_type="$1"  # "INITIAL" or "SESSION"
    local timestamp=$(date +%Y_%m_%d_%H:%M:%S)
    local session_dir="$SNAPSHOT_DIR/${snapshot_type}_$timestamp"
    
    mkdir -p "$session_dir"
    
    log_message "Creating $snapshot_type snapshot in: $session_dir"
    
    # Find all files recursively, excluding directories and ignored patterns
    find "$WATCH_DIR" -type f | while read -r file; do
        # Skip if file should be ignored
        should_ignore "$file" && continue
        
        # Skip backup directories
        [[ "$file" == *"/backups/"* ]] && continue
        
        # Create relative path structure in snapshot
        local rel_path="${file#$WATCH_DIR/}"
        local snapshot_file="$session_dir/$rel_path"
        local snapshot_file_dir=$(dirname "$snapshot_file")
        
        # Create directory structure
        mkdir -p "$snapshot_file_dir"
        
        # Copy file to snapshot
        cp "$file" "$snapshot_file" 2>/dev/null
    done
    
    # Count files and create manifest
    local actual_count=$(find "$session_dir" -type f 2>/dev/null | wc -l)
    log_message "$snapshot_type snapshot complete: $actual_count files backed up"
    
    cat > "$session_dir/SNAPSHOT_INFO.txt" << EOF
Snapshot Type: $snapshot_type
Created: $(date)
Directory: $WATCH_DIR
Files Backed Up: $actual_count
Purpose: AI Code Editor Protection

Files in this snapshot:
$(find "$session_dir" -type f -not -name "SNAPSHOT_INFO.txt" | sed "s|$session_dir/||" | sort)
EOF
    
    echo "$session_dir"
}

# Function to restore from snapshot
restore_from_snapshot() {
    local snapshot_dir="$1"
    
    if [[ ! -d "$snapshot_dir" ]]; then
        log_message "Error: Snapshot directory not found: $snapshot_dir"
        return 1
    fi
    
    log_message "=== RESTORING FROM SNAPSHOT ==="
    log_message "Snapshot: $snapshot_dir"
    
    # Restore files from snapshot
    find "$snapshot_dir" -type f -not -name "SNAPSHOT_INFO.txt" | while read -r snapshot_file; do
        local rel_path="${snapshot_file#$snapshot_dir/}"
        local target_file="$WATCH_DIR/$rel_path"
        local target_dir=$(dirname "$target_file")
        
        # Create directory if needed
        mkdir -p "$target_dir"
        
        # Restore file
        cp "$snapshot_file" "$target_file" 2>/dev/null
    done
    
    local actual_count=$(find "$snapshot_dir" -type f -not -name "SNAPSHOT_INFO.txt" | wc -l)
    log_message "Restore complete: $actual_count files restored"
}

# Function to list available snapshots
list_snapshots() {
    echo "Available snapshots:"
    if [[ -d "$SNAPSHOT_DIR" ]]; then
        find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "*_*" | sort | while read -r snapshot; do
            local snapshot_name=$(basename "$snapshot")
            local info_file="$snapshot/SNAPSHOT_INFO.txt"
            if [[ -f "$info_file" ]]; then
                local file_count=$(grep "Files Backed Up:" "$info_file" | cut -d: -f2 | tr -d ' ')
                local created=$(grep "Created:" "$info_file" | cut -d: -f2- | tr -d ' ')
                echo "  $snapshot_name ($file_count files) - $created"
            else
                echo "  $snapshot_name"
            fi
        done
    else
        echo "  No snapshots found"
    fi
}

# Main command handling
case "$1" in
    "initial")
        mkdir -p "$BACKUP_DIR" "$SNAPSHOT_DIR"
        create_snapshot "INITIAL"
        ;;
    "session")
        mkdir -p "$BACKUP_DIR" "$SNAPSHOT_DIR"
        log_message "=== AI EDITING SESSION STARTING ==="
        create_snapshot "SESSION"
        ;;
    "restore")
        if [[ -z "$2" ]]; then
            echo "Usage: $0 restore <snapshot_directory>"
            echo ""
            list_snapshots
            exit 1
        fi
        restore_from_snapshot "$2"
        ;;
    "list")
        list_snapshots
        ;;
    *)
        echo "AI Snapshot Manager"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  initial              - Create initial backup of all existing files"
        echo "  session              - Create pre-AI session snapshot"
        echo "  restore <snapshot>   - Restore files from snapshot"
        echo "  list                 - List available snapshots"
        echo ""
        echo "Examples:"
        echo "  $0 initial                                    # Backup all existing files"
        echo "  $0 session                                    # Create pre-AI session snapshot"
        echo "  $0 restore snapshots/SESSION_2025_01_15_14:30:25  # Restore from specific snapshot"
        ;;
esac