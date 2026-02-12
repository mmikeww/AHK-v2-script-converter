#Warn Unreachable, Off
active_title := "PRIORITY"
oGui5 := Gui()
oGui5.Add("Text", , "Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n" . active_title)
ogcMyListBox1 := oGui5.Add("ListBox", "vMyListBox1 r5", ["Normal", "High", "Low", "BelowNormal", "AboveNormal"])
ogcMyListBox1.OnEvent("DoubleClick", MyListBox.Bind("DoubleClick"))
ogcButtonOK := oGui5.Add("Button", "default", "OK")
ogcButtonOK.OnEvent("Click", _5ButtonOK.Bind("Normal"))
oGui5.Title := "Set Priority"
oGui5.Show()
return

MyListBox:
MyListBox()
return
_5ButtonOK:
_5ButtonOK()
return

;###############  V1toV2 FUNCS  ###############
MyListBox(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
_5ButtonOK()
}
;##############################################
_5ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("hello")
}