#!/usr/bin/bash
set -e

# Function to check if running as root
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Run this script with sudo"
        exit 1
    fi
}

# Function to execute configuration scripts
run_scripts() {
    echo "Starting configuration..."
    
    # Navigate to script directory
    if [ -d "script" ]; then
        cd script/
    else
        echo "Error: 'script' directory not found."
        exit 1
    fi

    # Execute scripts
    local scripts=(
        "./hide_grub.sh"
        "./manage_system.sh"
        "./rename_btrfs.sh"
        "./set_flatpak.sh"
        "./set_rpm.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            echo "Executing $script..."
            $script
        else
            echo "Warning: Script $script not found."
        fi
    done
    
    echo "Configuration completed."
}

# Main execution
main() {
    check_sudo
    run_scripts
}

main
