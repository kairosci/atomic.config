#!/usr/bin/bash
set -e

# Function to remove default Flatpak apps
remove_defaults() {
    echo "Removing default Flatpak applications..."
    local apps_to_remove=(
        "org.fedoraproject.Platform.GL.default"
        "org.kde.kcalc"
        "org.kde.kmahjongg"
        "org.kde.kmines"
        "org.kde.kolourpaint"
        "org.kde.krdc"
        "org.kde.skanpage"
    )

    flatpak uninstall --delete-data "${apps_to_remove[@]}"
    echo "Default Flatpak applications removed."
}

# Function to setup Flatpak remotes
setup_remotes() {
    echo "Setting up Flatpak remotes..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Flatpak remotes setup completed."
}

# Function to install Flatpak apps
install_apps() {
    echo "Installing Flatpak applications..."
    local apps_to_install=(
        "com.discordapp.Discord"
        "org.kde.kalk"
    )

    flatpak install flathub "${apps_to_install[@]}"
    echo "Flatpak applications installed."
}

# Main execution
main() {
    remove_defaults
    setup_remotes
    install_apps
}

main
