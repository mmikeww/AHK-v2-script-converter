g := new guiTest()
g._show()

Class guiTest
{
  __new()
  {
    Gui, New, hwndhwnd
    this.hwnd := hwnd
    Gui, Add, Button,, % hwnd " (B1)"
    Gui, Show, w400 h300
  }

  _show()
  {
    h := this.hwnd
    Gui % h ":Add", Button,, % h " (B2)"
    GuiControl, Disable, % h " (B2)"
    Gui % this.hwnd ":Show", w250 h150, % h
  }
}