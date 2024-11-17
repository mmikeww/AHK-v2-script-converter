; modified to inline VarSetCapacity in a DllCall
; v1 autohotkey.com/docs/commands/VarSetCapacity.htm
; v2 lexikos.github.io/v2/docs/commands/VarSetStrCapacity.htm
DllCall("wsprintf", "Ptr", VarSetCapacity(buf, 20)*0+&buf, "Str", "0x%08x", "UInt", 4919, "CDecl")
DllCall("wsprintf", "Str", buf, "Str", "0x%08x", "UInt", 4919, "CDecl")
MsgBox % buf . "<end>"
