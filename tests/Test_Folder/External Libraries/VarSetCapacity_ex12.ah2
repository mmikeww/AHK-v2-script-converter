char := Buffer(4, 0) ; V1toV2: if 'char' is a UTF-16 string, use 'VarSetStrCapacity(&char, 4)' and replace all instances of 'char.Ptr' with 'StrPtr(char)'
MsgBox(char.Ptr)
; MsgBox % &char