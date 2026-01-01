#!/usr/bin/bash
# =============================================================================
# Kionite Configuration Index
# Main entry point for system configuration
# =============================================================================

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "$SCRIPT_DIR/../lib/common.sh"

# =============================================================================
# Main Functions
# =============================================================================

run-scripts() {
    log-info "Starting Kionite configuration"
    
    local scripts_dir="$SCRIPT_DIR/script"
    
    if [[ ! -d "$scripts_dir" ]]; then
        log-error "Script directory not found: $scripts_dir"
        exit 1
    fi
    
    cd "$scripts_dir"
    
    # Configuration scripts in execution order
    local -a scripts=(
        "./hide-grub.sh"
        "./rename-btrfs.sh"
        "./set-flatpak.sh"
        "./disable-emojier.sh"
        "./hide-urw-fonts.sh"
        "./set-rpm.sh"
        "./set-spotify-pwa.sh"
        "./set-protonmail-pwa.sh"
        "./set-launcher-icon.sh"
        "./manage-system.sh"
        "./set-folder-protection.sh"
        "./set-safe-delete.sh"
        "./set-omb.sh"
        "./set-konsole.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            log-info "Executing: $script"
            "$script"
        else
            log-warn "Script not found: $script"
        fi
    done
    
    log-success "Configuration completed"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    require-root
    run-scripts
}

main "$@"
