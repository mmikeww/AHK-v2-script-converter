; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
mV2Gui["guiName"] := NewV2Gui("guiName")
mV2Gui["guiName"].Add("text",,"text              text                text       text")
mV2GC[["guiName","AAAA"]] := mV2Gui["guiName"].Add("Button","Default","AAAA")
mV2Gui["guiName"].Title := "guiName"
mV2Gui["guiName"].Show("y350")

mV2Gui["1"] := NewV2Gui("1")
mV2Gui["1"].OnEvent("Close",GuiClose)
mV2Gui["1"].OnEvent("Escape",GuiEscape) ; not name
mV2Gui["1"].Add("text",,"text2              text2                text2       text2")
mV2GC[["1","BBBB"]] := mV2Gui["1"].Add("Button","Default","BBBB")
mV2Gui["1"].Show("y500")

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
GuiEscape()
}
;##############################################
GuiEscape(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}