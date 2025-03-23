a := Buffer(4, 0) ; V1toV2: if 'a' is a UTF-16 string, use 'VarSetStrCapacity(&a, 4)' and replace all instances of 'a.Ptr' with 'StrPtr(a)'
b := Buffer(16, 0) ; V1toV2: if 'b' is a UTF-16 string, use 'VarSetStrCapacity(&b, 16)' and replace all instances of 'b.Ptr' with 'StrPtr(b)'

DllCall("example.dll", "ptr", a.Ptr, "ptr", b.Ptr)