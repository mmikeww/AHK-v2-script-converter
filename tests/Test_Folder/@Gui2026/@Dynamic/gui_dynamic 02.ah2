#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
g := guiTest()
g._show()

Class guiTest
{
  __new()
  {
    mV2Gui[""] := NewV2Gui("",1)
    hwnd := mV2Gui[""].Hwnd
    this.hwnd := hwnd
    mV2GC[["","hwndB1"]] := mV2Gui[""].Add("Button",,hwnd " (B1)")
    mV2Gui[""].Show("w400 h300")
  }

  _show()
  {
    h := this.hwnd
    If (!HasV2Gui(h)) {
      mV2Gui[h] := NewV2Gui(h)
    }
    mV2GC[[h,"hB2"]] := mV2Gui[h].Add("Button",,h " (B2)")
    mV2GC[[h,"hB2"]].Enabled := false
    If (!HasV2Gui(this.hwnd)) {
      mV2Gui[this.hwnd] := NewV2Gui(this.hwnd)
    }
    mV2Gui[this.hwnd].Title := h
    mV2Gui[this.hwnd].Show("w250 h150")
  }
}