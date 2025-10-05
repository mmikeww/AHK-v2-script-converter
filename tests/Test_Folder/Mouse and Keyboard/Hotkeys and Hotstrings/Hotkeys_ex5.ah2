Var := "Not set yet"
MsgBox(Var)
Return

^l::
{ ; V1toV2: Added opening brace for [^l]
global ; V1toV2: Made function global
Var := "Set"
Return
} ; V1toV2: Added closing brace for [^l]

^k::
{ ; V1toV2: Added opening brace for [^k]
global ; V1toV2: Made function global
MsgBox(Var)
Return
} ; V1toV2: Added closing brace for [^k]