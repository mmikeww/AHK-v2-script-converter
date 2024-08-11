[::   ; now allowed
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Run("Notepad")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

(::Run("Notepad") ; now allowed

^!s::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Send("Sincerely,{enter}John Smith")  ; This line sends keystrokes to the active (foremost) window.
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

NumpadEnd::
Numpad1::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("This hotkey is launched regardless of whether NumLock is on.")
return
} ; V1toV2: Added Bracket before hotkey or Hotstring

{::   ; now allowed
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("added hotkey support for more keys")
} ; V1toV2: Added bracket in the end