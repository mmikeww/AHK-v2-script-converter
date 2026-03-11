; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
  mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Text",,"Test")
if 1
{
  mV2GC[["1","Var"]] := mV2Gui["1"].Add("Edit",,"abc")
  Var := mV2GC[["1","Var"]].hwnd
}
else
  MsgBox("else")
mV2Gui["1"].Show()