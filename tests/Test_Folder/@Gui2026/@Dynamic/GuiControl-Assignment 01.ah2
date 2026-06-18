#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
  mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","P_1"]] := mV2Gui[""].Add("Progress","vP_1 w130","50")
mV2Gui[""].Show("w150 h50")
color := "0xFF0000"

Loop 1
  fcV2GC("","P_" . A_index).Opt(c := "+c" SubStr(color, 3)) ; V1toV2: Verify that control [P_%A_index%] is accurate