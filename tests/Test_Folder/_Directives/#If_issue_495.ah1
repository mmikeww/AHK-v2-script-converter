; https://github.com/mmikeww/AHK-v2-script-converter/issues/495
gosub showMsg
return

showMsg:
MsgBox % "Open Notepad++ before trying these HK/KS"
return
;-------------------------------------------------------------------
#IfWinActive ahk_class Notepad++
; only works in Notepad++
{
    :*:np::
    {
        MsgBox % "in notepad++"
        return
    }
    return
}
;-------------------------------------------------------------------
; Ctrl+Q
*^q::MsgBox % "Ctrl+Q in notepad++"
return

; Ctrl+W
*^w::MsgBox % "Ctrl+W in notepad++"
return