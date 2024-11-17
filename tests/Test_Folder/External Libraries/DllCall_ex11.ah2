Rect := Buffer(16, 0)  ; Set capacity to hold four 4-byte integers and initialize them all to zero. ; V1toV2: if 'Rect' is a UTF-16 string, use 'VarSetStrCapacity(&Rect, 16)' and replace all instances of 'Rect.Ptr' with 'StrPtr(Rect)'
NumPut("Int", A_ScreenWidth//2, Rect, 8)  ; The third integer in the structure is "rect.right".
NumPut("Int", A_ScreenHeight//2, Rect, 12) ; The fourth integer in the structure is "rect.bottom".
hDC := DllCall("GetDC", "Ptr", 0, "Ptr")  ; Pass zero to get the desktop's device context.
hBrush := DllCall("CreateSolidBrush", "UInt", 0x0000FF, "Ptr")  ; Create a red brush (0x0000FF is in BGR format).
DllCall("FillRect", "Ptr", hDC, "Ptr", Rect.Ptr, "Ptr", hBrush)  ; Fill the specified rectangle using the brush above.
DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)  ; Clean-up.
DllCall("DeleteObject", "Ptr", hBrush)  ; Clean-up.
