#Warn Unreachable, Off
#Requires Autohotkey v2.0
#SingleInstance Force
#Warn All, MsgBox

guiName := Gui()
guiName.Add("text", , "text              text                text       text")
ogcButtonAAAA := guiName.Add("Button", "Default", "AAAA")
ogcButtonAAAA.OnEvent("Click", guiNameButtonAAAA.Bind("Normal"))
guiName.Show()

myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Escape", GuiEscape) ; not name
myGui.Add("text", , "text2              text2                text2       text2")
ogcButtonBBBB := myGui.Add("Button", "Default", "BBBB")
ogcButtonBBBB.OnEvent("Click", ButtonBBBB.Bind("Normal"))
myGui.Show()

return

guiNameButtonAAAA(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
    ; Gui, Add, Button, Default, AAAA
    ; guiName + Button + AAAA
    ; guiNameButtonAAAA
    MsgBox("Button AAAA is call")
}

ButtonBBBB(A_GuiEvent:="", A_GuiControl:="", Info:="", *) {
    MsgBox("Button BBBB is call")
}

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