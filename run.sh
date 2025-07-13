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
    
    print_color $GREEN "Main Menu:"
    echo "1.  Single Location Versioning"
    echo "2.  Multi-Location Versioning"
    echo "3.  Location Management"
    echo "4.  View Logs"
    echo "5.  Setup & Configuration"
    echo "6.  Backup Management"
    echo "7.  System Information"
    echo "8.  Check Status"
    echo "0.  Exit"
    echo ""
    
    read -p $'\033[1;33mEnter your choice [0-8]: \033[0m' choice
}

# Function for single location menu
single_location_menu() {
    while true; do
        print_header
        print_color $GREEN "Single Location Versioning Menu:"
        echo "1. Start single location versioning"
        echo "2. Stop single location versioning"
        echo "3. Restart single location versioning"
        echo "4. View single location log"
        echo "5. Check what directory is being monitored"
        echo "6. Check single location status"
        echo "0. Back to main menu"
        echo ""
        
        read -p $'\033[1;33mEnter your choice [0-6]: \033[0m' choice
        
        case $choice in
            1)
                print_color $GREEN "Starting single location versioning..."
                nohup bash file_versioning.sh > file_versioning.log 2>&1 &
                sleep 2
                ./check_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $RED "Stopping single location versioning..."
                pkill -f file_versioning.sh
                sleep 1
                ./check_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $YELLOW "Restarting single location versioning..."
                pkill -f file_versioning.sh
                sleep 2
                nohup bash file_versioning.sh > file_versioning.log 2>&1 &
                sleep 2
                ./check_versioning.sh
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $BLUE "Single Location Log (last 20 lines):"
                echo ""
                tail -20 file_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $BLUE "Monitored Directory:"
                echo "Current directory: $(pwd)"
                echo "Backup directory: $(pwd)/backups"
                read -p "Press Enter to continue..."
                ;;
            6)
                print_color $BLUE "Single Location Status:"
                echo ""
                ./check_versioning.sh
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

# Function for multi-location menu
multi_location_menu() {
    while true; do
        print_header
        print_color $GREEN "Multi-Location Versioning Menu:"
        echo "1. Start multi-location versioning"
        echo "2. Stop multi-location versioning"
        echo "3. Restart multi-location versioning"
        echo "4. View multi-location log"
        echo "5. Show monitored locations"
        echo "6. Check multi-location status"
        echo "0. Back to main menu"
        echo ""
        
        read -p $'\033[1;33mEnter your choice [0-6]: \033[0m' choice
        
        case $choice in
            1)
                print_color $GREEN "Starting multi-location versioning..."
                ./check_multi_versioning.sh start
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $RED "Stopping multi-location versioning..."
                ./check_multi_versioning.sh stop
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $YELLOW "Restarting multi-location versioning..."
                ./check_multi_versioning.sh restart
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $BLUE "Multi-Location Log (last 20 lines):"
                echo ""
                tail -20 multi_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $BLUE "Monitored Locations:"
                echo ""
                ./manage_locations.sh list
                read -p "Press Enter to continue..."
                ;;
            6)
                print_color $BLUE "Multi-Location Status:"
                echo ""
                ./check_multi_versioning.sh status
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

# Function for log viewing menu
log_menu() {
    while true; do
        print_header
        print_color $GREEN "Log Viewing Menu:"
        echo ""
        echo "1. View single location log (last 20 lines)"
        echo "2. View single location log (last 50 lines)"
        echo "3. View multi-location log (last 20 lines)"
        echo "4. View multi-location log (last 50 lines)"
        echo "5. View all log files"
        echo "6. Clear log files"
        echo "0. Back to main menu"
        echo ""
        read -p $'\033[1;33mEnter your choice [0-6]: \033[0m' choice
        
        case $choice in
            1)
                print_color $BLUE "Single Location Log (last 20 lines):"
                echo ""
                tail -20 file_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            2)
                print_color $BLUE "Single Location Log (last 50 lines):"
                echo ""
                tail -50 file_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            3)
                print_color $BLUE "Multi-Location Log (last 20 lines):"
                echo ""
                tail -20 multi_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            4)
                print_color $BLUE "Multi-Location Log (last 50 lines):"
                echo ""
                tail -50 multi_versioning.log 2>/dev/null || echo "No log file found"
                read -p "Press Enter to continue..."
                ;;
            5)
                print_color $BLUE "All Log Files:"
                echo ""
                ls -la *.log 2>/dev/null || echo "No log files found"
                read -p "Press Enter to continue..."
                ;;
            6)
                print_color $RED "Clear Log Files:"
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

# Function for system information menu
system_info_menu() {
    print_header
    print_color $GREEN "System Information:"
    echo ""
    
    print_color $BLUE "Current Directory:"
    pwd
    echo ""
    
    print_color $BLUE "Available Scripts:"
    ls -la *.sh
    echo ""
    
    print_color $BLUE "Running Processes:"
    ps aux | grep -E "(file_versioning|multi.*versioning)" | grep -v grep
    echo ""
    
    print_color $BLUE "Disk Usage:"
    df -h .
    echo ""
    
    print_color $BLUE "System Load:"
    uptime
    echo ""
    
    read -p "Press Enter to continue..."
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
            1)
                single_location_menu
                ;;
            2)
                multi_location_menu
                ;;
            3)
                location_management_menu
                ;;
            4)
                log_menu
                ;;
            5)
                setup_menu
                ;;
            6)
                backup_menu
                ;;
            7)
                system_info_menu
                ;;
            8)
                print_header
                show_status
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