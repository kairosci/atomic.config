#!/usr/bin/bash

# Set Default Wallpapers
# Removes Fedora branding by applying standard desktop wallpapers


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"


# Function: set-gnome-wallpaper
# Description:
#   Sets the default GNOME wallpaper (Blobs) for Silverblue.
#   Changes both light and dark mode variants.

set-gnome-wallpaper() {
    log-info "Setting default GNOME wallpaper..."
    
    local wp_light="file:///usr/share/backgrounds/gnome/blobs-l.svg"
    local wp_dark="file:///usr/share/backgrounds/gnome/blobs-d.svg"
    
    # Verify files exist, otherwise fallback or warn
    if [[ ! -f "/usr/share/backgrounds/gnome/blobs-l.svg" ]]; then
        log-warn "Standard GNOME wallpaper not found. Skipping."
        return
    fi

    dconf write /org/gnome/desktop/background/picture-uri "'$wp_light'"
    dconf write /org/gnome/desktop/background/picture-uri-dark "'$wp_dark'"
    
    # Also set screensaver/lock screen to match
    dconf write /org/gnome/desktop/screensaver/picture-uri "'$wp_light'"
    
    log-success "GNOME wallpaper set to standard Blobs."
}


# Function: set-kde-wallpaper
# Description:
#   Sets the default Plasma wallpaper for Kionite.
#   Uses plasma-apply-wallpaperimage tool if available.

set-kde-wallpaper() {
    log-info "Setting default KDE wallpaper..."
    
    # Standard Plasma 6/5 wallpaper paths often vary. 
    # 'Next' is a common default, or we can look for specific files.
    # We'll try to apply a known nice default if found.
    
    local target_wp=""
    # Honeywave (Plasma 6) or similar
    local potential_bgs=(
        "/usr/share/wallpapers/Next/contents/images/5120x2880.png"
        "/usr/share/wallpapers/Next/contents/images/1920x1080.png"
        "/usr/share/wallpapers/Patak/contents/images/1080x1920.png" 
        "/usr/share/wallpapers/Milky Way/contents/images/5120x2880.png"
    )
    
    for bg in "${potential_bgs[@]}"; do
        if [[ -f "$bg" ]]; then
            target_wp="$bg"
            break
        fi
    done
    
    if [[ -z "$target_wp" ]]; then
        # Fallback: Let's assume 'Next' theme is present and apply via look-and-feel if we can't find specific image
        log-warn "Could not pinpoint a specific standard wallpaper image file."
        return
    fi
    
    log-info "Applying wallpaper: $target_wp"
    
    if command -v plasma-apply-wallpaperimage &>/dev/null; then
        plasma-apply-wallpaperimage "$target_wp"
        log-success "KDE wallpaper set successfully."
    else
        log-warn "plasma-apply-wallpaperimage not found. Wallpaper change skipped."
    fi
}

main() {
    ensure-user
    
    local distro
    distro="$(detect-distro)"
    
    case "$distro" in
        silverblue)
            set-gnome-wallpaper
            ;;
        kionite)
            set-kde-wallpaper
            ;;
    esac
}

main "$@"
