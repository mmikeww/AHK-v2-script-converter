SetTitleMatchMode, 2
Run, %A_ComSpec%,,, PID  ; Run command prompt.
WinWait, ahk_pid %PID%  ; Wait for it to appear.
ControlSend,, ipconfig{Enter}, cmd.exe  ; Send directly to the command prompt window.