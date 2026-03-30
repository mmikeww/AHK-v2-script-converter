#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
  mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text",,"Test")
if 1
{
  mV2GC[["","Var"]] := mV2Gui[""].Add("Edit",,"abc")
  Var := mV2GC[["","Var"]].hwnd
}
else
  MsgBox("else")
mV2Gui[""].Show()