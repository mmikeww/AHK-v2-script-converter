#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Tab3","Choose2",["General","View","Settings"])
mV2Gui[""].Title := "Some Window Title"
mV2Gui[""].Show()
WhichTab := ControlGetIndex("SysTabControl321", "Some Window Title")
MsgBox("Tab #" WhichTab " is active.")