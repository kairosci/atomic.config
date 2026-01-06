#!/usr/bin/bash

# Set RPM Packages
# Manages rpm-ostree packages for Kionite and Silverblue


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/common.sh"


# Constants - Kionite (KDE Plasma)


readonly -a KIONITE_PACKAGES_TO_REMOVE=(
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

readonly -a KIONITE_PACKAGES_TO_INSTALL=(
    "kalk"
    "ksshaskpass"
    "libvirt"
    "tlp"
    "tlp-rdw"
    "qemu-kvm"
    "distrobox"
    "rsms-inter-fonts"
    "google-noto-emoji-fonts"
    "breeze-gtk"
    "unzip"
    "arc-theme"
    "papirus-icon-theme"
)


# Constants - Silverblue (GNOME)


readonly -a SILVERBLUE_PACKAGES_TO_REMOVE=(
    "gnome-software"
    "gnome-software-rpm-ostree"
    "gnome-contacts"
    "gnome-maps"
    "gnome-weather"
    "gnome-tour"
    "gnome-connections"
    "gnome-characters"
    "gnome-font-viewer"
    "gnome-logs"
    "gnome-remote-desktop"
    "simple-scan"
    "totem"
    "cheese"
    "rhythmbox"
    "yelp"
    "firefox"
    "firefox-langpacks"
    "toolbox"
    "fedora-workstation-backgrounds"
)

readonly -a SILVERBLUE_PACKAGES_TO_INSTALL=(
    "libvirt"
    "tlp"
    "tlp-rdw"
    "qemu-kvm"
    "distrobox"
    "rsms-inter-fonts"
    "google-noto-emoji-fonts"
    "unzip"
    "arc-theme"
    "papirus-icon-theme"
)


# Functions


remove-base-packages() {
    local distro="$1"
    local -n packages_ref="$2"
    
    log-info "Removing base packages for $distro"
    
    local -a valid_packages=()
    local ostree_status
    ostree_status="$(rpm-ostree status)"
    
    for pkg in "${packages_ref[@]}"; do
        if rpm -q "$pkg" &>/dev/null; then
            if echo "$ostree_status" | grep -Fq "$pkg"; then
                log-info "Skipping $pkg (already has override)"
            else
                valid_packages+=("$pkg")
            fi
        else
            log-info "Skipping $pkg (not installed)"
        fi
    done
    
    if [[ ${#valid_packages[@]} -gt 0 ]]; then
        rpm-ostree override remove "${valid_packages[@]}"
        log-success "Base packages removed"
    else
        log-info "No base packages to remove"
    fi
}

install-third-party-repos() {
    log-info "Installing third-party repositories"
    
    # Brave Browser
    if [[ ! -f /etc/yum.repos.d/brave-browser.repo ]]; then
        log-info "Adding Brave repository"
        curl -fsS https://dl.brave.com/install.sh | sh
        log-success "Brave repository added"
    else
        log-info "Brave repository already exists"
    fi


}

install-packages() {
    local -n packages_ref="$1"
    
    log-info "Installing packages"
    
    if [[ ${#packages_ref[@]} -gt 0 ]]; then
        rpm-ostree install --idempotent --allow-inactive "${packages_ref[@]}"
        log-success "Packages installed"
    fi
}

install-google-antigravity() {
    log-info "Installing Antigravity"
    
    local repo_file="/etc/yum.repos.d/antigravity.repo"
    
    if [[ ! -f "$repo_file" ]]; then
        cat > "$repo_file" <<EOF
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF
        log-success "Antigravity repository added"
    fi
    
    rpm-ostree install --idempotent antigravity
    log-success "Antigravity installed"
}


# Function: configure-antigravity
# Description:
#   Configures Antigravity by checking for a user-supplied config file 
#   in the repository and installing it to ~/.config/antigravity.
#   Since we cannot read ~/.config directly during setup, this relies on a
#   backup strategy.

configure-antigravity() {
    log-info "Configuring Antigravity..."
    
    local real_user
    real_user="$(get-real-user)"
    local user_home
    user_home="$(get-user-home)"
    
    # Check if a backup config exists in the repo
    # Use data/Antigravity for full directory restore
    local repo_config_dir="$SCRIPT_DIR/../../../data/Antigravity"
    local target_dir="$user_home/.config/Antigravity"
    
    if [[ -d "$repo_config_dir" ]]; then
        log-info "Found Antigravity backup configuration in 'data/'. Restoring..."
        
        # Ensure parent dir exists
        mkdir -p "$(dirname "$target_dir")"
        
        # Restore directory matches (Merge/Overwrite configs, preserve local Cache/History)
        # using -u (update) to likely overwrite if source is newer, or just -f to force.
        # usually just copying the structure over is enough.
        cp -rf "$repo_config_dir/"* "$target_dir/"
        fix-ownership "$target_dir"
        
        # Install extensions if list exists
        local ext_list="$repo_config_dir/extensions.list"
        if [[ -f "$ext_list" ]] && command -v antigravity &>/dev/null; then
            log-info "Installing Antigravity extensions from backup list..."
            while IFS= read -r ext; do
                [[ -z "$ext" ]] && continue
                log-info "Installing extension: $ext"
                # Run as real user to ensure extensions go to user profile
                # Check if already installed to save time? antigravity might handle it.
                if ! sudo -u "$real_user" antigravity --install-extension "$ext" &>/dev/null; then
                    log-warn "Failed to install $ext (or already installed)"
                fi
            done < "$ext_list"
            log-success "Extensions installation process completed."
        fi
        
        log-success "Antigravity configuration updated from data backup (Cache preserved)."
    else
        log-warn "No Antigravity backup config found at $repo_config_dir."
        log-info "To persist your config, run ./config/script/import-antigravity-config.sh"
    fi
}


# Entry Point


main() {
    ensure-root
    local distro
    distro="$(detect-distro)"
    
    log-info "Detected distro: $distro"
    
    case "$distro" in
        kionite)
            remove-base-packages "Kionite" KIONITE_PACKAGES_TO_REMOVE
            install-third-party-repos
            install-packages KIONITE_PACKAGES_TO_INSTALL
            ;;
        silverblue)
            remove-base-packages "Silverblue" SILVERBLUE_PACKAGES_TO_REMOVE
            install-third-party-repos
            install-packages SILVERBLUE_PACKAGES_TO_INSTALL
            ;;
        *)
            log-error "Unknown distro: $distro"
            log-error "This script only supports Kionite and Silverblue"
            exit 1
            ;;
    esac
    
    install-google-antigravity
    configure-antigravity
}

main "$@"
