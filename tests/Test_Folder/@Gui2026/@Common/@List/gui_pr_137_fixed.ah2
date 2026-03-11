; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("DDL","Choose5",["1","2","3","4","","","5"])
mV2Gui["1"].Add("DDL","Choose7",["6","","7","","8","","9"])
mV2Gui["1"].Show()