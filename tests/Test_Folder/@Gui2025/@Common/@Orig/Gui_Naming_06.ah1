
delay := 1000

Gui, g1:Add, Button,, B1
Gui, g1:Show, w500 h500

sleep % delay
Gui, 1:Add, Button,, B2
Gui, 1:Show, w400 h400, B2

sleep % delay
Gui, New
Gui, Add, Button,, B3
Gui, Show, w300 h300, B3

sleep % delay
Gui, Add, Button,, B4
Gui, Show, w200 h200, B4

return
guiClose:
MsgBox % "closing"
exitapp