#!/usr/bin/bash
set -e

# Function to check if running as root
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

# Menu Display
show_menu() {
    clear
    echo "Kionite Manager"
    echo "1. Optimize"
    echo "2. Update"
    echo "3. Delete Folder"
    echo "4. Exit"
}

main() {
    check_sudo
    chmod +x config/index.sh config/script/*.sh utils/update_system.sh utils/delete_folder.sh

    while true; do
        show_menu
        read -p "> " choice
        
        clear
        case $choice in
            1)
                ./config/index.sh
                ;;
            2)
                ./utils/update_system.sh
                ;;
            3)
                ./utils/delete_folder.sh
                ;;
            4)
                exit 0
                ;;
            *)
                ;;
        esac
        
        read -p "..."
    done
}

main
