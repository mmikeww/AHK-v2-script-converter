name := dir := ""
SplitPath("C:\My Documents\Address List.txt", &name)
SplitPath("C:\My Documents\Address List.txt", , &dir)
MsgBox(name "`n" dir)