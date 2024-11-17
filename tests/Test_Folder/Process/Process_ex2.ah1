Process, Wait, notepad.exe, 5.5
NewPID := ErrorLevel  ; Save the value immediately since ErrorLevel is often changed.
if not NewPID
{
    MsgBox The specified process did not appear within 5.5 seconds.
    return
}
; Otherwise:
MsgBox A matching process has appeared (Process ID is %NewPID%).
Process, Priority, %NewPID%, Low
Process, Priority,, High  ; Have the script set itself to high priority.
WinClose Untitled - Notepad
Process, WaitClose, %NewPID%, 5
if ErrorLevel ; The PID still exists.
    MsgBox The process did not close within 5 seconds.