If DllCall("oleacc\AccessibleObjectFromEvent"
, "Ptr", hWnd
, "UInt", idObject
, "UInt", idChild
, "Ptr*", pacc
, "Ptr", VarSetCapacity(varChild,8+2*A_PtrSize,0)*0 + &varChild)=0
