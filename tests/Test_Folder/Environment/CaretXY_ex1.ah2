Sleep(1000)
CaretGetPos(&A_CaretX, &A_CaretY)
MsgBox("X: " A_CaretX " Y: " A_CaretY)

Sleep(1000)
CaretGetPos(&A_CaretX)
MsgBox("X: " A_CaretX)

Sleep(1000)
CaretGetPos(, &A_CaretY)
MsgBox("Y: " A_CaretY)