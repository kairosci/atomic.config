#!/usr/bin/bash

# Fedora Atomic Manager
# Interactive menu for system management (Kionite / Silverblue)


set -euo pipefail

# Get script directory
# Get script directory (follow symlinks)
TARGET_FILE="${BASH_SOURCE[0]}"
if [[ -L "$TARGET_FILE" ]]; then
    TARGET_FILE="$(readlink -f "$TARGET_FILE")"
fi
readonly SCRIPT_DIR="$(cd "$(dirname "$TARGET_FILE")" && pwd)"

# Source common library
source "$SCRIPT_DIR/lib/common.sh"


# Menu Functions


show-menu() {
    local distro
    distro="$(detect-distro)"
    
    clear
    clear
    echo "Fedora Atomic Manager [$distro]"
    echo "  1. Optimize System"
    echo "  2. Update System"
    echo "  3. Delete Folder"
    echo "  4. Enable/Disable Folder Protection"
    echo "  5. Switch Distro (Kionite/Silverblue)"
    echo "  6. Exit"
}


# Entry Point


main() {
    # require-root (now handled per-script)
    
    # Set executable permissions
    chmod +x "$SCRIPT_DIR/config/index.sh" \
             "$SCRIPT_DIR/config/script/"*.sh \
             "$SCRIPT_DIR/config/script/kionite/"*.sh \
             "$SCRIPT_DIR/config/script/silverblue/"*.sh \
             "$SCRIPT_DIR/utils/"*.sh \
             "$SCRIPT_DIR/lib/"*.sh 2>/dev/null || true
    
    while true; do
        show-menu
        read -rp "> " choice
        
        clear
        case "$choice" in
            1)
                "$SCRIPT_DIR/config/index.sh"
                ;;
            2)
                "$SCRIPT_DIR/utils/update-system.sh"
                ;;
            3)
                "$SCRIPT_DIR/utils/delete-folder.sh"
                ;;
            4)
                "$SCRIPT_DIR/utils/toggle-folder-protection.sh"
                ;;
            5)
                "$SCRIPT_DIR/utils/switch-distro.sh"
                ;;
            6)
                exit 0
                ;;
            *)
                log-warn "Invalid option: $choice"
                ;;
        esac
        
        read -rp "Press Enter to continue..."
    done
}

main "$@"
