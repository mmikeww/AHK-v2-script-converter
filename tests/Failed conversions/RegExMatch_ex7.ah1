Path := "C:\Foo\Bar\Baz.txt"
RegExMatch(Path, "\w+$", Extension)
MsgBox % Extension  ; Reports "txt".