#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off

delay := 1000

If (!HasV2Gui("g1")) {
    mV2Gui["g1"] := NewV2Gui("g1")
}
mV2GC[["g1","B1"]] := mV2Gui["g1"].Add("Button",,"B1")
mV2Gui["g1"].Show("w500 h500")

Sleep(delay)
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",guiClose)
}
mV2GC[["1","B2"]] := mV2Gui["1"].Add("Button",,"B2")
mV2Gui["1"].Title := "B2"
mV2Gui["1"].Show("w400 h400")

Sleep(delay)
mV2Gui[""] := NewV2Gui("",1)
mV2Gui[""].OnEvent("Close",guiClose)
mV2GC[["","B3"]] := mV2Gui[""].Add("Button",,"B3")
mV2Gui[""].Title := "B3"
mV2Gui[""].Show("w300 h300")

Sleep(delay)
mV2GC[["","B4"]] := mV2Gui[""].Add("Button",,"B4")
mV2Gui[""].Title := "B4"
mV2Gui[""].Show("w200 h200")

return
guiClose:
guiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
guiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
MsgBox("closing")
ExitApp()
}