MouseGetPos(&MouseX, &MouseY)
color := PixelGetColor(MouseX, MouseY, ) ;V1toV2: Switched from BGR to RGB values
MsgBox("The color at the current cursor position is " color ".")