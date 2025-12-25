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

    local valid_packages_to_remove=()
    local ostree_status=$(rpm-ostree status)

    for pkg in "${packages_to_remove[@]}"; do
        if rpm -q "$pkg" &> /dev/null; then
            # Check if package is already mentioned in rpm-ostree status (implies override exists)
            if echo "$ostree_status" | grep -Fq "$pkg"; then
                echo "Skipping removal of $pkg (already has an override/pending)."
            else
                valid_packages_to_remove+=("$pkg")
            fi
        else
            echo "Skipping removal of $pkg (not installed or already removed)."
        fi
    done

    if [ ${#valid_packages_to_remove[@]} -gt 0 ]; then
        rpm-ostree override remove "${valid_packages_to_remove[@]}"
        echo "Base packages removed."
    else
        echo "No base packages satisfy removal criteria."
    fi
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

    rpm-ostree install --idempotent "${packages_to_install[@]}"
    echo "New packages installed."
}

# Function to install Google Antigravity
install_google_antigravity() {
    echo "Installing Google Antigravity..."
    rpm-ostree install --idempotent google-antigravity
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
