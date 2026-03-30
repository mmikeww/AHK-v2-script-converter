#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Name"]] := mV2Gui[""].Add("Button","w100","Name")
mV2GC[["","Name"]].OnEvent("Click",ButtonName.Bind("Normal"))
mV2GC[["","@EDIT1"]] := mV2Gui[""].Add("Edit","R2 w100","Test`nTest")
mV2GC[["","@EDIT1"]].OnEvent("Change",ButtonName.Bind("Normal"))
mV2Gui[""].Show("w120")
Return

ButtonName:
ButtonName()
return

;###############  V1toV2 FUNCS  ###############
ButtonName(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
}