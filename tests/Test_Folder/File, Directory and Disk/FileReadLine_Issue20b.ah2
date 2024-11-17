LineCount := Random(1, 250)
try {
    Global ErrorLevel := 0, line := StrSplit(FileRead(A_Desktop "\List.txt"),"`n","`r")[LineCount]
} Catch {
    line := "", ErrorLevel := 1
}

if ErrorLevel {
    MsgBox("Failed to read line")
} else {
    MsgBox(line)
}