#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Button1"]] := mV2Gui[""].Add("Button",,"Button 1")
mV2GC[["","Button1"]].OnEvent("Click",b1.Bind("Normal"))
mV2GC[["","e1"]] := mV2Gui[""].Add("Edit","ve1","Some Text")
mV2Gui[""].Show()
Return

b1:
b1()
return

;###############  V1toV2 FUNCS  ###############
b1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
Var := "Focus" ; This fix works with focus, others won't
mV2GC[["","e1"]].%var%() ; V1toV2: SubCommand passed as variable, check variable contents and docs
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    e1 := ""
}
