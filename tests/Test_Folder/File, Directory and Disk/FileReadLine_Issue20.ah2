; fix issue #20
try {
	Global ErrorLevel := 0
	line := StrSplit(FileRead(A_Desktop "\List.txt"),"`n","`r")[5]
} Catch {
	line := ""
	ErrorLevel := 1
}
MsgBox(line)