#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
; https://github.com/mmikeww/AHK-v2-script-converter/issues/323

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","CheckBox1"]] := mV2Gui[""].Add("Checkbox","+checked","CheckBox 1")
mV2GC[["","CheckBox2"]] := mV2Gui[""].Add("Checkbox",,"CheckBox 2")
mV2Gui[""].Show("w250")
Return

^g::
{ ; V1toV2: Added opening brace for [^g]
global ; V1toV2: Made function global
OutputVar := ""
Try OutputVar := ControlGetChecked(GetTopCtrl(A_ScriptName), A_ScriptName)
MsgBox(OutputVar) ; 1
Return
} ; V1toV2: Added closing brace for [^g]