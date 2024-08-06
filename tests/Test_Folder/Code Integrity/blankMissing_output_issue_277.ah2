#Requires Autohotkey v2.0
#SingleInstance Force

esc::ExitApp()
F11::
F12::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
	MouseGetPos(&mX, &mY)
	((A_ThisHotkey="F11") ? announce("x := " mx) : announce("y := " my))
	return
} ; V1toV2: Added bracket before function

announce(msg) {
	ToolTip(msg)
	return
}