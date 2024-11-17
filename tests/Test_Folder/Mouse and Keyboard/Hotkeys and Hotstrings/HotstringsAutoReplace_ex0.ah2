::btw::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox("You typed `"btw`".")
return
} ; V1toV2: Added Bracket before label

:*:]d::  ; This hotstring replaces "]d" with the current date and time via the commands below.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
CurrentDateTime := FormatTime(, "M/d/yyyy h:mm tt")  ; It will look like 9/1/2005 3:53 PM
SendInput(CurrentDateTime)
return
} ; V1toV2: Added bracket in the end