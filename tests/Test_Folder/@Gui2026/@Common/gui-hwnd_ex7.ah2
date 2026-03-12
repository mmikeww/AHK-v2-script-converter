; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Var"]] := mV2Gui["1"].Add("Text",,"Text")
Var := mV2GC[["1","Var"]].hwnd
mV2Gui["1"].Show("w200 h200")