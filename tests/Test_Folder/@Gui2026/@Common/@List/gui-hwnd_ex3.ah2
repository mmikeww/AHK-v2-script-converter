; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","hOutput"]] := mV2Gui["1"].Add("ListBox","w300 h200")
hOutput := mV2GC[["1","hOutput"]].hwnd
mV2Gui["1"].Show()
MsgBox(hOutput)
Return