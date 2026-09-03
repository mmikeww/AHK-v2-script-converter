#Requires AutoHotkey v2.0
; headless_convert.ahk — CLI wrapper around the converter's Convert() core.
; NO GUI/dialogs/progress window: reads one v1 file, writes the v2 conversion, exits.
; Usage: AutoHotkey64.exe headless_convert.ahk <in.ahk> <out.ahk>
; NOTE: must live in the converter repo root so `#Include <v2DynGui>` and
;       `#Include Convert/...` resolve.
#SingleInstance Off
global gHeadless := true        ; set BEFORE includes - Global_Declare preserves pre-set values
#Include ConvertFuncs.ahk       ; defines Convert(); pulls Global_Declare + Convert/* chain

if (A_Args.Length < 2) {
    FileAppend("usage: headless_convert.ahk <in.ahk> <out.ahk>`n", "*")
    ExitApp 2
}
src := A_Args[1], dst := A_Args[2]
if !FileExist(src) {
    FileAppend("source not found: " src "`n", "*")
    ExitApp 3
}
text := FileRead(src)
out := Convert(text)
f := FileOpen(dst, "w", "utf-8")
f.Write(out)
f.Close()
FileAppend("OK wrote " dst " (" StrLen(out) " chars)`n", "*")
; emit any would-be MsgBox texts collected during conversion (converter debug msgs)
if (gHeadlessMsgs != "") {
    msgFile := dst "_msgs.txt"
    mf := FileOpen(msgFile, "w", "utf-8")
    mf.Write(gHeadlessMsgs)
    mf.Close()
    FileAppend("NOTICE " RegExReplace(gHeadlessMsgs, "\n---`r?\n.*", "") "`nfull msgs: " msgFile "`n", "*")
}
ExitApp 0
