#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder

Start()

return

ShowGui(id) {
  If (!HasV2Gui(id)) {
    mV2Gui[id] := NewV2Gui(id)
  }
  mV2GC[[id,"id"]] := mV2Gui[id].Add("Button",,id)
  saveID := id
  If (!HasV2Gui(saveID)) {
    mV2Gui[saveID] := NewV2Gui(saveID)
  }
  mV2Gui[saveID].Title := saveID
  mV2Gui[saveID].Show()
}

CreateGui() {
  mV2Gui[""] := NewV2Gui("",1,"+AlwaysOnTop +LastFound +ToolWindow  -DPIScale")
  hGui := mV2Gui[""].Hwnd
  WinSetTransparent(130)
  mV2Gui[""].BackColor := "00C8C8"
  Return hGui
}

Start() {
  static hGui := CreateGui()
  If (!HasV2Gui(hGui)) {
    mV2Gui[hGui] := NewV2Gui(hGui)
  }
  mV2Gui[hGui].Add("Text",,hGui)
  If (!HasV2Gui(hGui)) {
    mV2Gui[hGui] := NewV2Gui(hGui)
  }
  mV2Gui[hGui].Show("Hide w300 h300")
  ShowGui(hGui)
}