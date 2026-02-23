
; test for ctrlID conflicts when...
;  vLabel has same name as vVar
Gui, AI:Add, Button, gAISave w50, Text 1
Gui, AI:Add, Text, xp+75 yp+5 w50 vAISave, Text 2
Gui, AI:Show,w200 h200

return
AISave:
GuiControl, AI:, AISave, NewText
Return

GetControl(FocTex) {
  GuiControlGet, Save_File, AI:, AISave
}