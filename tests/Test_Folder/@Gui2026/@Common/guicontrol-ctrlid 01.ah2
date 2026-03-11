; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off

; test for ctrlID conflicts when...
;  vLabel has same name as vVar
If (!HasV2Gui("AI")) {
    mV2Gui["AI"] := NewV2Gui("AI")
}
mV2GC[["AI","Text1"]] := mV2Gui["AI"].Add("Button","w50","Text 1")
mV2GC[["AI","Text1"]].OnEvent("Click",AISave.Bind("Normal"))
mV2GC[["AI","AISave"]] := mV2Gui["AI"].Add("Text","xp+75 yp+5 w50 vAISave","Text 2")
mV2Gui["AI"].Show("w200 h200")

return
AISave:
AISave()
Return

GetControl(FocTex) {
  Save_File := mV2GC[["AI","AISave"]].Value
}

;###############  V1toV2 FUNCS  ###############
AISave(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
mV2GC[["AI","AISave"]].Value := "NewText"
Return
}