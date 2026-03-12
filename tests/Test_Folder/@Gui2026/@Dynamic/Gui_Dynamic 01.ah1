Title := "MyTitle"
gui, New, % "+LastFound hwndhwnd"
gui, add, button,gbtnTest, test
h := hwnd
Gui , % h ":Show", % "w300 h100", % Title " " h

return
btnTest:
MsgBox % "tested"
return

guiEscape:
MsgBox % "escape and close"
guiClose:
exitapp