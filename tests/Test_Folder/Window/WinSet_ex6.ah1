#Persistent
SetTimer, WatchForMenu, 5
return  ; End of auto-execute section.

WatchForMenu:
DetectHiddenWindows, On  ; Might allow detection of menu sooner.
if WinExist("ahk_class #32768")
    WinSet, Transparent, 150  ; Uses the window found by the above line.
return