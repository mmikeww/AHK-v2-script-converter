SplashTextGui := Gui("ToolWindow -Sysmenu Disabled", "A_Clipboard"), SplashTextGui.Add("Text",, "The A_Clipboard contains:`n" A_Clipboard), SplashTextGui.Show("w400 h300")
WinMove(0, 0, , , "A_Clipboard")
MsgBox("Press OK to dismiss the SplashText")
SplashTextGui.Destroy