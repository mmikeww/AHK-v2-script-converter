; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
; missing label/func - should NOT add event
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Order1234"]] := mV2Gui["1"].Add("Button","ym","Order 1, 2, 3, 4")
mV2Gui["1"].Show("w200 h100")