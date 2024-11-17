Str := "This is a test."
OutputVar := SubStr(Str, 1, -1*(6))
FileAppend("[" OutputVar "]", "*")