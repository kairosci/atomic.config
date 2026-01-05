/* Clear existing panels */
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    allPanels[i].remove();
}

/* Top Panel */
var topPanel = new Panel;
topPanel.location = "top";
topPanel.height = 30;

/* Widgets for Top Panel
   Layout: [Spacer] [Clock] [Spacer] ensures centering if AppMenu is not used. 
   Ubuntu style: [Activities/AppMenu] [Spacer] [Clock] [Spacer] [Tray] [User]

   Note: "org.kde.plasma.appmenu" requires kf5-yaru-kde or similar to look like Unity. 
   For modern Gnome look, we just want: [Spacer] [Clock] [Spacer]
   But we need "Activities" button? Usually that's on the dock or a hot corner.
   Let's assume standard Ubuntu: Top Bar has Clock in center. */

var appMenu = topPanel.addWidget("org.kde.plasma.appmenu"); /* Global Menu */
var leftSpacer = topPanel.addWidget("org.kde.plasma.panelspacer");
var clock = topPanel.addWidget("org.kde.plasma.digitalclock");
var rightSpacer = topPanel.addWidget("org.kde.plasma.panelspacer");
var tray = topPanel.addWidget("org.kde.plasma.systemtray");
var uks = topPanel.addWidget("org.kde.plasma.userswitcher");

/* Left Dock (Panel) */
var leftPanel = new Panel;
leftPanel.location = "left";
leftPanel.height = 48; /* Width in vertical mode */
leftPanel.offset = 0;

/* Widgets for Left Dock
   Ubuntu: Pinned Apps -> Spacer -> Trash -> Show Apps (at very bottom)
   KDE: Kickoff is the best "Show Apps" equivalent. 
   We place Task Manager first, then Spacer, then Kickoff at bottom?
   Or Kickoff at top (Activities style)?
   Let's go with: Kickoff (Top/Activities) -> TaskManager -> Spacer -> Trash */

var appLauncher = leftPanel.addWidget("org.kde.plasma.kickoff");
appLauncher.writeConfig("icon", "start-here"); /* Use distro icon or specific */

var taskManager = leftPanel.addWidget("org.kde.plasma.icontasks");
var dockSpacer = leftPanel.addWidget("org.kde.plasma.panelspacer");
var trash = leftPanel.addWidget("org.kde.plasma.trash");

/* Configure Task Manager (optional) */
taskManager.currentConfigGroup = ["General"];
taskManager.writeConfig("launchers", "applications:firefox.desktop,applications:org.kde.dolphin.desktop,applications:org.kde.konsole.desktop");

/* Apply */
topPanel.reloadConfig();
leftPanel.reloadConfig();
