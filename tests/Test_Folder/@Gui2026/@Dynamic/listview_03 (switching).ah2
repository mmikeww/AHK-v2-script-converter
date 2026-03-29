#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
w := 260, x := ((A_ScreenWidth - w)/2)-150
lv := 1
If (!HasV2Gui("")) {
  mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","LV_" lv]] := mV2Gui[""].Add("Listview","vLV_" lv,["C1","C2","C3"])
global gV2CurLV := mV2GC[["","LV_" lv]] ; LV1 DEFAULT
mV2GC[["","LV_2"]] := mV2Gui[""].Add("Listview","vLV_2",["C1","C2","C3"])
global gV2CurLV := mV2GC[["","LV_2"]] ; LV2 DEFAULT
mV2Gui[""].Show("x" x " w" w)
MsgBox("NO DATA IN EITHER LISTVIEW")

if (1) {
  global gV2CurLV := mV2GC[["","LV_1"]]	; SWITCH TO LV1
  msg := "ADD ROW TO LV1"
} else {
  msg := "ADD ROW TO LV2"
}
gV2CurLV.Add(, 1, 2, 3)
MsgBox(msg)

if (1) {
  global gV2CurLV := mV2GC[["","LV_2"]]	; SWITCH TO LV2
  msg := "ADD ROW TO LV2"
} else {
  msg := "ADD ROW TO LV1"
}
gV2CurLV.Add(, 4, 5, 6)
MsgBox(msg)

if (1) {
  global gV2CurLV := mV2GC[["","LV_1"]]	; SWITCH TO LV1
  msg := "ADD ROW TO LV1"
} else {
  msg := "ADD ROW TO LV2"
}
gV2CurLV.Add(, 7, 8, 9)
MsgBox(msg)

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    LV_2 := ""
}