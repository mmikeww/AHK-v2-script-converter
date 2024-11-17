OutputVar := EnvGet(A_Is64bitOS ? "ProgramW6432" : "ProgramFiles")
MsgBox("Program files are in: " OutputVar)