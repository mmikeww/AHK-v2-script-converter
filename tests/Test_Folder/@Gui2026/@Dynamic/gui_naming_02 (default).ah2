; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
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

;Gui 1:Default ; V1toV2: removed, but applied
V1toV2_LineFill := true ; remove me after inspection
mV2GC[["1","button3"]] := mV2Gui["1"].add("button",,"button 3")

;Gui, Default ; V1toV2: removed
V1toV2_LineFill := true ; remove me after inspection
mV2GC[["1","button4"]] := mV2Gui["1"].add("button",,"button 4")

guiName := "2"
;Gui, %guiName%:Default ; V1toV2: removed, but applied
V1toV2_LineFill := true ; remove me after inspection
mV2GC[[guiName,"button5"]] := mV2Gui[guiName].add("button",,"button 5")