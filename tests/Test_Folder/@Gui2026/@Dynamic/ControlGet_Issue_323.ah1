; https://github.com/mmikeww/AHK-v2-script-converter/issues/323

Gui, Add, Checkbox,+checked, CheckBox 1
Gui, Add, Checkbox,, CheckBox 2
Gui, Show, w250
Return

^g::
ControlGet, OutputVar, Checked,,, %A_ScriptName%
MsgBox % OutputVar ; 1
Return