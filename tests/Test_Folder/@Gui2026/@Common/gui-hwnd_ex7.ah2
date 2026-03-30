#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Var"]] := mV2Gui[""].Add("Text",,"Text")
Var := mV2GC[["","Var"]].hwnd
mV2Gui[""].Show("w200 h200")