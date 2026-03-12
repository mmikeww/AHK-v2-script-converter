; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
g := guiTest()
g._show()

Class guiTest
{
  __new()
  {
    mV2Gui["v1Gui:hwnd"] := NewV2Gui("v1Gui:hwnd")
    hwnd := mV2Gui["v1Gui:hwnd"].Hwnd
    this.hwnd := hwnd
    mV2GC[["v1Gui:hwnd","hwndB1"]] := mV2Gui["v1Gui:hwnd"].Add("Button",,hwnd " (B1)")
    mV2Gui["v1Gui:hwnd"].Show("w400 h300")
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