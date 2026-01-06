#!/usr/bin/bash

# Set Adwaita Fonts
# Sets Adwaita Sans and Adwaita Mono as default system fonts.


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"


# Function: set-gnome-fonts
# Description:
#   Applies Adwaita font settings for GNOME Desktop using dconf.

set-gnome-fonts() {
    log-info "Applying Adwaita fonts for GNOME..."
    
    # Interface Text
    dconf write /org/gnome/desktop/interface/font-name "'Adwaita Sans 11'"
    # Document Text (Cantarell is often default, but Adwaita Sans is consistent)
    dconf write /org/gnome/desktop/interface/document-font-name "'Adwaita Sans 11'"
    # Monospace Text
    dconf write /org/gnome/desktop/interface/monospace-font-name "'Adwaita Mono 11'"
    # Legacy Window Titles
    dconf write /org/gnome/desktop/wm/preferences/titlebar-font "'Adwaita Sans Bold 11'"
    
    log-success "GNOME fonts set to Adwaita."
}


# Function: set-kde-fonts
# Description:
#   Applies Adwaita font settings for KDE Plasma using kwriteconfig.

set-kde-fonts() {
    log-info "Applying Adwaita fonts for KDE..."
    
    # KDE font format: "Family,Size,Style,Weight,..."
    # Adwaita Sans
    local font_general="Adwaita Sans,10,-1,5,50,0,0,0,0,0"
    local font_bold="Adwaita Sans,10,-1,5,75,0,0,0,0,0"
    local font_small="Adwaita Sans,8,-1,5,50,0,0,0,0,0"
    local font_mono="Adwaita Mono,10,-1,5,50,0,0,0,0,0"
    
    local config_tool="kwriteconfig5"
    if command -v kwriteconfig6 &>/dev/null; then
        config_tool="kwriteconfig6"
    fi

    # Helper to clean up repeated calls
    set-k-font() {
        "$config_tool" --file kdeglobals --group "$1" --key "$2" "$3"
    }

    set-k-font "General" "font" "$font_general"
    set-k-font "General" "menuFont" "$font_general"
    set-k-font "General" "smallestReadableFont" "$font_small"
    set-k-font "General" "toolBarFont" "$font_general"
    set-k-font "WM" "activeFont" "$font_bold"
    set-k-font "General" "fixed" "$font_mono"
    
    log-success "KDE fonts set to Adwaita."
}

main() {
    ensure-user
    
    local distro
    distro="$(detect-distro)"
    
    case "$distro" in
        silverblue)
            set-gnome-fonts
            ;;
        kionite)
            set-kde-fonts
            ;;
        *)
            log-warn "Unknown distro: $distro. Fonts not applied."
            ;;
    esac
}

main "$@"
