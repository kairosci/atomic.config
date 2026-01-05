#!/usr/bin/bash
# =============================================================================
# Set Ubuntu Look (Kionite)
# =============================================================================

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../lib/common.sh"

readonly YARU_KDE_REPO="https://github.com/ubuntu/yaru.git"
readonly LAYOUT_SCRIPT="https://raw.githubusercontent.com/L4ki/Plasma-Desktop-Script/master/plasma-layout-ubuntu.js"

install-yaru-kde() {
    log-info "Installing Yaru-KDE theme..."
    require-command git "git is required to install Yaru-KDE"
    
    local temp_dir
    temp_dir="$(mktemp -d)"
    
    log-info "Cloning Yaru repository..."
    git clone --depth 1 "$YARU_KDE_REPO" "$temp_dir/yaru"
    
    local plasma_version
    plasma_version=$(rpm -q plasma-workspace | grep -oP 'plasma-workspace-\K\d' || echo "6")
    log-info "Detected Plasma version: $plasma_version"
    
    local user_theme_dir="$HOME/.local/share/plasma/look-and-feel"
    mkdir -p "$user_theme_dir"
}

apply-ubuntu-layout() {
    log-info "Applying Ubuntu-like Panel Layout..."
    
    if [[ -z "${KDE_FULL_SESSION:-}" ]]; then
        log-warn "Not running in a KDE session. Layout changes might not apply immediately."
    fi
    
    # 1. Top Panel
    # 2. Left Dock (Panel)
    
    log-info "Configuring Panels..."
    log-warn "This will reset your current Plasma panel configuration."
}

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
    
    if command -v qdbus6 &>/dev/null; then
        qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    elif command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    elif command -v qdbus-qt5 &>/dev/null; then
        qdbus-qt5 org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
}

configure-kwin() {
    log-info "Configuring KWin (Window Manager)..."
    
    apply-kwrite "kwinrc" "org.kde.kdecoration2" "ButtonsOnLeft" "XIAM"
    apply-kwrite "kwinrc" "org.kde.kdecoration2" "ButtonsOnRight" ""
    
    reload-kwin
}

configure-kde-theme() {
    log-info "Configuring KDE Theme Elements..."
    
    log-info "Setting Icon Theme to Yaru"
    apply-kwrite "kdeglobals" "Icons" "Theme" "Yaru"
    
    log-info "Setting Cursor Theme to Yaru"
    apply-kwrite "kcminputrc" "Mouse" "cursorTheme" "Yaru"
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

tune-animations() {
    log-info "Tuning KWin Animations..."

    # AnimationDurationFactor: 0.5 = Fast (2x speed)
    apply-kwrite "kdeglobals" "KDE" "AnimationDurationFactor" "0.5"
    
    # "High" (ForceSmooth) ensures vsync
    apply-kwrite "kwinrc" "Compositing" "LatencyPolicy" "High"
    
    reload-kwin
}

configure-task-switcher() {
    log-info "Configuring Task Switcher..."
    # "Thumbnail Grid" style
    apply-kwrite "kwinrc" "TabBox" "LayoutName" "thumbnail_grid"
}

apply-layout-script() {
    log-info "Applying Ubuntu Layout via Plasma Scripting..."
    
    local script_path="$SCRIPT_DIR/ubuntu-layout.js"
    if [[ ! -f "$script_path" ]]; then
        log-error "Layout script not found: $script_path"
        return 1
    fi
    
    local script_content
    script_content=$(cat "$script_path")
    
    if command -v qdbus6 &>/dev/null; then
        qdbus6 org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    fi
    
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    elif command -v qdbus-qt5 &>/dev/null; then
        qdbus-qt5 org.kde.Plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script_content"
        return 0
    fi
    
    log-warn "No qdbus tool found. Cannot apply panel layout."
}

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
