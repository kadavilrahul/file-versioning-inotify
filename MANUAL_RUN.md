### Option 1: Single-Location Setup
For monitoring a single directory:

1. Run the single-location setup:
```bash
bash setup_file_versioning.sh
```

2. Start monitoring:
```bash
nohup bash file_versioning.sh > file_versioning.log 2>&1 &
```

3. Check status:
```bash
bash check_versioning.sh
```

### Option 2: Multi-Location Setup
For monitoring multiple directories simultaneously:

1. Run the multi-location setup:
```bash
bash setup_multi_versioning.sh
```

2. Add directories to monitor:
```bash
./manage_locations.sh add /path/to/directory1
./manage_locations.sh add /path/to/directory2
```

3. Start multi-location monitoring:
```bash
./check_multi_versioning.sh start
```

4. Check status:
```bash
./check_multi_versioning.sh status
```

## Usage

### Interactive Management (Recommended)
Launch the comprehensive management interface:
```bash
./run.sh
```

### Single-Location Commands
1. **Start monitoring** (current directory and subdirectories):
```bash
nohup bash file_versioning.sh > file_versioning.log 2>&1 &
```

2. **Check status**:
```bash
bash check_versioning.sh
```

3. **Stop monitoring**:
```bash
pkill -f file_versioning.sh
```

### Multi-Location Commands
1. **Manage locations**:
```bash
./manage_locations.sh add /path/to/directory     # Add directory
./manage_locations.sh remove /path/to/directory  # Remove directory
./manage_locations.sh list                       # List all locations
./manage_locations.sh clear                      # Clear all locations
```

2. **Control multi-location monitoring**:
```bash
./check_multi_versioning.sh start     # Start monitoring all locations
./check_multi_versioning.sh stop      # Stop monitoring
./check_multi_versioning.sh status    # Check status
./check_multi_versioning.sh restart   # Restart monitoring
./check_multi_versioning.sh locations # Show monitored locations
```

## Systemd Service Management

1. Enable the service to start on boot:
```bash
sudo systemctl enable file_versioning.service
```

2. Start the service:
```bash
sudo systemctl start file_versioning.service
```

3. Stop the service:
```bash
sudo systemctl stop file_versioning.service
```

4. Check the service status:
```bash
sudo systemctl status file_versioning.service
```

## Configuration

### Ignore Patterns (.versioningignore)
The system automatically creates a `.versioningignore` file in each monitored directory with sensible defaults:

```bash
# System and temporary files
.DS_Store
*.tmp
*.temp
*.swp
*~
*cache.db*
.aider*

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
