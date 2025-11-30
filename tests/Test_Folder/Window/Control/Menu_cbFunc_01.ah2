Tray := A_TrayMenu
Tray.Add("Reload Wallpaper Launcher", lbReload)
Tray.Add("Exit", lbExit)
Tray.Add("Change Wallpaper", lbChangeWallpaper)

lbReload:
lbReload()
Reload()
; missing 'return' here results in missing closing brace for converted function

lbExit:
lbExit()
ExitApp()

lbChangeWallpaper:
lbChangeWallpaper()
return

;###############  V1toV2 FUNCS  ###############
lbReload(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
Reload()
}
;##############################################
lbExit(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
ExitApp()
}
;##############################################
lbChangeWallpaper(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
Run(WallpaperChangerScript)
return
}