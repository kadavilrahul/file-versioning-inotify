# File Versioning System with inotify

A comprehensive file versioning system that automatically creates backups of files when they are modified, using Linux's inotify for file system monitoring. Supports both single-location and multi-location monitoring with an interactive management interface.

## Prerequisites
- Linux system

## Installation

### Quick Start with Interactive Interface
1. Clone the repository:
```bash
git clone https://github.com/kadavilrahul/file-versioning-inotify.git
```
```bash
cd file-versioning-inotify
```

2. Launch the interactive management interface:
```bash
bash run.sh
```

The interactive interface provides a comprehensive menu system for:
- Single-location and multi-location versioning setup
- Starting, stopping, and monitoring services
- Managing monitored locations
- Viewing logs and backup management
- System configuration


## File Organization

### Core Scripts
- `run.sh`: Interactive management interface with color-coded menus
- `file_versioning.sh`: Single-location monitoring script
- `multi_location_versioning.sh`: Multi-location monitoring script
- `check_versioning.sh`: Single-location status checker
- `check_multi_versioning.sh`: Multi-location status and control script
- `manage_locations.sh`: Location management for multi-location setup

### Setup Scripts
- `setup_file_versioning.sh`: Single-location setup and configuration
- `setup_multi_versioning.sh`: Multi-location setup and initialization

### Configuration Files
- `.versioning_locations`: List of directories for multi-location monitoring
- `.versioningignore`: Patterns of files/directories to ignore during versioning
- `.gitignore`: Git ignore patterns for the project

### Runtime Files (Auto-generated)
- `backups/`: Directory where backups are stored
- `.file_versioning.pid`: PID file for single-location monitoring
- `.multi_versioning.pid`: PID file for multi-location monitoring
- `file_versioning.log`: Single-location activity log
- `multi_versioning.log`: Multi-location activity log

## Backup Format
- Backups are stored in the `backups/` directory within each monitored location
- Naming format: `original_filename_YYYY_MM_DD_HH:MM:SS`
- Example: `document.txt_2025_02_01_14:53:51`
- Each monitored directory maintains its own backup folder


## Troubleshooting

### Common Issues
1. **inotify-tools not found**: Install with `sudo apt-get install inotify-tools`
2. **Permission denied**: Ensure scripts are executable with `chmod +x *.sh`
3. **Process not stopping**: Use `pkill -f versioning` to force stop
4. **Backup directory full**: Use the backup management tools in `run.sh`

### Log Analysis
- Single-location logs: `file_versioning.log`
- Multi-location logs: `multi_versioning.log`
- Use `tail -f <logfile>` for real-time monitoring

## Features
- **Real-time file change monitoring** using inotify
- **Automatic timestamped backups** with format: `filename_YYYY_MM_DD_HH:MM:SS`
- **Single-location versioning** - Monitor current directory and subdirectories
- **Multi-location versioning** - Monitor multiple directories simultaneously
- **Interactive management interface** with color-coded menu system
- **Smart ignore patterns** with `.versioningignore` support
- **Process management** with PID tracking and status monitoring
- **Location management** - Add, remove, list monitored directories
- **Log management** with detailed activity tracking
- **Backup management** with cleanup and organization tools
- **Non-intrusive background operation**
- **Systemd service support** for automatic startup
- **Useful for AI-based code editors** - ensures code is always backed up
- **Cross-platform compatibility** (Linux systems with inotify)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
MIT License - feel free to use and modify as needed.

## Author
[Rahul Dinesh]
