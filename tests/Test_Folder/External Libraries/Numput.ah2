MyVar := Buffer(4, 0) ; V1toV2: if 'MyVar' is a UTF-16 string, use 'VarSetStrCapacity(&MyVar, 4)' and replace all instances of 'MyVar.Ptr' with 'StrPtr(MyVar)'
NumPut("int", 1, MyVar)