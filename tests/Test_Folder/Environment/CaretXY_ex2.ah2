Persistent
Sleep(1000)
SetTimer(WatchCaret,100)
return
WatchCaret()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    CaretGetPos(&A_CaretX, &A_CaretY), ToolTip("X" A_CaretX " Y" A_CaretY, A_CaretX, A_CaretY - 20)
return
} ; V1toV2: Added bracket in the end