w := 260, x := ((A_ScreenWidth - w)/2)-150
lv := 1
Gui, Add, Listview, % "vLV_" lv, C1|C2|C3 ; LV1 DEFAULT
Gui, Add, Listview, vLV_2, C1|C2|C3 ; LV2 DEFAULT
Gui, Show, % "x" x " w" w
msgbox NO DATA IN EITHER LISTVIEW

if (1) {
  Gui, Listview, LV_1	; SWITCH TO LV1
  msg := "ADD ROW TO LV1"
} else {
  msg := "ADD ROW TO LV2"
}
LV_Add(, 1,2,3)
msgbox % msg

if (1) {
  Gui, Listview, LV_2	; SWITCH TO LV2
  msg := "ADD ROW TO LV2"
} else {
  msg := "ADD ROW TO LV1"
}
LV_Add(, 4,5,6)
msgbox % msg

if (1) {
  Gui, Listview, LV_1	; SWITCH TO LV1
  msg := "ADD ROW TO LV1"
} else {
  msg := "ADD ROW TO LV2"
}
LV_Add(, 7,8,9)
msgbox % msg