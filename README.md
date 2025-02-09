# File Versioning System with inotify

A lightweight file versioning system that automatically creates backups of files when they are modified, using Linux's inotify for file system monitoring.

## Features
- Real-time file change monitoring using inotify
- Automatic timestamped backups
- Simple process management with PID tracking
- Easy to use start/stop/status commands
- Non-intrusive background operation
- Useful in working with AI-based code editors
- It makes sure that your code is always backed up after code editor makes changes

## Prerequisites
- Linux system with inotify-tools installed
# Ubuntu/Debian
```bash
sudo apt-get install inotify-tools
```
# CentOS/RHEL
```bash
sudo yum install inotify-tools
```

## Installation

### Option 1: Quick Setup (Recommended)
For quick setup in your target directory:

1. Download the setup script
```bash
git clone https://github.com/kadavilrahul/file-versioning-inotify.git file-versioning-inotify && cp file-versioning-inotify/{setup_file_versioning.sh,file_versioning.sh,check_versioning.sh} . && rm -rf file-versioning-inotify
```

2. Run the setup script
```bash
bash setup_file_versioning.sh && nohup bash file_versioning.sh > file_versioning.log 2>&1 &
```

- Check Status:
```bash
bash check_versioning.sh
```

- Stop File Versioning:
```bash
pkill -f file_versioning.sh
```

This script will:
1. Clone the repository (if needed)
2. Copy the necessary scripts to your current directory
3. Make them executable
4. Clean up the cloned repository

### Option 2: Manual Installation
1. Navigate to the directory you want to monitor:
```bash
cd /path/to/your/directory  # Replace with the directory you want to monitor
```

2. Clone the repository:
```bash
git clone https://github.com/kadavilrahul/file-versioning-inotify.git
```

3. Copy the scripts to your target directory:
```bash
cp file-versioning-inotify/file_versioning.sh file-versioning-inotify/check_versioning.sh .
rm -rf file-versioning-inotify
```

## Usage

1. Start File Versioning (will monitor current directory):
```bash
nohup bash file_versioning.sh > file_versioning.log 2>&1 &
```

2. Check Status:
```bash
bash check_versioning.sh
```

3. Stop File Versioning:
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
[Rahul Dinesh]
