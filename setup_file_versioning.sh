#!/bin/bash

# Clone the repository if it doesn't exist
if [ ! -d "file-versioning-inotify" ]; then
    echo "Cloning repository..."
    git clone https://github.com/kadavilrahul/file-versioning-inotify
fi

# Copy the necessary files to the current directory
echo "Moving versioning scripts to current directory..."
cp file-versioning-inotify/file_versioning.sh .
cp file-versioning-inotify/check_versioning.sh .

# Make the scripts executable
chmod +x file_versioning.sh
chmod +x check_versioning.sh

# Function to update .gitignore in the destination directory
update_gitignore() {
    local dest_dir="$1"
    local gitignore="$dest_dir/.gitignore"

    # Create .gitignore if it doesn't exist
    if [ ! -f "$gitignore" ]; then
        touch "$gitignore"
    fi

    # Add the ignore patterns
    if ! grep -q "# Ignore shell scripts, log files, and pid files" "$gitignore"; then
        echo "# Ignore shell scripts, log files, and pid files" >> "$gitignore"
    fi
    if ! grep -q "*.log" "$gitignore"; then
        echo "*.log" >> "$gitignore"
    fi
    if ! grep -q "*.pid" "$gitignore"; then
        echo "*.pid" >> "$gitignore"
    fi
    if ! grep -q "# Ignore specific shell script files" "$gitignore"; then
        echo "# Ignore specific shell script files" >> "$gitignore"
    fi
    if ! grep -q "setup_file_versioning.sh" "$gitignore"; then
        echo "setup_file_versioning.sh" >> "$gitignore"
    fi
    if ! grep -q "file_versioning.sh" "$gitignore"; then
        echo "file_versioning.sh" >> "$gitignore"
    fi
    if ! grep -q "check_versioning.sh" "$gitignore"; then
        echo "check_versioning.sh" >> "$gitignore"
    fi
    if ! grep -q "# Ignore backups folder" "$gitignore"; then
        echo "# Ignore backups folder" >> "$gitignore"
    fi
    if ! grep -q "backups/" "$gitignore"; then
        echo "backups/" >> "$gitignore"
    fi
}

# Update .gitignore in the destination directory
DEST_DIR=$(pwd)
update_gitignore "$DEST_DIR"

# Remove the cloned repository
echo "Cleaning up..."
rm -rf file-versioning-inotify

echo "Setup complete! The file versioning scripts are now ready to use."
