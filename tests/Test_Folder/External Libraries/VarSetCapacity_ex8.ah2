a := 0
Loop (var := Buffer(16, 0)).Size//4 ; V1toV2: if 'var' is a UTF-16 string, use 'VarSetStrCapacity(&var, 16)' and replace all instances of 'var.Ptr' with 'StrPtr(var)'
  a += 1
MsgBox("Var's capacity of 16 fits {" a "} 4-byte variables")
