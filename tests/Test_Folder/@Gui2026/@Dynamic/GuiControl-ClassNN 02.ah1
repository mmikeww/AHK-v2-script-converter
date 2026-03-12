
Gui, 2:Add, Button, vbtn1, Hello
Gui, 2:Add, Button, vbtn2 gBtn2Lbl, Goodbye (clickMe)
Gui, 2:Add, GroupBox, x0 y70 h50 w150 wrap, Group1
Gui, 2:Show, w200 h125
GuiControl, 2:Move, Button2, x50 y10 w125 h50

return
Btn2Lbl:
GuiControl, 2:Hide, Button1
GuiControl, 2:Disable, Button2
Gui, Font, s10 Bold, Verdana
GuiControl, % A_Gui ":Text", Button3, GroupBox is actually a "Button" Class
GuiControl, 2:Font, Button3
Sleep, 3000
GuiControl, % A_Gui ":Text", Button2, See ya!
GuiControl, 2:Font, Button2
Sleep, 1500
Gui, %A_Gui%:Destroy
ExitApp