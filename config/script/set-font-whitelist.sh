#!/usr/bin/bash
# =============================================================================
# Set Font Whitelist
# Hides all non-essential system fonts (bloat) from the user interface.
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

readonly CONFIG_FILE="$HOME/.config/fontconfig/conf.d/99-whitelist.conf"

create-whitelist-config() {
    log-info "Creating generic font blocklist (whitelist-only approach)..."
    
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    cat > "$CONFIG_FILE" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <description>Reject all system fonts except Adwaita, Apple Emoji and User fonts</description>

  <!-- Reject everything in /usr/share/fonts by default -->
  <selectfont>
    <rejectfont>
        <glob>/usr/share/fonts/*</glob>
    </rejectfont>
  </selectfont>

  <!-- Re-enable (Accept) specific essential fonts -->
  <selectfont>
    <acceptfont>
        <!-- User installed fonts ( ~/.local/share/fonts ) -->
        <glob>~/.local/share/fonts/*</glob>
        <glob>/home/*/.local/share/fonts/*</glob>
        
        <!-- Adwaita Fonts (often linked or in system) -->
        <pattern>
            <patelt name="family"><string>Adwaita</string></patelt>
        </pattern>
        <pattern>
            <patelt name="family"><string>Adwaita Sans</string></patelt>
        </pattern>
        <pattern>
            <patelt name="family"><string>Adwaita Mono</string></patelt>
        </pattern>
        
        <!-- Apple Color Emoji (User installed but safer to explicit) -->
        <pattern>
            <patelt name="family"><string>Apple Color Emoji</string></patelt>
        </pattern>
        
        <!-- Cantarell (GNOME default fallback, sometimes needed) -->
        <pattern>
            <patelt name="family"><string>Cantarell</string></patelt>
        </pattern>
    </acceptfont>
  </selectfont>

</fontconfig>
EOF

    log-success "Font whitelist configured at $CONFIG_FILE"
}

update-cache() {
    log-info "Updating font cache..."
    if command -v fc-cache &>/dev/null; then
        fc-cache -f
    fi
}

main() {
    ensure-user
    create-whitelist-config
    update-cache
    log-success "Only whitelisted fonts are now visible."
}

main "$@"
