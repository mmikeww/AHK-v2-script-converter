#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Button1"]] := mV2Gui[""].Add("Button","vButton1","Button1")
mV2GC[["","Button1"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["","Button2"]] := mV2Gui[""].Add("Button","vButton2","Button2")
mV2GC[["","Button2"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["","Button3"]] := mV2Gui[""].Add("Button","vButton3","Button3")
mV2GC[["","Button3"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["","Button4"]] := mV2Gui[""].Add("Button","vButton4","Button4")
mV2GC[["","Button4"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2GC[["","Button5"]] := mV2Gui[""].Add("Button","vButton5","Button5")
mV2GC[["","Button5"]].OnEvent("Click",ButtonPress.Bind("Normal"))
mV2Gui[""].Title := "Test"
mV2Gui[""].Show()
Return

ButtonPress:
ButtonPress()
Return

;###############  V1toV2 FUNCS  ###############
ButtonPress(A_GuiEvent:="", A_GuiControl:="", Info:="", *)
{ ; V1toV2: Lbl->Func
;global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("You pressed:" A_GuiControl)
Return
}