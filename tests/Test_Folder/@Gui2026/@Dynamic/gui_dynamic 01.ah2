#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
Title := "MyTitle"
mV2Gui[""] := NewV2Gui("",1,"+LastFound")
hwnd := mV2Gui[""].Hwnd
mV2Gui[""].OnEvent("Close",guiClose)
mV2Gui[""].OnEvent("Escape",guiEscape)
mV2GC[["","test"]] := mV2Gui[""].add("button",,"test")
mV2GC[["","test"]].OnEvent("Click",btnTest.Bind("Normal"))
h := hwnd
If (!HasV2Gui(h)) {
    mV2Gui[h] := NewV2Gui(h)
}
mV2Gui[h].Title := Title " " h
mV2Gui[h].Show("w300 h100")

return
btnTest:
btnTest()
return

guiEscape:
guiEscape()
return
guiClose:
guiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
btnTest(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("tested")
return
}
;##############################################
guiEscape(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("escape and close")
guiClose()
}
;##############################################
guiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}