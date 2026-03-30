#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","OK"]] := mV2Gui[""].Add("Button",,"OK")
mV2GC[["","OK"]].OnEvent("Click",ButtonOK.Bind("Normal"))
mV2Gui[""].Show()
Return

ButtonOK:
ButtonOK()
return

;###############  V1toV2 FUNCS  ###############
ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2Gui[""].Hide()
}