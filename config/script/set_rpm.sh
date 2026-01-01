#!/usr/bin/bash
set -e


remove_base_packages() {
    echo "Removing base packages"
    local packages_to_remove=(
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
        echo "Base packages removed"
    else
        echo "No base packages found"
    fi
}


install_third_party_repos() {
    echo "Installing repos"
    
    if [ ! -f /etc/yum.repos.d/brave-browser.repo ]; then
        echo "Adding Brave"
        curl -fsS https://dl.brave.com/install.sh | sh
    else
        echo "Brave exists"
    fi



    echo "Repo check done"
}


install_packages() {
    echo "Installing packages"
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
        "distrobox"
        "rsms-inter-fonts"
        "breeze-gtk"
        "adw-gtk3-theme"
    )

    rpm-ostree install --idempotent "${packages_to_install[@]}"
    echo "Packages installed"
}


install_google_antigravity() {

    echo "Adding Antigravity repo"
    sudo tee /etc/yum.repos.d/antigravity.repo << EOL
    [antigravity-rpm]
    name=Antigravity RPM Repository
    baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
    enabled=1
    gpgcheck=0
EOL

    echo "Installing Antigravity"
    rpm-ostree install --idempotent antigravity
    echo "Antigravity installed"
}


main() {
    remove_base_packages
    install_third_party_repos
    install_packages
    install_google_antigravity
}

main
