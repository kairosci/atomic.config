#!/usr/bin/bash
set -e

# Hide URW35 fonts from applications via fontconfig (system and user level)

FONTCONFIG_CONTENT='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- Hide URW35 fonts from applications -->
    <selectfont>
        <rejectfont>
            <glob>/usr/share/fonts/urw-base35/*</glob>
        </rejectfont>
    </selectfont>
</fontconfig>'

hide_urw_fonts_system() {
    echo "Hiding URW35 fonts (system level)"
    
    local system_conf="/etc/fonts/conf.d/99-hide-urw-fonts.conf"
    
    if [ ! -f "$system_conf" ]; then
        echo "$FONTCONFIG_CONTENT" | sudo tee "$system_conf" > /dev/null
        echo "System config created"
    else
        echo "System config already exists"
    fi
}

hide_urw_fonts_user() {
    echo "Hiding URW35 fonts (user level)"
    
    # Get actual user home (not root when running with sudo)
    local user_home
    if [ -n "$SUDO_USER" ]; then
        user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    else
        user_home="$HOME"
    fi
    
    local fontconfig_dir="$user_home/.config/fontconfig/conf.d"
    local user_conf="$fontconfig_dir/99-hide-urw-fonts.conf"
    
    mkdir -p "$fontconfig_dir"
    
    if [ ! -f "$user_conf" ]; then
        echo "$FONTCONFIG_CONTENT" > "$user_conf"
        # Fix ownership if running as sudo
        if [ -n "$SUDO_USER" ]; then
            chown -R "$SUDO_USER:$SUDO_USER" "$user_home/.config/fontconfig"
        fi
        echo "User config created"
    else
        echo "User config already exists"
    fi
}

refresh_font_cache() {
    echo "Refreshing font cache"
    fc-cache -f
    echo "Done"
}

main() {
    hide_urw_fonts_system
    hide_urw_fonts_user
    refresh_font_cache
}

main
