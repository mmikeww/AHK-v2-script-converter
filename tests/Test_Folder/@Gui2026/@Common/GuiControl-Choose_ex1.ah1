Gui, Add, DDL, vList gHandler, A|B|C
Gui, Add, Button,, 1
Gui, Add, Button, xp+50 yp, A
Gui, Add, Button, xp-50 yp+25, 2
Gui, Add, Button, xp+50 yp, B
Gui, Add, Button, xp-50 yp+25, 3
Gui, Add, Button, xp+50 yp, C
Gui, Show
return

Button1:
GuiControl, Choose, List, 1
return
Button2:
GuiControl, ChooseString, List, B
return
Button3:
GuiControl, Choose, List, 3
return

ButtonA:
GuiControl, Choose, List, |1
return
ButtonB:
GuiControl, ChooseString, List, |B
return
ButtonC:
GuiControl, Choose, List, ||3
return

Handler:
MsgBox