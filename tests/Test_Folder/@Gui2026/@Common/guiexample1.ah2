; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Text",,"Please enter your name:")
mV2GC[["1","Name"]] := mV2Gui["1"].Add("Edit","vName")
mV2Gui["1"].Show()