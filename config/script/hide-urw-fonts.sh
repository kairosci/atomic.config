#!/usr/bin/bash
# =============================================================================
# Hide URW35 Fonts
# Hides URW fonts from applications via fontconfig
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly FONTCONFIG_CONTENT='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- Hide URW35 fonts from applications -->
    <selectfont>
        <rejectfont>
            <glob>/usr/share/fonts/urw-base35/*</glob>
        </rejectfont>
    </selectfont>
</fontconfig>'

readonly SYSTEM_CONF="/etc/fonts/conf.d/99-hide-urw-fonts.conf"

# =============================================================================
# Functions
# =============================================================================

hide-urw-fonts-system() {
    log-info "Hiding URW35 fonts (system level)"
    
    if [[ ! -f "$SYSTEM_CONF" ]]; then
        echo "$FONTCONFIG_CONTENT" | tee "$SYSTEM_CONF" > /dev/null
        log-success "System config created"
    else
        log-info "System config already exists"
    fi
}

hide-urw-fonts-user() {
    log-info "Hiding URW35 fonts (user level)"
    
    local user_home
    user_home="$(get-user-home)"
    
    local fontconfig_dir="$user_home/.config/fontconfig/conf.d"
    local user_conf="$fontconfig_dir/99-hide-urw-fonts.conf"
    
    mkdir -p "$fontconfig_dir"
    
    if [[ ! -f "$user_conf" ]]; then
        echo "$FONTCONFIG_CONTENT" > "$user_conf"
        fix-ownership-recursive "$user_home/.config/fontconfig"
        log-success "User config created"
    else
        log-info "User config already exists"
    fi
}

refresh-font-cache() {
    log-info "Refreshing font cache"
    fc-cache -f
    log-success "Font cache refreshed"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    ensure-root
    hide-urw-fonts-system
    hide-urw-fonts-user
    refresh-font-cache
}

main "$@"
