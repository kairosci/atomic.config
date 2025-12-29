#!/usr/bin/bash
set -e

# Disable plasma-emojier via local override

disable_plasma_emojier() {
    echo "Disabling plasma-emojier"
    
    # Get actual user home (not root when running with sudo)
    local user_home
    if [ -n "$SUDO_USER" ]; then
        user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        user_home="$HOME"
    fi
    
    local local_apps_dir="$user_home/.local/share/applications"
    local emojier_desktop="$local_apps_dir/org.kde.plasma.emojier.desktop"
    
    mkdir -p "$local_apps_dir"
    
    if [ ! -f "$emojier_desktop" ]; then
        cat > "$emojier_desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Emoji Selector
Hidden=true
NoDisplay=true
EOF
        # Fix ownership if running as sudo
        if [ -n "$SUDO_USER" ]; then
            chown "$SUDO_USER:$SUDO_USER" "$emojier_desktop"
        fi
        echo "Emojier hidden"
    else
        echo "Emojier already hidden"
    fi
    
    echo "Done"
}

main() {
    disable_plasma_emojier
}

main
