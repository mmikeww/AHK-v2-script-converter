#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2GC[["1","Name"]] := mV2Gui["1"].Add("Edit","vName","AAA")
mV2Gui["1"].Title := "A"
mV2Gui["1"].Show("w50 h50 y250")

If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
}
mV2GC[["2","Name"]] := mV2Gui["2"].Add("Edit","vName","BBB")
mV2Gui["2"].Title := "B"
mV2Gui["2"].Show("w50 h50 y350")

If (!HasV2Gui("3")) {
    mV2Gui["3"] := NewV2Gui("3")
}
mV2GC[["3","Name"]] := mV2Gui["3"].Add("Edit","vName","CCC")
mV2Gui["3"].Title := "C"
mV2Gui["3"].Show("w50 h50 y450")
Return

^l::
{ ; V1toV2: Added opening brace for [^l]
global ; V1toV2: Made function global
Name := fcV2GC("","Name").Value
MsgBox(Name "`n" A_DefaultGui)
SetDefaultGui("2") ; Only applies to *this* thread
Name := fcV2GC("","Name").Value
MsgBox(Name "`n" A_DefaultGui)
} ; V1toV2: Added closing brace for [^l] (NO CLEAR EXIT FOUND)

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    Name := ""
}