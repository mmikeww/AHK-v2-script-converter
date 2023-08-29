MyVar := Buffer(16, 0) ; V1toV2: if 'MyVar' is a UTF-16 string, use 'VarSetStrCapacity(&MyVar, 16)'
NumPut("int", 4, 
   "int", 3, 
   "int", 2, 
   "int", 1, 
   MyVar)