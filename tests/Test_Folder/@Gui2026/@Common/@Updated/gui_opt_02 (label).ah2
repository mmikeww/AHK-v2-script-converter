; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("MyGui")) {
    mV2Gui["MyGui"] := NewV2Gui("MyGui")
}
mV2Gui["MyGui"].Opt("+Resize")
h := mV2Gui["MyGui"].Hwnd
mV2Gui["MyGui"].OnEvent("Close",MainClose)
mV2Gui["MyGui"].OnEvent("Escape",MainEscape)
mV2Gui["MyGui"].Show("w150 h150")

return
MainEscape:
MainEscape()
return

MainClose:
MainClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
MainEscape(*) { ; V1toV2: Lbl->Func
global
MsgBox("Escape")
return
}
;##############################################
MainClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("Closing")
ExitApp()
}