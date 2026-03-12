; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("DDL","Choose5",["A","B","C","D","E","F"])
MsgBox("Line 1")

mV2Gui["1"].Add("DDL","Choose6",["A","B","C","D","E","F"])



MsgBox("Line 2")

mV2Gui["1"].Show()