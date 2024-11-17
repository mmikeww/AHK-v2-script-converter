SetTimer(ControlMoveTimer)
IB := InputBox("", "My Input Box"), OutputVar := IB.Value
return

ControlMoveTimer()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
if not WinExist("My Input Box")
    return
; Otherwise the above set the "last found" window for us:
SetTimer(ControlMoveTimer,0)
WinActivate()
ControlMove(10, , 200, , "OK")  ; Move the OK button to the left and increase its width.
return
} ; V1toV2: Added bracket in the end