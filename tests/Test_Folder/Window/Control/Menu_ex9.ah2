Persistent
Tray := A_TrayMenu
Tray.Delete() ; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning
Tray.Add("Exit", Exit)
Return

Exit:
Exit()
ExitApp()

;###############  V1toV2 FUNCS  ###############
Exit(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
ExitApp()
}