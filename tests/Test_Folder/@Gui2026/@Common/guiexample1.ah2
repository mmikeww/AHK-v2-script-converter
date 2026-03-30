#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text",,"Please enter your name:")
mV2GC[["","Name"]] := mV2Gui[""].Add("Edit","vName")
mV2Gui[""].Show()

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    Name := ""
}