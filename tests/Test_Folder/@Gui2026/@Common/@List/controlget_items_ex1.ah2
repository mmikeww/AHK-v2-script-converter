#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","ColorChoice"]] := mV2Gui[""].Add("ComboBox","vColorChoice",["Red","Green","Blue","Black","White"])
mV2Gui[""].Title := "WinTitle"
mV2Gui[""].Show()
oItems := ControlGetItems("ComboBox1", "WinTitle", , , )
loop oItems.length
{
    Items .= A_index=1 ? "" : "`n"
    Items .= oItems[A_Index] 
}
Loop Parse, Items, "`n"
    MsgBox("Item number " A_Index " is " A_LoopField ".")

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    ColorChoice := ""
}