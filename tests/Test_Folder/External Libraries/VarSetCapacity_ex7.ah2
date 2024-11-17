Rect := Buffer(16, 0) ; V1toV2: if 'Rect' is a UTF-16 string, use 'VarSetStrCapacity(&Rect, 16)' and replace all instances of 'Rect.Ptr' with 'StrPtr(Rect)' NB! if this is part of a control flow block without {}, please enclose this and the next line in {}!
DllCall("GetWindowRect", "Ptr", WinExist("A"), "Ptr",  Rect)
L := NumGet(Rect, 0, "Int"), T := NumGet(Rect, 4, "Int")
R := NumGet(Rect, 8, "Int"), B := NumGet(Rect, 12, "Int")
MsgBox("Left " L " Top " T " Right " R " Bottom " B)
