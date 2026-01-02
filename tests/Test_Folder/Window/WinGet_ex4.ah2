#Warn Unreachable, Off
Persistent
SetTimer(WatchActiveWindow,200)
return

WatchActiveWindow:
WatchActiveWindow()
return

;###############  V1toV2 FUNCS  ###############
WatchActiveWindow() { ; V1toV2: Lbl->Func
global
oControlList := WinGetControls("A",,,)
For v in oControlList
{
   ControlList .= A_index=1 ? v : "`r`n" v
}
ToolTip(ControlList)
return
}