#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
Company := "My Company"

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Add("Text","x20 y20 w60 h20","Date:")
mV2GC[["","Date"]] := mV2Gui[""].Add("Edit","x90 y20 w150 h20 vDate")
mV2Gui[""].Add("Text","x20 y50 w60 h20","Company:")
mV2GC[["","CompanyName"]] := mV2Gui[""].Add("Edit","x90 y50 w150 h20 vCompanyName")
mV2Gui[""].Add("Text","x20 y80 w60 h20","Position:")
mV2GC[["","PositionTitle"]] := mV2Gui[""].Add("Edit","x90 y80 w150 h20 vPositionTitle")

mV2GC[["","CompanyName"]].Value := Company
fcV2GC("","Edit3").Value := "My Position"

mV2GC[["","Append"]] := mV2Gui[""].Add("Button","x130 y120 w100 h30","Append")
mV2GC[["","Append"]].OnEvent("Click",AppendButton.Bind("Normal"))
mV2Gui[""].Title := "Append Data"
mV2Gui[""].Show()

return
AppendButton:
AppendButton()
return

;###############  V1toV2 FUNCS  ###############
AppendButton(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("appending")
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    CompanyName := ""
    Date := ""
    PositionTitle := ""
}