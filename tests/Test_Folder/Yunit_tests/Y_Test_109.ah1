name := dir := ""
FullFileName = C:\My Documents\Address List.txt
SplitPath, FullFileName, name
SplitPath, FullFileName, , dir
FileAppend, %name%`n%dir%, *