ihVar := InputHook("T3","f"), ihVar.Start(), ErrorLevel := ihVar.Wait(), Var := ihVar.Input
if (ErrorLevel = "Timeout")
  MsgBox("Timeout")