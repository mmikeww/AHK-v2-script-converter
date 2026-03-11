Gui, new, hwndguiHwnd
Gui, add, pic, gBH1, % "C:\Windows\SysWOW64\SecurityAndMaintenance.png"
Gui, add, button, gBH1 x100 w50 h50, btn1
Gui, show, w275 h325, % guiHwnd
MsgBox % "Click the PICTURE or BUTTON"

return
BH1:
  hdlr2 := "BH2", f := func(hdlr2)
  if (A_GuiControl = "btn1") {
    ctrl := "BUTTON"
    GuiControl, +g, btn1, % f
  } else {
    ctrl := "PICTURE"
    GuiControl, +g, static1, % f
  }
  msg := "Click 1 on " ctrl " handled by BH1..."
      . "`n`nClick it again to change handlers!"
  MsgBox % msg
  return

BH2() { ; will need params added, or at least (*)
  static c := 0, disabled := false
  c++
  MsgBox % "BH2 at your service!`nVisit: " c
  if (c > 3 && !disabled) {
    disabled := true
    ; either of these will disable eh for PICTURE only
    GuiControl,  -g, static1, % f
    ;GuiControl, +g, static1
    MsgBox % "Event handler for PICTURE is now DISABLED"
  }
}