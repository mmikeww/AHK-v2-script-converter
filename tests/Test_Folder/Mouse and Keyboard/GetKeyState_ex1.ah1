GetKeyState, state, RButton  ; Right mouse button.
GetKeyState, state, Joy2  ; The second button of the first joystick.

GetKeyState, state, Shift
if (state = "D")
    MsgBox At least one Shift key is down.
else
    MsgBox Neither Shift key is down.

GetKeyState, state, CapsLock, T ;  D if CapsLock is ON or U otherwise.