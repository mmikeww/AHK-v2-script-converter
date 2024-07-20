; REMOVED: #CommentFlag NewString
; REMOVED: #EscapeChar _
; REMOVED: #DerefChar #
; REMOVED: #Delimiter /

Var := "String"

MsgBox("This is a test") ; should be omitted
MsgBox("This is a `nnewline")
MsgBox(Var)