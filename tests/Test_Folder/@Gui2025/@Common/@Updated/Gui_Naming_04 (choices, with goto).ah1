
mustExit = 0
if (mustExit=1)
 goto AIGuiClose
else if (mustExit=2)
 goto Exit
else
 msgbox Creating GUI


ontop=1
if (ontop=1)
  Gui, AI:New, +AlwaysOnTop
else if (ontop=0)
  Gui, AI:New, -AlwaysOnTop
else
  Gui, AI:New, +AlwaysOnTop

Gui, Add, Edit, w70, Testing
Gui, Add, Button,, Click
Gui, Show, w115 h70, AI work

return
AIGuiClose:
Exit:
msgbox Exiting!
exitapp