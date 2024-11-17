#t::  ; Press Win+T to make the color under the mouse cursor invisible.
MouseGetPos, MouseX, MouseY, MouseWin
PixelGetColor, MouseRGB, %MouseX%, %MouseY%, RGB
; It seems necessary to turn off any existing transparency first:
WinSet, TransColor, Off, ahk_id %MouseWin%
WinSet, TransColor, %MouseRGB% 220, ahk_id %MouseWin%
return

#o::  ; Press Win+O to turn off transparency for the window under the mouse.
MouseGetPos,,, MouseWin
WinSet, TransColor, Off, ahk_id %MouseWin%
return

#g::  ; Press Win+G to show the current settings of the window under the mouse.
MouseGetPos,,, MouseWin
WinGet, Transparent, Transparent, ahk_id %MouseWin%
WinGet, TransColor, TransColor, ahk_id %MouseWin%
ToolTip Translucency:`t%Transparent%`nTransColor:`t%TransColor%
return