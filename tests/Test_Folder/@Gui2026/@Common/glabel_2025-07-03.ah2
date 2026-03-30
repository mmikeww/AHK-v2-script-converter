#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off

; 2025-07-03 - prevent this from being mistaken as label
; which caused it to be conv to func by mistake
Mute:=1	; mistaken for Mute: after conv to Mute:=1

If (!HasV2Gui("")) {
	mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","Mute"]] := mV2Gui[""].Add("Checkbox","0x8000 vMute checked" . mute . " xp+140 yp w50","&Mute")
mV2GC[["","Mute"]].OnEvent("Click",Mute.Bind("Normal"))
mV2Gui[""].Show()

If (Mute = 0)	; no confusion here
	SoundPlay("c:\WINDOWS\Media\chimes.wav")

Mute:
Mute()
Return

;###############  V1toV2 FUNCS  ###############
Mute(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)
ControlFocus("Edit1", AppWindow)
Return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    Mute := ""
}