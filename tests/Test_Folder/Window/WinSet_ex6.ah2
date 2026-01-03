#Warn Unreachable, Off
Persistent
SetTimer(WatchForMenu,5)
return  ; End of auto-execute section.

WatchForMenu:
WatchForMenu()
return

;###############  V1toV2 FUNCS  ###############
WatchForMenu() { ; V1toV2: Lbl->Func
global
DetectHiddenWindows(true)  ; Might allow detection of menu sooner.
if WinExist("ahk_class #32768")
    WinSetTransparent(150)  ; Uses the window found by the above line.
return
}