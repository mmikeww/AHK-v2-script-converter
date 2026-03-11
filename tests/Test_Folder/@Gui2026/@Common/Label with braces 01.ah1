Gui, Add, Button, vButton1 gButtonPress, Button1
Gui, Add, Button, vButton2 gButtonPress, Button2
Gui, Add, Button, vButton3 gButtonPress, Button3
Gui, Add, Button, vButton4 gButtonPress, Button4
Gui, Add, Button, vButton5 gButtonPress, Button5
Gui, Show,, Test
Return

ButtonPress:
{
Msgbox % "You pressed:" A_GuiControl
Return
}