#!/usr/bin/bash

# Optimize Animations (Silverblue)


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

optimize-animations() {
    log-info "Optimizing GNOME Animations for Fluidity..."

    dconf write /org/gnome/desktop/interface/enable-animations true
    
    # Just Perfection: Animation Speed
    # Value: 5 (Very Fast)
    # Rationale: Provides a snappy, almost instant response feel.
    local speed=5
    log-info "Setting Just Perfection Animation Speed to $speed (Very Fast)"
    dconf write /org/gnome/shell/extensions/just-perfection/animation "$speed"

    # Dash to Dock: Animation Duration
    # Value: 0.20s
    # Rationale: Matches the accelerated system animations for consistency.
    if dconf list /org/gnome/shell/extensions/dash-to-dock/ &>/dev/null; then
        log-info "Optimizing Dash to Dock animations..."
        dconf write /org/gnome/shell/extensions/dash-to-dock/animation-time 0.20
    fi
    
    # Blur My Shell: Performance Tuning
    # Rationale: Removing noise and lowering sigma improving rendering speed 
    #            on lower-end hardware or heavily loaded sessions.
    if dconf list /org/gnome/shell/extensions/blur-my-shell/ &>/dev/null; then
        log-info "Tuning Blur My Shell for performance..."
        dconf write /org/gnome/shell/extensions/blur-my-shell/noise-amount 0.0
        dconf write /org/gnome/shell/extensions/blur-my-shell/brightness 1.0
        dconf write /org/gnome/shell/extensions/blur-my-shell/sigma 30
    fi

    dconf write /org/gnome/mutter/center-new-windows true
    
    # Input Fluidity (Tap to Click)
    log-info "Enabling Tap to Click for Touchpads..."
    dconf write /org/gnome/desktop/peripherals/touchpad/tap-to-click true
    
    log-success "GNOME animation and performance settings applied."
}

main() {
    ensure-user
    optimize-animations
}

main "$@"
