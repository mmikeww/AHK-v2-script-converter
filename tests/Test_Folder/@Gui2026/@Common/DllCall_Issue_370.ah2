#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
; https://github.com/mmikeww/AHK-v2-script-converter/issues/370

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
installerHwnd := mV2Gui[""].Hwnd
try DllCall("UxTheme\SetWindowThemeAttribute", "ptr", installerHwnd, "int", 1, "int64*", (3<<32)|3, "int", 8) ; Hide window title.
mV2Gui[""].Show("w400 h100")
return