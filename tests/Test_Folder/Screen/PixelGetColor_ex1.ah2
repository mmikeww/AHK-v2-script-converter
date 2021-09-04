MouseGetPos(&MouseX, &MouseY)
color := PixelGetColor(MouseX, MouseY)
MsgBox("The color at the current cursor position is " color ".")