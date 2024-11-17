Tray:= A_TrayMenu
Tray.Add("Reload Wallpaper Launcher", lbReload)
Tray.Add("Exit", lbExit)
Tray.Add("Change Wallpaper", lbChangeWallpaper)

lbReload(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Reload()
} ; V1toV2: Added Bracket before label
; missing 'return' here results in missing closing brace for converted function

lbExit(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()
} ; V1toV2: Added Bracket before label

lbChangeWallpaper(A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Run(WallpaperChangerScript)
return
} ; V1toV2: Added bracket in the end