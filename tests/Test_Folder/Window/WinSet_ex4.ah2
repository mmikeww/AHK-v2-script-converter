#t::  ; Press Win+T to make the color under the mouse cursor invisible.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MouseGetPos(&MouseX, &MouseY, &MouseWin)
MouseRGB := PixelGetColor(MouseX, MouseY)
; It seems necessary to turn off any existing transparency first:
WinSetTransColor("Off", "ahk_id " MouseWin)
WinSetTransColor(MouseRGB " 220", "ahk_id " MouseWin)
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

#o::  ; Press Win+O to turn off transparency for the window under the mouse.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MouseGetPos(, , &MouseWin)
WinSetTransColor("Off", "ahk_id " MouseWin)
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

#g::  ; Press Win+G to show the current settings of the window under the mouse.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MouseGetPos(, , &MouseWin)
Transparent := WinGetTransparent("ahk_id " MouseWin)
TransColor := WinGetTransColor("ahk_id " MouseWin)
ToolTip("Translucency:`t" Transparent "`nTransColor:`t" TransColor)
return
} ; V1toV2: Added bracket in the end