; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
greenGuiMargin := 16

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].MarginX := greenGuiMargin, mV2Gui["1"].MarginY := greenGuiMargin
mV2Gui["1"].SetFont("s22","Georgia")
mV2Gui["1"].Add("Text",,"Hello World!")
mV2Gui["1"].Title := "Anti gLabel Test"
mV2Gui["1"].Show("w256 h256")