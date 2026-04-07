; https://github.com/mmikeww/AHK-v2-script-converter/issues/370

Gui, +hwndinstallerHwnd
try DllCall("UxTheme\SetWindowThemeAttribute", "ptr", installerHwnd, "int", 1, "int64*", (3<<32)|3, "int", 8) ; Hide window title.
Gui, Show, w400 h100
return