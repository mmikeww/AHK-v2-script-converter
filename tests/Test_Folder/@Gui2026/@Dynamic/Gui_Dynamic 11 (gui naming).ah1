Gui, Add, Text,, This is GUI 1
Gui, Add, Button, gNextGui, Next GUI
Gui, Add, Button, gAddButton, Add button
Gui, Show, x50 w200 h200
NextGui()
NextGUI()
Return

NextGui() {
static x := 50
x += 255
wh := 200
Gui, New, hwndh ;, +lastFound
Gui, Add, Text,, GUI %h%
Gui, Add, Button, gAddButton, Add button
Gui, Show, x%x% w%wh% h%wh%
Return
}

AddButton:
Gui, Add, Button,, Submit
Return

ButtonSubmit:
MsgBox % A_GuiEvent
Return