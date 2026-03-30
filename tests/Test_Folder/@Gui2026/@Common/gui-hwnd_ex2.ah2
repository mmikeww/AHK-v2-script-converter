#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","TextC"]] := mV2Gui[""].Add("Text","vTextC","HWND Test")
mV2GC[["","FirstName"]] := mV2Gui[""].Add("Edit","vFirstName")
test := mV2GC[["","FirstName"]].hwnd
mV2GC[["","Submit"]] := mV2Gui[""].Add("Button",,"Submit")
mV2GC[["","Submit"]].OnEvent("Click",Clicked.Bind("Normal"))
mV2Gui[""].Show()
Return

Clicked:
Clicked()
Return

;###############  V1toV2 FUNCS  ###############
Clicked(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox(test)
Return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    FirstName := ""
}