#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].add("text",,"
(Ltrim
Continuation section
    Indented
)")
mV2Gui[""].Show()