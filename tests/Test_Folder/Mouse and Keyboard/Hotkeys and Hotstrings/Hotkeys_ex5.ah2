Var := "Not set yet"
MsgBox(Var)
Return

^l::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
Var := "Set"
Return
} ; V1toV2: Added Bracket before hotkey or Hotstring

^k::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
MsgBox(Var)
Return
} ; V1toV2: Added bracket in the end