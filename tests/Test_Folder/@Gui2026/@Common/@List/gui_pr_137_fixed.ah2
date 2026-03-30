#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("DDL","Choose5",["1","2","3","4","","","5"])
mV2Gui[""].Add("DDL","Choose7",["6","","7","","8","","9"])
mV2Gui[""].Show()