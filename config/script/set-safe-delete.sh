#!/usr/bin/bash

# Set Safe Delete
# Configures rm alias to use gio trash for safe deletion


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"


# Main Function



# Function: setup-alias
# Description:
#   Configures the 'rmt' alias for safe deletion using 'gio trash'.
#   Restores the standard 'rm' behavior for permanent deletion.
#   Modifies the user's .bashrc file.

setup-alias() {
    log-info "Configuring safe delete aliases..."
    
    local user_home
    user_home="$(get-user-home)"
    
    local bashrc="${user_home}/.bashrc"
    
    if [[ ! -f "$bashrc" ]]; then
        log-error ".bashrc not found at: $bashrc"
        return 1
    fi
    
    # Verify gio availability before proceeding
    if ! command-exists gio; then
        log-warn "'gio' command not found. Cannot configure safe delete ('rmt')."
        return 0
    fi
    
    # Check for existing configuration
    if grep -q "Safe Delete Configuration (Kionite Setup)" "$bashrc"; then
        log-info "Safe delete configuration already present in .bashrc"
        return 0
    fi
    
    log-info "Appending safe delete aliases to $bashrc"
    
    # Alias Configuration:
    #   rmt -> gio trash (Move to trash/recycle bin)
    #   rm  -> /usr/bin/rm (Standard permanent delete, implicit)
    {
        echo "# Safe Delete Configuration (Kionite Setup)"
        echo "# 'rm' is preserved for standard permanent deletion."
        echo "# 'rmt' is added for safe deletion (moves to trash)."
        echo "alias rmt='gio trash 2>/dev/null || /usr/bin/rm'"
    } >> "$bashrc"
    
    fix-ownership "$bashrc"
    
    log-success "Safe delete configured. Please restart your terminal or run 'source ~/.bashrc'."
}


# Entry Point


main() {
    require-root
    setup-alias
}

main "$@"
