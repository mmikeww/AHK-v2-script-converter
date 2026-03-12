; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off

; 2025-07-03 - prevent this from being mistaken as label
; which caused it to be conv to func by mistake
Mute:=1	; mistaken for Mute: after conv to Mute:=1

If (!HasV2Gui("1")) {
	mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Mute"]] := mV2Gui["1"].Add("Checkbox","0x8000 vMute checked" . mute . " xp+140 yp w50","&Mute")
mV2GC[["1","Mute"]].OnEvent("Click",Mute.Bind("Normal"))
mV2Gui["1"].Show()

If (Mute = 0)	; no confusion here
	SoundPlay("c:\WINDOWS\Media\chimes.wav")

Mute:
Mute()
Return

;###############  V1toV2 FUNCS  ###############
Mute(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
oSaved := mV2Gui[gCurGuiID].Submit(0)
Try Mute := oSaved.Mute
ControlFocus("Edit1", AppWindow)
Return
}