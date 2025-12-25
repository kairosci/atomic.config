#!/usr/bin/bash
set -e

# Function to remove base packages
remove_base_packages() {
    echo "Removing base packages..."
    local packages_to_remove=(
        "cldr-emoji-annotation-dtd"
        "cldr-emoji-annotation"
        "default-fonts-core-emoji"
        "google-noto-color-emoji-fonts"
        "ibus-typing-booster"
        "kde-connect"
        "kde-connect-libs"
        "kdeconnectd"
        "kinfocenter"
        "plasma-drkonqi"
        "plasma-welcome"
        "plasma-welcome-fedora"
        "plasma-discover"
        "plasma-discover-rpm-ostree"
        "plasma-discover-flatpak"
        "plasma-discover-notifier"
        "plasma-discover-kns"
        "kcharselect"
        "kdebugsettings"
        "khelpcenter"
        "krfb"
        "krfb-libs"
        "kjournald"
        "kjournald-libs"
        "kwalletmanager5"
        "filelight"
        "firefox"
        "firefox-langpacks"
        "toolbox"
    )

    rpm-ostree override remove "${packages_to_remove[@]}"
    echo "Base packages removed."
}

# Function to install third-party repositories
install_third_party_repos() {
    echo "Installing third-party repositories..."
    curl -fsS https://dl.brave.com/install.sh | sh
    curl -o /etc/yum.repos.d/fedora-spotify.repo https://negativo17.org/repos/fedora-spotify.repo
    echo "Third-party repositories installed."
}

# Function to install new packages
install_packages() {
    echo "Installing new packages..."
    local packages_to_install=(
        "clang"
        "cmake"
        "java-latest-openjdk"
        "kalk"
        "ksshaskpass"
        "libvirt"
        "tlp"
        "tlp-rdw"
        "make"
        "ncurses-devel"
        "nodejs"
        "qemu-kvm"
        "kde-l10n-ko"
        "glibc-langpack-ko"
        "distrobox"
        "spotify-client"
    )

    rpm-ostree install "${packages_to_install[@]}"
    echo "New packages installed."
}

# Function to install Google Antigravity
install_google_antigravity() {
    echo "Installing Google Antigravity..."
    rpm-ostree install google-antigravity
    echo "Google Antigravity installed."
}

# Main execution
main() {
    remove_base_packages
    install_third_party_repos
    install_packages
    install_google_antigravity
}

main
