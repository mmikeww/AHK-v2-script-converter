; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
active_title := "PRIORITY"
If (!HasV2Gui("5")) {
    mV2Gui["5"] := NewV2Gui("5")
}
mV2Gui["5"].Add("Text",,"Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n" . active_title)
mV2GC[["5","MyListBox1"]] := mV2Gui["5"].Add("ListBox","vMyListBox1 r5",["Normal","High","Low","BelowNormal","AboveNormal"])
mV2GC[["5","MyListBox1"]].OnEvent("DoubleClick",MyListBox.Bind("DoubleClick"))
mV2GC[["5","OK"]] := mV2Gui["5"].Add("Button","default","OK")
mV2GC[["5","OK"]].OnEvent("Click",_5ButtonOK.Bind("Normal"))
mV2Gui["5"].Title := "Set Priority"
mV2Gui["5"].Show()
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