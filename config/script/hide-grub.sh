#!/usr/bin/bash
# =============================================================================
# Hide GRUB Menu
# Sets GRUB timeout to 0 for instant boot
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly GRUB_CONFIG="/boot/grub2/grub.cfg"

# =============================================================================
# Main Function
# =============================================================================

hide-grub() {
    log-info "Hiding GRUB menu"
    
    if [[ ! -f "$GRUB_CONFIG" ]]; then
        log-warn "GRUB config not found: $GRUB_CONFIG"
        return 0
    fi
    
    # Backup original
    cp "$GRUB_CONFIG" "${GRUB_CONFIG}.bak"
    
    # Set timeout to 0
    sed -i 's/^set timeout=.*/set timeout=0/' "$GRUB_CONFIG"
    
    # Make read-only to prevent regeneration
    chmod 444 "$GRUB_CONFIG"
    
    log-success "GRUB menu hidden"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    hide-grub
}

main "$@"
