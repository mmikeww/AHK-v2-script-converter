
Convert(ScriptString)
{

   ;// Commands and How to convert them
   ;// Specification format:
   ;//          CommandName,Param1,Param2,etc | Replacement string format (see below)
   ;// Param format:
   ;//          - param names ending in "T2E" will convert a literal Text param TO an Expression
   ;//              this would be used when converting a Command to a Func or otherwise needing an expr
   ;//              such as      word -> "word"      or      %var% -> var
   ;//              like the 'value' param in those  `IfEqual, var, value`  commands
   ;//          - param names ending in "CBE2E" would convert parameters that 'Can Be an Expression TO an EXPR' 
   ;//              this would only be used if the conversion goes from Command to Func 
   ;//              we'd need to strip a preceeding "% " which was used to force an expr when it was unnecessary 
   ;//          - param names ending in "CBE2T" would convert parameters that 'Can Be an Expression TO literal TEXT'
   ;//              this would be used if the conversion goes from Command to Command
   ;//              because in v2, those command parameters can no longer optionally be an expression.
   ;//              these will be wrapped in %%s, so   expr+1   is now    %expr+1%
   ;//          - any other param name will not be converted
   ;//              this means that the literal text of the parameter is unchanged
   ;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
   ;// Replacement format:
   ;//          - use {1} which corresponds to Param1, etc
   ;//          - use [] for one optional param. don't think it will currently work for multiple
   ;//          - use asterisk * and a function name to call, for custom processing when the params dont directly match up
   CommandsToConvert := "
   (
      DriveSpaceFree,OutputVar,Path | DriveGet, {1}, SpaceFree, {2}
      EnvAdd,var,valueCBE2E,TimeUnitsT2E | *_EnvAdd
      EnvSub,var,valueCBE2E,TimeUnitsT2E | *_EnvSub
      EnvDiv,var,valueCBE2E | {1} /= {2}
      EnvMult,var,valueCBE2E | {1} *= {2}
      EnvUpdate | SendMessage, `% WM_SETTINGCHANGE := 0x001A, 0, Environment,, `% "ahk_id " . HWND_BROADCAST := "0xFFFF"
      IfEqual,var,valueT2E | if ({1} = {2})
      IfNotEqual,var,valueT2E | if ({1} != {2})
      IfGreater,var,valueT2E | if ({1} > {2})
      IfGreaterOrEqual,var,valueT2E | if ({1} >= {2})
      IfLess,var,valueT2E | if ({1} < {2})
      IfLessOrEqual,var,valueT2E | if ({1} <= {2})
      SetEnv,var,valueT2E | {1} := {2}
      Sleep,DelayCBE2T | Sleep, {1}
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringGetPos,OutputVar,InputVar,SearchTextT2E,SideT2E,OffsetCBE2E | *_StringGetPos
      StringMid,OutputVar,InputVar,StartCharCBE2E,CountCBE2E,L_T2E | *_StringMid
      StringLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, {3})
      StringRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, -1*({3}))
      StringTrimLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, ({3})+1)
      StringTrimRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, -1*({3}))
      StringUpper,OutputVar,InputVar,T| StrUpper, {1}, `%{2}`%[, {3}]
      StringLower,OutputVar,InputVar,T| StrLower, {1}, `%{2}`%[, {3}]
      StringReplace,OutputVar,InputVar,SearchTxt,ReplTxt,ReplAll | *_StrReplace
      WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *_ActiveStats
      WinGetActiveTitle,OutputVar | WinGetTitle, {1}, A
   )"

   ;Directives := "#Warn UseUnsetLocal`r`n#Warn UseUnsetGlobal"

   Remove := "
   (
      #AllowSameLineComments
      #CommentFlag
      #Delimiter
      #DerefChar
      #EscapeChar
      #LTrim
      #MaxMem
      #NoEnv
      Progress
      SetBatchLines
      SetFormat
      SoundGetWaveVolume
      SoundSetWaveVolume
      SplashImage
      SplashTextOn
      SplashTextOff
      A_FormatInteger
      A_FormatFloat
   )"


   ;SubStrFunction := "`r`n`r`n; This function may be removed if StartingPos is always > 0.`r`nCheckStartingPos(p) {`r`n   Return, p - (p <= 0)`r`n}`r`n`r`n"


   Output := ""

   ; parse each line of the input script
   Loop, Parse, %ScriptString%, `n, `r
   {
      Skip := false
      ;Line := A_LoopReadLine
      Line := A_LoopField
      Orig_Line := Line
      RegExMatch(Line, "^(\s*)", Indentation)
      Indentation := Indentation[1]
      ;msgbox, % "Line:`n" Line "`n`nIndentation=[" Indentation "]`nStrLen(Indentation)=" StrLen(Indentation)
      FirstChar := SubStr(Trim(Line), 1, 1)
      FirstTwo := SubStr(LTrim(Line), 1, 2)
      ;msgbox, FirstChar=%FirstChar%`nFirstTwo=%FirstTwo%
      if RegExMatch(Line, "(\s+`;.*)$", EOLComment)
      {
         EOLComment := EOLComment[1]
         Line := RegExReplace(Line, "(\s+`;.*)$", "")
         ;msgbox, % "Line:`n" Line "`n`nEOLComment:`n" EOLComment
      }
      else
         EOLComment := ""

      CommandMatch := -1

      ; -------------------------------------------------------------------------------
      ;
      ; skip empty lines or comment lines
      ;
      If (Trim(Line) == "") || ( FirstChar == ";" )
      {
         ; Do nothing, but we still want to add the line to the output file
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; skip comment blocks
      ;
      else if FirstTwo == "/*"
         InCommentBlock := true
      
      else if FirstTwo == "*/"
         InCommentBlock := false
      
      else if InCommentBlock
      {
         ; Do nothing, but skip all the following

         ;msgbox in comment block`nLine=%Line%
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ;else If InStr(Line, "SendMode") && InStr(Line, "Input")
         ;Skip := true
      
      ; -------------------------------------------------------------------------------
      ;
      ; check if this starts a continuation section
      ;
      ; no idea what that RegEx does, but it works to prevent detection of ternaries
      ; got that RegEx from Coco here: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/EnumIncludes.ahk#L65
      ; and modified it slightly
      ;
      else if ( FirstChar == "(" )
           && RegExMatch(Line, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$")
      {
         InCont := 1
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
         InCont := 0
         if (Cont_String = 1)
         {
            Line_With_Quote_After_Paren := RegExReplace(Line, "\)", ")`"", "", 1)
            ;MsgBox, Line:`n%Line%`n`nLine_With_Quote_After_Paren:`n%Line_With_Quote_After_Paren%
            Output .= Line_With_Quote_After_Paren . "`r`n"
            LastLine := Line_With_Quote_After_Paren
            continue
         }
      }

      else if InCont
      {
         ;Line := ToExp(Line . JoinBy)
         ;If InCont > 1
            ;Line := ". " . Line
         ;InCont++
         ;MsgBox, Inside Cont. Section`n`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nOutput:`n[`n%Output%`n]
         Output .= Line . "`r`n"
         LastLine := Line
         continue
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Replace = with := expression equivilents in "var = value" assignment lines
      ;
      ; var = 3      will be replaced with    var := "3"
      ; lexikos says var=value should always be a string, even numbers
      ; https://autohotkey.com/boards/viewtopic.php?p=118181#p118181
      ;
      else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", Equation) ; Thanks Lexikos
      {
         ;msgbox assignment regex`nLine: %Line%`n%Equation[1]%`n%Equation[2]%
         Line := RTrim(Equation[1]) . " := " . ToStringExpr(Equation[2])   ; regex above keeps the indentation already
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Traditional-if to Expression-if
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?)", Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%`n6: %Equation[6]%
         Line := Indentation . format_v("{else}if {not}({variable} {op} {value}){otb}"
                                        , { else: Equation[1]
                                          , not: Equation[2]
                                          , variable: RTrim(Equation[3])
                                          , op: Equation[4]
                                          , value: ToExp(Equation[5])
                                          , otb: Equation[6] } )
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var is type
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) is (not\s+)?([^{;]*)(\s*{?)", Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         Line := Indentation . format_v("{else}if {not}({variable} is {type}){otb}"
                                        , { else: Equation[1]
                                          , not: (Equation[3]) ? "!" : ""
                                          , variable: Equation[2]
                                          , type: ToStringExpr(Equation[4])
                                          , otb: Equation[5] } )
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Replace = with := in function default params
      ;
      else if RegExMatch(Line, "i)^\s*\w+\((.+)\)", MatchFunc)
      ; this regex matches anything inside the parentheses () for both func definitions, and func calls :(
      {
         AllParams := MatchFunc[1]
         ;msgbox, % "function line`n`nLine:`n" Line "`n`nAllParams:`n" AllParams

         ; first replace all commas and question marks inside quoted strings with placeholders
         ;  - commas: because we will use comma as delimeter to parse each individual param
         ;  - question mark: because we will use that to determine if there is a ternary
         pos := 1, quoted_string_match := ""
         while (pos := RegExMatch(AllParams, "`".*?`"", MatchObj, pos+StrLen(quoted_string_match)))  ; for each quoted string
         {
            quoted_string_match := MatchObj.Value(0)
            ;msgbox, % "quoted_string_match=" quoted_string_match "`nlen=" StrLen(quoted_string_match) "`npos=" pos
            string_with_placeholders := StrReplace(quoted_string_match, ",", "MY_COMMª_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "?", "MY_¿¿¿_PLA¢E_HOLDER")
            ;msgbox, %string_with_placeholders%
            Line := StrReplace(Line, quoted_string_match, string_with_placeholders, Cnt, 1)
         }
         ;msgbox, % "Line:`n" Line

         ; get all the params again, this time from our line with the placeholders
         if RegExMatch(Line, "i)^\s*\w+\((.+)\)", MatchFunc2)
         {
            AllParams2 := MatchFunc2[1]
            pos := 1, match := ""
            Loop, Parse, %AllParams2%, `,   ; for each individual param (separate by comma)
            {
               thisprm := A_LoopField
               ;msgbox, % "Line:`n" Line "`n`nthisparam:`n" thisprm
               if RegExMatch(A_LoopField, "i)([\s]*[a-z_][a-z_0-9]*[\s]*)=([^,\)]*)", ParamWithEquals)
               {
                  ;msgbox, % "Line:`n" Line "`n`nParamWithEquals:`n" ParamWithEquals[0] "`n" ParamWithEquals[1] "`n" ParamWithEquals[2]
                  ; replace the = with :=
                  ;   question marks were already replaced above if they were within quotes
                  ;   so if a questionmark still exists then it must be for ternary during a func call
                  ;   which we will exclude. for example:  MyFunc((var=5) ? 5 : 0)
                  if !InStr(A_LoopField, "?")
                  {
                     TempParam := ParamWithEquals[1] . ":=" . ParamWithEquals[2]
                     ;msgbox, % "Line:`n" Line "`n`nParamWithEquals:`n" ParamWithEquals[0] "`n" TempParam
                     Line := StrReplace(Line, ParamWithEquals[0], TempParam, Cnt, 1)
                     ;msgbox, % "Line after replacing = with :=`n" Line
                  }
               }
            }
         }

         ; deref the placeholders
         Line := StrReplace(Line, "MY_COMMª_PLA¢E_HOLDER", ",")
         Line := StrReplace(Line, "MY_¿¿¿_PLA¢E_HOLDER", "?")
      }
      ; -------------------------------------------------------------------------------
      ;
      ; Fix     return %var%        ->       return var
      ;
      ; we use the same parsing method as the next else clause below
      ;
      else if (Trim(SubStr(TmpLine := RegExReplace(Line, ",\s+", ","), 1, FirstDelim := RegExMatch(TmpLine, "\w[,\s]"))) = "return")
      {
         Params := SubStr(TmpLine, FirstDelim+2)
         if RegExMatch(Params, "^`%\w+`%$")       ; if the var is wrapped in %%, then remove them
         {
            Params := SubStr(Params, 2, -1)
            Line := Indentation . "return " . Params . EOLComment  ; 'return' is the only command that we won't use a comma before the 1st param
         }
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Command replacing
      ;
      else
      ; To add commands to be checked for, modify the list at the top of this file
      {
         CommandMatch := 0
         TmpLine := RegExReplace(Line, ",\s+", ",")
         FirstDelim := RegExMatch(TmpLine, "\w[,\s]") 
         if (FirstDelim > 0)
         {
            Command := Trim( SubStr(TmpLine, 1, FirstDelim) )
            Params := SubStr(TmpLine, FirstDelim+2)
         }
         else
         {
            Command := Trim( SubStr(TmpLine, 1) )
            Params := ""
         }
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
               ;if (Command = "EnvUpdate")
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

                  ;msgbox, % "Line:`n" Line "`n`nParam[ParamLen-1]=" Param[Param.Length()-1]
                  Param[Param.Length()-1] := Param[Param.Length()-1]  "," Param[Param.Length()]
                  ;msgbox, % "Param[ParamLen-1]=" Param[Param.Length()-1]
                  Param.Delete(Param.Length())
               }

               ; convert the params to expression or not
               Loop, % Param.Length()
               {
                  this_param := Param[A_Index]
                  this_param := StrReplace(this_param, "MY_COMMª_PLA¢E_HOLDER", ",")
                  if (ListParam[A_Index] ~= "T2E$")           ; 'Text TO Expression'
                  {
                     Param[A_Index] := ToExp(this_param)
                  }
                  else if (ListParam[A_Index] ~= "CBE2E$")    ; 'Can Be an Expression TO an Expression'
                  {
                     if (SubStr(this_param, 1, 2) = "`% ")            ; if this param expression was forced
                        Param[A_Index] := SubStr(this_param, 3)       ; remove the forcing
                     else
                        Param[A_Index] := RemoveSurroundingPercents(this_param)
                  }
                  else if (ListParam[A_Index] ~= "CBE2T$")    ; 'Can Be an Expression TO literal Text'
                  {
                     if (this_param is "integer")                     ; if this param is int
                     || (SubStr(this_param, 1, 2) = "`% ")            ; or the expression was forced
                        Param[A_Index] := this_param                  ; dont do any conversion
                     else
                        Param[A_Index] := "`%" . this_param . "`%"    ; wrap in percent signs to evaluate the expr
                  }
                  else
                  {
                     ;msgbox, %this_param%
                     Param[A_Index] := this_param
                  }
               }

               Part[2] := Trim(Part[2])
               If ( SubStr(Part[2], 1, 1) == "*" )   ; if using a special function
               {
                  FuncName := SubStr(Part[2], 2)
                  ;msgbox FuncName=%FuncName%
                  If IsFunc(FuncName)
                     Line := Indentation . %FuncName%(Param)
               }
               else                               ; else just using the command replacement defined at the top
               {
                  ;if (Command = "StringMid")
                     ;msgbox, % "in else`nLine: " Line "`nPart[2]: " Part[2] "`n`nListParam.Length: " ListParam.Length() "`nParam.Length: " Param.Length() "`n`nParam[1]: " Param[1] "`nParam[2]: " Param[2] "`nParam[3]: " Param[3] "`nParam[4]: " Param[4]
                  If ParamDif := (ListParam.Length() - Param.Length() )
                  {
                     ; Remove all unused optional parameters
                     ;msgbox, ParamDif=%ParamDif%
                     ;msgbox, % "before regexreplace`nPart[2]: " Part[2]
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
                  Line := Indentation . format_v(Part[2], Param)
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
      ;If !FoundSubStr && !InCommentBlock && InStr(Line, "SubStr") 
      ;{
         ;FoundSubStr := true
         ;Line .= " `; WARNING: SubStr conversion may change in the near future"
      ;}
      
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

      ;msgbox, New Line=`n%Line%
      Output .= Line . EOLComment . "`r`n"
      LastLine := Line
   }

   ; The following will be uncommented at a a later time
   ;If FoundSubStr
   ;   Output.Write(SubStrFunction)

   ; trim the very last newline that we add to every line (a few code lines above)
   if (SubStr(Output, -2) = "`r`n")
      Output := SubStr(Output, 1, -2)

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
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      TOut :=SubStr(Text, 3)               ; then just return it without the %
   else if InStr(Text, "`%")        ; deref   %var% -> var
   {
      ;msgbox %text%
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
   else      ; wrap anything else in quotes
   {
      TOut := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . TOut . qu
   }
   return (TOut)
}



; same as above, except numbers are excluded. 
; that is, a number will be turned into a quoted number.  3 -> "3"
ToStringExpr(Text)
{
   static qu := "`"" ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")
   If (Text = "")       ; If text is empty
      TOut := (qu . qu) ; Two double quotes
   else if InStr(Text, "`%")        ; deref   %var% -> var
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
   ;else if type(Text+0) != "String"
   ;{
      ;msgbox %text%
      ;TOut := Text+0
   ;}
   else      ; wrap anything else in quotes
   {
      TOut := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . TOut . qu
   }
   return (TOut)
}

; change   "text" -> text
RemoveSurroundingQuotes(text)
{
   if (SubStr(text, 1, 1) = "`"") && (SubStr(text, -1) = "`"")
      return SubStr(text, 2, -1)
   return text
}

; change   %text% -> text
RemoveSurroundingPercents(text)
{
   if (SubStr(text, 1, 1) = "`%") && (SubStr(text, -1) = "`%")
      return SubStr(text, 2, -1)
   return text
}

; =============================================================================
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
; =============================================================================
_ActiveStats(p) {
   If p[1]
      Out .= format_v("WinGetTitle, {1}, A", p)
   Count := p.Length()
   loop 5
      p[A_Index] := ( p[A_Index] ? " " . p[A_Index] : "" )
   if Count > 1 ; Width and/or Height and/or X and/or Y but not Title
      Out .= (p[1] ? "`r`n" : "") . format_v("WinGetPos,{4},{5},{2},{3}, A", p)
   return Out   
}

_EnvAdd(p) {
   If p[3]
      return format_v("{1} := DateAdd({1}, {2}, {3})", p)
   else
      return format_v("{1} += {2}", p)
}

_EnvSub(p) {
   If p[3]
      return format_v("{1} := DateDiff({1}, {2}, {3})", p)
   else
      return format_v("{1} -= {2}", p)
}

_StringGetPos(p)
{
   if p.Length() = 3
      return format_v("{1} := InStr({2}, {3}) - 1", p)

   ; modelled off of:   https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script.cpp#L14181
   else if p.Length() >= 4
   {
      p[5] := p[5] ? p[5] : 0   ; 5th param is 'Offset' aka starting position. set default value if none specified

      p4FirstChar := SubStr(p[4], 1, 1)
      p4LastChar := SubStr(p[4], -1)
      ;msgbox, % p[4] "`np4FirstChar=" p4FirstChar "`np4LastChar=" p4LastChar
      if (p4FirstChar = "`"") && (p4LastChar = "`"")   ; remove start/end quotes, would be nice if a non-expr was passed in
      {
         p4noquotes := SubStr(p[4], 2, -1)
         p4char1 := SubStr(p4noquotes, 1, 1)
         occurences := SubStr(p4noquotes, 2)
         ;msgbox, % p[4]
         p[4] := occurences ? occurences : 1
        
         if (StrUpper(p4char1) = "R") || (p4noquotes = "1")
            return format_v("{1} := InStr({2}, {3}, (A_StringCaseSense=`"On`") ? true : false, -1*(({5})+1), {4}) - 1", p)
         else
            return format_v("{1} := InStr({2}, {3}, (A_StringCaseSense=`"On`") ? true : false, ({5})+1, {4}) - 1", p)
      }
      else
      {
         ; else then a variable was passed (containing the "L#|R#" string),
         ;      or literal text converted to expr, something like:   "L" . A_Index
         ; output something anyway even though it won't work, so that they can see something to fix
         return format_v("{1} := InStr({2}, {3}, (A_StringCaseSense=`"On`") ? true : false, ({5})+1, {4}) - 1", p)
      }
   }
}


_StringMid(p)
{
   if p.Length() = 3
      return format_v("{1} := SubStr({2}, {3})", p)
   else if p.Length() = 4
      return format_v("{1} := SubStr({2}, {3}, {4})", p)
   else if p.Length() = 5
   {
      ;msgbox, % p[5] "`n" SubStr(p[5], 1, 2)
      ; any string that starts with 'L' is accepted
      if (StrUpper(SubStr(p[5], 2, 1) = "L"))
         return format_v("{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p)
      else
      {
         out := format_v("if (SubStr({5}, 1, 1) = `"L`")", p) . "`r`n"
         out .= format_v("    {1} := SubStr(SubStr({2}, 1, {3}), -{4})", p) . "`r`n"
         out .= format_v("else", p) . "`r`n"
         out .= format_v("    {1} := SubStr({2}, {3}, {4})", p)
         return out
      }
   }
}


_StrReplace(p)
{
   ; v1
   ; StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
   ; v2
   ; StrReplace, OutputVar, Haystack, SearchText [, ReplaceText, OutputVarCount, Limit = -1]

   if p.Length() = 3
      return format_v("StrReplace, {1}, `%{2}`%, {3},,, 1", p)
   else if p.Length() = 4
      return format_v("StrReplace, {1}, `%{2}`%, {3}, {4},, 1", p)
   else if p.Length() = 5
   {
      p5char1 := SubStr(p[5], 1, 1)
      ;msgbox, % p[5] "`n" p5char1

      if (p[5] = "UseErrorLevel")    ; UseErrorLevel also implies ReplaceAll
         return format_v("StrReplace, {1}, `%{2}`%, {3}, {4}, ErrorLevel", p)
      else if (p5char1 = "1") || (StrUpper(p5char1) = "A")
         ; if the first char of the ReplaceAll param starts with '1' or 'A'
         ; then all of those imply 'replace all'
         ; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
         return format_v("StrReplace, {1}, `%{2}`%, {3}, {4}", p)
   }
}


; =============================================================================



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

