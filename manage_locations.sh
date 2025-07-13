#!/bin/bash

# Location Management Script for Multi-Location File Versioning
# Manages the list of directories to be monitored

LOCATIONS_FILE=".versioning_locations"

# Function to display usage
show_usage() {
    echo "Usage: $0 [add|remove|list|clear] [directory_path]"
    echo ""
    echo "Commands:"
    echo "  add <path>     - Add a directory to monitoring list"
    echo "  remove <path>  - Remove a directory from monitoring list"
    echo "  list           - List all monitored directories"
    echo "  clear          - Clear all monitored directories"
    echo ""
    echo "Examples:"
    echo "  $0 add /var/www/project1"
    echo "  $0 remove /var/www/project1"
    echo "  $0 list"
    echo "  $0 clear"
}

# Function to add a location
add_location() {
    local path="$1"
    
    if [ -z "$path" ]; then
        echo "Error: Please specify a directory path"
        show_usage
        exit 1
    fi
    
    # Convert to absolute path
    path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    # Check if directory exists
    if [ ! -d "$path" ]; then
        echo "Error: Directory does not exist: $path"
        exit 1
    fi
    
    # Create locations file if it doesn't exist
    touch "$LOCATIONS_FILE"
    
    # Check if location already exists
    if grep -Fxq "$path" "$LOCATIONS_FILE" 2>/dev/null; then
        echo "Location already exists: $path"
        exit 0
    fi
    
    # Add location to file
    echo "$path" >> "$LOCATIONS_FILE"
    echo "Added location: $path"
}

# Function to remove a location
remove_location() {
    local path="$1"
    
    if [ -z "$path" ]; then
        echo "Error: Please specify a directory path"
        show_usage
        exit 1
    fi
    
    # Convert to absolute path
    path=$(realpath "$path" 2>/dev/null || echo "$path")
    
    if [ ! -f "$LOCATIONS_FILE" ]; then
        echo "No locations file found"
        exit 1
    fi
    
    # Remove location from file
    if grep -Fxq "$path" "$LOCATIONS_FILE"; then
        grep -Fxv "$path" "$LOCATIONS_FILE" > "${LOCATIONS_FILE}.tmp"
        mv "${LOCATIONS_FILE}.tmp" "$LOCATIONS_FILE"
        echo "Removed location: $path"
    else
        echo "Location not found: $path"
        exit 1
    fi
}

# Function to list all locations
list_locations() {
    if [ ! -f "$LOCATIONS_FILE" ]; then
        echo "No locations configured"
        return
    fi
    
    if [ ! -s "$LOCATIONS_FILE" ]; then
        echo "No locations configured"
        return
    fi
    
    echo "Monitored locations:"
    local count=0
    while IFS= read -r location || [ -n "$location" ]; do
        # Skip empty lines and comments
        [[ -z "$location" || "$location" =~ ^[[:space:]]*# ]] && continue
        
        count=$((count + 1))
        if [ -d "$location" ]; then
            echo "  $count. $location ✓"
        else
            echo "  $count. $location ✗ (not found)"
        fi
    done < "$LOCATIONS_FILE"
    
    if [ $count -eq 0 ]; then
        echo "No locations configured"
    fi
}

# Function to clear all locations
clear_locations() {
    if [ -f "$LOCATIONS_FILE" ]; then
        > "$LOCATIONS_FILE"
        echo "All locations cleared"
    else
        echo "No locations file found"
    fi
}

# Main script logic
case "$1" in
    "add")
        add_location "$2"
        ;;
    "remove")
        remove_location "$2"
        ;;
    "list")
        list_locations
        ;;
    "clear")
        clear_locations
        ;;
    *)
        show_usage
        exit 1
        ;;
esac