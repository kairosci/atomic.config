#!/usr/bin/bash
# =============================================================================
# Set System Theme
# Applies Arc Dark Theme (Solid) and Papirus Icons
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

apply-settings() {
    log-info "Applying Theme (Arc-Dark) and Icons (Papirus)..."
    
    # GNOME / Silverblue
    if [[ "$(detect-distro)" == "silverblue" ]]; then
        # Theme: Arc-Dark (Official RPM)
        # Icons: Papirus-Dark (RPM)
        
        dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        dconf write /org/gnome/desktop/interface/gtk-theme "'Arc-Dark'"
        dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
        dconf write /org/gnome/desktop/wm/preferences/theme "'Arc-Dark'"
        
        # Link GTK4 config from Arc-Dark
        if [[ -d "/usr/share/themes/Arc-Dark/gtk-4.0" ]]; then
            mkdir -p "$HOME/.config/gtk-4.0"
            ln -sf "/usr/share/themes/Arc-Dark/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
            ln -sf "/usr/share/themes/Arc-Dark/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
            ln -sf "/usr/share/themes/Arc-Dark/gtk-4.0/assets" "$HOME/.config/gtk-4.0/assets"
        fi
    fi
    
    # KDE / Kionite
    if [[ "$(detect-distro)" == "kionite" ]]; then
       local config_tool="kwriteconfig5"
       command -v kwriteconfig6 &>/dev/null && config_tool="kwriteconfig6"
       
       "$config_tool" --file kdeglobals --group Icons --key Theme "Papirus-Dark"
       # Arc usually provides a KDE Global Theme or Color Scheme if installed via kionite packages
       # Otherwise we use BreezeDark as base or ArcDark if available
       "$config_tool" --file kdeglobals --group General --key ColorScheme "ArcDark"
       
       # Force GTK3 override
       mkdir -p "$HOME/.config/gtk-3.0"
       {
           echo "[Settings]"
           echo "gtk-theme-name=Arc-Dark"
           echo "gtk-icon-theme-name=Papirus-Dark"
           echo "gtk-application-prefer-dark-theme=1"
       } > "$HOME/.config/gtk-3.0/settings.ini"
    fi
    
    log-success "Tech/Arc-Dark theme settings applied."
}

main() {
    ensure-user
    apply-settings
}

main "$@"
