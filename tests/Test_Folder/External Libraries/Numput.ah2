VarSetStrCapacity(&MyVar, 4) ; V1toV2: if 'MyVar' is NOT a UTF-16 string, use 'MyVar := Buffer(4)'
NumPut("int", 1, MyVar)