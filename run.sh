#!/bin/bash

# Interactive File Versioning Management Script
# Provides a menu-driven interface for all versioning operations

# Installation commands for required dependencies:
# Ubuntu/Debian
# sudo apt-get install inotify-tools
# CentOS/RHEL
# sudo yum install inotify-tools

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored text
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}

# Function to print header
print_header() {
    clear
    print_color $CYAN "=================================================="
    print_color $CYAN "    File Versioning Management System"
    print_color $CYAN "    $(TZ='Asia/Kolkata' date '+%Y-%m-%d %H:%M:%S IST')"
    print_color $CYAN "=================================================="
    echo ""
}

# Function to show current status
show_status() {
    print_color $YELLOW "Current Status:"
    echo ""
    
    # Single location status
    print_color $BLUE "Single Location Versioning:"
    ./check_versioning.sh
    echo ""
    
    # Multi-location status
    print_color $BLUE "Multi-Location Versioning:"
    ./check_multi_versioning.sh status
    echo ""
}

# Function to show main menu
show_main_menu() {
    print_header
    
    print_color $GREEN "File Versioning Management Menu:"
    echo ""
    echo "MONITORING CONTROLS:"
    echo "1.  Start Single Location Monitoring    - Monitor current directory for file changes"
    echo "2.  Start Multi-Location Monitoring     - Monitor multiple directories simultaneously"
    echo "3.  Stop All Monitoring                 - Stop all active file monitoring processes"
    echo "4.  Restart All Monitoring              - Restart both single and multi-location monitoring"
    echo ""
    echo "LOCATION MANAGEMENT:"
    echo "5.  Add Location                        - Add directory to multi-location monitoring"
    echo "6.  Remove Location                     - Remove directory from multi-location monitoring"
    echo "7.  List All Locations                  - Show all monitored directories"
    echo "8.  Clear All Locations                 - Remove all directories from monitoring"
    echo ""
    echo "STATUS & MONITORING:"
    echo "9.  View Current Status                 - Check all monitoring processes status"
    echo "10. View Recent Activity                - Show recent file changes from logs"
    echo "11. View Detailed Logs                  - Show detailed activity from all logs"
    echo "12. Clear All Logs                      - Remove all log files"
    echo ""
    echo "BACKUP MANAGEMENT:"
    echo "13. View Backup Directory               - List all backup files"
    echo "14. Count Backup Files                  - Show total backup count"
    echo "15. Show Backup Disk Usage              - Display backup storage usage"
    echo "16. Find Recent Backups                 - Show backups from last hour"
    echo "17. Find Backups by Pattern             - Search backups by filename"
    echo "18. Clean Old Backups                   - Remove backups older than 7 days"
    echo ""
    echo "SYSTEM SETUP:"
    echo "19. Run Single Location Setup           - Configure single location monitoring"
    echo "20. Run Multi-Location Setup            - Configure multi-location monitoring"
    echo "21. Check Prerequisites                 - Verify system dependencies"
    echo "22. Make Scripts Executable             - Fix script permissions"
    echo "23. View Configuration Files            - Show config and PID files"
    echo ""
    echo "0.  Exit"
    echo ""
    
    read -p $'\033[1;33mEnter your choice [0-23]: \033[0m' choice
}


# Function for location management menu
location_management_menu() {
    while true; do
        print_header
        print_color $GREEN "Location Management Menu:"
        echo "1. Add location"
        echo "2. Remove location"
        echo "3. List all locations"
        echo "4. Clear all locations"
        echo "0. Back to main menu"
        echo ""
        
        read -p $'\033[1;33mEnter your choice [0-4]: \033[0m' choice
        
        case $choice in
            1)
                print_color $GREEN "Add Location:"
                echo "Enter the full path of the directory to monitor:"
                read -r path
                if [ -n "$path" ]; then
                    ./manage_locations.sh add "$path"
                else
                    print_color $RED "No path provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $RED "Remove Location:"
                echo "Enter the full path of the directory to remove:"
                read -r path
                if [ -n "$path" ]; then
                    ./manage_locations.sh remove "$path"
                else
                    print_color $RED "No path provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $BLUE "All Monitored Locations:"
                echo ""
                ./manage_locations.sh list
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $RED "Clear All Locations:"
                echo "Are you sure you want to clear all monitored locations? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    ./manage_locations.sh clear
                    print_color $GREEN "All locations cleared."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Function for status and logs menu
status_and_logs_menu() {
    while true; do
        print_header
        print_color $GREEN "Status & Logs Menu:"
        echo ""
        echo "1. Check Current Status              - View all monitoring processes status"
        echo "2. View Recent Activity (20 lines)  - Show recent file changes from all logs"
        echo "3. View Detailed Logs (50 lines)    - Show detailed activity from all logs"
        echo "4. Show Monitored Locations          - List all directories being monitored"
        echo "5. Clear All Logs                    - Remove all log files"
        echo "0. Back to main menu"
        echo ""
        read -p $'\033[1;33mEnter your choice [0-5]: \033[0m' choice
        
        case $choice in
            1)
                print_header
                show_status
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $BLUE "Recent Activity (last 20 lines):"
                echo ""
                print_color $YELLOW "=== Single Location Log ==="
                tail -10 file_versioning.log 2>/dev/null || echo "No single location log found"
                echo ""
                print_color $YELLOW "=== Multi-Location Log ==="
                tail -10 multi_versioning.log 2>/dev/null || echo "No multi-location log found"
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $BLUE "Detailed Activity (last 50 lines):"
                echo ""
                print_color $YELLOW "=== Single Location Log ==="
                tail -25 file_versioning.log 2>/dev/null || echo "No single location log found"
                echo ""
                print_color $YELLOW "=== Multi-Location Log ==="
                tail -25 multi_versioning.log 2>/dev/null || echo "No multi-location log found"
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $BLUE "Monitored Locations:"
                echo ""
                print_color $YELLOW "Single Location:"
                if [ -f ".file_versioning.pid" ]; then
                    echo "  Current directory: $(pwd)"
                else
                    echo "  Not active"
                fi
                echo ""
                print_color $YELLOW "Multi-Location:"
                ./manage_locations.sh list
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $RED "Clear All Logs:"
                echo "Are you sure you want to clear all log files? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    > file_versioning.log 2>/dev/null
                    > multi_versioning.log 2>/dev/null
                    print_color $GREEN "Log files cleared."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Function for setup menu
setup_menu() {
    while true; do
        print_header
        print_color $GREEN "Setup & Configuration Menu:"
        echo ""
        echo "1. Run single location setup"
        echo "2. Run multi-location setup"
        echo "3. Check prerequisites"
        echo "4. Make all scripts executable"
        echo "5. View configuration files"
        echo "0. Back to main menu"
        echo ""
        read -p $'\033[1;33mEnter your choice [0-5]: \033[0m' choice
        
        case $choice in
            1)
                print_color $GREEN "Running single location setup..."
                ./setup_file_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $GREEN "Running multi-location setup..."
                ./setup_multi_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $BLUE "Checking prerequisites..."
                echo ""
                if command -v inotifywait >/dev/null 2>&1; then
                    print_color $GREEN "✅ inotify-tools is installed"
                else
                    print_color $RED "❌ inotify-tools is NOT installed"
                    echo "Install with: sudo apt-get install inotify-tools"
                fi
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $GREEN "Making all scripts executable..."
                chmod +x *.sh
                print_color $GREEN "✅ All scripts are now executable"
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $BLUE "Configuration Files:"
                echo ""
                echo "Single location ignore file:"
                ls -la .versioningignore 2>/dev/null || echo "Not found"
                echo ""
                echo "Multi-location config file:"
                ls -la .versioning_locations 2>/dev/null || echo "Not found"
                echo ""
                echo "PID files:"
                ls -la .*.pid 2>/dev/null || echo "No PID files found"
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Function for backup management menu
backup_menu() {
    while true; do
        print_header
        print_color $GREEN "Backup Management Menu:"
        echo ""
        echo "1. View backup directory contents"
        echo "2. Count backup files"
        echo "3. Show backup disk usage"
        echo "4. Find recent backups (last hour)"
        echo "5. Find backups by filename pattern"
        echo "6. Clean old backups (older than 7 days)"
        echo "0. Back to main menu"
        echo ""
        read -p $'\033[1;33mEnter your choice [0-6]: \033[0m' choice
        
        case $choice in
            1)
                print_color $BLUE "Backup Directory Contents:"
                echo ""
                ls -la backups/ 2>/dev/null || echo "No backup directory found"
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $BLUE "Backup File Count:"
                echo ""
                local count=$(find backups/ -type f 2>/dev/null | wc -l)
                echo "Total backup files: $count"
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $BLUE "Backup Disk Usage:"
                echo ""
                du -sh backups/ 2>/dev/null || echo "No backup directory found"
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $BLUE "Recent Backups (last hour):"
                echo ""
                find backups/ -type f -mmin -60 2>/dev/null || echo "No recent backups found"
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $GREEN "Find Backups by Pattern:"
                echo "Enter filename pattern (e.g., *.txt, script*):"
                read -r pattern
                if [ -n "$pattern" ]; then
                    print_color $BLUE "Matching backups:"
                    find backups/ -name "*${pattern}*" 2>/dev/null || echo "No matching backups found"
                else
                    print_color $RED "No pattern provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                print_color $RED "Clean Old Backups:"
                echo "This will delete backup files older than 7 days."
                echo "Are you sure? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    local count=$(find backups/ -type f -mtime +7 2>/dev/null | wc -l)
                    find backups/ -type f -mtime +7 -delete 2>/dev/null
                    print_color $GREEN "Deleted $count old backup files."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            0)
                break
                ;;
            *)
                print_color $RED "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}


# Main script execution
main() {
    # Check if we're in the right directory
    if [ ! -f "file_versioning.sh" ]; then
        print_color $RED "Error: file_versioning.sh not found in current directory."
        print_color $YELLOW "Please run this script from the file versioning directory."
        exit 1
    fi
    
    # Make sure all scripts are executable
    chmod +x *.sh 2>/dev/null
    
    # Main menu loop
    while true; do
        show_main_menu
        
        case $choice in
            # MONITORING CONTROLS
            1)
                print_color $GREEN "Starting single location monitoring..."
                ./check_versioning.sh start
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $GREEN "Starting multi-location monitoring..."
                ./check_multi_versioning.sh start
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $RED "Stopping all monitoring processes..."
                ./check_versioning.sh stop 2>/dev/null
                ./check_multi_versioning.sh stop 2>/dev/null
                print_color $GREEN "All monitoring stopped."
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $YELLOW "Restarting all monitoring..."
                ./check_versioning.sh stop 2>/dev/null
                ./check_multi_versioning.sh stop 2>/dev/null
                sleep 2
                ./check_versioning.sh start
                ./check_multi_versioning.sh start
                print_color $GREEN "All monitoring restarted."
                read -p "Press Enter to continue..."
                ;;
            
            # LOCATION MANAGEMENT
            5)
                print_color $GREEN "Add Location:"
                echo "Enter the full path of the directory to monitor:"
                read -r path
                if [ -n "$path" ]; then
                    ./manage_locations.sh add "$path"
                else
                    print_color $RED "No path provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                print_color $RED "Remove Location:"
                echo "Enter the full path of the directory to remove:"
                read -r path
                if [ -n "$path" ]; then
                    ./manage_locations.sh remove "$path"
                else
                    print_color $RED "No path provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            7)
                print_color $BLUE "All Monitored Locations:"
                echo ""
                ./manage_locations.sh list
                read -p "Press Enter to continue..."
                ;;
            8)
                print_color $RED "Clear All Locations:"
                echo "Are you sure you want to clear all monitored locations? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    ./manage_locations.sh clear
                    print_color $GREEN "All locations cleared."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            
            # STATUS & MONITORING
            9)
                print_header
                show_status
                read -p "Press Enter to continue..."
                ;;
            10)
                print_color $BLUE "Recent Activity (last 20 lines):"
                echo ""
                print_color $YELLOW "=== Single Location Log ==="
                tail -10 file_versioning.log 2>/dev/null || echo "No single location log found"
                echo ""
                print_color $YELLOW "=== Multi-Location Log ==="
                tail -10 multi_versioning.log 2>/dev/null || echo "No multi-location log found"
                read -p "Press Enter to continue..."
                ;;
            11)
                print_color $BLUE "Detailed Activity (last 50 lines):"
                echo ""
                print_color $YELLOW "=== Single Location Log ==="
                tail -25 file_versioning.log 2>/dev/null || echo "No single location log found"
                echo ""
                print_color $YELLOW "=== Multi-Location Log ==="
                tail -25 multi_versioning.log 2>/dev/null || echo "No multi-location log found"
                read -p "Press Enter to continue..."
                ;;
            12)
                print_color $RED "Clear All Logs:"
                echo "Are you sure you want to clear all log files? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    > file_versioning.log 2>/dev/null
                    > multi_versioning.log 2>/dev/null
                    print_color $GREEN "Log files cleared."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            
            # BACKUP MANAGEMENT
            13)
                print_color $BLUE "Backup Directory Contents:"
                echo ""
                ls -la backups/ 2>/dev/null || echo "No backup directory found"
                read -p "Press Enter to continue..."
                ;;
            14)
                print_color $BLUE "Backup File Count:"
                echo ""
                local count=$(find backups/ -type f 2>/dev/null | wc -l)
                echo "Total backup files: $count"
                read -p "Press Enter to continue..."
                ;;
            15)
                print_color $BLUE "Backup Disk Usage:"
                echo ""
                du -sh backups/ 2>/dev/null || echo "No backup directory found"
                read -p "Press Enter to continue..."
                ;;
            16)
                print_color $BLUE "Recent Backups (last hour):"
                echo ""
                find backups/ -type f -mmin -60 2>/dev/null || echo "No recent backups found"
                read -p "Press Enter to continue..."
                ;;
            17)
                print_color $GREEN "Find Backups by Pattern:"
                echo "Enter filename pattern (e.g., *.txt, script*):"
                read -r pattern
                if [ -n "$pattern" ]; then
                    print_color $BLUE "Matching backups:"
                    find backups/ -name "*${pattern}*" 2>/dev/null || echo "No matching backups found"
                else
                    print_color $RED "No pattern provided."
                fi
                read -p "Press Enter to continue..."
                ;;
            18)
                print_color $RED "Clean Old Backups:"
                echo "This will delete backup files older than 7 days."
                echo "Are you sure? (y/N)"
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    local count=$(find backups/ -type f -mtime +7 2>/dev/null | wc -l)
                    find backups/ -type f -mtime +7 -delete 2>/dev/null
                    print_color $GREEN "Deleted $count old backup files."
                else
                    print_color $YELLOW "Operation cancelled."
                fi
                read -p "Press Enter to continue..."
                ;;
            
            # SYSTEM SETUP
            19)
                print_color $GREEN "Running single location setup..."
                ./setup_file_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            20)
                print_color $GREEN "Running multi-location setup..."
                ./setup_multi_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            21)
                print_color $BLUE "Checking prerequisites..."
                echo ""
                if command -v inotifywait >/dev/null 2>&1; then
                    print_color $GREEN "✅ inotify-tools is installed"
                else
                    print_color $RED "❌ inotify-tools is NOT installed"
                    echo "Install with: sudo apt-get install inotify-tools"
                fi
                read -p "Press Enter to continue..."
                ;;
            22)
                print_color $GREEN "Making all scripts executable..."
                chmod +x *.sh
                print_color $GREEN "✅ All scripts are now executable"
                read -p "Press Enter to continue..."
                ;;
            23)
                print_color $BLUE "Configuration Files:"
                echo ""
                echo "Single location ignore file:"
                ls -la .versioningignore 2>/dev/null || echo "Not found"
                echo ""
                echo "Multi-location config file:"
                ls -la .versioning_locations 2>/dev/null || echo "Not found"
                echo ""
                echo "PID files:"
                ls -la .*.pid 2>/dev/null || echo "No PID files found"
                read -p "Press Enter to continue..."
                ;;
            
            0)
                print_color $GREEN "Goodbye!"
                exit 0
                ;;
            *)
                print_color $RED "Invalid choice. Please try again."
                sleep 1
                ;;
        esac
    done
}

# Run the main function
main