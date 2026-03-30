#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text",,"This is GUI 1")
mV2GC[["","NextGUI"]] := mV2Gui[""].Add("Button",,"Next GUI")
mV2GC[["","NextGUI"]].OnEvent("Click",NextGui.Bind("Normal"))
mV2GC[["","Addbutton"]] := mV2Gui[""].Add("Button",,"Add button")
mV2GC[["","Addbutton"]].OnEvent("Click",AddButton.Bind("Normal"))
mV2Gui[""].Show("x50 w200 h200")
NextGui()
NextGUI()
Return

NextGui(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
static x := 50
x += 255
wh := 200
mV2Gui[""] := NewV2Gui("",1)
h := mV2Gui[""].Hwnd ;, +lastFound
mV2Gui[""].Add("Text",,"GUI " . h)
mV2GC[["","Addbutton"]] := mV2Gui[""].Add("Button",,"Add button")
mV2GC[["","Addbutton"]].OnEvent("Click",AddButton.Bind("Normal"))
mV2Gui[""].Show("x" . x . " w" . wh . " h" . wh)
Return
}

AddButton:
AddButton()
Return

ButtonSubmit:
ButtonSubmit()
Return

;###############  V1toV2 FUNCS  ###############
AddButton(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2GC[["","Submit"]] := mV2Gui[""].Add("Button",,"Submit")
mV2GC[["","Submit"]].OnEvent("Click",ButtonSubmit.Bind("Normal"))
Return
}
;##############################################
ButtonSubmit(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox(A_GuiEvent)
Return
}