#!/usr/bin/bash

# Set Apple Emojis
# Installs Apple Color Emoji and configures fontconfig to prioritize it.


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

readonly FONT_URL="https://github.com/samuelngs/apple-emoji-linux/releases/latest/download/AppleColorEmoji.ttf"
readonly FONT_DIR="$HOME/.local/share/fonts"
readonly FONT_FILE="$FONT_DIR/AppleColorEmoji.ttf"
readonly FONT_CONFIG_DIR="$HOME/.config/fontconfig/conf.d"
readonly FONT_CONFIG_FILE="$FONT_CONFIG_DIR/01-emoji.conf"


# Function: install-apple-emoji
# Description:
#   Downloads the Apple Color Emoji font if not present.

install-apple-emoji() {
    log-info "Checking for Apple Color Emoji..."
    
    if [[ -f "$FONT_FILE" ]]; then
        log-info "Apple Color Emoji already installed."
        return
    fi
    
    log-info "Downloading Apple Color Emoji..."
    mkdir -p "$FONT_DIR"
    
    if curl -fsSL -o "$FONT_FILE" "$FONT_URL"; then
        log-success "Apple Color Emoji downloaded successfully."
    else
        log-error "Failed to download Apple Color Emoji."
        return 1
    fi
}


# Function: configure-fontconfig
# Description:
#   Creates a fontconfig file to prioritize Apple Color Emoji.

configure-fontconfig() {
    log-info "Configuring font metadata to prioritize Apple Emojis..."
    
    mkdir -p "$FONT_CONFIG_DIR"
    
    cat > "$FONT_CONFIG_FILE" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- Prioritize Apple Color Emoji for sans-serif, serif, monospace, and emoji families -->
  <match target="pattern">
    <test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend" binding="weak">
      <string>Apple Color Emoji</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>serif</string></test>
    <edit name="family" mode="prepend" binding="weak">
      <string>Apple Color Emoji</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend" binding="weak">
      <string>Apple Color Emoji</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family"><string>emoji</string></test>
    <edit name="family" mode="prepend" binding="strong">
      <string>Apple Color Emoji</string>
    </edit>
  </match>
</fontconfig>
EOF
    log-success "Font configuration created at $FONT_CONFIG_FILE"
}


# Function: update-cache
# Description:
#   Updates the system font cache.

update-cache() {
    log-info "Updating font cache..."
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$FONT_DIR"
        log-success "Font cache updated."
    else
        log-warn "fc-cache not found. You may need to restart per session."
    fi
}

main() {
    ensure-user
    install-apple-emoji
    configure-fontconfig
    update-cache
    log-info "Apple Emojis setup complete."
}

main "$@"
