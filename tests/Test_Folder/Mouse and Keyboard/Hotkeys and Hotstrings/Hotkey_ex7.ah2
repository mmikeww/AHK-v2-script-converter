; https://github.com/mmikeww/AHK-v2-script-converter/issues/328

toggle := f_toggle
Hotkey("f", toggle)

f_toggle(ThisHotkey) {
MsgBox(ThisHotKey)
}


StartSelection("Area 51 # do-do-do-do... #")

StartSelection(area) {
handler := Select.Bind(area)
Hotkey("^RButton", handler, "On")
}

Select(area, ThisHotkey) {
MsgBox(area "`n" ThisHotkey)
}