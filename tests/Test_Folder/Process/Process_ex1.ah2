Run("notepad.exe", , , &NewPID)
ProcessSetPriority("High", NewPID)
MsgBox("The newly launched Notepad's PID is " NewPID ".")