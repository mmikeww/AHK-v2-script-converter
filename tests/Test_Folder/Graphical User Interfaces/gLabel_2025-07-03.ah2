
; 2025-07-03 - prevent this from being mistaken as label
; which caused it to be conv to func by mistake
Mute:=1	; mistaken for Mute: after conv to Mute:=1

myGui := Gui()
ogcCheckboxMute := myGui.Add("Checkbox", "0x8000 vMute  checked" . mute . " xp+140 yp w50", "&Mute")
ogcCheckboxMute.OnEvent("Click", Mute.Bind("Normal"))

If (Mute = 0)	; no confusion here
	SoundPlay("c:\WINDOWS\Media\chimes.wav")

Mute(A_GuiEvent := "", A_GuiControl := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
oSaved := myGui.Submit(0)
Mute := oSaved.Mute
ControlFocus("Edit1", AppWindow)
Return
} ; V1toV2: Added bracket in the end