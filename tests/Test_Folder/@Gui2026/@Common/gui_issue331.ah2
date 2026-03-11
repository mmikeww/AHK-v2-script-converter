; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
v := "test gui"
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Title := v
mV2Gui["1"].Show("w250 h100")