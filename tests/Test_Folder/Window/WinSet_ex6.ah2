Persistent
SetTimer(WatchForMenu,5)
return  ; End of auto-execute section.

WatchForMenu()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
DetectHiddenWindows(true)  ; Might allow detection of menu sooner.
if WinExist("ahk_class #32768")
    WinSetTransparent(150)  ; Uses the window found by the above line.
return
} ; V1toV2: Added bracket in the end