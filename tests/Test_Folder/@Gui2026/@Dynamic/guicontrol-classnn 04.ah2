; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
Company := "My Company"

If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Add("Text","x20 y20 w60 h20","Date:")
mV2GC[["1","Date"]] := mV2Gui["1"].Add("Edit","x90 y20 w150 h20 vDate")
mV2Gui["1"].Add("Text","x20 y50 w60 h20","Company:")
mV2GC[["1","CompanyName"]] := mV2Gui["1"].Add("Edit","x90 y50 w150 h20 vCompanyName")
mV2Gui["1"].Add("Text","x20 y80 w60 h20","Position:")
mV2GC[["1","PositionTitle"]] := mV2Gui["1"].Add("Edit","x90 y80 w150 h20 vPositionTitle")

mV2GC[["1","CompanyName"]].Value := Company
fcV2GC("","Edit3").Value := "My Position"

mV2GC[["1","Append"]] := mV2Gui["1"].Add("Button","x130 y120 w100 h30","Append")
mV2GC[["1","Append"]].OnEvent("Click",AppendButton.Bind("Normal"))
mV2Gui["1"].Title := "Append Data"
mV2Gui["1"].Show()

return
AppendButton:
AppendButton()
return

;###############  V1toV2 FUNCS  ###############
AppendButton(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox("appending")
}