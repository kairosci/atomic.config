#!/usr/bin/bash
set -e

echo "Setting up ProtonMail PWA via Brave"

# Ensure directories exist in /usr/local which is writable
mkdir -p /usr/local/share/applications
mkdir -p /usr/local/share/icons/hicolor/512x512/apps

# Download Icon
echo "Downloading ProtonMail Icon..."
# Using the 2022 App Logo suitable for 512px
curl -L -o /usr/local/share/icons/hicolor/512x512/apps/protonmail.png "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Proton_Mail_app_logo_2022.svg/512px-Proton_Mail_app_logo_2022.svg.png"

# Create Desktop Entry in /usr/local/share/applications
cat <<EOF > /usr/local/share/applications/protonmail-pwa.desktop
[Desktop Entry]
Name=ProtonMail (PWA)
Exec=brave-browser --app=https://mail.proton.me
Icon=protonmail
Type=Application
Categories=Office;Network;Email;
StartupWMClass=mail.proton.me
EOF

echo "ProtonMail PWA configuration created in /usr/local/share/applications"
