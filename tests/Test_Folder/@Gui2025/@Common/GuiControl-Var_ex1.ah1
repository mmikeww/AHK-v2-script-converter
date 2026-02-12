Gui, Add, Button, gb1, Button 1
Gui, Add, Edit, ve1, Some Text
Gui, Show
Return

b1:
Var := "Focus" ; This fix works with focus, others won't
GuiControl, % var, e1
