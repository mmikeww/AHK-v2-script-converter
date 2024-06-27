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
myGui.OnEvent("Escape", GuiClose)
; not name
myGui.Add("text", , "text2              text2                text2       text2")
ogcButtonBBBB := myGui.Add("Button", "Default", "BBBB")
ogcButtonBBBB.OnEvent("Click", ButtonBBBB.Bind("Normal"))
myGui.Show()

return

guiNameButtonAAAA() {
    ; Gui, Add, Button, Default, AAAA
    ; guiName + Button + AAAA
    ; guiNameButtonAAAA
    MsgBox("Button AAAA is call")
}

ButtonBBBB() {
    MsgBox("Button BBBB is call")
}

GuiClose(*)
{ ; V1toV2: Added bracket
    global ; V1toV2: Made function global
    GuiEscape:
    ExitApp()
} ; Added bracket in the end