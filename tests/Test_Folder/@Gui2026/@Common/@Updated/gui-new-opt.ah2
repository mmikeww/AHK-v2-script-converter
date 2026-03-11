; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
mV2Gui["1"] := NewV2Gui("1",,"Owner")
ThisHwnd := mV2Gui["1"].Hwnd
mV2Gui["1"].Show("w600 h200")

mV2Gui["nnGui2"] := NewV2Gui("nnGui2","+Owner" . ThisHwnd,"Child 1")
mV2Gui["nnGui2"].Show("w500 h150")

mV2Gui["nnGui3"] := NewV2Gui("nnGui3","+Owner" . ThisHwnd,"Child 2")
mV2Gui["nnGui3"].Show("w300 h100")