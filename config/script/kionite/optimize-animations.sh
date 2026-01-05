#!/usr/bin/bash
# =============================================================================
# Optimize Animations (Kionite)
# Configures KDE Plasma animations for Speed and Fluidity
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

optimize-animations() {
    log-info "Optimizing KWin Animations..."

    # AnimationDurationFactor:
    # 1.0 = Normal
    # 0.5 = Fast (2x speed) - Recommended for "Fast & Fluid"
    # 0.2-0.3 = Very Fast
    # 0 = Instant
    
    local speed="0.5" # Set to Fast

    log-info "Setting Animation Duration Factor to $speed"
    
    # We use kwriteconfig6 if available (Plasma 6), else kwriteconfig5
    local config_tool="kwriteconfig5"
    if command -v kwriteconfig6 &>/dev/null; then
        config_tool="kwriteconfig6"
    fi

    # Apply to [KDE] group in kdeglobals (Standard location)
    "$config_tool" --file kdeglobals --group KDE --key AnimationDurationFactor "$speed"
    
    # Ensure Compositor Latency is correct for smoothness
    # "High" (ForceSmooth) ensures vsync and less tearing, good for "Fluidity".
    # "Low" reduces input lag but might tear.
    # We stick to High/ForceSmooth for Fluidity.
    "$config_tool" --file kwinrc --group Compositing --key LatencyPolicy "High"

    log-success "Animation settings applied."
    
    # Reload KWin to apply changes
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
