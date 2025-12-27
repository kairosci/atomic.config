#!/usr/bin/bash
set -e

# Function to check if running as root
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script with sudo"
        exit 1
    fi
}

# System Update
update_system() {
    echo "Updating System (rpm-ostree)..."
    echo "Reloading rpm-ostree configuration..."
    rpm-ostree reload
    echo "Refreshing metadata..."
    rpm-ostree refresh-md
    echo "Starting upgrade..."
    rpm-ostree upgrade
}

# Flatpak Update
update_flatpak() {
    echo "Updating Flatpaks..."
    flatpak update -y
}

# Cleanup
cleanup() {
    echo "Cleaning up System..."
    
    echo "Cleaning rpm-ostree base..."
    rpm-ostree cleanup --base -m

    echo "Removing unused Flatpak runtimes (and data)..."
    flatpak uninstall --unused --delete-data -y

    echo "Vacuuming system logs..."
    journalctl --vacuum-files=0
    journalctl --vacuum-time=2weeks
}

main() {
    check_sudo
    update_system
    update_flatpak
    cleanup
    echo " Update and Cleanup Completed! "
    echo "You may need to reboot to apply rpm-ostree changes."
}

main
