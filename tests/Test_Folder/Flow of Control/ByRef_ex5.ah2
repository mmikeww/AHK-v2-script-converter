MyFunc(&Param) {
; Stuff
}


Param := Buffer(4, 4) ; V1toV2: if 'Param' is a UTF-16 string, use 'VarSetStrCapacity(&Param, 4)' and replace all instances of 'Param.Ptr' with 'StrPtr(Param)'