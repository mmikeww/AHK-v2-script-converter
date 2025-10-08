Hotkey("^!z", MyLabel)
return

MyLabel:
MyLabel()
return

;###############  V1toV2 FUNCS  ###############
MyLabel(ThisHotkey:="") { ; V1toV2: Lbl->Func
global
MsgBox("You pressed " A_ThisHotkey ".")
return
}