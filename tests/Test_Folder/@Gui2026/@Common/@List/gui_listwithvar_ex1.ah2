#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
MyArr := "a|b|c"
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("DDL","x10",StrSplit(MyArr,"|")) ; V1toV2: Ensure DDL has correct choose value
mV2Gui[""].Show()