; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
mV2Gui["1"] := NewV2Gui("1","+resize")
mV2Gui["1"].OnEvent("Close",my_lblClose)
mV2Gui["1"].OnEvent("Escape",my_lblEscape)
mV2Gui["1"].OnEvent("Size",my_lblSize)
mV2Gui["1"].show("w100 h100")

return
my_lblEscape:
my_lblEscape()
return

my_lblClose:
my_lblClose()
ExitApp()
return

my_lblSize:
my_lblSize()
return

;###############  V1toV2 FUNCS  ###############
my_lblEscape(*) { ; V1toV2: Lbl->Func
global
MsgBox("escape")
return
}
;##############################################
my_lblClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("closing")
ExitApp()
}
;##############################################
my_lblSize(thisGui:="", MinMax:="", A_GuiWidth:="", A_GuiHeight:="") { ; V1toV2: Lbl->Func
global
WinGetPos(&X, &Y, &W, &H)
ToolTip("x " x " y " y " w " w " h " h)
return
}