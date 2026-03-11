; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
w := 260, x := ((A_ScreenWidth - w)/2)-150
lv := 1
If (!HasV2Gui("1")) {
  mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","LV_" lv]] := mV2Gui["1"].Add("Listview","vLV_" lv,["C1","C2","C3"])
global gV2CurLV := mV2GC[["1","LV_" lv]] ; LV1 DEFAULT
mV2GC[["1","LV_2"]] := mV2Gui["1"].Add("Listview","vLV_2",["C1","C2","C3"])
global gV2CurLV := mV2GC[["1","LV_2"]] ; LV2 DEFAULT
mV2Gui["1"].Show("x" x " w" w)
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
  global gV2CurLV := mV2GC[["1","LV_2"]]	; SWITCH TO LV2
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