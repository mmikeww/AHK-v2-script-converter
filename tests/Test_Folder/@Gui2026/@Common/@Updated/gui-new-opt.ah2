#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
mV2Gui["1"] := NewV2Gui("1",1,,"Owner")
ThisHwnd := mV2Gui["1"].Hwnd
mV2Gui["1"].Show("w600 h200")

mV2Gui[""] := NewV2Gui("",1,"+Owner" . ThisHwnd,"Child 1")
mV2Gui[""].Show("w500 h150")

mV2Gui[""] := NewV2Gui("",1,"+Owner" . ThisHwnd,"Child 2")
mV2Gui[""].Show("w300 h100")