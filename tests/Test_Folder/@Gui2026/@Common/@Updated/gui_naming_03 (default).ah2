#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
mV2Gui["guiName"] := NewV2Gui("guiName",1)
mV2Gui[""].Add("text",,"text              text                text       text")
mV2GC[["","AAAA"]] := mV2Gui[""].Add("Button","Default","AAAA")
mV2Gui[""].Title := "guiName"
mV2Gui[""].Show("y350")

mV2Gui[""] := NewV2Gui("",1)
mV2Gui[""].OnEvent("Close",GuiClose)
mV2Gui[""].OnEvent("Escape",GuiEscape) ; not name
mV2Gui[""].Add("text",,"text2              text2                text2       text2")
mV2GC[["","BBBB"]] := mV2Gui[""].Add("Button","Default","BBBB")
mV2Gui[""].Show("y500")

return

GuiClose:
GuiClose()
return
GuiEscape:
GuiEscape()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
GuiEscape()
}
;##############################################
GuiEscape(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}