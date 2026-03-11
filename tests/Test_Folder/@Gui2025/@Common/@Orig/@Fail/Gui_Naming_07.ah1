Gui, 1:Add, Button,,B1
Gui, Add, Button,, B2
Gui, Show, w400 h400, 1

Gui, 2:Add, Button,, B3
Gui, 2:Show, w300 h300, 2
Gui, Add, Button,, B4

Gui, New
Gui, Add, Button,, B5
Gui, Show, w200 h200, B5

Gui, 1:Add,Button,,B6

Gui, 3:Add, Button,, B7
Gui, 3:Show, w75 h75, 3
Gui, Add, Button,, B8
Gui, 3:Show, w200, 3

return
GuiClose:
MsgBox % "closing"
exitapp