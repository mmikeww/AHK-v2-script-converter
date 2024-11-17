DllCall("GetWindowRect", "Ptr", WinExist("A"), "Ptr", VarSetCapacity(Rect, 16, 0)*0 + &Rect)
L := NumGet(Rect, 0, "Int"), T := NumGet(Rect, 4, "Int")
R := NumGet(Rect, 8, "Int"), B := NumGet(Rect, 12, "Int")
MsgBox % "Left " L " Top " T " Right " R " Bottom " B
