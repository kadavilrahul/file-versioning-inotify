# AI-Enhanced File Versioning System

A comprehensive file versioning system with **AI code editor protection** that automatically creates backups when files are modified. Features enhanced monitoring, smart backup organization, and snapshot/restore capabilities specifically designed for AI editing sessions.

## Table of Contents
- [Quick Start](#quick-start)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [AI Protection Features](#ai-protection-features)
- [File Organization](#file-organization)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Interactive Interface (Recommended)
```bash
git clone https://github.com/kadavilrahul/file-versioning-inotify.git
```
```bash
cd file-versioning-inotify

```bash
bash run.sh
```

### Direct Usage
```bash
# Start AI-enhanced monitoring
./file_versioning.sh

# Create initial snapshot
./ai_snapshot_manager.sh initial

# Create pre-AI session snapshot
./ai_snapshot_manager.sh session
```

## Features

### AI Code Editor Protection
- **Auto-detects AI editors** (aider, cursor, copilot, continue, codeium)
- **Smart backup organization** (AI sessions vs normal editing)
- **Enhanced event monitoring** (CREATE, MODIFY, CLOSE_WRITE, MOVED_TO)
- **Content deduplication** (avoids identical backups)
- **Session snapshots** for easy rollback

### Organized Backup Structure
```
backups/
├── regular/        # Normal editing backups
├── ai-sessions/    # AI editor session backups
└── snapshots/      # Full system snapshots
```

### Core Features
- **Real-time monitoring** using Linux inotify
- **Multi-location support** - Monitor multiple directories
- **Interactive management** - Comprehensive menu system
- **Systemd integration** - Auto-start on boot
- **Smart ignore patterns** - Configurable file exclusions

## Installation

### Prerequisites
- Linux system with inotify support
- `inotify-tools` package

### Setup Options

#### Option 1: Single-Location Setup
```bash
# Install dependencies
sudo apt-get install inotify-tools

# Setup single location monitoring
./setup_file_versioning.sh

# Start monitoring
nohup ./file_versioning.sh > file_versioning.log 2>&1 &

# Check status
./check_versioning.sh
```

#### Option 2: Multi-Location Setup
```bash
# Setup multi-location monitoring
./setup_multi_versioning.sh

# Add directories to monitor
./manage_locations.sh add /path/to/directory1
./manage_locations.sh add /path/to/directory2

# Start monitoring
./check_multi_versioning.sh start

# Check status
./check_multi_versioning.sh status
```

## Usage

### Interactive Management (Recommended)
```bash
./run.sh
```

**Main Menu Options:**
- **Monitoring Controls** (1-8): Start/stop/restart single/multi-location monitoring
- **Location Management**: Add, remove, list monitored directories  
- **Backup Management**: View, count, clean, and search backup files
- **AI Features**: Snapshot management and backup organization
- **System Setup**: Configure system, check prerequisites, service management

### Command Line Usage

#### Single-Location Commands
```bash
# Start monitoring current directory
./file_versioning.sh

# Check status
./check_versioning.sh

# Stop monitoring
./check_versioning.sh stop

# Restart monitoring
./check_versioning.sh restart
```

#### Multi-Location Commands
```bash
# Manage locations
./manage_locations.sh add /path/to/directory     # Add directory
./manage_locations.sh remove /path/to/directory  # Remove directory
./manage_locations.sh list                       # List all locations
./manage_locations.sh clear                      # Clear all locations

# Control monitoring
./check_multi_versioning.sh start     # Start monitoring all locations
./check_multi_versioning.sh stop      # Stop monitoring
./check_multi_versioning.sh status    # Check status
./check_multi_versioning.sh restart   # Restart monitoring
```

#### Systemd Service Management
```bash
# Enable auto-start on boot
sudo systemctl enable file_versioning.service

# Start/stop service
sudo systemctl start file_versioning.service
sudo systemctl stop file_versioning.service

# Check service status
sudo systemctl status file_versioning.service
```

## AI Protection Features

### Snapshot Management
```bash
# Create initial backup of all existing files
./ai_snapshot_manager.sh initial

# Create pre-AI editing session snapshot
./ai_snapshot_manager.sh session

# List available snapshots
./ai_snapshot_manager.sh list

# Restore from specific snapshot
./ai_snapshot_manager.sh restore snapshots/SESSION_2025_01_15_14:30:25

# View snapshot details
./ai_snapshot_manager.sh list
```

### AI Detection & Smart Backups
- **Automatic detection** of AI editor processes (aider, cursor, copilot, etc.)
- **High-frequency backups** during AI sessions
- **Event-tagged backups**: `filename_AI_CREATE_2025_01_15_14:30:25`
- **Session-specific organization** for easy tracking
- **Content deduplication** to avoid identical backups

### Backup Organization
- **AI Session Backups**: Stored in `backups/ai-sessions/` with `AI_` prefix
- **Normal Backups**: Stored in `backups/regular/` with `NORMAL_` prefix
- **Snapshots**: Full directory snapshots in `backups/snapshots/`

## File Organization

### Core Scripts
| Script | Purpose |
|--------|---------|
| `run.sh` | Interactive management interface with color-coded menus |
| `file_versioning.sh` | AI-enhanced single-location monitoring |
| `ai_snapshot_manager.sh` | Snapshot creation and restore capabilities |
| `multi_location_versioning.sh` | Multi-location monitoring script |
| `check_versioning.sh` | Single-location status and control |
| `check_multi_versioning.sh` | Multi-location status and control |
| `manage_locations.sh` | Location management for multi-location setup |

### Setup Scripts
| Script | Purpose |
|--------|---------|
| `setup_file_versioning.sh` | Single-location setup and configuration |
| `setup_multi_versioning.sh` | Multi-location setup and initialization |

### Configuration Files
| File | Purpose |
|------|---------|
| `.versioningignore` | Patterns of files/directories to ignore |
| `.versioning_locations` | List of directories for multi-location monitoring |
| `file_versioning.log` | Single-location activity log |
| `multi_versioning.log` | Multi-location activity log |

### Runtime Files (Auto-generated)
- `backups/regular/` - Normal editing backups
- `backups/ai-sessions/` - AI editor session backups  
- `backups/snapshots/` - Full system snapshots
- `.file_versioning.pid` - Single-location PID file
- `.multi_versioning.pid` - Multi-location PID file

## Configuration

### Ignore Patterns (.versioningignore)
The system automatically creates enhanced ignore patterns:

```bash
# AI Editor specific files
.cursor/
.copilot/
.aider*
.continue/
.ai-session/
*.ai-backup

# System and temporary files
.DS_Store
*.tmp
*.temp
*.swp
*~
*cache.db*

# Build and dependency directories
node_modules/
build/
dist/
target/
__pycache__/
*.pyc

# IDE directories
.idea/
.vscode/
.settings/

# Log files and version control
*.log
logs/
.git/
.svn/
backups/
```

### Backup Format
- **Regular backups**: `filename_NORMAL_SAVE_2025_01_15_14:30:25`
- **AI session backups**: `filename_AI_CREATE_2025_01_15_14:30:25`
- **Event types**: CREATE, MODIFY, SAVE, MOVE
- **Snapshots**: Full directory structure preserved with manifest

## Troubleshooting

### Common Issues
| Issue | Solution |
|-------|----------|
| `inotify-tools not found` | Install: `sudo apt-get install inotify-tools` |
| `Permission denied` | Make executable: `chmod +x *.sh` |
| `Process not stopping` | Force stop: `pkill -f versioning` |
| `No AI detection` | Check if AI editor process is running with `ps aux \| grep -E "(aider\|cursor\|copilot)"` |
| `Backup directory full` | Use cleanup tools in `run.sh` menu option 13 |
| `Multi-location won't start` | Ensure `.versioning_locations` exists with valid paths |
| `Empty locations file` | Add directories using `./manage_locations.sh add <path>` |

### Log Analysis
```bash
# View recent activity
tail -f file_versioning.log

# Check AI vs normal backup activity
grep "\[AI\]" file_versioning.log
grep "\[NORMAL\]" file_versioning.log

# Monitor real-time changes
tail -f file_versioning.log | grep "Backup created"

# View multi-location logs
tail -f multi_versioning.log
```

### Performance Tips
- Use `.versioningignore` to exclude large directories (node_modules, build folders)
- Regular cleanup of old backups using menu option 13
- Monitor disk usage with backup management tools
- Use snapshots for major checkpoints rather than continuous backup

### Service Debugging
```bash
# Check if service is enabled
sudo systemctl is-enabled file_versioning.service

# View service logs
sudo journalctl -u file_versioning.service -f

# Restart service
sudo systemctl restart file_versioning.service
```

## Advanced Usage

### Custom AI Editor Integration
Add custom AI editor detection by modifying the `detect_ai_activity()` function in `file_versioning.sh`:

```bash
# Add your custom AI editor
pgrep -f "your_ai_editor" >/dev/null 2>&1 && ai_processes="$ai_processes your_ai_editor"
```

### Backup Retention Policies
- **Automatic cleanup**: Old backups (7+ days) via menu option 13
- **Manual cleanup**: `find backups/ -type f -mtime +N -delete`
- **Snapshot management**: Keep important session snapshots, clean others

### Integration with Version Control
The system works alongside Git and other VCS:
- Backups are independent of Git commits
- `.versioningignore` excludes `.git/` directory
- Useful for tracking changes between commits
- Provides additional safety net for AI-generated changes

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
MIT License - feel free to use and modify as needed.

## Author
[Rahul Dinesh]