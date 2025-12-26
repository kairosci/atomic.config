#!/usr/bin/bash
set -e

# Function to clean system logs and ostree
system_cleanup() {
    echo "Starting system cleanup..."
    journalctl --vacuum-files=0
    rpm-ostree cleanup --base -m
    echo "System cleanup completed."
}

# Function to remove user configuration directories
remove_user_configs() {
    echo "Removing user configurations..."
    
    local config_dirs=(
        "$HOME/.config/kdeconnect"
        "$HOME/.config/kdeconnectrc"
        "$HOME/.config/plasma-welcomerc"
        "$HOME/.config/filelightrc"
        "$HOME/.config/kdebugrc"
        "$HOME/.config/khelpcenterrc"
        "$HOME/.config/kcharselectrc"
        "$HOME/.config/plasmaemojierrc"
        "$HOME/.config/drkonqirc"
        "$HOME/.mozilla"
        "$HOME/.config/ibus/typing-booster"
        "$HOME/.config/krfbrc"
        "$HOME/.config/toolboxrc"
        "$HOME/.config/discoverrc"
        "$HOME/.config/kdeveloprc"
        "$HOME/.config/kmail2rc"
        "$HOME/.config/kmailsearchindexingrc"
        "$HOME/.config/emaildefaults"
        "$HOME/.config/emailidentities"
        "$HOME/.config/khelpcenter"
        "$HOME/.config/ksplashrc"
    )

    local share_dirs=(
        "$HOME/.local/share/akonadi"
        "$HOME/.local/share/akonadi_migration_agent"
        "$HOME/.local/share/gravatar"
        "$HOME/.local/share/kdevscratchpad"
        "$HOME/.local/share/kdevelop"
        "$HOME/.local/share/kmail2"
        "$HOME/.local/share/local-mail"
        "$HOME/.local/share/logs"
        "$HOME/.local/share/phishingurl"
        "$HOME/.local/share/user-places.xbel"
        "$HOME/.local/share/user-places.xbel.bak"
        "$HOME/.local/share/user-places.xbel.tbcache"
        "$HOME/.local/share/recently-used.xbel"
        "$HOME/.local/share/baloo"
        "$HOME/.local/share/contacts"
        "$HOME/.local/share/kactivitymanagerd"
        "$HOME/.local/share/kded6"
        "$HOME/.local/share/klipper"
        "$HOME/.local/share/libkunitconversion"
        "$HOME/.local/share/ksshaskpass"
        "$HOME/.local/share/knewstuff3"
        "$HOME/.local/share/toolbox"
        "$HOME/.local/share/waydroid"
    )

    # Remove config directories
    for dir in "${config_dirs[@]}"; do
        rm -rf "$dir"
    done

    # Remove share directories
    for dir in "${share_dirs[@]}"; do
        rm -rf "$dir"
    done
    
    echo "User configurations removed."
}

# Function to upgrade the system
system_upgrade() {
    echo "Upgrading system with rpm-ostree..."
    rpm-ostree reload
    rpm-ostree refresh-md
    rpm-ostree upgrade
    echo "System upgrade completed."
}

# Function to manage Flatpak packages
flatpak_maintenance() {
    echo "Performing Flatpak maintenance..."
    flatpak uninstall --unused --delete-data -y
    flatpak update -y
    echo "Flatpak maintenance completed."
}

# Main execution
main() {
    system_cleanup
    remove_user_configs
    system_upgrade
    flatpak_maintenance
}

main
