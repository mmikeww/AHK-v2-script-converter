Gui, Add, Button, gLBL2, Test
Gui, Add, Button, gLBL3, Test
Gui, Add, Button, gLBL4, Test
Gui, Add, Button, gLBL5, Test
Gui, Show

gosub LBL2

Goto LBL1
Return

LBL1:
MsgBox, LBL1

LBL2:
msgbox LBL2

LBL3:
msgbox LBL3

LBL4:
msgbox LBL4
return

LBL5:
msgbox LBL5
return