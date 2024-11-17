Hotkey("^!z", MyLabel)
return

MyLabel(ThisHotkey)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("You pressed " A_ThisHotkey ".")
return
} ; V1toV2: Added bracket in the end