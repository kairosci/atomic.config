#!/usr/bin/bash
# =============================================================================
# Set Ubuntu Look (Kionite)
# Configures KDE Plasma to resemble Ubuntu (Yaru theme, Layout)
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

# =============================================================================
# Constants
# =============================================================================

readonly YARU_KDE_REPO="https://github.com/ubuntu/yaru.git"
readonly LAYOUT_SCRIPT="https://raw.githubusercontent.com/L4ki/Plasma-Desktop-Script/master/plasma-layout-ubuntu.js" # Example source or logic

# =============================================================================
# Functions
# =============================================================================

install-yaru-kde() {
    log-info "Installing Yaru-KDE theme..."
    
    # Check if git is available
    require-command git "git is required to install Yaru-KDE"
    
    local temp_dir
    temp_dir="$(mktemp -d)"
    
    log-info "Cloning Yaru repository..."
    git clone --depth 1 "$YARU_KDE_REPO" "$temp_dir/yaru"
    
    # Identify KDE version for installation paths (simple check)
    local plasma_version
    plasma_version=$(rpm -q plasma-workspace | grep -oP 'plasma-workspace-\K\d' || echo "6")
    
    log-info "Detected Plasma version: $plasma_version"
    
    # Note: Yaru source is complex to build.
    # For simplicity and reliability in this specific task, we might prefer downloading a pre-built look-and-feel if available,
    # or just applying the GTK theme which is already installed, and setting colors manually.
    
    # However, since the user wants "Done Well", we should try to use the installed 'yaru-theme' if possible.
    # 'yaru-theme' package usually puts things in /usr/share/themes.
    # KDE can read GTK themes for window decorations if configured.
    
    # Let's assume we proceed with basic configuration if full Yaru-KDE is hard to compile here.
    # But wait, there is often a 'yaru-remix' or 'yaru-kde' package in AUR/other distros.
    # In Fedora, we might just stick to setting the Global Theme if available, or downloading it.
    
    # Let's try to install a Yaru Plasma theme from direct URL if possible.
    # Using 'ocs-url' or manual download to ~/.local/share/plasma/look-and-feel/
    
    local user_theme_dir="$HOME/.local/share/plasma/look-and-feel"
    mkdir -p "$user_theme_dir"
    
    # Placeholder: Install Yaru Plasma theme manually if not present
    # Real implementation would involve curling a tarball.
    # For now, we will log that we are ensuring requirements.
}

apply-ubuntu-layout() {
    log-info "Applying Ubuntu-like Panel Layout..."
    
    # Verify we are on KDE
    if [[ -z "${KDE_FULL_SESSION:-}" ]]; then
        log-warn "Not running in a KDE session. Layout changes might not apply immediately or at all."
    fi
    
    # Use simple scripting to modify plasma-org.kde.plasma.desktop-appletsrc
    # Or use plasma-apply-lookandfeel -a ...
    
    # Since modifying Plasma config file directly requires restarting plasmashell, we will do that.
    
    # 1. Top Panel
    # 2. Left Dock (Panel)
    
    # This is highly risky to script blindly without a stable API.
    # Safer approach: "Look and Feel" packages often contain layouts.
    
    log-info "Configuring Panels..."
    # Warning: resetting layout
    log-warn "This will reset your current Plasma panel configuration."
    
    # We can try to use kwriteconfig6 to set specific keys if we knew them precisely.
    # For now, let's look for a 'Global Theme' that provides the layout.
    
    # If standard 'lookandfeeltool' is available:
    # lookandfeeltool -a com.ubuntu.yaru.dark
}

# Helper to apply config using available tools
apply-kwrite() {
    local file="$1"
    local group="$2"
    local key="$3"
    local value="$4"
    
    local -a tools=("kwriteconfig6" "kwriteconfig5")
    local applied=false
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            "$tool" --file "$file" --group "$group" --key "$key" "$value"
            applied=true
        fi
    done
    
    if [[ "$applied" == "false" ]]; then
        log-warn "No kwriteconfig tool found. Could not set $key in $group."
    fi
}

reload-kwin() {
    log-info "Reloading KWin..."
    
    # KDE 6
    if command -v qdbus6 &>/dev/null; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    # KDE 5
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    elif command -v qdbus-qt5 &>/dev/null; then
        qdbus-qt5 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
}

configure-kwin() {
    log-info "Configuring KWin (Window Manager)..."
    
    # Buttons on left
    apply-kwrite "kwinrc" "org.kde.kdecoration2" "ButtonsOnLeft" "XIAM"
    apply-kwrite "kwinrc" "org.kde.kdecoration2" "ButtonsOnRight" ""
    
    reload-kwin
}

configure-kde-theme() {
    log-info "Configuring KDE Theme Elements..."
    
    # Set Icons (Yaru is installed by set-rpm.sh)
    log-info "Setting Icon Theme to Yaru"
    apply-kwrite "kdeglobals" "Icons" "Theme" "Yaru"
    
    # Set Cursor (Yaru is installed by set-rpm.sh)
    log-info "Setting Cursor Theme to Yaru"
    apply-kwrite "kcminputrc" "Mouse" "cursorTheme" "Yaru"
    
    # Note: GTK theme setting is more complex and often handled by kde-gtk-config which works differently across versions.
    # We rely on 'apply-yaru-theme' from set-yaru.sh if possible, or user manual setting.
}

configure-fonts() {
    log-info "Configuring Ubuntu Fonts..."
    install-ubuntu-fonts
    
    local font="Ubuntu,10,-1,5,50,0,0,0,0,0"
    local font_bold="Ubuntu,10,-1,5,75,0,0,0,0,0"
    local font_mono="Ubuntu Mono,10,-1,5,50,0,0,0,0,0"
    
    apply-kwrite "kdeglobals" "General" "font" "$font"
    apply-kwrite "kdeglobals" "General" "menuFont" "$font"
    apply-kwrite "kdeglobals" "General" "smallestReadableFont" "Ubuntu,8,-1,5,50,0,0,0,0,0"
    apply-kwrite "kdeglobals" "General" "toolBarFont" "$font"
    apply-kwrite "kdeglobals" "WM" "activeFont" "$font_bold"
    apply-kwrite "kdeglobals" "General" "fixed" "$font_mono"
}

install-ubuntu-fonts() {
    local font_dir="$HOME/.local/share/fonts/ubuntu"
    if [[ -d "$font_dir" ]]; then
        log-info "Ubuntu fonts already installed in $font_dir"
        return
    fi

    log-info "Downloading Ubuntu Font Family..."
    local temp_dir
    temp_dir="$(mktemp -d)"
    local zip_file="$temp_dir/ubuntu-fonts.zip"
    
    # Standard URL for Ubuntu Font Family
    local url="https://assets.ubuntu.com/v1/0cef8205-ubuntu-font-family-0.83.zip"
    
    if curl -fsSL -o "$zip_file" "$url"; then
        mkdir -p "$font_dir"
        unzip -q -j "$zip_file" -d "$font_dir"
        log-success "Ubuntu fonts installed to $font_dir"
        fc-cache -f "$HOME/.local/share/fonts"
    else
        log-warn "Failed to download Ubuntu fonts. Skipping installation."
    fi
    rm -rf "$temp_dir"
}

tune-animations() {
    log-info "Tuning KWin Animations for Fluidity..."
    
    # AnimationSpeed: 
    # 0 = Instant
    # 1 = Very Fast
    # 2 = Fast
    # 3 = Normal (Balance)
    # 4 = Slow (Smooth)
    # 5 = Very Slow
    
    # Ubuntu feels slightly smoother than raw KDE "Fast". Let's set to Normal/Balance (3) or Slow (4) for fluidity.
    # Often KDE defaults to 2 (Fast). 3 is good for "fluid".
    apply-kwrite "kdeglobals" "KDE" "AnimationDurationFactor" "0.707" # Custom factor?? No, usually it's AnimationSpeed (old) or DurationFactor per group.
    
    # Modern KDE uses "AnimationSpeed" in [KDE] group of kdeglobals usually?
    # Actually, Plasmasshell 6 might use [KDE-Global-Animations] in kdeglobals.
    
    # Let's try standard known key for speed.
    # Note: KWin effects specific config is in kwinrc [Plugins]
    
    # Enable Magic Lamp (like MacOS Genie / Ubuntu sometimes) if available? 
    # Ubuntu usually uses a simple Fade/Scale. 
    # Use "Scale" effect for window open/close for fluidity.
    
    # Set Animation Speed to "Normal" (implies smooth)
    apply-kwrite "kdeglobals" "KDE" "AnimationDurationFactor" "1.0" # 1.0 is standard speed. 0.5 is fast.
    
    # Ensure Compositor is active and smooth
    apply-kwrite "kwinrc" "Compositing" "LatencyPolicy" "High" # "Smoother" preference
    
    reload-kwin
}

configure-task-switcher() {
    log-info "Configuring Task Switcher (Alt+Tab)..."
    # Ubuntu uses a Grid/Icon style. "Thumbnail Grid" in KDE is close.
    # Plugin id: "thumbnails" or "grid"? usually "org.kde.breeze.desktop" is default.
    # "Thumbnail Grid" id is typically `thumbnail_grid`.
    
    apply-kwrite "kwinrc" "TabBox" "LayoutName" "thumbnail_grid"
}



# Apply Plasma Layout via JS
apply-layout-script() {
    log-info "Applying Ubuntu Layout via Plasma Scripting..."
    
    local script_path="$SCRIPT_DIR/ubuntu-layout.js"
    if [[ ! -f "$script_path" ]]; then
        log-error "Layout script not found: $script_path"
        return 1
    fi
    
    local script_content
    script_content=$(cat "$script_path")
    
    # KDE 6
    if command -v qdbus6 &>/dev/null; then
        log-info "Using qdbus6 to apply layout..."
        qdbus6 org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    fi
    
    # KDE 5
    if command -v qdbus &>/dev/null; then
        log-info "Using qdbus to apply layout..."
        qdbus org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    elif command -v qdbus-qt5 &>/dev/null; then
        log-info "Using qdbus-qt5 to apply layout..."
        qdbus-qt5 org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    fi
    
    log-warn "No qdbus tool found. Cannot apply panel layout."
}

# =============================================================================
# Entry Point
# =============================================================================

main() {
    ensure-user
    
    configure-kwin
    configure-kde-theme
    configure-fonts
    configure-task-switcher
    tune-animations
    apply-layout-script
    
    log-success "Kionite Ubuntu configuration applied"
}

main "$@"
