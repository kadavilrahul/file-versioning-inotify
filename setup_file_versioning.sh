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

    # Create a temporary file with all desired entries
    cat > "$gitignore.tmp" << EOL
# Ignore shell scripts, log files, pid files and versioning ignore
*.log
*.pid
.versioningignore

# Ignore specific shell script files
setup_file_versioning.sh
file_versioning.sh
check_versioning.sh

# Ignore backups folder
backups/
EOL

    # Merge existing content with new content, removing duplicates
    if [ -f "$gitignore" ]; then
        cat "$gitignore" "$gitignore.tmp" | sort -u > "$gitignore.new"
        mv "$gitignore.new" "$gitignore"
    else
        mv "$gitignore.tmp" "$gitignore"
    fi

    # Clean up
    rm -f "$gitignore.tmp"
}

# Update .gitignore in the destination directory
DEST_DIR=$(pwd)
update_gitignore "$DEST_DIR"

# Remove the cloned repository
echo "Cleaning up..."
rm -rf file-versioning-inotify

echo "Setup complete! The file versioning scripts are now ready to use."
