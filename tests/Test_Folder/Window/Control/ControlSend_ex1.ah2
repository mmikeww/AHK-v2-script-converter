Run("Notepad", , "Min", &PID)  ; Run Notepad minimized.
WinWait("ahk_pid " PID)  ; Wait for it to appear.
; Send the text to the inactive Notepad edit control.
; The third parameter is omitted so the last found window is used.
ControlSend("This is a line of text in the notepad window.{Enter}", "Edit1")
ControlSendText("Notice that {Enter} is not sent as an Enter keystroke with ControlSendRaw.", "Edit1")

MsgBox("Press OK to activate the window to see the result.")
WinActivate("ahk_pid " PID)  ; Show the result.