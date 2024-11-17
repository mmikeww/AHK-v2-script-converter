MyVar := "joe"
MyVar2 := "`"hello`" joe"
if (MyVar2 = "`"hello`" " MyVar)
    FileAppend("The contents of MyVar and MyVar2 are identical.", "*")