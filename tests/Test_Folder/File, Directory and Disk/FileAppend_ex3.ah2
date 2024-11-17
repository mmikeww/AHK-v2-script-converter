FTPCommandFile := A_ScriptDir "\FTPCommands.txt"
FTPLogFile := A_ScriptDir "\FTPLog.txt"
FileDelete(FTPCommandFile)  ; In case previous run was terminated prematurely.

FileAppend("
(
open host.domain.com
username
password
binary
cd htdocs
put " VarContainingNameOfTargetFile "
delete SomeOtherFile.htm
rename OldFileName.htm NewFileName.htm
ls -l
quit
)", FTPCommandFile)  ; The comma is required in this case.

RunWait(A_ComSpec " /c ftp.exe -s:`"" FTPCommandFile "`" >`"" FTPLogFile "`"")
FileDelete(FTPCommandFile)  ; Delete for security reasons.
Run(FTPLogFile)  ; Display the log for review.