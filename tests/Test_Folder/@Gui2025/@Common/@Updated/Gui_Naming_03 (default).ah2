#Warn Unreachable, Off
guiName := Gui()
guiName.Add("text", , "text              text                text       text")
ogcButtonAAAA := guiName.Add("Button", "Default", "AAAA")
guiName.Title := "guiName"
guiName.Show("y350")

myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Escape", GuiEscape) ; not name
myGui.Add("text", , "text2              text2                text2       text2")
ogcButtonBBBB := myGui.Add("Button", "Default", "BBBB")
myGui.Show("y500")

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