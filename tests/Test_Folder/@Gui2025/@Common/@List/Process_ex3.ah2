#Warn Unreachable, Off
#z::HK1_z() ; Win+Z hotkey
return

_5GuiEscape:
_5GuiEscape()
return
_5GuiClose:
_5GuiClose()
return

MyListBox:
MyListBox()
return
; else fall through to the next label:
_5ButtonOK:
_5ButtonOK()
return

;###############  V1toV2 FUNCS  ###############
HK1_z() { ; V1toV2: HK->Func
global
active_pid := WinGetPID("A")
active_title := WinGetTitle("A")
oGui5 := Gui()
oGui5.OnEvent("Close", _5GuiClose)
oGui5.OnEvent("Escape", _5GuiEscape)
oGui5.Add("Text", , "Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n" . active_title)
ogcMyListBox1 := oGui5.Add("ListBox", "vMyListBox1 r5", ["Normal", "High", "Low", "BelowNormal", "AboveNormal"])
ogcMyListBox1.OnEvent("DoubleClick", MyListBox.Bind("DoubleClick"))
ogcButtonOK := oGui5.Add("Button", "default", "OK")
ogcButtonOK.OnEvent("Click", _5ButtonOK.Bind("Normal"))
oGui5.Title := "Set Priority"
oGui5.Show()
return
}
;##############################################
_5GuiEscape(*) { ; V1toV2: Lbl->Func
global
_5GuiClose()
}
;##############################################
_5GuiClose(*) { ; V1toV2: Lbl->Func
global
Try oGui5.Destroy()
return
}
;##############################################
MyListBox(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
if (A_GuiEvent != "DoubleClick")
    return
_5ButtonOK()
}
;##############################################
_5ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MyListBox1 := ogcMyListBox1.Text
Try oGui5.Destroy()
ErrorLevel := ProcessSetPriority(MyListBox1, active_pid)
if ErrorLevel
    MsgBox("Success: Its priority was changed to `"" MyListBox1 "`".")
else
    MsgBox("Error: Its priority could not be changed to `"" MyListBox1 "`".")
return
}