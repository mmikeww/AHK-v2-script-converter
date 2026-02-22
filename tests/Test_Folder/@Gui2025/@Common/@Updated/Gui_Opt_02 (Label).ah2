#Warn Unreachable, Off
MyGui := Gui()
MyGui.Opt("+Resize"), h := MyGui.Hwnd
MyGui.OnEvent("Close", MainClose)
MyGui.OnEvent("Escape", MainEscape)
MyGui.Show("w150 h150")

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