; modified to inline VarSetCapacity in a DllCall
; v1 autohotkey.com/docs/commands/VarSetCapacity.htm
; v2 lexikos.github.io/v2/docs/commands/VarSetStrCapacity.htm
DllCall("wsprintf", "Ptr", VarSetStrCapacity(&buf, 20)*0+StrPtr(buf), "Str", "0x%08x", "UInt", 4919, "CDecl") ; V1toV2: if 'buf' is NOT a UTF-16 string, use 'buf := Buffer(20)'
DllCall("wsprintf", "Str", buf, "Str", "0x%08x", "UInt", 4919, "CDecl")
MsgBox(buf . "<end>")
