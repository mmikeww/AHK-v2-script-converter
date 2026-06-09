#Warn Unreachable, Off
Persistent
Tray := A_TrayMenu
Tray.Delete() ; V1toV2: Will simulate v1 NoStandard, only when placed immediately after menu ini
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