Gui, Add, Button, w100, Name
Gui, Add, Edit, gButtonName R2 w100, Test`nTest
Gui, Show, w120
Return

ButtonName:
MsgBox % "A_GuiEvent: " A_GuiEvent "`nA_GuiControl: " A_GuiControl