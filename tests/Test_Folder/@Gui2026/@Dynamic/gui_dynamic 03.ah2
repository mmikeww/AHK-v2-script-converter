#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
Loop 3
{
  name := "gui" A_Index
  If (!HasV2Gui(name)) {
    mV2Gui[name] := NewV2Gui(name)
  }
  mV2GC[[name,"nameB1"]] := mV2Gui[name].Add("Button",,name " (B1)")
  ChangeGui(name)
}
return

ChangeGui(id)  ; v1 func, with dynamic gui handling
{
  static w := 600, h := 600
  w -= 125, h -= 125
  If (!HasV2Gui(id)) {
    mV2Gui[id] := NewV2Gui(id)
  }
  mV2GC[[id,"idB2"]] := mV2Gui[id].add("Button",,id " (B2)")
  mV2Gui[id].Title := id
  mV2Gui[id].Show("w" w " h" h)
}