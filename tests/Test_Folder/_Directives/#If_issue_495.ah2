#Warn Unreachable, Off
; https://github.com/mmikeww/AHK-v2-script-converter/issues/495
showMsg() ; V1toV2: Gosub
return

showMsg:
showMsg()
return
;-------------------------------------------------------------------
#HotIf WinActive("ahk_class Notepad++")
; only works in Notepad++
;{ ; V1toV2: removed
    :*:np::
    {
        MsgBox("in notepad++")
        return
    }
    return
;} ; V1toV2: removed
;-------------------------------------------------------------------
; Ctrl+Q
*^q::MsgBox("Ctrl+Q in notepad++")
return

; Ctrl+W
*^w::MsgBox("Ctrl+W in notepad++")
return

;###############  V1toV2 FUNCS  ###############
showMsg() { ; V1toV2: Lbl->Func
global
MsgBox("Open Notepad++ before trying these HK/KS")
return
}