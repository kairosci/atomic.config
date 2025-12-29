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
    echo "Starting configuration"
    
    # Navigate to script directory relative to this script
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -d "$SCRIPT_DIR/script" ]; then
        cd "$SCRIPT_DIR/script/"
    else
        echo "Error: 'script' directory not found at $SCRIPT_DIR/script"
        exit 1
    fi

    # Execute scripts
    local scripts=(
        "./hide_grub.sh"
        "./rename_btrfs.sh"
        "./set_flatpak.sh"
        "./disable_emojier.sh"
        "./hide_urw_fonts.sh"
        "./set_rpm.sh"
        "./manage_system.sh"
        "./set_folder_protection.sh"
        "./set_safe_delete.sh"
        "./set_omb.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            echo "Executing $script"
            $script
        else
            echo "Warning: Script $script not found"
        fi
    done
    
    echo "Configuration completed"
}

# Main execution
main() {
    check_sudo
    run_scripts
}

main
