; https://github.com/mmikeww/AHK-v2-script-converter/issues/328

toggle := Func("f_toggle")
Hotkey, f, % toggle

f_toggle() {
MsgBox % ThisHotKey
}


StartSelection("Area 51 # do-do-do-do... #")

StartSelection(area) {
handler := Func("Select").Bind(area)
Hotkey, ^RButton, % handler, On
}

Select(area) {
MsgBox, % area "`n" ThisHotkey
}