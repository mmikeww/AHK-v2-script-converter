; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2289653604

GoSub MyFunc()
MsgBox, C
GoSub MyFunc2()

MyFunc():
MsgBox, A
MyFunc2():
MsgBox, B
MyFunc3():
MsgBox, D
Return

; A > B > D > C > B > D > A > B > D