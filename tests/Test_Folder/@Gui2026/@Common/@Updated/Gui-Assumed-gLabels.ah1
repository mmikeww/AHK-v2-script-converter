Gui1Pos := A_ScreenHeight // 2 * 0.7

Gui, Add, Button,, Button 1
Gui, Add, Button, ys, Button 2
Gui, Show, y%Gui1Pos%

Gui, New
Gui, Add, Button,, Button 3
Gui, Add, Button, ys, Button 4
Gui, Add, Button, ys, Button 5
Gui, Show
Return

ButtonButton1() {
MsgBox, First Button Pressed
Return
}

ButtonButton2:
MsgBox, Second Button Pressed
Return

ButtonButton3:
MsgBox, Third Button Pressed
Return

ButtonButton4() {
MsgBox, Fourth Button Pressed via %A_GuiEvent%
Return
}