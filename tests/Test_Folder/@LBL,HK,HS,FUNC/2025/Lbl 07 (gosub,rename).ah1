; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2216654421

GoSub MyFunc()
MsgBox, C
GoSub MyFunc2()

MyFunc():
MsgBox, A
MyFunc2():
MsgBox, B
Return

; A > B > C > B > A > B