^h::
{ ; V1toV2: Added opening brace for [^h]
global ; V1toV2: Made function global
Goto("Start")
MsgBox("Skipped")

Start:
MsgBox("This MsgBox is under the start label")
Return
} ; V1toV2: Added closing brace for [^h]