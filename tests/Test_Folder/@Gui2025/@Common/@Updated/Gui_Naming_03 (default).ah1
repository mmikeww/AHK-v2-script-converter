Gui, guiName:new
Gui, Add, text,, % "text              text                text       text"
Gui, Add, Button, Default, AAAA
Gui, Show, w500, guiName

Gui, new ; not name
Gui, Add, text,, % "text2              text2                text2       text2"
Gui, Add, Button, Default, BBBB
Gui, Show

return

GuiClose:
GuiEscape:
ExitApp