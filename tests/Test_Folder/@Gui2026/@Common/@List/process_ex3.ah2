#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
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
If (!HasV2Gui("5")) {
    mV2Gui["5"] := NewV2Gui("5")
    mV2Gui["5"].OnEvent("Close",_5GuiClose)
    mV2Gui["5"].OnEvent("Escape",_5GuiEscape)
}
mV2Gui["5"].Add("Text",,"Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n" . active_title)
mV2GC[["5","MyListBox1"]] := mV2Gui["5"].Add("ListBox","vMyListBox1 r5",["Normal","High","Low","BelowNormal","AboveNormal"])
mV2GC[["5","MyListBox1"]].OnEvent("DoubleClick",MyListBox.Bind("DoubleClick"))
mV2GC[["5","OK"]] := mV2Gui["5"].Add("Button","default","OK")
mV2GC[["5","OK"]].OnEvent("Click",_5ButtonOK.Bind("Normal"))
mV2Gui["5"].Title := "Set Priority"
mV2Gui["5"].Show()
return
}
;##############################################
_5GuiEscape(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
_5GuiClose()
}
;##############################################
_5GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
DestroyGui("")
return
}
;##############################################
MyListBox(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
if (A_GuiEvent != "DoubleClick")
    return
_5ButtonOK()
}
;##############################################
_5ButtonOK(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MyListBox1 := mV2GC[["","MyListBox1"]].Text
DestroyGui("")
ErrorLevel := ProcessSetPriority(MyListBox1, active_pid)
if ErrorLevel
    MsgBox("Success: Its priority was changed to `"" MyListBox1 "`".")
else
    MsgBox("Error: Its priority could not be changed to `"" MyListBox1 "`".")
return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    MyListBox1 := ""
}