#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","MyEdit"]] := mV2Gui[""].Add("Edit","vMyEdit w100 h100","Test")
mV2Gui[""].SetFont("s30 cRed","Verdana")  ; If desired, use a line like this to set a new default font for the window.
mV2GC[["","MyEdit"]].SetFont("s30 cRed","Verdana")  ; Put the above font into effect for a control.
mV2Gui[""].Show()

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    MyEdit := ""
}