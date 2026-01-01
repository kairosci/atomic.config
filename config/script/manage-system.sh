#!/usr/bin/bash
# =============================================================================
# Manage System
# System cleanup, config removal, upgrade, and Flatpak maintenance
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly -a CONFIG_DIRS=(
    ".config/kdeconnect"
    ".config/kdeconnectrc"
    ".config/plasma-welcomerc"
    ".config/filelightrc"
    ".config/kdebugrc"
    ".config/khelpcenterrc"
    ".config/kcharselectrc"
    ".config/plasmaemojierrc"
    ".config/drkonqirc"
    ".mozilla"
    ".config/ibus/typing-booster"
    ".config/krfbrc"
    ".config/toolboxrc"
    ".config/discoverrc"
    ".config/kdeveloprc"
    ".config/kmail2rc"
    ".config/kmailsearchindexingrc"
    ".config/emaildefaults"
    ".config/emailidentities"
    ".config/khelpcenter"
    ".config/ksplashrc"
)

readonly -a SHARE_DIRS=(
    ".local/share/akonadi"
    ".local/share/akonadi_migration_agent"
    ".local/share/gravatar"
    ".local/share/kdevscratchpad"
    ".local/share/kdevelop"
    ".local/share/kmail2"
    ".local/share/local-mail"
    ".local/share/logs"
    ".local/share/phishingurl"
    ".local/share/user-places.xbel"
    ".local/share/user-places.xbel.bak"
    ".local/share/user-places.xbel.tbcache"
    ".local/share/recently-used.xbel"
    ".local/share/baloo"
    ".local/share/contacts"
    ".local/share/kactivitymanagerd"
    ".local/share/kded6"
    ".local/share/klipper"
    ".local/share/libkunitconversion"
    ".local/share/ksshaskpass"
    ".local/share/knewstuff3"
    ".local/share/toolbox"
    ".local/share/waydroid"
)

# =============================================================================
# Functions
# =============================================================================

system-cleanup() {
    log-info "System cleanup"
    journalctl --vacuum-files=0
    rpm-ostree cleanup --base -m
    log-success "System cleaned"
}

remove-user-configs() {
    log-info "Removing user configs"
    
    local user_home
    user_home="$(get-user-home)"
    
    for dir in "${CONFIG_DIRS[@]}"; do
        rm -rf "$user_home/$dir"
    done
    
    for dir in "${SHARE_DIRS[@]}"; do
        rm -rf "$user_home/$dir"
    done
    
    log-success "User configs removed"
}

system-upgrade() {
    log-info "Upgrading system"
    rpm-ostree reload
    rpm-ostree refresh-md
    rpm-ostree upgrade
    log-success "System upgraded"
}

flatpak-maintenance() {
    log-info "Flatpak maintenance"
    flatpak uninstall --unused --delete-data -y || true
    flatpak update -y
    log-success "Flatpak maintenance done"
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    system-cleanup
    remove-user-configs
    system-upgrade
    flatpak-maintenance
}

main "$@"
