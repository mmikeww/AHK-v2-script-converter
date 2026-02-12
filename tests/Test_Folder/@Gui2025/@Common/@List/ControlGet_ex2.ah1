Gui, Add, Tab3,, General|View||Settings
Gui, Show , , Some Window Title
ControlGet, WhichTab, Tab,, SysTabControl321, Some Window Title
MsgBox Tab #%WhichTab% is active.