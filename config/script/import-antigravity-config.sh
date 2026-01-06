#!/usr/bin/bash

# Import Antigravity Config
# Copies the current user Antigravity configuration to the project repo


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

readonly USER_CONFIG_DIR="$HOME/.config/Antigravity"
readonly REPO_DATA_DIR="$SCRIPT_DIR/../../data/Antigravity"

main() {
    ensure-user
    
    log-info "Importing Antigravity configuration..."
    
    if [[ ! -d "$USER_CONFIG_DIR" ]]; then
        log-error "Antigravity config directory not found at: $USER_CONFIG_DIR"
        log-info "Please ensure Antigravity is configured and the directory exists."
        exit 1
    fi
    
    log-info "Source: $USER_CONFIG_DIR"
    log-info "Destination: $REPO_DATA_DIR"
    
    # Create destination parent directory
    mkdir -p "$(dirname "$REPO_DATA_DIR")"
    
    # Remove existing repo config to ensure clean copy
    rm -rf "$REPO_DATA_DIR"
    
    # Create destination directory structure
    mkdir -p "$REPO_DATA_DIR/User"
    
    # Define essential files to copy
    local -a files_to_copy=(
        "User/settings.json"
        "User/keybindings.json"
        "User/tasks.json"
    )
    
    local success=true
    
    # Copy individual config files if they exist
    for file in "${files_to_copy[@]}"; do
        if [[ -f "$USER_CONFIG_DIR/$file" ]]; then
            cp "$USER_CONFIG_DIR/$file" "$REPO_DATA_DIR/$file"
            log-info "Imported: $file"
        fi
    done
    
    # Copy snippets directory if it exists
    if [[ -d "$USER_CONFIG_DIR/User/snippets" ]]; then
        cp -r "$USER_CONFIG_DIR/User/snippets" "$REPO_DATA_DIR/User/"
        log-info "Imported: User/snippets/"
    fi
    
    # Export installed extensions list
    if command -v antigravity &>/dev/null; then
        log-info "Exporting installed extensions list..."
        if antigravity --list-extensions > "$REPO_DATA_DIR/extensions.list"; then
            log-info "Extensions list saved to extensions.list"
        else
            log-warn "Failed to export extensions list."
        fi
    fi
    
    log-success "Selective configuration import completed to data/Antigravity."
    log-info "Cache, History, and huge storage files were ignored."
    log-info "You can now commit the 'data' directory."
}

main "$@"
