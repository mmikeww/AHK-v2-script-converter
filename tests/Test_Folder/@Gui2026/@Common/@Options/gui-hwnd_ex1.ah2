#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
myVar := mV2Gui[""].Hwnd
mV2Gui[""].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui[""].Hwnd
mV2Gui[""].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui[""].Hwnd
mV2Gui[""].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui[""].Hwnd

var1 := mV2Gui[""].Hwnd
var2 := mV2Gui[""].Hwnd
mV2Gui[""].Opt("-Caption")
var1 := mV2Gui[""].Hwnd
var2 := mV2Gui[""].Hwnd
mV2Gui[""].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
var1 := mV2Gui[""].Hwnd
var2 := mV2Gui[""].Hwnd