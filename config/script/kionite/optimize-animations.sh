#!/usr/bin/bash
# =============================================================================
# Optimize Animations (Kionite)
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

optimize-animations() {
    log-info "Optimizing KWin Animations..."

    # AnimationDurationFactor: 0.5 = Fast (2x speed)
    local speed="0.5"

    log-info "Setting Animation Duration Factor to $speed"
    
    local config_tool="kwriteconfig5"
    if command -v kwriteconfig6 &>/dev/null; then
        config_tool="kwriteconfig6"
    fi

    "$config_tool" --file kdeglobals --group KDE --key AnimationDurationFactor "$speed"
    
    # "High" (ForceSmooth) ensures vsync and less tearing
    "$config_tool" --file kwinrc --group Compositing --key LatencyPolicy "High"

    log-success "Animation settings applied."
    
    log-info "Reloading KWin..."
    if command -v qdbus6 &>/dev/null; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    elif command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    elif command -v qdbus-qt5 &>/dev/null; then
        qdbus-qt5 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
}

main() {
    ensure-user
    optimize-animations
}

main "$@"
