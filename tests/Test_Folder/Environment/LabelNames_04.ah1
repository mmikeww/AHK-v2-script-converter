; glabel name will cause conflict once renamed
Gui, Add, Button, gInit$Vars, Make MsgBox
Gui, Show
Return

; has conflict with other label once renamed
Init$Vars:
MsgBox Created MsgBox
gosub Init#Vars
Return

Init_Vars:
msgbox conflicting label name 1
goto Init$Vars
Return

^i::
msgbox hotkey pressed
gosub Init_Vars
Return

Init#Vars:
msgbox conflicting label name 3
return

Init%Vars:	; comment
msgbox conflicting label name 4

;Init@Vars()
;{
;msgbox % msgbox conflicting name 2
;}