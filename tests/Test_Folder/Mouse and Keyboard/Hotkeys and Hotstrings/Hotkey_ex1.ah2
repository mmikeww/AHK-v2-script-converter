Hotkey("^!z", MyLabel)
return

MyLabel(ThisHotkey)
{ ; V1toV2: Added bracket
MsgBox("You pressed " A_ThisHotkey ".")
return
} ; V1toV2: Added bracket in the end
