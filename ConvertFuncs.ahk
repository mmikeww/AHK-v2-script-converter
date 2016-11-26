
Convert(ScriptString)
{
   Remove := "
   (
      #AllowSameLineComments
      #MaxMem
      SoundGetWaveVolume
      SoundSetWaveVolume
      #NoEnv
      #Delimiter
      SetFormat
      A_FormatInteger
      A_FormatFloat
   )"


   ;// Commands and How to convert them
   ;// Specification format:
   ;//          CommandName,Param1,Param2,etc | Replacement string format (see below)
   ;// Param format:
   ;//          params names containing "var" (such as "InputVar,OutputVar,TitleVar") will not be converted
   ;//          any other param name will be converted from literal text to expression using the ToExp() func
   ;// Replacement format:
   ;//          use asterisk * and a function name to call
   ;//          or
   ;//          use {1} which corresponds to Param1, etc
   ;//          use [] for optional params. no idea why StringMid has an empty [] below
   CommandsToConvert := "
   (
      EnvAdd,InputVar,ExprVar,TimeUnits | *_EnvAdd
      EnvDiv,InputVar,ExprVar | {1} /= {2}
      EnvMult,InputVar,ExprVar | {1} *= {2}
      EnvSub,InputVar,ExprVar,TimeUnits | {1} -= {2}[, {3}]
      IfEqual,InputVar,value | if ({1} = {2})
      IfNotEqual,InputVar,value | if ({1} != {2})
      IfGreater,InputVar,value | if ({1} > {2})
      IfGreaterOrEqual,InputVar,value | if ({1} >= {2})
      IfLess,InputVar,value | if ({1} < {2})
      IfLessOrEqual,InputVar,value | if ({1} <= {2})
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringGetPos,OutputVar,InputVar,SearchText,Side,Offset | *_StringGetPos
      StringMid,OutputVar,InputVar,StartChar,Count,L | {1} := SubStr({2}, {3}[, {4}][])
      StringLeft,OutputVar,InputVar,Count | {1} := SubStr({2}, 1, {3})
      StringRight,OutputVar,InputVar,Count | {1} := SubStr({2}, -{3}+1, {3})
      StringTrimLeft,OutputVar,InputVar,Count | {1} := SubStr({2}, 1, -{3})
      StringTrimRight,OutputVar,InputVar,Count | {1} := SubStr({2}, {3}+1)
      StringUpper,OutputVar,InputVar,Tvar | StrUpper, {1}, `%{2}`%[, {3}]
      StringLower,OutputVar,InputVar,Tvar | StrLower, {1}, `%{2}`%[, {3}]
      WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *ActiveStats
      WinGetActiveTitle,OutputVar | WinGetTitle, {1}, A
      DriveSpaceFree,OutputVar,PathVar | DriveGet, {1}, SpaceFree, {2}
   )"

   ;Directives := "#Warn UseUnsetLocal`r`n#Warn UseUnsetGlobal"

   SubStrFunction := "`r`n`r`n; This function may be removed if StartingPos is always > 0.`r`nCheckStartingPos(p) {`r`n   Return, p - (p <= 0)`r`n}`r`n`r`n"


   ;Output := FileOpen(FNOut, "w")
   Output := ""
   ;LoopRead, %FN%
   Loop, Parse, %ScriptString%, `n, `r
   {
      Skip := false
      ;Line := A_LoopReadLine
      Line := A_LoopField
      Orig_Line := Line
      ;msgbox, Original Line=`n%Line%
      FirstChar := SubStr(Trim(Line), 1, 1)
      FirstTwo := SubStr(LTrim(Line), 1, 2)
      ;msgbox, FirstChar=%FirstChar%`nFirstTwo=%FirstTwo%
      CommandMatch := -1

      If (Trim(Line) == "") || ( FirstChar == ";" )
      {
         ; Do nothing, but we still want to add the line to the output file
      }
      
      else if FirstTwo == "/*"
         InCommentBlock := true
      
      else if FirstTwo == "*/"
         InCommentBlock := false
      
      else if InCommentBlock
      {
         ; Do nothing, but skip all the following

         ;msgbox in comment block`nLine=%Line%
      }
      
      else If InStr(Line, "SendMode") && InStr(Line, "Input")
         Skip := true
      
      ; check if this starts a continuation section
      ; no idea what that RegEx does, but it works to prevent detection of ternaries
      ; got that RegEx from Uberi here: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/EnumIncludes.ahk#L65
      else if ( FirstChar == "(" )
           && RegExMatch(Line, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$")
      {
         Cont := 1
         ;If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", Join)
            ;JoinBy := Join[1]
         ;else
            ;JoinBy := "``n"
         ;MsgBox, Start of continuation section`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nOutput:`n[`n%Output%`n]
         If InStr(LastLine, ":= `"`"")
         {
            ; if LastLine was something like:                                  var := ""
            ; that means that the line before conversion was:                  var = 
            ; and this new line is an opening ( for continuation section
            ; so remove the last quote and the newline `r`n chars so we get:   var := "
            ; and then re-add the newlines
            Output := SubStr(Output, 1, -3) . "`r`n"
            ;MsgBox, Output after removing one quote mark:`n[`n%Output%`n]
            Cont_String := 1
            ;;;Output.Seek(-4, 1) ; Remove the newline characters and double quotes
         }
         else
         {
            ;;;Output.Seek(-2, 1)
            ;;;Output.Write(" `% ")
         }
         ;continue ; Don't add to the output file
      }

      else if ( FirstChar == ")" )
      {
         ;MsgBox, End Cont. Section`n`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nOutput:`n[`n%Output%`n]
         Cont := 0
         if (Cont_String = 1)
         {
            Line_With_Quote_After_Paren := RegExReplace(Line, "\)", ")`"", "", 1)
            ;MsgBox, Line:`n%Line%`n`nLine_With_Quote_After_Paren:`n%Line_With_Quote_After_Paren%
            Output .= Line_With_Quote_After_Paren . "`r`n"
            LastLine := Line_With_Quote_After_Paren
            continue
         }
      }

      else if Cont
      {
         ;Line := ToExp(Line . JoinBy)
         ;If Cont > 1
            ;Line := ". " . Line
         ;Cont++
         ;MsgBox, Inside Cont. Section`n`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nOutput:`n[`n%Output%`n]
         Output .= Line . "`r`n"
         LastLine := Line
         continue
      }
      
      ; Replace = with := expression equivilents
      else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", Equation) ; Thanks Lexikos
      {
         ;msgbox assignment regex`nLine: %Line%`n%Equation[1]%`n%Equation[2]%
         Line := RTrim(Equation[1]) . " := " . ToExp(Equation[2])
      }
      
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?)", Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%`n6: %Equation[6]%
         Line := format_v("{else}if {not}({variable} {op} {equation}){otb}"
                        , {else: Equation[1], not: Equation[2], variable: RTrim(Equation[3])
                        , op: Equation[4], equation: ToExp(Equation[5]), otb: Equation[6]} )
      }
      
      else ; Command replacing
      ; To add commands to be checked for, modify the list at the top of this file
      {
         CommandMatch := 0
         TmpLine := RegExReplace(Line, ",\s+", ",")
         FirstDelim := RegExMatch(TmpLine, "\w[,\s]") 
         Command := Trim( SubStr(TmpLine, 1, FirstDelim) )
         Params := SubStr(TmpLine, FirstDelim+2)
         ;msgbox, TmpLine=%TmpLine%`nFirstDelim=%FirstDelim%`nCommand=%Command%`nParams=%Params%
         ; Now we format the parameters into their v2 equivilents
         LoopParse, %CommandsToConvert%, `n
         {
            StrSplit, Part, %A_LoopField%, |
            ;msgbox % A_LoopField "`n[" part[1] "]`n[" part[2] "]"
            ListDelim := RegExMatch(Part[1], "[,\s]")
            ListCommand := Trim( SubStr(Part[1], 1, ListDelim-1) )
            If (ListCommand = Command)
            {
               CommandMatch := 1
               ListParams := RTrim( SubStr(Part[1], ListDelim+1) )
               ;msgbox, CommandMatch`nListCommand=%ListCommand%`nListParams=%ListParams%
               ListParam := Array()
               Param := Array() ; Parameters in expression form
               LoopParse, %ListParams%, `,
                  ListParam[A_Index] := A_LoopField
               Params := StrReplace(Params, "``,", "MY_COMMª_PLA¢E_HOLDER")     ; ugly hack
               LoopParse, %Params%, `,
               {
                  this_param := LTrim(A_LoopField)      ; trim leading spaces off each param
                  Param[A_Index] := this_param       ; populate array with the params
               }
               ;msgbox, % "Param.Length=" Param.Length()

               ; if we detect one too many params, it could be because of this:
               if (Param.Length() - ListParam.Length() = 1)
               {
                  ; "Commas that appear within the last parameter of a command do not need to be escaped because 
                  ;  the program knows to treat them literally."
                  ; from:   https://autohotkey.com/docs/commands/_EscapeChar.htm

                  ;msgbox, % "Param[ParamLen-1]=" Param[Param.Length()-1]
                  Param[Param.Length()-1] := Param[Param.Length()-1]  "," Param[Param.Length()]
                  ;msgbox, % "Param[ParamLen-1]=" Param[Param.Length()-1]
                  Param.Delete(Param.Length())
               }
               Loop, % Param.Length()
               {
                  this_param := Param[A_Index]
                  this_param := StrReplace(this_param, "MY_COMMª_PLA¢E_HOLDER", ",")
                  If InStr(ListParam[A_Index], "var")
                     Param[A_Index] := this_param
                  else
                     Param[A_Index] := ToExp(this_param)
               }

               Part[2] := Trim(Part[2])
               If ( SubStr(Part[2], 1, 1) == "*" )
               {
                  FuncName := SubStr(Part[2], 2)
                  ;msgbox FuncName=%FuncName%
                  If IsFunc(FuncName)
                     Line := %FuncName%(Param)
               }
               else
               {
                  ;if (Command = "StringGetPos")
                     ;msgbox, % "in else`nLine: " Line "`nPart[2]: " Part[2] "`nParam[1]: " Param[1]
                  If ParamDif := (ListParam.Length() - Param.Length() )
                  {
                     ; Remove all unused optional parameters
                     ;msgbox, ParamDif=%ParamDif%
                     Part[2] := RegExReplace(Part[2], "\[[^\]]*\]", "", Count, ParamDif, 1)
                     ;msgbox, % "after regexreplace`nPart[2]: " Part[2]
                  }
                  else    ; else if the optional params are included, then remove the []s before formatting
                  {
                     ;msgbox, ParamDif=%ParamDif%
                     Part[2] := StrReplace(Part[2], "[")
                     Part[2] := StrReplace(Part[2], "]")
                     ;msgbox
                  }
                  ;msgbox, % "after replacing []`nPart[2]: " Part[2]
                  Line := format_v(Part[2], Param)
                  ;msgbox, % "after replacing []`nLine: " Line
               }
            }
         }
      }
      
      ; Remove lines we can't use
      If CommandMatch = 0 && !InCommentBlock
         LoopParse, %Remove%, `n, `r
         {
            If InStr(Orig_Line, A_LoopField)
            {
               ;msgbox, skip removed line`nOrig_Line=%Orig_Line%`nA_LoopField=%A_LoopField%
               Skip := true
            }
         }

      
      ; TEMPORARY
      If !FoundSubStr && !InCommentBlock && InStr(Line, "SubStr") 
      {
         FoundSubStr := true
         Line .= " `; WARNING: SubStr conversion may change in the near future"
      }
      
      ; Put the directives after the first non-comment line
      If !FoundNonComment && !InCommentBlock && A_Index != 1 && FirstChar != ";" && FirstTwo != "*/"
      {
         ;Output.Write(Directives . "`r`n")
         ;msgbox, directives
         ;Output .= Directives . "`r`n"
         ;FoundNonComment := true
      }
      

      If Skip
      {
         ;msgbox Skipping`n%Line%
         Line := format_v("; REMOVED: {line}", {line: Line})
      }
      ;Output.Write(Line . "`r`n")
      ;msgbox, New Line=`n%Line%
      Output .= Line . "`r`n"
      LastLine := Line
   }

   ; The following will be uncommented at a a later time
   ;If FoundSubStr
   ;   Output.Write(SubStrFunction)

   ; trim the very last newline that we add to every line (a few code lines above)
   if (SubStr(Output, -2) = "`r`n")
      Output := SubStr(Output, 1, -2)

   ;Output.Close()
   return Output
}

; =============================================================================
; Convert traditional statements to expressions
;    Don't pass whole commands, instead pass one parameter at a time
; =============================================================================
ToExp(Text)
{
   static qu := "`"" ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")
   If (Text = "")       ; If text is empty
      TOut := (qu . qu) ; Two double quotes
   else if InStr(Text, "`%")
   {
      TOut := ""
      Loop % StrLen(Text)
      {
         Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         If Symbol == "`%"
         {
            If (DeRef := !DeRef) && (A_Index != 1)
               TOut .= qu . " . "
            else If (!DeRef) && (A_Index != StrLen(Text))
               TOut .= " . " . qu
         }
         else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }
      If Symbol != "`%"
         TOut .= (qu) ; One double quote
   }
   else if type(Text+0) != "String"
   {
      ;msgbox %text%
      TOut := Text+0
   }
   else
   {
      StrReplace, TOut, %Text%, % qu, % bt . qu, All
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . TOut . qu
   }
   return (TOut)
}

; =============================================================================
; Formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
; =============================================================================
ActiveStats(p) {
   If p[1]
      Out .= format_v("WinGetTitle, {1}, A", p)
   Count := p.Length()
   loop 5
      p[A_Index] := ( p[A_Index] ? " " . p[A_Index] : "" )
   if Count > 1 ; Width and/or Height and/or X and/or Y but not Title
      Out .= (p[1] ? "`r`n" : "") . format_v("WinGetPos{2},{3},{4},{5}, A", p)
   return Out   
}

_EnvAdd(p) {
   If p[3]
      return format_v("{1} := DateAdd({1}, {2}, {3})", p)
   else
      return format_v("{1} += {2}", p)
}

_StringGetPos(p)
{
   if p.Length() = 3
      return format_v("{1} := InStr({2}, {3}) - 1", p)

   ; modelled off of:   https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script.cpp#L14181
   else if p.Length() >= 4
   {
      p4FirstChar := SubStr(p[4], 1, 1)
      p4LastChar := SubStr(p[4], -1)
      ;msgbox, % p[4] "`np4FirstChar=" p4FirstChar "`np4LastChar=" p4LastChar
      p[5] := p[5] ? p[5] : 0              ; 5th param is 'Offset' aka starting position
      ;msgbox, % p[5]
      ; if the 5th param is a quoted string, then it was used as expression and not a number
      if (SubStr(p[5], 1, 1) = "`"") && (SubStr(p[5], -1) = "`"")
         p[5] := SubStr(p[5], 2, -1)  ; remove quotes

      if (p4FirstChar = "`"") && (p4LastChar = "`"")   ; remove start/end quotes, would be nice if a non-expr was passed in
      {
         p4noquotes := SubStr(p[4], 2, -1)
         p4char1 := SubStr(p4noquotes, 1, 1)
         occurences := SubStr(p4noquotes, 2)
         ;msgbox, % p[4]
         p[4] := occurences ? occurences : 1
        
         if (StrUpper(p4char1) = "R") || (p4noquotes = "1")
            out := format_v("{1} := InStr({2}, {3}, false, -1*(({5})+1), {4}) - 1", p)
         else
            out := format_v("{1} := InStr({2}, {3}, false, ({5})+1, {4}) - 1", p)
         ;msgbox, %out%
      }
      else
      {
         ; else then a variable was passed (containing the "L#|R#" string),
         ;      or literal text converted to expr, something like:   "L" . A_Index
         ; output something anyway even though it won't work, so that they can see something to fix
         out := format_v("{1} := InStr({2}, {3}, false, ({5})+1, {4}) - 1", p)
      }
   }

   ; still need warning because StringCaseSense can mess things up
   out .= "`r`n`; WARNING: if you use StringCaseSense in your script you may need to inspect the 3rd param 'false' above"

   return out
}


format_v(f, v)
{
    local out, arg, i, j, s, m, key, buf, c, type, p, O_
    out := "" ; To make #Warn happy.
    VarSetCapacity(arg, 8), j := 1, VarSetCapacity(s, StrLen(f)*2.4)  ; Arbitrary estimate (120% * size of Unicode char).
    O_ := A_AhkVersion >= "2" ? "" : "O)"  ; Seems useful enough to support v1.
    while i := RegExMatch(f, O_ "\{((\w+)(?::([^*`%{}]*([scCdiouxXeEfgGaAp])))?|[{}])\}", m, j)  ; For each {placeholder}.
    {
        out .= SubStr(f, j, i-j)  ; Append the delimiting literal text.
        j := i + m.Len[0]  ; Calculate next search pos.
        if (m.1 = "{" || m.1 = "}") {  ; {{} or {}}.
            out .= m.2
            continue
        }
        key := m.2+0="" ? m.2 : m.2+0  ; +0 to convert to pure number.
        if !v.HasKey(key) {
            out .= m.0  ; Append original {} string to show the error.
            continue
        }
        if m.3 = "" {
            out .= v[key]  ; No format specifier, so just output the value.
            ;if InStr(out, "var")
            ;   msgbox, %out%
            continue
        }
        if (type := m.4) = "s"
            NumPut((p := v.GetAddress(key)) ? p : &(s := v[key] ""), arg)
        else if InStr("cdioux", type)  ; Integer types.
            NumPut(v[key], arg, "int64") ; 64-bit in case of something like {1:I64i}.
        else if InStr("efga", type)  ; Floating-point types.
            NumPut(v[key], arg, "double")
        else if (type = "p")  ; Pointer type.
            NumPut(v[key], arg)
        else {  ; Note that this doesn't catch errors like "{1:si}".
            out .= m.0  ; Output m unaltered to show the error.
            continue
        }
        ; MsgBox % "key=" key ",fmt=" m.3 ",typ=" m.4 . (m.4="s" ? ",str=" NumGet(arg) ";" (&s) : "")
        if (c := DllCall("msvcrt\_vscwprintf", "wstr", "`%" m.3, "ptr", &arg, "cdecl")) >= 0  ; Determine required buffer size.
          && DllCall("msvcrt\_vsnwprintf", "wstr", buf, "ptr", VarSetCapacity(buf, ++c*2)//2, "wstr", "`%" m.3, "ptr", &arg, "cdecl") >= 0 {  ; Format string into buf.
            out .= buf  ; Append formatted string.
            continue
        }
    }
    out .= SubStr(f, j)  ; Append remainder of format string.
    return out
}

