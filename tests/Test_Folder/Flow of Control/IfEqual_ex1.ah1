var = value
IfEqual var, value, FileGetSize, size, %A_ScriptFullPath%
MsgBox, %size%