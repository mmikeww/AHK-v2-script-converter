CheckCaret := true
Sleep(1000)

if CheckCaret
  CaretGetPos(&A_CaretX, &A_CaretY), MsgBox("A_CaretX: " A_CaretX "`nA_CaretY: " A_CaretY)