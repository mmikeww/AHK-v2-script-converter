; https://github.com/mmikeww/AHK-v2-script-converter/issues/232
Gui, Add, Text,, Gui Number 1
Gui, Add, Edit, vEdit1, I love to edit
Gui, Add, Button, gOpen2Gui, Open GUI 2
Gui, Add, Button, gSumbitResults, Submit my edit
Gui, Show, w150
Return

Open2Gui:
Gui, New
Gui, Add, Text,, Gui Number 2
Gui, Add, Edit, vEdit2, I love to button
Gui, Add, Button, gSumbitResults, Submit my edit
Gui, Show, w100
Return

SumbitResults:
Gui, Submit
MsgBox % Edit1
Return