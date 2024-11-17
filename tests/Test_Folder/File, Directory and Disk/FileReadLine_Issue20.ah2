; fix issue #20
line := StrSplit(FileRead(A_Desktop "\List.txt"),"`n","`r")[5]
MsgBox(line)