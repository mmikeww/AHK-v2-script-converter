MyVar := Buffer(4, 0) ; V1toV2: if 'MyVar' is a UTF-16 string, use 'VarSetStrCapacity(&MyVar, 4)'
NumPut("int", 1, MyVar)