#Requires AutoHotkey v1.1.35+
#SingleInstance Force

esc::ExitApp
F11::
F12::
	MouseGetPos, mX, mY
	((A_ThisHotkey="F11") ? announce("x := " mx) : announce("y := " my))
	return

announce(msg) {
	tooltip % msg
	return
}