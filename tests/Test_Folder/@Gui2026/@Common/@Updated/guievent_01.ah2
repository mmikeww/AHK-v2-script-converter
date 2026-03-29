#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
; missing label/func - should NOT add event
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Order1234"]] := mV2Gui[""].Add("Button","ym","Order 1, 2, 3, 4")
mV2Gui[""].Show("w200 h100")