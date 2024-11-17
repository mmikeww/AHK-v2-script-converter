SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "Clipboard"), SplashTextGui.Add("Text",, "The clipboard contains:`n" A_Clipboard), SplashTextGui.Show("w400 h300")
WinMove(0, 0, , , "Clipboard")
MsgBox("Press OK to dismiss the SplashText")
SplashTextGui.Destroy