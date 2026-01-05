#!/usr/bin/bash
# =============================================================================
# Set GNOME Extensions
# Installs and enables extensions for Ubuntu-like experience on Silverblue
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

# Extensions to enable (installed via rpm-ostree or Flatpak Extension Manager)
readonly -a GNOME_EXTENSIONS=(
    "appindicatorsupport@rgcjonas.gmail.com"     # AppIndicator/Tray icons
    "dash-to-dock@micxgx.gmail.com"               # Ubuntu-style dock
    "blur-my-shell@aunetx"                        # Blur effects
    "just-perfection-desktop@just-perfection"    # Desktop tweaks
    "caffeine@patapon.info"                       # Prevent auto-suspend
)

# =============================================================================
# Functions
# =============================================================================

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
    
    local real_user
    real_user="$(get-real-user)"
    
    # Enable user extensions globally
    dconf write /org/gnome/shell/disable-user-extensions false
    
    log-success "User extensions enabled"
}

configure-dash-to-dock() {
    log-info "Configuring Dash to Dock (Ubuntu-style)"
    
    # Set dock position to bottom (Ubuntu-style)
    dconf write /org/gnome/shell/extensions/dash-to-dock/dock-position "'BOTTOM'"
    
    # Extend dock across screen
    dconf write /org/gnome/shell/extensions/dash-to-dock/extend-height false
    
    # Show on all monitors
    dconf write /org/gnome/shell/extensions/dash-to-dock/multi-monitor true
    
    # Auto-hide behavior
    dconf write /org/gnome/shell/extensions/dash-to-dock/intellihide-mode "'ALL_WINDOWS'"
    
    # Icon size
    dconf write /org/gnome/shell/extensions/dash-to-dock/dash-max-icon-size 48
    
    # Transparency
    dconf write /org/gnome/shell/extensions/dash-to-dock/transparency-mode "'DYNAMIC'"
    
    log-success "Dash to Dock configured"
}

configure-just-perfection() {
    log-info "Configuring Just Perfection (desktop tweaks)"
    
    # Hide search on overview
    dconf write /org/gnome/shell/extensions/just-perfection/search false
    
    # Show workspaces in overview
    dconf write /org/gnome/shell/extensions/just-perfection/workspace true
    
    # Animation speed (faster)
    dconf write /org/gnome/shell/extensions/just-perfection/animation 4
    
    log-success "Just Perfection configured"
}

install-cli-tools() {
    log-info "Installing CLI tools for extension management..."
    
    # Ensure pip is installed (user scope)
    if ! command -v pip &>/dev/null; then
        log-info "Installing pip..."
        python3 -m ensurepip --user --default-pip
        
        # Add local bin to PATH for this session
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Install gnome-extensions-cli
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
        
        # Install and enable
        # Note: We use --upgrade to ensure we have the latest compatible version
        gnome-extensions-cli install "$ext"
        gnome-extensions-cli enable "$ext"
    done
    
    log-success "Extensions installed and enabled"
}

remove-extension-manager() {
    log-info "Removing GNOME Extension Manager (cleanup)..."
    if flatpak list --app | grep -q "com.mattjakeman.ExtensionManager"; then
        flatpak uninstall flathub com.mattjakeman.ExtensionManager -y
    else
        log-info "Extension Manager not found, skipping removal."
    fi
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    ensure-user
    # CLI setup
    install-cli-tools
    
    # Install extensions via CLI
    install-extensions-cli
    
    enable-user-extensions
    
    # Try to configure extensions if they're installed
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/dash-to-dock/ &>/dev/null; then
        configure-dash-to-dock
    fi
    
    if command -v dconf &>/dev/null && dconf list /org/gnome/shell/extensions/just-perfection/ &>/dev/null; then
        configure-just-perfection
    fi
    
    # Cleanup (remove flatpak as requested)
    remove-extension-manager
}

main "$@"
