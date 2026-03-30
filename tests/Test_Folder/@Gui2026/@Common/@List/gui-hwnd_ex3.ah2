#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","hOutput"]] := mV2Gui[""].Add("ListBox","w300 h200")
hOutput := mV2GC[["","hOutput"]].hwnd
mV2Gui[""].Show()
MsgBox(hOutput)
Return