
; not completed yet
; test to Add Brackets from a certain point ( can be a hotkey, label or hotstring)
; Closing Bracket will be added when pointer is in a hotstring and encounters:
; Another hotkey/Hotstring declaration (this is a possible change of working)
; A Function declaration ( not yet implemented)
; A Class declaration ( not yet implemented)

; test


AddBracket(ScriptString){
    oScriptString := StrSplit(ScriptString, "`n", "`r")
    Result := ""
    HotkeyPointer := 0 ; active searching for the end of the hotkey
    HotkeyStart := 0 ; active searching for the beginning of the bracket
    RestString := ScriptString ;Used to have a string to look the rest of the file

    loop oScriptString.Length {
        Line := oScriptString[A_Index]
        
        if (HotkeyPointer=1){
            if RegExMatch(RestString,"is)^\s*([\w]+?\([^\)]*\)[\s\n\r]*(`;[^\r\n]*|)([\s\n\r]*){).*"){ ; Function declaration detection
                ; not bulletproof perfect, but a start
                Result .= "} `; Added bracket before function`r`n"
                HotkeyPointer := 0
            }
        }
        if (RegExMatch(Line,"i)^(\s*;).*") or RegExMatch(Line,"i)^(\s*)$")){ ; comment or empty
            ; Do noting
        }
        else if (RegExMatch(Line,"i)^\s*[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:).*")>0){ ; Hotkey or string
            if (HotkeyPointer=1){
                Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
                HotkeyPointer := 0
            }
            if (RegExMatch(Line,"i)^\s*[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:\s*[^\s;].+)")>0){
                ; oneline detected do noting
            }
            else {
                ; Hotkey detected start searching for start
                HotkeyStart := 1
            }
        }
        else If (HotkeyStart=1){
            if (RegExMatch(Line,"i)^\s*({).*")){ ; Hotkey is already good :)
                HotkeyPointer := 0
            }
            else{
                Result .= "{ `; V1toV2: Added bracket`r`n"
                HotkeyPointer := 1
            }
            HotkeyStart := 0
        }
        if (HotkeyPointer=1){
            if (RegExMatch(RestString,"is)^[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:).*")>0){ ; Hotkey or string
                Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
                HotkeyPointer := 0
            }
            else if (RegExMatch(RestString,"is)^[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\s).*")>0 and RegExMatch( oScriptString[A_Index-1],"is)^[\s`n`r\t]*(return).*")>0){ ; Label
                Result .= "} `; V1toV2: Added Bracket before label`r`n"
                HotkeyPointer := 0
            }
        }
        RestString := SubStr(RestString, InStr(RestString,"`n")+1)
        Result .= Line
        Result .= "`r`n"
    }
    if (HotkeyPointer=1){
        Result .= "} `; V1toV2: Added bracket in the end`r`n"
    }
    return Result
}

