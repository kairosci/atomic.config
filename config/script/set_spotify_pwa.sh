#!/usr/bin/bash
set -e

echo "Setting up Spotify PWA via Brave"

# Ensure directories exist in /usr/local which is writable
mkdir -p /usr/local/share/applications
mkdir -p /usr/local/share/icons/hicolor/512x512/apps

# Download Icon
echo "Downloading Spotify Icon..."
# Using a high quality PNG icon
curl -L -o /usr/local/share/icons/hicolor/512x512/apps/spotify.png "https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/Spotify_logo_without_text.svg/512px-Spotify_logo_without_text.svg.png"

# Create Desktop Entry in /usr/local/share/applications
cat <<EOF > /usr/local/share/applications/spotify-pwa.desktop
[Desktop Entry]
Name=Spotify (PWA)
Exec=brave-browser --app=https://open.spotify.com
Icon=spotify
Type=Application
Categories=Audio;Music;
StartupWMClass=open.spotify.com
EOF

echo "Spotify PWA configuration created in /usr/local/share/applications"
