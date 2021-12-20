MsgBox(SubStr("123abc789", 4, 3)) ; Returns abc

Str := "The Quick Brown Fox Jumps Over the Lazy Dog"
MsgBox(SubStr(Str, 1, 19))  ; Returns "The Quick Brown Fox"
MsgBox(SubStr(Str, -8))  ; Returns "Lazy Dog"