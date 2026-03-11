; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Text"]] := mV2Gui["1"].Add("Button",,"Text.")
VAR := mV2GC[["1","Text"]].hwnd
mV2Gui["1"].Show()