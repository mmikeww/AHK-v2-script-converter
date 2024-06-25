Path := "C:\Foo\Bar\Baz.txt"
RegExMatch(Path, "\w+$", &Extension)
MsgBox((Extension&&Extension[0]))  ; Reports "txt".