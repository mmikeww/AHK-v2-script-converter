#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
mV2Gui[""] := NewV2Gui("",1,"+resize")
mV2Gui[""].OnEvent("Close",my_lblClose)
mV2Gui[""].OnEvent("Escape",my_lblEscape)
mV2Gui[""].OnEvent("Size",my_lblSize)
mV2Gui[""].show("w100 h100")

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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("escape")
return
}
;##############################################
my_lblClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("closing")
ExitApp()
}
;##############################################
my_lblSize(thisGui:="", MinMax:="", A_GuiWidth:="", A_GuiHeight:="") { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
WinGetPos(&X, &Y, &W, &H)
ToolTip("x " x " y " y " w " w " h " h)
return
}