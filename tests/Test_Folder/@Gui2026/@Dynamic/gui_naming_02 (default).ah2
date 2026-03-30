#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","button1"]] := mV2Gui["1"].Add("Button",,"button 1")
mV2Gui["1"].Show("x300 w250 h100")

If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
}
mV2GC[["2","button2"]] := mV2Gui["2"].Add("Button",,"button 2")
mV2Gui["2"].Show("x650 w250 h100")

SetDefaultGui("1")
mV2GC[["","button3"]] := mV2Gui[""].add("button",,"button 3")

SetDefaultGui("")
mV2GC[["","button4"]] := mV2Gui[""].add("button",,"button 4")

; NOTE: button 5 is incorrectly added to gui 1 during conversion, but to gui 2 at execution (correctly)
guiName := "2"
SetDefaultGui(guiName)
mV2GC[["","button5"]] := mV2Gui[""].add("button",,"button 5")