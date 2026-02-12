Gui, Add, Button, gTag, Test
Gui, Add, Button, gTest, Test
Gui, Add, Button, gTag1, Test
Gui, Add, Button, gTest1, Test
Gui, Show

Goto Somewhere
Return

Somewhere:
MsgBox, Test
Return

Tag:
msgbox tag
return

Test:
msgbox test
return

Tag1:
msgbox tag1
return

Test1:
msgbox test1
return