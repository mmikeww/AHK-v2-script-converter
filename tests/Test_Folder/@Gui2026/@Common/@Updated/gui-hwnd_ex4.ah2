#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text",,"Gui 1`nNormal")
v1 := mV2Gui[""].Hwnd
mV2Gui[""].Show("w100 h100 y0")
mV2Gui[""] := NewV2Gui("",1)
v2 := mV2Gui[""].Hwnd
mV2Gui[""].Add("Text",,"Gui 2`nNew")
mV2Gui[""].Show("w100 h100 y150")
mV2Gui["g2"] := NewV2Gui("g2",1)
v3 := mV2Gui["g2"].Hwnd
mV2Gui["g2"].Add("Text",,"Gui 3`nName:New")
mV2Gui["g2"].Show("w100 h100 y300")
mV2Gui["g3"] := NewV2Gui("g3",1)
v4 := mV2Gui["g3"].Hwnd
mV2Gui["g3"].Add("Text",,"Gui 4`nName: New")
mV2Gui["g3"].Show("w100 h100 y450")
Return

^l::MsgBox(v1 "`n" v2 "`n" v3 "`n" v4)