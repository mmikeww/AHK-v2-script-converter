#Requires AutoHotkey v1.1.33.11
#SingleInstance Force
#Warn All, MsgBox

Gui, guiName:new
Gui, Add, text,, % "text              text                text       text"
Gui, Add, Button, Default, AAAA
Gui, Show

Gui, new ; not name
Gui, Add, text,, % "text2              text2                text2       text2"
Gui, Add, Button, Default, BBBB
Gui, Show

return

guiNameButtonAAAA() {
    ; Gui, Add, Button, Default, AAAA
    ; guiName + Button + AAAA
    ; guiNameButtonAAAA
    MsgBox, % "Button AAAA is call"
}

ButtonBBBB() {
    MsgBox, % "Button BBBB is call"
}

GuiClose:
GuiEscape:
ExitApp