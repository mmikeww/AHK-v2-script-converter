#Warn Unreachable, Off
OnClipboardChange(OnClipboardChange_v2)
Persistent
MsgBox("copy something to the clipboard")
return

OnClipboardChange_v2:
OnClipboardChange_v2()
Return

;###############  V1toV2 FUNCS  ###############
OnClipboardChange_v2(dataType:="") { ; V1toV2: Lbl->Func
global
MsgBox("clipboard changed`n" . dataType)
Return
}