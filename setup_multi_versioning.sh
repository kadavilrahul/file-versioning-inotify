#!/bin/bash

# Setup Multi-Location File Versioning System
# Initializes and configures multi-location versioning

LOCATIONS_FILE=".versioning_locations"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "=== Multi-Location File Versioning Setup ==="
echo ""

# Check for required tools
echo "Checking prerequisites..."
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "❌ Error: inotify-tools is not installed."
    echo ""
    echo "Please install it first:"
    echo "  Ubuntu/Debian: sudo apt-get install inotify-tools"
    echo "  CentOS/RHEL: sudo yum install inotify-tools"
    exit 1
else
    echo "✅ inotify-tools is installed"
fi

# Make scripts executable
echo "Making scripts executable..."
chmod +x "$SCRIPT_DIR/multi_location_versioning.sh"
chmod +x "$SCRIPT_DIR/manage_locations.sh"
chmod +x "$SCRIPT_DIR/check_multi_versioning.sh"
echo "✅ Scripts are now executable"

# Initialize locations file if it doesn't exist
if [ ! -f "$LOCATIONS_FILE" ]; then
    echo "Creating locations configuration file..."
    touch "$LOCATIONS_FILE"
    echo "✅ Created $LOCATIONS_FILE"
else
    echo "✅ Locations file already exists: $LOCATIONS_FILE"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Next steps:"
echo "1. Add directories to monitor:"
echo "   ./manage_locations.sh add /path/to/directory"
echo ""
echo "2. Start multi-location versioning:"
echo "   ./check_multi_versioning.sh start"
echo ""
echo "3. Check status:"
echo "   ./check_multi_versioning.sh status"
echo ""
echo "Available commands:"
echo "  ./manage_locations.sh add <path>     - Add directory to monitor"
echo "  ./manage_locations.sh list          - List monitored directories"
echo "  ./manage_locations.sh remove <path> - Remove directory from monitoring"
echo "  ./check_multi_versioning.sh start   - Start monitoring"
echo "  ./check_multi_versioning.sh stop    - Stop monitoring"
echo "  ./check_multi_versioning.sh status  - Check status"
echo ""

# Ask if user wants to add current directory
read -p "Would you like to add the current directory ($PWD) to monitoring? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ./manage_locations.sh add "$PWD"
fi

# Ask if user wants to add the other versioning location
if [ -d "/root/projects/file-versioning-inotify" ]; then
    read -p "Would you like to add /root/projects/file-versioning-inotify to monitoring? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./manage_locations.sh add "/root/projects/file-versioning-inotify"
    fi
fi

echo ""
echo "Setup completed successfully! 🎉"
echo "Use './manage_locations.sh list' to see configured locations."