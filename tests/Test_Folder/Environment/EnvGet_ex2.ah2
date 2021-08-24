OutputVar := EnvGet(A_Is64bitOS ? "ProgramW6432" : "ProgramFiles")
msgResult := MsgBox("Program files are in: " . OutputVar)