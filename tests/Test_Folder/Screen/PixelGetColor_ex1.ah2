MouseGetPos(&MouseX, &MouseY)
color := PixelGetColor(MouseX, MouseY, ) ; V1toV2: Now returns RGB instead of BGR
MsgBox("The color at the current cursor position is " color ".")