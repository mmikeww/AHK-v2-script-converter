myGui := Gui()
myGui.Opt("+AlwaysOnTop +Disabled -SysMenu +Owner")  ; +Owner avoids a taskbar button.
myGui.Add("Text", , "Some text to display.")
myGui.Title := "Title of Window"
myGui.Show("NoActivate")  ; NoActivate avoids deactivating the currently active window.