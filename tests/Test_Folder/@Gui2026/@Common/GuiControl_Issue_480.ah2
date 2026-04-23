#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
; https://github.com/mmikeww/AHK-v2-script-converter/issues/480

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
V2TabCtrl := mV2GC[["","Tab1"]] := mV2Gui[""].Add("Tab","vTab1 w200 h100",["A","B","C"])
V2TabCtrl.UseTab(1)
mV2Gui[""].Add("Text",,"I am Tab A !")
V2TabCtrl.UseTab(2)
mV2Gui[""].Add("Text",,"I am Tab B !")
V2TabCtrl.UseTab(3)
mV2Gui[""].Add("Text",,"I am Tab C !")

V2TabCtrl := mV2GC[["","Tab2"]] := mV2Gui[""].Add("Tab","vTab2 x10 y110 w200 h100",["D","E","F"])
V2TabCtrl.UseTab(1)
mV2Gui[""].Add("Text",,"I am Tab D !")
V2TabCtrl.UseTab(2)
mV2Gui[""].Add("Text",,"I am Tab E !")
V2TabCtrl.UseTab(3)
mV2Gui[""].Add("Text",,"I am Tab F !")
mV2Gui[""].Show("w220 h220")

TabB:= 2
mV2GC[["","Tab1"]].Choose(TabB)	; tab B
mV2GC[["","Tab2"]].Choose(3)		; tab F

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    Tab1 := ""
    Tab2 := ""
}