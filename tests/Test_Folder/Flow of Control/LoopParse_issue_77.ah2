prefix := "dyn"
dyn_dynamic := "a,b"

Loop Parse, dyn_dynamic, ","
    MsgBox(A_LoopField)

Loop Parse, %prefix%_dynamic, ","
    MsgBox(A_LoopField)

Loop Parse, %prefix%_dynamic, ","
    MsgBox(A_LoopField)
