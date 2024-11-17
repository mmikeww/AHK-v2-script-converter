#Persistent
SetTimer, WatchActiveWindow, 200
return

WatchActiveWindow:
WinGet, ControlList, ControlList, A
ToolTip, %ControlList%
return