#Warn Unreachable, Off
Persistent
SetTimer(WatchCursor,100)
return

WatchCursor:
WatchCursor()
return

;###############  V1toV2 FUNCS  ###############
WatchCursor() { ; V1toV2: Lbl->Func
global
MouseGetPos(, , &id, &control)
title := WinGetTitle("ahk_id " id)
class := WinGetClass("ahk_id " id)
ToolTip("ahk_id " id "`nahk_class " class "`n" title "`nControl: " control)
return
}