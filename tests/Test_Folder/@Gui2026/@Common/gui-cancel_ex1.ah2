; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","OK"]] := mV2Gui["1"].Add("Button",,"OK")
mV2GC[["1","OK"]].OnEvent("Click",ButtonOK.Bind("Normal"))
mV2Gui["1"].Show()
Return

ButtonOK:
ButtonOK()
return

;###############  V1toV2 FUNCS  ###############
ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
mV2Gui["1"].Hide()
}