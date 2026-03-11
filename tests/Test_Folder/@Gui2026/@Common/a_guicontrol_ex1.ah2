; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Name"]] := mV2Gui["1"].Add("Button","w100","Name")
mV2GC[["1","Name"]].OnEvent("Click",ButtonName.Bind("Normal"))
mV2GC[["1","@EDIT1"]] := mV2Gui["1"].Add("Edit","R2 w100","Test`nTest")
mV2GC[["1","@EDIT1"]].OnEvent("Change",ButtonName.Bind("Normal"))
mV2Gui["1"].Show("w120")
Return

ButtonName:
ButtonName()
return

;###############  V1toV2 FUNCS  ###############
ButtonName(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl)
}