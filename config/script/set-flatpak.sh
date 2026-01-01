#!/usr/bin/bash
# =============================================================================
# Set Flatpak Apps
# Removes default apps and installs curated selection
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly -a APPS_TO_REMOVE=(
    "org.fedoraproject.Platform.GL.default"
    "org.kde.kmahjongg"
    "org.kde.kmines"
    "org.kde.kolourpaint"
    "org.kde.krdc"
    "org.kde.skanpage"
)

readonly -a APPS_TO_INSTALL=(
    "com.discordapp.Discord"
)

# =============================================================================
# Functions
# =============================================================================

remove-defaults() {
    log-info "Removing default Flatpak apps"
    
    local -a valid_apps=()
    local installed_apps
    installed_apps="$(flatpak list --app --columns=application 2>/dev/null || true)"
    
    for app in "${APPS_TO_REMOVE[@]}"; do
        if echo "$installed_apps" | grep -q "$app"; then
            valid_apps+=("$app")
        else
            log-info "Skipping $app (not installed)"
        fi
    done
    
    if [[ ${#valid_apps[@]} -gt 0 ]]; then
        flatpak uninstall --delete-data -y "${valid_apps[@]}"
        log-success "Default apps removed"
    else
        log-info "No default apps to remove"
    fi
}

setup-remotes() {
    log-info "Setting up Flatpak remotes"
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    log-success "Remotes configured"
}

install-apps() {
    log-info "Installing Flatpak apps"
    
    if [[ ${#APPS_TO_INSTALL[@]} -gt 0 ]]; then
        flatpak install flathub "${APPS_TO_INSTALL[@]}" -y || true
        log-success "Apps installed"
    else
        log-info "No apps to install"
    fi
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    remove-defaults
    setup-remotes
    install-apps
}

main "$@"
