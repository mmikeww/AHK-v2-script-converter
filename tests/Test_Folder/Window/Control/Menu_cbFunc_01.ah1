Menu, Tray, Add, Reload Wallpaper Launcher, lbReload
Menu, Tray, Add, Exit, lbExit
Menu, Tray, Add, Change Wallpaper, lbChangeWallpaper

lbReload:
Reload
; missing 'return' here results in missing closing brace for converted function

lbExit:
exitapp

lbChangeWallpaper:
Run %WallpaperChangerScript%
return