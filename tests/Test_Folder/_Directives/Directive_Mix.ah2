; V1toV2: Removed #CommentFlag NewString
; V1toV2: Removed #EscapeChar _
; V1toV2: Removed #DerefChar #
; V1toV2: Removed #Delimiter /

Var := "String"

MsgBox("This is a test") ; should be omitted
MsgBox("This is a `nnewline")
MsgBox(Var)