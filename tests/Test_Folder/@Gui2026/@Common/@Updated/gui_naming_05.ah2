#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("g1")) {
    mV2Gui["g1"] := NewV2Gui("g1")
}
mV2GC[["g1","B1"]] := mV2Gui["g1"].Add("Button",,"B1")
mV2Gui["g1"].Show("w300 h300")
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Show("w200 h200")
mV2GC[["","B2"]] := mV2Gui[""].Add("Button",,"B2")