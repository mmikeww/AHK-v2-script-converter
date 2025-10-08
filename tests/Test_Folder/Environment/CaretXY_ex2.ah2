Persistent
Sleep(1000)
SetTimer(WatchCaret,100)
return
WatchCaret:
WatchCaret()
return

;###############  V1toV2 FUNCS  ###############
WatchCaret() { ; V1toV2: Lbl->Func
global
    CaretGetPos(&A_CaretX, &A_CaretY), ToolTip("X" A_CaretX " Y" A_CaretY, A_CaretX, A_CaretY - 20)
return
}