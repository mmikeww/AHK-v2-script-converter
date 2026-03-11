; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","MyEdit"]] := mV2Gui["1"].Add("Edit","vMyEdit w100 h100","Test")
mV2Gui["1"].SetFont("s30 cRed","Verdana")  ; If desired, use a line like this to set a new default font for the window.
mV2GC[["1","MyEdit"]].SetFont("s30 cRed","Verdana")  ; Put the above font into effect for a control.
mV2Gui["1"].Show()