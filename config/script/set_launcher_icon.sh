#!/usr/bin/bash
set -e

# Function to set KDE default launcher icon
set_launcher_icon() {
    echo "Setting KDE default launcher icon"
    
    local config_file="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    
    if [ ! -f "$config_file" ]; then
        echo "Plasma config file not found. Please run this after first login."
        exit 1
    fi
    
    # Find the kickoff applet section and add/update the icon setting
    # The default KDE icon is "start-here-kde-plasma"
    local kickoff_section=$(grep -n "plugin=org.kde.plasma.kickoff" "$config_file" | head -1 | cut -d: -f1)
    
    if [ -z "$kickoff_section" ]; then
        echo "Kickoff applet not found in config"
        exit 1
    fi
    
    # Check if there's already a General section for kickoff
    local general_section=$(grep -n "\[Containments\]\[.*\]\[Applets\]\[.*\]\[Configuration\]\[General\]" "$config_file" | while read line; do
        line_num=$(echo "$line" | cut -d: -f1)
        if [ "$line_num" -gt "$kickoff_section" ]; then
            echo "$line_num"
            break
        fi
    done)
    
    # Use kwriteconfig6 to set the icon (preferred method for KDE 6)
    if command -v kwriteconfig6 &> /dev/null; then
        # Find the applet ID for kickoff
        local applet_id=$(grep -B1 "plugin=org.kde.plasma.kickoff" "$config_file" | grep -oP '\[Applets\]\[\K[0-9]+')
        local containment_id=$(grep -B1 "plugin=org.kde.plasma.kickoff" "$config_file" | grep -oP '\[Containments\]\[\K[0-9]+')
        
        if [ -n "$applet_id" ] && [ -n "$containment_id" ]; then
            kwriteconfig6 --file "$config_file" \
                --group "Containments" --group "$containment_id" \
                --group "Applets" --group "$applet_id" \
                --group "Configuration" --group "General" \
                --key "icon" "start-here-kde-plasma"
            echo "Launcher icon set to KDE Plasma default"
        else
            echo "Could not find kickoff applet configuration"
            exit 1
        fi
    else
        echo "kwriteconfig6 not found, manual configuration required"
        exit 1
    fi
    
    echo "Done! Please restart Plasma or log out/in for changes to take effect."
    echo "You can restart Plasma with: kquitapp6 plasmashell && kstart plasmashell"
}

# Main execution
main() {
    set_launcher_icon
}

main
