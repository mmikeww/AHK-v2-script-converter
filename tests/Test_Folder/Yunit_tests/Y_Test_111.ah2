name := dir := ""
FullFileName := "C:\My Documents\Address List.txt"
SplitPath(FullFileName, &name)
SplitPath(FullFileName, , &dir)
MsgBox(name "`n" dir)