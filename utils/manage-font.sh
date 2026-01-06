#!/usr/bin/bash
# =============================================================================
# Manage Fonts
# Installs fonts from Google Fonts or manages visibility.
# Usage: ./manage-font.sh "Roboto"
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

readonly USER_FONTS_DIR="$HOME/.local/share/fonts"
readonly WHITELIST_CONFIG="$HOME/.config/fontconfig/conf.d/99-whitelist.conf"

check-installed() {
    local font_name="$1"
    if fc-list : family | grep -iq "^${font_name}$"; then
        return 0
    else
        return 1
    fi
}

install-google-font() {
    local font_name="$1"
    log-info "Searching Google Fonts for '$font_name'..."
    
    # Sanitize for URL (replace spaces with +)
    local safe_name="${font_name// /+}"
    local download_url="https://fonts.google.com/download?family=${safe_name}"
    
    local temp_dir
    temp_dir="$(mktemp -d)"
    local zip_file="${temp_dir}/${safe_name}.zip"
    
    # Try to download. Google returns a zip if found, or HTML error if not.
    # We use curl with -f to fail on 404/500, but Google might verify user agent.
    # We follow redirects -L.
    
    if curl -fsSL -o "$zip_file" "$download_url"; then
        # Check if it's actually a zip
        if ! file "$zip_file" | grep -q "Zip archive"; then
            log-error "Font not found on Google Fonts or invalid response."
            rm -rf "$temp_dir"
            return 1
        fi
        
        log-info "Downloading..."
        mkdir -p "$USER_FONTS_DIR/$font_name"
        unzip -boq "$zip_file" -d "$USER_FONTS_DIR/$font_name"
        
        # Cleanup garbage usually in zip
        rm -rf "$USER_FONTS_DIR/$font_name/"*.txt
        
        log-success "Installed $font_name to $USER_FONTS_DIR"
        rm -rf "$temp_dir"
        return 0
    else
        log-error "Failed to download from Google Fonts."
        rm -rf "$temp_dir"
        return 1
    fi
}

main() {
    local font_name="${1:-}"
    
    if [[ -z "$font_name" ]]; then
        echo "Usage: $0 \"Font Name\""
        exit 1
    fi
    
    ensure-user
    
    # 1. Check if visible/installed
    if check-installed "$font_name"; then
        log-success "Font '$font_name' is already active and visible."
        exit 0
    fi
    
    # 2. Not visible. Check if physically present but hidden?
    # Our whitelist logic accepts ~/.local/share/fonts/* by default.
    # So if it's not visible, it's likely not installed or it's a system font we blocked.
    
    
    log-warn "Font '$font_name' not found active."
    
    # 3. Try to install from Google Fonts
    if install-google-font "$font_name"; then
        log-info "Updating font cache..."
        fc-cache -f
        
        if check-installed "$font_name"; then
            log-success "Font '$font_name' is now installed and active."
        else
            log-warn "Font installed but still not detected. You may need to restart applications."
        fi
    else
        log-error "Could not auto-install '$font_name'."
        echo "Tip: You can manually copy .ttf files to '$USER_FONTS_DIR' and they will be auto-whitelisted."
    fi
}

main "$@"
