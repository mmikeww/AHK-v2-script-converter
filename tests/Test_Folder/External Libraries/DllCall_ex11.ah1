VarSetCapacity(Rect, 16, 0)  ; Set capacity to hold four 4-byte integers and initialize them all to zero.
NumPut(A_ScreenWidth//2, Rect, 8, "Int")  ; The third integer in the structure is "rect.right".
NumPut(A_ScreenHeight//2, Rect, 12, "Int") ; The fourth integer in the structure is "rect.bottom".
hDC := DllCall("GetDC", "Ptr", 0, "Ptr")  ; Pass zero to get the desktop's device context.
hBrush := DllCall("CreateSolidBrush", "UInt", 0x0000FF, "Ptr")  ; Create a red brush (0x0000FF is in BGR format).
DllCall("FillRect", "Ptr", hDC, "Ptr", &Rect, "Ptr", hBrush)  ; Fill the specified rectangle using the brush above.
DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)  ; Clean-up.
DllCall("DeleteObject", "Ptr", hBrush)  ; Clean-up.
