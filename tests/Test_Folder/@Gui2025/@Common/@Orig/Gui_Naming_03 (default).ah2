#Warn Unreachable, Off
guiName := Gui()
guiName.Add("text", , "text              text                text       text")
ogcButtonAAAA := guiName.Add("Button", "Default", "AAAA")
guiName.Title := "guiName"
guiName.Show("y350")

guiName1 := Gui()
guiName1.OnEvent("Close", GuiClose)
guiName1.OnEvent("Escape", GuiEscape) ; not name
guiName1.Add("text", , "text2              text2                text2       text2")
ogcButtonBBBB := guiName1.Add("Button", "Default", "BBBB")
guiName1.Show("y500")

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