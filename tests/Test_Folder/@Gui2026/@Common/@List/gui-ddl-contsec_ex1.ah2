#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("DDL","Choose5",["A","B","C","D","E","F"])
MsgBox("Line 1")

mV2Gui[""].Add("DDL","Choose6",["A","B","C","D","E","F"])



MsgBox("Line 2")

mV2Gui[""].Show()