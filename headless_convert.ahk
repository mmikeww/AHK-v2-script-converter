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
src := StrReplace(src, '/', '\'), dst := StrReplace(dst, '/', '\')      ; SplitPath parses backslash paths only
if !FileExist(src) {
    FileAppend("source not found: " src "`n", "*")
    ExitApp 3
}
global gFilePath := src                                                  ; shim-name suffix derives from the source file name
text := FileRead(src)
out := Convert(text)
out := NormalizeIncludes(out, src, dst)
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

;################################################################################
; 2026-09-05 LOCAL (breakage #9/#10): the conversion core is layout-agnostic,
; but #Include targets that resolve relative to the SOURCE location
; (%A_ScriptDir%\.., %A_AhkPath%\..\ tricks, <lib> angle form) break once the
; output is relocated/flattened. Normalize each include against known places:
;   <Name>            -> %A_ScriptDir%\Lib\Name.ahk   when <srcDir>\Lib\Name.ahk exists
;   src-resolvable    -> %A_ScriptDir%\<basename>     (file exists relative to srcDir;
;                        the caller is responsible for having converted that file)
;   unresolved        -> %A_ScriptDir%\<basename>     (basename exists next to OUT;
;                        covers %A_AhkPath%\..\ tricks of installed layouts)
; '*i' optional-include flags are preserved (re-emitted outside the quotes -
; the converter wrongly quotes the flag together with the path).
; Convert the include TARGET first (convert order matters for dependents).
NormalizeIncludes(code, srcPath, dstPath) {
    srcPath := StrReplace(srcPath, '/', '\'), dstPath := StrReplace(dstPath, '/', '\')
    SplitPath(srcPath,, &srcDir)
    SplitPath(dstPath,, &outDir)
    outLines := ''
    for each, line in StrSplit(code, '`n', '`r')
    {
        if (RegExMatch(line, 'i)^(\h*#Include(?:Again)?\h+)(.*)$', &m)) {
            spec := Trim(m[2])
            flag := ''
            if (RegExMatch(spec, 'i)^\*i\h*(.*)$', &mi)) {
                flag := '*i '
                spec := Trim(mi[1])
            }
            spec := StrReplace(spec, '"')
            target := ''
            if (SubStr(spec, 1, 1) = '<' && SubStr(spec, -1) = '>') {
                libName := SubStr(spec, 2, StrLen(spec) - 2)
                if FileExist(srcDir '\Lib\' libName '.ahk')
                    target := '%A_ScriptDir%\Lib\' libName '.ahk'
            } else {
                resolved := StrReplace(spec, '%A_ScriptDir%', srcDir)
                if (!InStr(resolved, '%') && FileExist(resolved)) {
                    SplitPath(resolved, &baseName)
                    target := '%A_ScriptDir%\' baseName
                } else {
                    SplitPath(spec, &baseName2)
                    if (baseName2 != '' && FileExist(outDir '\' baseName2))
                        target := '%A_ScriptDir%\' baseName2
                }
            }
            if (target != '')
                line := '#Include ' flag '"' target '"'
        }
        outLines .= line '`r`n'
    }
    return RegExReplace(outLines, '\r\n$',,, 1)
}
