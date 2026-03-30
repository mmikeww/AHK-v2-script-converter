#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/232
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text",,"Gui Number 1")
mV2GC[["","Edit1"]] := mV2Gui[""].Add("Edit","vEdit1","I love to edit")
mV2GC[["","OpenGUI2"]] := mV2Gui[""].Add("Button",,"Open GUI 2")
mV2GC[["","OpenGUI2"]].OnEvent("Click",Open2Gui.Bind("Normal"))
mV2GC[["","Submitmyedit"]] := mV2Gui[""].Add("Button",,"Submit my edit")
mV2GC[["","Submitmyedit"]].OnEvent("Click",SumbitResults.Bind("Normal"))
mV2Gui[""].Show("w150")
Return

Open2Gui:
Open2Gui()
Return

SumbitResults:
SumbitResults()
Return

;###############  V1toV2 FUNCS  ###############
Open2Gui(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2Gui[""] := NewV2Gui("",1)
mV2Gui[""].Add("Text",,"Gui Number 2")
mV2GC[["","Edit2"]] := mV2Gui[""].Add("Edit","vEdit2","I love to button")
mV2GC[["","Submitmyedit"]] := mV2Gui[""].Add("Button",,"Submit my edit")
mV2GC[["","Submitmyedit"]].OnEvent("Click",SumbitResults.Bind("Normal"))
mV2Gui[""].Show("w100")
Return
}
;##############################################
SumbitResults(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui])
MsgBox(Edit1)
Return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    Edit1 := ""
    Edit2 := ""
}