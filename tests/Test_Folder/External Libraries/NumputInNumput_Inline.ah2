VarSetStrCapacity(&MyVar, 16) ; V1toV2: if 'test' is NOT a UTF-16 string, use 'test := Buffer(16)'
NumPut("int", 4, 
   "int", 3, 
   "int", 2, 
   "int", 1, 
   MyVar)