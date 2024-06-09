; systray root menu (should be TraySetIcon)
Menu, Tray, Add   ;Add separator line
Menu, Tray, Icon, %A_ScriptDir%\WallpaperLauncher\screen.ico   ;Add tray icon
Menu, Tray, Tip, Wallpaper Launcher V4 `nDouble-click to change wallpaper`nRight-click for more options   ;Add tooltip

; menuItem/submenu (should be Tray.SetIcon)
Menu, Tray, Add, Change Wallpaper, lbChangeWallpaper   ;Add menu item
Menu, Tray, Icon, Change Wallpaper, %A_ScriptDir%\WallpaperLauncher\screen.ico   ;Add menu icon