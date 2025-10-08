; https://github.com/mmikeww/AHK-v2-script-converter/issues/236#issuecomment-2495219614

GoSub, LabelA
MsgBox, After Label
GoSub, LabelA ; Implied
Return ; Implied
LabelA:
MsgBox, In Label
Return