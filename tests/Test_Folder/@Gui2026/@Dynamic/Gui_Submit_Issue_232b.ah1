; https://github.com/mmikeww/AHK-v2-script-converter/issues/232

Gui, New, +hwndh1
Gui, Add, Text,, Gui Number 1
Gui, Add, Edit, vEdit1, Gui Number 1
Gui, Add, Button, gOpen2Gui, Open GUI 2
Gui, Add, Button, gSumbitResults, Submit my edit
Gui, Show, x200 w250, % h1
Return

Open2Gui:
Gui, New, +hwndh2
Gui, Add, Text,, Gui Number 2
Gui, Add, Edit, vEdit2, Gui Number 2
Gui, Add, Button, gSumbitResults, Submit my edit
Gui, Show, x400 w250, % h2
Return

SumbitResults:
Gui, Submit, nohide
MsgBox % "Edit1=" Edit1 "`nEdit2=" Edit2
Return