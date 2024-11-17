SetTimer, ControlMoveTimer
InputBox, OutputVar, My Input Box
return

ControlMoveTimer:
if not WinExist("My Input Box")
    return
; Otherwise the above set the "last found" window for us:
SetTimer, ControlMoveTimer, Off
WinActivate
ControlMove, OK, 10, , 200  ; Move the OK button to the left and increase its width.
return