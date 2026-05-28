goto lblEnd
return

^q::
{
MsgBox % "HK"
goto lbl1
return

lbl1:
MsgBox % "Nested Label 1"
goto lbl2
return

lbl2:
MsgBox % "Nested Label 2"
return
}

MsgBox % "Global"
return

lblEnd: