MyVar := "joe"
MyVar2 := "joe2"
if (MyVar = MyVar2)
    FileAppend("The contents of MyVar and MyVar2 are identical.", "*")
else if (MyVar != "")
    FileAppend("MyVar is not empty/blank", "*")