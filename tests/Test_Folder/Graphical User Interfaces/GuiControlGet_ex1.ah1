Gui, Add, Radio, v_Type, Option 1
Gui, Add, Radio,, Option 2
Gui, Add, Button, gCheckResponse, Check Response
Gui, Show
Return

CheckResponse:
GuiControlGet, _Type
If (_Type = 1) {
  MsgBox, You Selected Option 1
} else {
  MsgBox, You Selected Option 2
}