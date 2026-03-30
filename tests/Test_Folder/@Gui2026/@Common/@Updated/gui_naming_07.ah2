#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
}
mV2GC[["1","B1"]] := mV2Gui["1"].Add("Button",,"B1")
mV2GC[["","B2"]] := mV2Gui[""].Add("Button",,"B2")
mV2Gui[""].Title := "1"
mV2Gui[""].Show("w400 h400")

If (!HasV2Gui("2")) {
    mV2Gui["2"] := NewV2Gui("2")
}
mV2GC[["2","B3"]] := mV2Gui["2"].Add("Button",,"B3")
mV2Gui["2"].Title := "2"
mV2Gui["2"].Show("w300 h300")
mV2GC[["","B4"]] := mV2Gui[""].Add("Button",,"B4")

mV2Gui[""] := NewV2Gui("",1)
mV2Gui[""].OnEvent("Close",GuiClose)
mV2GC[["","B5"]] := mV2Gui[""].Add("Button",,"B5")
mV2Gui[""].Title := "B5"
mV2Gui[""].Show("w200 h200")

mV2GC[["1","B6"]] := mV2Gui["1"].Add("Button",,"B6")

If (!HasV2Gui("3")) {
    mV2Gui["3"] := NewV2Gui("3")
}
mV2GC[["3","B7"]] := mV2Gui["3"].Add("Button",,"B7")
mV2Gui["3"].Title := "3"
mV2Gui["3"].Show("w75 h75")
mV2GC[["","B8"]] := mV2Gui[""].Add("Button",,"B8")
mV2Gui["3"].Title := "3"
mV2Gui["3"].Show("w200")

return
GuiClose:
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("closing")
ExitApp()
}