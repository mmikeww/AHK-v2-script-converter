varChild := Buffer(8+2*A_PtrSize, 0) ; V1toV2: if 'varChild' is a UTF-16 string, use 'VarSetStrCapacity(&varChild, 8+2*A_PtrSize)' NB! if this is part of a control flow block without {}, please enclose this and the next line in {}!
If DllCall("oleacc\AccessibleObjectFromEvent", "Ptr", hWnd, "UInt", idObject, "UInt", idChild, "Ptr*", &pacc := 0, "Ptr",  varChild)=0
