arg  :=  1

If arg
   MsgBox true (IF)
else
   MsgBox false (IF)


IfMsgbox % arg
   MsgBox true (IfMsgbox)
else
   MsgBox false (IfMsgbox)


IfInString arg, 1
   MsgBox true (IfInString)
else
   MsgBox false (IfInString)

   
IfNotInString arg, 1
   MsgBox true (IfNotInString)
else
   MsgBox false (IfNotInString)


IfExist arg
   MsgBox true (IfExist)
else
   MsgBox false (IfExist)

   
IfNotExist arg
   MsgBox true (IfNotExist)
else
   MsgBox false (IfNotExist)

   
IfLess arg, 1
   MsgBox true (IfLess)
else
   MsgBox false (IfLess)

   
IfLessOrEqual arg, 1
   MsgBox true (IfLessOrEqual)
else
   MsgBox false (IfLessOrEqual)

   
IfGreater arg, 1
   MsgBox true (IfGreater)
else
   MsgBox false (IfGreater)

   
IfGreaterOrEqual arg, 1
   MsgBox true (IfGreaterOrEqual)
else
   MsgBox false (IfGreaterOrEqual)


IfEqual arg, 1
   MsgBox true (IfEqual)
else
   MsgBox false (IfEqual)


IfNotEqual arg, 1
   MsgBox true (IfNotEqual)
else
   MsgBox false (IfNotEqual)


IfWinExist
   MsgBox true (IfWinExist)
else
   MsgBox false (IfWinExist)


IfWinNotExist
   MsgBox true (IfWinNotExist)
else
   MsgBox false (IfWinNotExist)


IfWinActive
   MsgBox true (IfWinActive)
else
   MsgBox false (IfWinActive)


IfWinNotActive
   MsgBox true (IfWinNotActive)
else
   MsgBox false (IfWinNotActive)
