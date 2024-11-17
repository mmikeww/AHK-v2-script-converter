; The line below ensures that the path of the 64-bit Program Files
; directory is returned if the OS is 64-bit and the script is not.
SetRegView(64)  ; Requires [v1.1.08+]

OutputVar := RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion", "ProgramFilesDir")
MsgBox("Program files are in: " OutputVar)