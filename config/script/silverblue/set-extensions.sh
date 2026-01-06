#!/usr/bin/bash

# Set GNOME Extensions


set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"


# GNOME Extensions List

readonly -a GNOME_EXTENSIONS=(
    # System & UX Improvements
    "appindicatorsupport@rgcjonas.gmail.com"
    "dash-to-dock@micxgx.gmail.com"
    "just-perfection-desktop@just-perfection"
    "caffeine@patapon.info"
    
    # Visual Customizations
    "blur-my-shell@aunetx"
    "transparent-top-bar@ftpix.com"
)


# Function: install-extension-manager
# Description: Installs the GUI Extension Manager from Flathub.

install-extension-manager() {
    log-info "Installing GNOME Extension Manager via Flatpak"
    
    if ! flatpak list --app | grep -q "com.mattjakeman.ExtensionManager"; then
        flatpak install flathub com.mattjakeman.ExtensionManager -y
        log-success "Extension Manager installed"
    else
        log-info "Extension Manager already installed"
    fi
}

enable-user-extensions() {
    log-info "Enabling GNOME user extensions"
    dconf write /org/gnome/shell/disable-user-extensions false
}


# Function: configure-dash-to-dock
# Description: Configures Dash to Dock to mimic Ubuntu's bottom dock style.

configure-dash-to-dock() {
    log-info "Configuring Dash to Dock (Ubuntu-style)"
    
    dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
    dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false
    dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
    dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'ALL_WINDOWS'"
    dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 48
    dconf write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'DYNAMIC'"
}


# Function: configure-just-perfection
# Description: Fine-tunes desktop behavior and animation speed.

configure-just-perfection() {
    log-info "Configuring Just Perfection (desktop tweaks)"
    
    dconf write /org/gnome/shell/extensions/just-perfection/search false
    dconf write /org/gnome/shell/extensions/just-perfection/workspace true
    # Animation speed (Very Fast)
    dconf write /org/gnome/shell/extensions/just-perfection/animation 5
}


# Function: configure-blur-my-shell
# Description: Disables panel blur to allow for a solid opaque top bar.

configure-blur-my-shell() {
    log-info "Configuring Blur My Shell (disable panel blur)"
    
    # Disable panel blur to allow solid color
    dconf write /org/gnome/shell/extensions/blur-my-shell/panel/blur false
}


# Function: configure-transparent-top-bar
# Description: 
#   Configures the top bar to be completely opaque (0 transparency).
#   Handles multiple potential dconf paths for compatibility.

configure-transparent-top-bar() {
    log-info "Configuring Transparent Top Bar (Opaque)"
    
    # Set transparency to 0 (Opaque)
    # Note: Schema path might vary, trying common paths
    if dconf list /com/ftpix/transparentbar/ &>/dev/null; then
        dconf write /com/ftpix/transparentbar/transparency 0
        dconf write /com/ftpix/transparentbar/dark-full-screen true
    elif dconf list /org/gnome/shell/extensions/transparent-top-bar/ &>/dev/null; then
         dconf write /org/gnome/shell/extensions/transparent-top-bar/transparency 0
    else
        # Force write to assumed path if not found (extension might not be loaded yet)
        dconf write /com/ftpix/transparentbar/transparency 0
    fi
}

install-cli-tools() {
    log-info "Installing CLI tools for extension management..."
    
    if ! command -v pip &>/dev/null; then
        log-info "Installing pip..."
        python3 -m ensurepip --user --default-pip
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    if ! command -v gnome-extensions-cli &>/dev/null; then
        log-info "Installing gnome-extensions-cli..."
        pip install --user gnome-extensions-cli
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install-extensions-cli() {
    log-info "Installing GNOME extensions via CLI..."
    
    for ext in "${GNOME_EXTENSIONS[@]}"; do
        log-info "Processing $ext..."
        gnome-extensions-cli install "$ext"
        gnome-extensions-cli enable "$ext"
    done
}

remove-extension-manager() {
    log-info "Removing GNOME Extension Manager (cleanup)..."
    if flatpak list --app | grep -q "com.mattjakeman.ExtensionManager"; then
        flatpak uninstall flathub com.mattjakeman.ExtensionManager -y
    fi
}

main() {
    ensure-user
    install-cli-tools
    install-extensions-cli
    enable-user-extensions
    
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/dash-to-dock/ &>/dev/null; then
        configure-dash-to-dock
    fi
    
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/just-perfection/ &>/dev/null; then
        configure-just-perfection
    fi

    if command -v dconf &>/dev/null; then
        configure-blur-my-shell
        configure-transparent-top-bar
    fi
    
    remove-extension-manager
}

main "$@"
