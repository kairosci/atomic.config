#!/usr/bin/bash
# =============================================================================
# Set Yaru Theme
# Applies Yaru theme as default for GNOME on Silverblue
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly GTK_THEME="Yaru"
readonly ICON_THEME="Yaru"
readonly CURSOR_THEME="Yaru"
readonly SOUND_THEME="Yaru"

# =============================================================================
# Functions
# =============================================================================

apply-yaru-theme() {
    log-info "Applying Yaru theme for GNOME"
    
    local real_user
    real_user="$(get-real-user)"
    
    # Set GTK theme
    log-info "Setting GTK theme to $GTK_THEME"
    sudo -u "$real_user" dconf write /org/gnome/desktop/interface/gtk-theme "'$GTK_THEME'"
    
    # Set icon theme
    log-info "Setting icon theme to $ICON_THEME"
    sudo -u "$real_user" dconf write /org/gnome/desktop/interface/icon-theme "'$ICON_THEME'"
    
    # Set cursor theme
    log-info "Setting cursor theme to $CURSOR_THEME"
    sudo -u "$real_user" dconf write /org/gnome/desktop/interface/cursor-theme "'$CURSOR_THEME'"
    
    # Set sound theme
    log-info "Setting sound theme to $SOUND_THEME"
    sudo -u "$real_user" dconf write /org/gnome/desktop/sound/theme-name "'$SOUND_THEME'"
    
    # Set color scheme to prefer dark
    log-info "Setting dark color scheme"
    sudo -u "$real_user" dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    
    log-success "Yaru theme applied successfully"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    require-root
    apply-yaru-theme
}

main "$@"
