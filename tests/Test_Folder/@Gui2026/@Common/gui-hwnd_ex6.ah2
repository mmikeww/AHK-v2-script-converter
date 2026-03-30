#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Text"]] := mV2Gui[""].Add("Button",,"Text.")
VAR := mV2GC[["","Text"]].hwnd
mV2Gui[""].Show()