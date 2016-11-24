
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
   ;// our format:
   ;//          CommandName,Param1,Param2,etc | format replacement string using {1} which corresponds to Param1 etc
   ;// param format:
   ;//          params containing "var" such as "InputVar,OutputVar,TitleVar" will not be converted
   ;//          any other param name will be converted from literal text to expression using the ToExp() func
   Convert := "
   (
      EnvAdd,InputVar,ExprVar,TimeUnits | *EnvAdd
      EnvDiv,InputVar,ExprVar | {1} /= {2}
      EnvMult,InputVar,ExprVar | {1} *= {2}
      EnvSub,InputVar,ExprVar,TimeUnits | {1} -= {2}[, {3}]
      IfEqual,InputVar,value | if {1} = {2}
      IfNotEqual,InputVar,value | if {1} != {2}
      IfGreater,InputVar,value | if {1} > {2}
      IfGreaterOrEqual,InputVar,value | if {1} >= {2}
      IfLess,InputVar,value | if {1} < {2}
      IfLessOrEqual,InputVar,value | if {1} <= {2}
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringGetPos,OutputVar,InputVar,SearchText,Side, Offset | {1} := InStr({2}, {3}[][, false, {5}])
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
           && RegExMatch(Line, "i)^\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$")
      {
         Cont := 1
         ;If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", Join)
            ;JoinBy := Join[1]
         ;else
            ;JoinBy := "``n"
         ;MsgBox, Line:`n%Line%`n`nLastLine:`n%LastLine%`n`nOutput:`n[`n%Output%`n]
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
      
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|<|>)([^{;]*)(\s*{?)", Equation)
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
         LoopParse, %Convert%, `n
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
               LoopParse, %Params%, `,
               {
                  this_param := LTrim(A_LoopField)      ; trim leading spaces off each param
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
                  If ParamDif := (ListParam.Length() - Param.Length() )
                     ; Remove all unused optional parameters
                     Part[2] := RegExReplace(Part[2], "\[[^\]]*\]", "", Count, ParamDif, 1)
                  Part[2] := StrReplace(Part[2], "[")
                  Part[2] := StrReplace(Part[2], "]")
                  ;msgbox, % "Line=" Line "`nPart[2]=" Part[2] "`nParam[1]=" Param[1]
                  Line := format_v(Part[2], Param)
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
   Text := Trim(Text, " `t")
   If Text = ""
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
      StrReplace, TOut, %Text%, % qu, % qu . qu, All
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

EnvAdd(p) {
   If p[3]
      return format_v("{1} := DateAdd({1}, {2}, {3})", p)
   else
      return format_v("{1} += {2}", p)
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
