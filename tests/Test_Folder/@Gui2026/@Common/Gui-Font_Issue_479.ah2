#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
; https://github.com/mmikeww/AHK-v2-script-converter/issues/479
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].SetFont("bold")
mV2Gui["1"].Add("Text",,"Bold Text")
mV2Gui["1"].SetFont("norm") ; v2 requires "norm"
mV2Gui["1"].Add("Text",,"Normal Text")
mV2Gui["1"].Title := "Norm Font"
mV2Gui["1"].Show("w250 h100")