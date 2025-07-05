
; 2025-07-03 - prevent this from being mistaken as label
; which caused it to be conv to func by mistake
Mute=1	; mistaken for Mute: after conv to Mute:=1

Gui, Add, Checkbox, 0x8000 vMute gMute checked%mute% xp+140 yp w50, &Mute

If (Mute = 0)	; no confusion here
	Soundplay, c:\WINDOWS\Media\chimes.wav

Mute:
Gui, Submit, Nohide
ControlFocus, Edit1, %AppWindow%
Return