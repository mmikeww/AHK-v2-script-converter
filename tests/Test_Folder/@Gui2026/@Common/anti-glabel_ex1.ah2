#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
greenGuiMargin := 16

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].MarginX := greenGuiMargin, mV2Gui[""].MarginY := greenGuiMargin
mV2Gui[""].SetFont("s22","Georgia")
mV2Gui[""].Add("Text",,"Hello World!")
mV2Gui[""].Title := "Anti gLabel Test"
mV2Gui[""].Show("w256 h256")