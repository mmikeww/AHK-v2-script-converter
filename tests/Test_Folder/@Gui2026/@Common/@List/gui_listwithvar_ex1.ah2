; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
MyArr := "a|b|c"
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("DDL","x10",StrSplit(MyArr,"|")) ; V1toV2: Ensure DDL has correct choose value
mV2Gui["1"].Show()