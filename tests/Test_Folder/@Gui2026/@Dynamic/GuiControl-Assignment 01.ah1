Gui, Add, Progress, vP_1 w130, 50
Gui, Show, w150 h50
color := "0xFF0000"

Loop 1
  GuiControl, % c := "+c" SubStr(color, 3), P_%A_index%