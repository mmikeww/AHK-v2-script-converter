; systray root menu (should be TraySetIcon)
Tray:= A_TrayMenu
Tray.Add()   ;Add separator line
TraySetIcon(A_ScriptDir . "\WallpaperLauncher\screen.ico")   ;Add tray icon
A_IconTip := "Wallpaper Launcher V4 `nDouble-click to change wallpaper`nRight-click for more options"   ;Add tooltip

; menuItem/submenu (should be Tray.SetIcon)
Tray.Add("Change Wallpaper", lbChangeWallpaper)   ;Add menu item
Tray.SetIcon("Change Wallpaper", A_ScriptDir . "\WallpaperLauncher\screen.ico")   ;Add menu icon