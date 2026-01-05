# Fedora Atomic Config

> 🚀 Configuration scripts for **Fedora Kionite** (KDE Plasma) and **Fedora Silverblue** (GNOME) with automatic distro detection.

## ✨ Features

| Feature | Kionite | Silverblue |
|---------|:-------:|:----------:|
| Distro Detection | ✅ | ✅ |
| Remove Bloatware | ✅ | ✅ |
| Install Brave Browser | ✅ | ✅ |
| Flatpak Setup | ✅ | ✅ |
| TLP Power Management | ✅ | ✅ |
| Distrobox | ✅ | ✅ |
| Libvirt/QEMU | ✅ | ✅ |
| Yaru Theme | ❌ | ✅ |
| GNOME Extensions | ❌ | ✅ |
| KDE Launcher Fix | ✅ | ❌ |
| Konsole Profile | ✅ | ❌ |

## 🎨 Themes

**Kionite:** Breeze GTK + Adwaita GTK3

**Silverblue:** Yaru (GTK, icons, cursor, sounds) + Dark mode

## 🔌 GNOME Extensions (Silverblue)

Scripts configure Ubuntu-like experience:

- **Dash to Dock** — Bottom dock with intellihide
- **AppIndicator** — System tray icons
- **Blur my Shell** — Blur effects
- **Just Perfection** — Desktop tweaks, faster animations
- **Caffeine** — Prevent auto-suspend

## 📦 Installation

```bash
git clone https://codeberg.org/kairosci/kionite-config.git
cd kionite-config
sudo ./setup.sh
```

Restart terminal, then run:

```bash
kionite
```

## 🗂️ Structure

```
├── lib/common.sh           # Shared utilities + detect-distro()
├── config/
│   ├── index.sh            # Main entry point
│   └── script/
│       ├── kionite/        # KDE-specific scripts
│       ├── silverblue/     # GNOME-specific scripts
│       └── *.sh            # Common scripts
└── utils/                  # Utility scripts
```

## 🛠️ Dev Tools

> **Note:** Development packages (nodejs, clang, cmake...) should be installed inside **Distrobox** containers, not in the base system.

## 📜 License

MIT
