Persistent
SetTimer(WatchCursor,100)
return

WatchCursor()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MouseGetPos(, , &id, &control)
title := WinGetTitle("ahk_id " id)
class := WinGetClass("ahk_id " id)
ToolTip("ahk_id " id "`nahk_class " class "`n" title "`nControl: " control)
return
} ; V1toV2: Added bracket in the end