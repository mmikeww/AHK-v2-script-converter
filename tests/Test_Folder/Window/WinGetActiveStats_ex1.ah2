Title := WinGetTitle("A")
WinGetPos(&X, &Y, &Width, &Height, "A")
MsgBox("The active window `"" Title "`" is " Width " wide, " Height " tall, and positioned at " X "," Y ".")