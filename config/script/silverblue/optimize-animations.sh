#!/usr/bin/bash
# =============================================================================
# Optimize Animations (Silverblue)
# Configures GNOME Shell animations for Speed and Fluidity
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

optimize-animations() {
    log-info "Optimizing GNOME Animations..."

    # Ensure animations are enabled globally
    gsettings set org.gnome.desktop.interface enable-animations true
    
    # Just Perfection Animation Speed
    # 1 = Very Slow
    # 2 = Slow
    # 3 = Standard
    # 4 = Fast
    # 5 = Very Fast
    # 6 = Instant
    
    # We choose 4 (Fast) for "Fluid & Fast"
    local speed=4
    
    # Check if Just Perfection schema path exists (via dconf) or just write it
    # We assume the extension is installed via set-extensions.sh
    
    log-info "Setting Just Perfection Animation Speed to $speed (Fast)"
    dconf write /org/gnome/shell/extensions/just-perfection/animation "$speed"

    # Additional fluid settings
    # Center new windows (feels more predictable/faster)
    gsettings set org.gnome.mutter center-new-windows true
    
    log-success "GNOME animation settings applied."
}

main() {
    ensure-user
    optimize-animations
}

main "$@"
