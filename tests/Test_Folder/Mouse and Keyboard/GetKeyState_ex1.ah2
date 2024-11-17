state := GetKeyState("RButton", ) ? "D" : "U"  ; Right mouse button.
state := GetKeyState("Joy2", ) ? "D" : "U"  ; The second button of the first joystick.

state := GetKeyState("Shift", ) ? "D" : "U"
if (state = "D")
    MsgBox("At least one Shift key is down.")
else
    MsgBox("Neither Shift key is down.")

state := GetKeyState("CapsLock", "T") ? "D" : "U" ;  D if CapsLock is ON or U otherwise.