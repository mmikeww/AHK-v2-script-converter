[::   ; now allowed
Run Notepad
return

(::Run Notepad ; now allowed

^!s::
Send Sincerely,{enter}John Smith  ; This line sends keystrokes to the active (foremost) window.
return

NumpadEnd::
Numpad1::
MsgBox, This hotkey is launched regardless of whether NumLock is on.
return

{::   ; now allowed
msgbox added hotkey support for more keys