; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("g1")) {
    mV2Gui["g1"] := NewV2Gui("g1")
}
mV2GC[["g1","B1"]] := mV2Gui["g1"].Add("Button",,"B1")
mV2Gui["g1"].Show("w300 h300")
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Show("w200 h200")
mV2GC[["1","B2"]] := mV2Gui["1"].Add("Button",,"B2")