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

# Remove the cloned repository
echo "Cleaning up..."
rm -rf file-versioning-inotify

echo "Setup complete! The file versioning scripts are now ready to use."
