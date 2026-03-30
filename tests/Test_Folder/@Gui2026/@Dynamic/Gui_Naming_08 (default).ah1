Gui, 1:Add, Edit, vName, AAA
Gui, 1:Show, w50 h50 y250, A

Gui, 2:Add, Edit, vName, BBB
Gui, 2:Show, w50 h50 y350, B

Gui, 3:Add, Edit, vName, CCC
Gui, 3:Show, w50 h50 y450, C
Return

^l::
GuiControlGet, Name
MsgBox % Name "`n" A_DefaultGui
Gui, 2:Default ; Only applies to *this* thread
GuiControlGet, Name
MsgBox % Name "`n" A_DefaultGui