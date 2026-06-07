; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-3244926208

GoSub, A ; Runs A then returns here
Goto, A ; Runs A then exits at return
GoSub, A ; Shouldn't run (but does in v2 conv)

A:
MsgBox
Return