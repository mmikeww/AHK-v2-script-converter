; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
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
mV2Gui["nnGui2"] := NewV2Gui("nnGui2")
mV2Gui["nnGui2"].OnEvent("Close",guiClose)
mV2GC[["nnGui2","B3"]] := mV2Gui["nnGui2"].Add("Button",,"B3")
mV2Gui["nnGui2"].Title := "B3"
mV2Gui["nnGui2"].Show("w300 h300")

Sleep(delay)
mV2GC[["nnGui2","B4"]] := mV2Gui["nnGui2"].Add("Button",,"B4")
mV2Gui["nnGui2"].Title := "B4"
mV2Gui["nnGui2"].Show("w200 h200")

return
guiClose:
guiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
guiClose(*) { ; V1toV2: Lbl->Func
global
MsgBox("closing")
ExitApp()
}