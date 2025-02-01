# File Versioning System with inotify

A lightweight file versioning system that automatically creates backups of files when they are modified, using Linux's inotify for file system monitoring.

## Features
- Real-time file change monitoring using inotify
- Automatic timestamped backups
- Simple process management with PID tracking
- Easy to use start/stop/status commands
- Non-intrusive background operation

## Prerequisites
- Linux system with inotify-tools installed
```bash
# Ubuntu/Debian
sudo apt-get install inotify-tools

# CentOS/RHEL
sudo yum install inotify-tools
```

## Installation
1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/file-versioning-inotify.git
cd file-versioning-inotify
```

2. Make scripts executable:
```bash
chmod +x file_versioning.sh check_versioning.sh
```

## Usage

### Start File Versioning
```bash
nohup ./file_versioning.sh > file_versioning.log 2>&1 &
```

### Check Status
```bash
./check_versioning.sh
```

### Stop File Versioning
```bash
pkill -f file_versioning.sh
```

## File Organization
- `file_versioning.sh`: Main script that monitors and creates backups
- `check_versioning.sh`: Helper script to check if the versioning system is running
- `backups/`: Directory where backups are stored (created automatically)
- `.file_versioning.pid`: PID file for process management (created automatically)

## Backup Format
- Backups are stored in the `backups` directory
- Naming format: `original_filename_YYYY_MM_DD_HH:MM:SS`
- Example: `document.txt_2025_02_01_14:53:51`

## Configuration
Edit `file_versioning.sh` to customize:
- `WATCH_DIR`: Directory to monitor (default: script location)
- `BACKUP_DIR`: Directory for storing backups (default: backups/ subdirectory)

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
MIT License - feel free to use and modify as needed.

## Author
[Your Name]
