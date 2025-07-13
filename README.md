# File Versioning System with inotify

A comprehensive file versioning system that automatically creates backups of files when they are modified, using Linux's inotify for file system monitoring. Supports both single-location and multi-location monitoring with an interactive management interface.

## Prerequisites
- Linux system

## Installation

### Quick Start with Interactive Interface
1. Clone the repository:
```bash
git clone https://github.com/kadavilrahul/file-versioning-inotify.git && cd file-versioning-inotify
```

2. Launch the interactive management interface:
```bash
bash run.sh
```

The interactive interface provides a unified menu system with 23 organized options:
- **Monitoring Controls** (1-4): Start, stop, restart single/multi-location monitoring
- **Location Management** (5-8): Add, remove, list, clear monitored directories
- **Status & Monitoring** (9-12): View current status, logs, and activity
- **Backup Management** (13-18): View, count, clean, and search backup files
- **System Setup** (19-23): Configure system, check prerequisites, view configuration


## File Organization

### Core Scripts
- `run.sh`: Interactive management interface with color-coded menus
- `file_versioning.sh`: Single-location monitoring script
- `multi_location_versioning.sh`: Multi-location monitoring script
- `check_versioning.sh`: Single-location status checker with start/stop/restart commands
- `check_multi_versioning.sh`: Multi-location status and control script with validation
- `manage_locations.sh`: Location management for multi-location setup

### Setup Scripts
- `setup_file_versioning.sh`: Single-location setup and configuration
- `setup_multi_versioning.sh`: Multi-location setup and initialization

### Configuration Files
- `.versioning_locations`: List of directories for multi-location monitoring (excluded from git)
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
5. **Multi-location won't start**: Ensure `.versioning_locations` file exists and contains valid directory paths
6. **Empty locations file**: Add directories using the location management menu (options 5-8)

### Log Analysis
- Single-location logs: `file_versioning.log`
- Multi-location logs: `multi_versioning.log`
- Use `tail -f <logfile>` for real-time monitoring

## Features
- **Real-time file change monitoring** using inotify
- **Automatic timestamped backups** with format: `filename_YYYY_MM_DD_HH:MM:SS`
- **Single-location versioning** - Monitor current directory and subdirectories
- **Multi-location versioning** - Monitor multiple directories simultaneously
- **Unified interactive interface** with comprehensive 23-option menu system
- **Smart ignore patterns** with `.versioningignore` support
- **Process management** with PID tracking and status monitoring
- **Location management** with validation - Add, remove, list monitored directories
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
