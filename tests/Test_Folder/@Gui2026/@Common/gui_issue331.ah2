#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
v := "test gui"
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Title := v
mV2Gui[""].Show("w250 h100")