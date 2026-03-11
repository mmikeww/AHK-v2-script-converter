; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
myVar := mV2Gui["1"].Hwnd
mV2Gui["1"].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui["1"].Hwnd
mV2Gui["1"].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui["1"].Hwnd
mV2Gui["1"].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
myVar := mV2Gui["1"].Hwnd

var1 := mV2Gui["1"].Hwnd
var2 := mV2Gui["1"].Hwnd
mV2Gui["1"].Opt("-Caption")
var1 := mV2Gui["1"].Hwnd
var2 := mV2Gui["1"].Hwnd
mV2Gui["1"].Opt("+AlwaysOnTop -Caption +Owner +LastFound")
var1 := mV2Gui["1"].Hwnd
var2 := mV2Gui["1"].Hwnd