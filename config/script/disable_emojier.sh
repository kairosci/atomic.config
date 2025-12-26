#!/usr/bin/bash
set -e

# Function to disable plasma-emojier
disable_plasma_emojier() {
    echo "Disabling plasma-emojier..."
    
    # Hide the application from launchers by copying to local and setting Hidden=true
    local local_apps_dir="$HOME/.local/share/applications"
    mkdir -p "$local_apps_dir"
    
    # Create override desktop file to hide emojier
    cat > "$local_apps_dir/org.kde.plasma.emojier.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Emoji Selector
Hidden=true
NoDisplay=true
EOF
    
    # Disable global keyboard shortcut for emojier
    local kglobalaccel_dir="$HOME/.local/share/kglobalaccel"
    mkdir -p "$kglobalaccel_dir"
    
    # Create override to disable the global shortcut
    cat > "$kglobalaccel_dir/org.kde.plasma.emojier.desktop" <<EOF
[Global Shortcuts]
_k_friendly_name=Emoji Selector
show=none
EOF
    
    echo "plasma-emojier disabled successfully."
    echo "Note: The emojier binary still exists in /usr/bin/plasma-emojier but won't be accessible via launcher or shortcuts."
}

# Main execution
main() {
    disable_plasma_emojier
}

main
