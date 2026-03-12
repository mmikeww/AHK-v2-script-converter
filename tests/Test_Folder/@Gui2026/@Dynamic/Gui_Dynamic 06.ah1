
Start()

return

ShowGui(id) {
  Gui, % id ":Add", Button,, %id%
  saveID := id
  Gui, %saveID%:Show,, % saveID
}

CreateGui() {
  Gui, New, +hwndhGui +AlwaysOnTop +LastFound +ToolWindow  -DPIScale
  WinSet, Transparent, 130
  Gui, Color, 00C8C8
  Return hGui
}

Start() {
  static hGui := CreateGui()
  Gui % hGui ":Add", Text,, % hGui
  Gui, %hGui%:Show, Hide w300 h300
  ShowGui(hGui)
}