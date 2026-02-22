#Warn Unreachable, Off

; test for ctrlID conflicts when...
;  vLabel has same name as vVar
AI := Gui()
ogcButtonText1 := AI.Add("Button", "w50", "Text 1")
ogcButtonText1.OnEvent("Click", AISave.Bind("Normal"))
ogcTextAISave := AI.Add("Text", "xp+75 yp+5 w50 vAISave", "Text 2")
AI.Show("w200 h200")

return
AISave:
AISave()
Return

GetControl(FocTex) {
  Save_File := ogcTextAISave.Value
}

;###############  V1toV2 FUNCS  ###############
AISave(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
ogcTextAISave.Value := "NewText"
Return
}