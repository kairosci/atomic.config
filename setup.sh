#!/usr/bin/bash
# =============================================================================
# Kionite Setup Manager
# Interactive menu for system management
# =============================================================================

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Menu Functions
# =============================================================================

show-menu() {
    clear
    echo "================================"
    echo "       Kionite Manager"
    echo "================================"
    echo ""
    echo "  1. Optimize System"
    echo "  2. Update System"
    echo "  3. Delete Folder"
    echo "  4. Exit"
    echo ""
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    require-root
    
    # Set executable permissions
    chmod +x "$SCRIPT_DIR/config/index.sh" \
             "$SCRIPT_DIR/config/script/"*.sh \
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
                log-info "Goodbye!"
                exit 0
                ;;
            *)
                log-warn "Invalid option: $choice"
                ;;
        esac
        
        echo ""
        read -rp "Press Enter to continue..."
    done
}

main "$@"
