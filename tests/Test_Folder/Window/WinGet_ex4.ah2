Persistent
SetTimer(WatchActiveWindow,200)
return

WatchActiveWindow()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
oControlList := WinGetControls("A",,,)
For v in oControlList
{
   ControlList .= A_index=1 ? v : "`r`n" v
}
ToolTip(ControlList)
return
} ; V1toV2: Added bracket in the end