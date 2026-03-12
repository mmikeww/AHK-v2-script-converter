; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
Title := "MyTitle"
mV2Gui["v1Gui:hwnd"] := NewV2Gui("v1Gui:hwnd","+LastFound")
hwnd := mV2Gui["v1Gui:hwnd"].Hwnd
mV2Gui["v1Gui:hwnd"].OnEvent("Close",guiClose)
mV2Gui["v1Gui:hwnd"].OnEvent("Escape",guiEscape)
mV2GC[["v1Gui:hwnd","test"]] := mV2Gui["v1Gui:hwnd"].add("button",,"test")
mV2GC[["v1Gui:hwnd","test"]].OnEvent("Click",btnTest.Bind("Normal"))
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
MsgBox("tested")
return
}
;##############################################
guiEscape(*) { ; V1toV2: Lbl->Func
global
MsgBox("escape and close")
guiClose()
}
;##############################################
guiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}