
Gui, Add, Button, vbtn1, Hello
Gui, Add, Button, vbtn2 gBtn2Lbl, Goodbye (clickMe)
Gui, Show, w200 h100
GuiControl, Move, Button2, x50 y10 w125 h50

return
Btn2Lbl:
GuiControl, Hide, Button1
GuiControl, % A_Gui ":Text", Button2, See ya!
GuiControl, Disable, Button2
Gui, Font, s10 Bold, Verdana
GuiControl, Font, Button2
Sleep, 1000
Gui, %A_Gui%:Destroy