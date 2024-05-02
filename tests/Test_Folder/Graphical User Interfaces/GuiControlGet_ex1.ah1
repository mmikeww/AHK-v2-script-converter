Gui, Add, Radio, vType, Option 1
Gui, Add, Radio,, Option 2
Gui, Add, Button, gCheckResponse, Check Response
Gui, Show
Return

CheckResponse:
GuiControlGet, Type
If (Type = 1) {
  MsgBox, You Selected Option 1
} else {
  MsgBox, You Selected Option 2
}