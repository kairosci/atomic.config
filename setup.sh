#!/usr/bin/bash
# =============================================================================
# Kionite Setup
# Installs Kionite Manager and configures global access
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
             "$SCRIPT_DIR/utils/"*.sh \
             "$SCRIPT_DIR/lib/"*.sh 2>/dev/null || true
}

configure-bashrc() {
    log-info "Configuring .bashrc..."
    
    local user_home
    user_home="$(get-user-home)"
    local bashrc="$user_home/.bashrc"
    local alias_cmd="alias kionite=\"$SCRIPT_DIR/index.sh\""
    
    if [[ ! -f "$bashrc" ]]; then
        log-warn ".bashrc not found at $bashrc"
        return
    fi
    
    if grep -q "alias kionite=" "$bashrc"; then
        log-info "Alias already exists in .bashrc"
    else
        echo "" >> "$bashrc"
        echo "# Kionite Manager" >> "$bashrc"
        echo "$alias_cmd" >> "$bashrc"
        log-success "Added 'kionite' alias to .bashrc"
        log-info "Please restart your terminal or run: source ~/.bashrc"
    fi
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    require-root
    
    log-info "Installing Kionite Manager..."
    
    set-permissions
    configure-bashrc
    
    log-success "Installation completed!"
    log-info "You can now run 'kionite' from anywhere (after restarting terminal)."
}

main "$@"
