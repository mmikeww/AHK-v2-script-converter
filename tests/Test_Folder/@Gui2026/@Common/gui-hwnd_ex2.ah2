; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","TextC"]] := mV2Gui["1"].Add("Text","vTextC","HWND Test")
mV2GC[["1","FirstName"]] := mV2Gui["1"].Add("Edit","vFirstName")
test := mV2GC[["1","FirstName"]].hwnd
mV2GC[["1","Submit"]] := mV2Gui["1"].Add("Button",,"Submit")
mV2GC[["1","Submit"]].OnEvent("Click",Clicked.Bind("Normal"))
mV2Gui["1"].Show()
Return

Clicked:
Clicked()
Return

;###############  V1toV2 FUNCS  ###############
Clicked(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
MsgBox(test)
Return
}