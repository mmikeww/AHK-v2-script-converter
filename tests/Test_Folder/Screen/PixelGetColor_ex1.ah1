MouseGetPos, MouseX, MouseY
PixelGetColor, color, %MouseX%, %MouseY%
MsgBox The color at the current cursor position is %color%.

PixelGetColor, color, %MouseX%, %MouseY%, RGB
MsgBox The color at the current cursor position is %color%.

PixelGetColor, color, %MouseX%, %MouseY%, Alt RGB
MsgBox The color at the current cursor position is %color%.