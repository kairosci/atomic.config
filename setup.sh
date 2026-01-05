#!/usr/bin/bash
# =============================================================================
# Fedora Atomic Setup
# Installs Atomic Manager and configures global access
# =============================================================================

set -euo pipefail

# Get script directory
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
source "$SCRIPT_DIR/lib/common.sh"

# =============================================================================
# Main Functions
# =============================================================================

set-permissions() {
    log-info "Setting executable permissions..."
    chmod +x "$SCRIPT_DIR/index.sh" \
             "$SCRIPT_DIR/config/index.sh" \
             "$SCRIPT_DIR/config/script/"*.sh \
             "$SCRIPT_DIR/config/script/kionite/"*.sh \
             "$SCRIPT_DIR/config/script/silverblue/"*.sh \
             "$SCRIPT_DIR/utils/"*.sh \
             "$SCRIPT_DIR/lib/"*.sh 2>/dev/null || true
}

configure-bashrc() {
    log-info "Configuring .bashrc..."
    
    local user_home
    user_home="$(get-user-home)"
    local bashrc="$user_home/.bashrc"
    local alias_cmd="alias atomic=\"$SCRIPT_DIR/index.sh\""
    
    if [[ ! -f "$bashrc" ]]; then
        log-warn ".bashrc not found at $bashrc"
        return
    fi
    
    # Remove old kionite alias if exists
    if grep -q "alias kionite=" "$bashrc"; then
        sed -i '/# Kionite Manager/d' "$bashrc"
        sed -i '/alias kionite=/d' "$bashrc"
        log-info "Removed old 'kionite' alias"
    fi
    
    if grep -q "alias atomic=" "$bashrc"; then
        log-info "Alias already exists in .bashrc"
    else
        echo "" >> "$bashrc"
        echo "# Fedora Atomic Manager" >> "$bashrc"
        echo "$alias_cmd" >> "$bashrc"
        log-success "Added 'atomic' alias to .bashrc"
        log-info "Please restart your terminal or run: source ~/.bashrc"
    fi
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    require-root
    
    local distro
    distro="$(detect-distro)"
    
    log-info "Installing Fedora Atomic Manager..."
    log-info "Detected: $distro"
    
    set-permissions
    configure-bashrc
    
    log-success "Installation completed!"
    log-info "You can now run 'atomic' from anywhere (after restarting terminal)."
}

main "$@"
