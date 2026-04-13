arg  :=  1

If arg
   msgResult := MsgBox("true (IF)")
else
   msgResult := MsgBox("false (IF)")


if (msgResult = arg)
   msgResult := MsgBox("true (IfMsgbox)")
else
   msgResult := MsgBox("false (IfMsgbox)")


if InStr(arg, 1)
   msgResult := MsgBox("true (IfInString)")
else
   msgResult := MsgBox("false (IfInString)")

   
if !InStr(arg, 1)
   msgResult := MsgBox("true (IfNotInString)")
else
   msgResult := MsgBox("false (IfNotInString)")


if FileExist("arg")
   msgResult := MsgBox("true (IfExist)")
else
   msgResult := MsgBox("false (IfExist)")

   
if !FileExist("arg")
   msgResult := MsgBox("true (IfNotExist)")
else
   msgResult := MsgBox("false (IfNotExist)")

   
if (arg < 1)
   msgResult := MsgBox("true (IfLess)")
else
   msgResult := MsgBox("false (IfLess)")

   
if (arg <= 1)
   msgResult := MsgBox("true (IfLessOrEqual)")
else
   msgResult := MsgBox("false (IfLessOrEqual)")

   
if (arg > 1)
   msgResult := MsgBox("true (IfGreater)")
else
   msgResult := MsgBox("false (IfGreater)")

   
if (arg >= 1)
   msgResult := MsgBox("true (IfGreaterOrEqual)")
else
   msgResult := MsgBox("false (IfGreaterOrEqual)")


if (arg = 1)
   msgResult := MsgBox("true (IfEqual)")
else
   msgResult := MsgBox("false (IfEqual)")


if (arg != 1)
   msgResult := MsgBox("true (IfNotEqual)")
else
   msgResult := MsgBox("false (IfNotEqual)")


if WinExist()
   msgResult := MsgBox("true (IfWinExist)")
else
   msgResult := MsgBox("false (IfWinExist)")


if !WinExist()
   msgResult := MsgBox("true (IfWinNotExist)")
else
   msgResult := MsgBox("false (IfWinNotExist)")


if WinActive()
   msgResult := MsgBox("true (IfWinActive)")
else
   msgResult := MsgBox("false (IfWinActive)")


if !WinActive()
   msgResult := MsgBox("true (IfWinNotActive)")
else
   msgResult := MsgBox("false (IfWinNotActive)")
