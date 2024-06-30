Random, LineCount, 1, 250
FileReadLine, line, %A_Desktop%\List.txt, %LineCount%

if ErrorLevel {
    MsgBox, Failed to read line
} else {
    MsgBox %line%
}