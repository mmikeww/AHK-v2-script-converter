#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","MyListbox"]] := mV2Gui[""].Add("Listbox","vMyListbox")
mV2Gui[""].Show()
mV2GC[["","MyListbox"]].Opt("+AltSubmit")

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    MyListbox := ""
}