; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Button1"]] := mV2Gui["1"].Add("Button","vButton1","Button1")
mV2GC[["1","Button1"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["1","Button2"]] := mV2Gui["1"].Add("Button","vButton2","Button2")
mV2GC[["1","Button2"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["1","Button3"]] := mV2Gui["1"].Add("Button","vButton3","Button3")
mV2GC[["1","Button3"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["1","Button4"]] := mV2Gui["1"].Add("Button","vButton4","Button4")
mV2GC[["1","Button4"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["1","Button5"]] := mV2Gui["1"].Add("Button","vButton5","Button5")
mV2GC[["1","Button5"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2Gui["1"].Title := "Test"
mV2Gui["1"].Show()
Return

ButtonPress:
ButtonPress()
Return

;###############  V1toV2 FUNCS  ###############
ButtonPress(A_GuiEvent:="", A_GuiControl:="", Info:="", *)
{ ; V1toV2: Lbl->Func
;global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("You pressed:" A_GuiControl)
Return
}