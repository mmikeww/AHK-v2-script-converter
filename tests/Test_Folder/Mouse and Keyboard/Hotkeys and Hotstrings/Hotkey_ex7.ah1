https://github.com/mmikeww/AHK-v2-script-converter/issues/328

toggle := Func("f_toggle")
Hotkey, f, % toggle

f_toggle() {
MsgBox, f
}