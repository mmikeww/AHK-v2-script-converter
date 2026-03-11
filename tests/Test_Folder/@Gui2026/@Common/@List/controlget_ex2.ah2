; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Tab3","Choose2",["General","View","Settings"])
mV2Gui["1"].Title := "Some Window Title"
mV2Gui["1"].Show()
WhichTab := ControlGetIndex("SysTabControl321", "Some Window Title")
MsgBox("Tab #" WhichTab " is active.")