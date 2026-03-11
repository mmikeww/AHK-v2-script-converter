Gui, Add, Button, w110, Name
Gui, Add, Button, w110 gchangeButtonText, changeButtonText
Gui, Add, Edit, R2 w110, Test`nTest
Gui, Show, w140
;changeButtonText()
Return

ButtonName:
MsgBox % "A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl

changeButtonText() {
  static c := 0
  c++
  ; these track proper controls in real time
  ; with or without gui id, and with only classNN id
  GuiControl,Text,Button2, Change Name (%c%)
  GuiControl,Text,Button1, Button1 (%c%)
}