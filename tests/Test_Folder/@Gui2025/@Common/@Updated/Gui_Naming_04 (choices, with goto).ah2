#Warn Unreachable, Off

mustExit := 0
if (mustExit=1)
{
 goto("AIGuiClose")
 Return ; V1toV2: post-return for Goto
}
else if (mustExit=2)
{
 goto("Exit")
 Return ; V1toV2: post-return for Goto
}
else
 MsgBox("Creating GUI")


ontop:=1
if (ontop=1)
{
  AI := Gui("+AlwaysOnTop")
  AI.OnEvent("Close", AIGuiClose)
}
else if (ontop=0)
{
  AI := Gui("-AlwaysOnTop")
  AI.OnEvent("Close", AIGuiClose)
}
else
{
  AI := Gui("+AlwaysOnTop")
  AI.OnEvent("Close", AIGuiClose)
}

ogcEditTesting := AI.Add("Edit", "w70", "Testing")
ogcButtonClick := AI.Add("Button", , "Click")
AI.Title := "AI work"
AI.Show("w115 h70")

return
AIGuiClose:
AIGuiClose()
return
Exit:
Exit()
ExitApp()

;###############  V1toV2 FUNCS  ###############
AIGuiClose(*) { ; V1toV2: Lbl->Func
global
Exit()
}
;##############################################
Exit() { ; V1toV2: Lbl->Func
global
MsgBox("Exiting!")
ExitApp()
}