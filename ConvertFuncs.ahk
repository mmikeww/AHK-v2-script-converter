
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
   ;//          - use asterisk * and a function name to call, for custom processing when the params dont directly match up
   CommandsToConvert := "
   (
      DriveSpaceFree,OutputVar,Path | DriveGet, {1}, SpaceFree, {2}
      EnvAdd,var,valueCBE2E,TimeUnitsT2E | *_EnvAdd
      EnvSub,var,valueCBE2E,TimeUnitsT2E | *_EnvSub
      EnvDiv,var,valueCBE2E | {1} /= {2}
      EnvMult,var,valueCBE2E | {1} *= {2}
      EnvUpdate | SendMessage, `% WM_SETTINGCHANGE := 0x001A, 0, Environment,, `% "ahk_id " . HWND_BROADCAST := "0xFFFF"
      FileCopyDir,source,dest,flag | DirCopy, {1}, {2}, {3}
      FileCreateDir,dir | DirCreate, {1}
      FileMoveDir,source,dest,flag | DirMove, {1}, {2}, {3}
      FileRemoveDir,dir,recurse | DirDelete, {1}, {2}
      FileSelectFolder,var,startingdir,opts,prompt | DirSelect, {1}, {2}, {3}, {4}
      FileSelectFile,var,opts,rootdirfile,prompt,filter | FileSelect, {1}, {2}, {3}, {4}, {5}
      IfEqual,var,valueT2E | if ({1} = {2})
      IfNotEqual,var,valueT2E | if ({1} != {2})
      IfGreater,var,valueT2E | if ({1} > {2})
      IfGreaterOrEqual,var,valueT2E | if ({1} >= {2})
      IfLess,var,valueT2E | if ({1} < {2})
      IfLessOrEqual,var,valueT2E | if ({1} <= {2})
      IfInString,var,valueT2E | if InStr({1}, {2}, (A_StringCaseSense="On") ? true : false)
      IfNotInString,var,valueT2E | if !InStr({1}, {2}, (A_StringCaseSense="On") ? true : false)
      IfExist,fileT2E | if FileExist({1})
      IfNotExist,fileT2E | if !FileExist({1})
      IfWinExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinExist({1}, {2}, {3}, {4})
      IfWinNotExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinExist({1}, {2}, {3}, {4})
      IfWinActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinActive({1}, {2}, {3}, {4})
      IfWinNotActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinActive({1}, {2}, {3}, {4})
      SetEnv,var,valueT2E | {1} := {2}
      Sleep,DelayCBE2T | Sleep, {1}
      Sort,var,options | Sort, {1}, `%{1}`%, {2}
      SplitPath,varCBE2T,filename,dir,ext,name_no_ext,drv | SplitPath, {1}, {2}, {3}, {4}, {5}, {6}
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringGetPos,OutputVar,InputVar,SearchTextT2E,SideT2E,OffsetCBE2E | *_StringGetPos
      StringMid,OutputVar,InputVar,StartCharCBE2E,CountCBE2E,L_T2E | *_StringMid
      StringLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, {3})
      StringRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, -1*({3}))
      StringTrimLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, ({3})+1)
      StringTrimRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, -1*({3}))
      StringUpper,OutputVar,InputVar,T| StrUpper, {1}, `%{2}`%, {3}
      StringLower,OutputVar,InputVar,T| StrLower, {1}, `%{2}`%, {3}
      StringReplace,OutputVar,InputVar,SearchTxt,ReplTxt,ReplAll | *_StrReplace
      WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *_WinGetActiveStats
      WinGetActiveTitle,OutputVar | WinGetTitle, {1}, A
   )"


   ;// this is a list of all renamed variables or functions, in this format:
   ;//          OrigWord | ReplacementWord
   ;//
   ;// functions should include the parentheses
   ;//
   ;// important: the order matters. the first 2 in the list could cause a mistake if not ordered properly
   KeywordsToRename := "
   (
      A_LoopFileFullPath | A_LoopFilePath
      A_LoopFileLongPath | A_LoopFileFullPath
      ComSpec | A_ComSpec
      Asc() | Ord()
      ComObjParameter() | ComObject()
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
      RegExMatch(Line, "^(\s*)", &Indentation)
      Indentation := Indentation[1]
      ;msgbox, % "Line:`n" Line "`n`nIndentation=[" Indentation "]`nStrLen(Indentation)=" StrLen(Indentation)
      FirstChar := SubStr(Trim(Line), 1, 1)
      FirstTwo := SubStr(LTrim(Line), 1, 2)
      ;msgbox, FirstChar=%FirstChar%`nFirstTwo=%FirstTwo%
      if RegExMatch(Line, "(\s+`;.*)$", &EOLComment)
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
      ; first replace any renamed vars/funcs
      ;
      Loop, Parse, %KeywordsToRename%, `n
      {
         StrSplit, Part, %A_LoopField%, |
         srchtxt := Trim(Part[1])
         rplctxt := Trim(Part[2])
         if SubStr(srchtxt, -2) = "()"
            srchtxt := SubStr(srchtxt, 1, -1)
         if SubStr(rplctxt, -2) = "()"
            rplctxt := SubStr(rplctxt, 1, -1)
         ;msgbox % A_LoopField "`n[" srchtxt "]`n[" rplctxt "]"

         if InStr(Line, srchtxt)
         {
            if SubStr(srchtxt, -1) = "("
               srchtxt := StrReplace(srchtxt, "(", "\(")
            ;msgbox, %Line%
            Line := RegExReplace(Line, "i)([^\w])" . srchtxt . "([^\w])", "$1" . rplctxt . "$2")
            ;msgbox, %Line%
         }
      }


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
         ;If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", &Join)
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
      else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", &Equation) ; Thanks Lexikos
      {
         ;msgbox assignment regex`nLine: %Line%`n%Equation[1]%`n%Equation[2]%
         Line := RTrim(Equation[1]) . " := " . ToStringExpr(Equation[2])   ; regex above keeps the indentation already
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Traditional-if to Expression-if
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?)", &Equation)
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
      ; if var between
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?between ([^{;]*) and ([^{;]*)(\s*{?)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         Line := Indentation . format_v("{else}if {not}({var} >= {val1} && {var} <= {val2}){otb}"
                                        , { else: Equation[1]
                                          , var: Equation[2]
                                          , not: (Equation[3]) ? "!" : ""
                                          , val1: ToExp(Equation[4])
                                          , val2: ToExp(Equation[5])
                                          , otb: Equation[6] } )
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var is type
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) is (not\s+)?([^{;]*)(\s*{?)", &Equation)
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
      else if RegExMatch(Line, "i)^\s*(\w+)\((.+)\)", &MatchFunc)
           && !(MatchFunc[1] ~= "i)(if|while)")         ; skip if(expr) and while(expr) when no space before paren
      ; this regex matches anything inside the parentheses () for both func definitions, and func calls :(
      {
         AllParams := MatchFunc[2]
         ;msgbox, % "function line`n`nLine:`n" Line "`n`nAllParams:`n" AllParams

         ; first replace all commas and question marks inside quoted strings with placeholders
         ;  - commas: because we will use comma as delimeter to parse each individual param
         ;  - question mark: because we will use that to determine if there is a ternary
         pos := 1, quoted_string_match := ""
         while (pos := RegExMatch(AllParams, "`".*?`"", &MatchObj, pos+StrLen(quoted_string_match)))  ; for each quoted string
         {
            quoted_string_match := MatchObj.Value(0)
            ;msgbox, % "quoted_string_match=" quoted_string_match "`nlen=" StrLen(quoted_string_match) "`npos=" pos
            string_with_placeholders := StrReplace(quoted_string_match, ",", "MY_COMMª_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "?", "MY_¿¿¿_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "=", "MY_ÈQÜAL§_PLA¢E_HOLDER")
            ;msgbox, %string_with_placeholders%
            Line := StrReplace(Line, quoted_string_match, string_with_placeholders, Cnt, 1)
         }
         ;msgbox, % "Line:`n" Line

         ; get all the params again, this time from our line with the placeholders
         if RegExMatch(Line, "i)^\s*\w+\((.+)\)", &MatchFunc2)
         {
            AllParams2 := MatchFunc2[1]
            pos := 1, match := ""
            Loop, Parse, %AllParams2%, `,   ; for each individual param (separate by comma)
            {
               thisprm := A_LoopField
               ;msgbox, % "Line:`n" Line "`n`nthisparam:`n" thisprm
               if RegExMatch(A_LoopField, "i)([\s]*[a-z_][a-z_0-9]*[\s]*)=([^,\)]*)", &ParamWithEquals)
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
         Line := StrReplace(Line, "MY_ÈQÜAL§_PLA¢E_HOLDER", "=")
      }
      ; -------------------------------------------------------------------------------
      ;
      ; Fix     return %var%        ->       return var
      ;
      ; we use the same parsing method as the next else clause below
      ;
      else if (Trim(SubStr(Line, 1, FirstDelim := RegExMatch(Line, "\w[,\s]"))) = "return")
      {
         Params := SubStr(Line, FirstDelim+2)
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
         FirstDelim := RegExMatch(Line, "\w[,\s]") 
         if (FirstDelim > 0)
         {
            Command := Trim( SubStr(Line, 1, FirstDelim) )
            Params := SubStr(Line, FirstDelim+2)
         }
         else
         {
            Command := Trim( SubStr(Line, 1) )
            Params := ""
         }
         ;msgbox, Line=%Line%`nFirstDelim=%FirstDelim%`nCommand=%Command%`nParams=%Params%
         ; Now we format the parameters into their v2 equivilents
         Loop, Parse, %CommandsToConvert%, `n
         {
            StrSplit, Part, %A_LoopField%, |
            ;msgbox % A_LoopField "`n[" part[1] "]`n[" part[2] "]"
            ListDelim := RegExMatch(Part[1], "[,\s]")
            ListCommand := Trim( SubStr(Part[1], 1, ListDelim-1) )
            If (ListCommand = Command)
            {
               CommandMatch := 1
               same_line_action := false
               ListParams := RTrim( SubStr(Part[1], ListDelim+1) )
               ;if (Command = "EnvUpdate")
               ;msgbox, CommandMatch`nListCommand=%ListCommand%`nListParams=%ListParams%
               ListParam := Array()
               Param := Array() ; Parameters in expression form
               Loop, Parse, %ListParams%, `,
                  ListParam[A_Index] := A_LoopField
               Params := StrReplace(Params, "``,", "ESCAPED_COMMª_PLA¢E_HOLDER")     ; ugly hack
               Loop, Parse, %Params%, `,
               {
                  ; populate array with the params
                  ; only trim preceeding spaces off each param if the param index is within the
                  ; command's number of allowable params. otherwise, dont trim the spaces
                  ; for ex:  `IfEqual, x, h, e, l, l, o`   should be   `if (x = "h, e, l, l, o")`
                  ; see ~10 lines below
                  if (A_Index <= ListParam.Length())
                     Param[A_Index] := LTrim(A_LoopField)   ; trim leading spaces off each param
                  else
                     Param[A_Index] := A_LoopField
               }
               ;msgbox, % "Line:`n`n" Line "`n`nParam.Length=" Param.Length() "`nListParam.Length=" ListParam.Length()

               ; if we detect TOO MANY PARAMS, could be for 2 reasons
               if ((param_num_diff := Param.Length() - ListParam.Length()) > 0)
               {
                  extra_params := ""
                  Loop, param_num_diff
                     extra_params .= "," . Param[ListParam.Length() + A_Index]
                  extra_params := SubStr(extra_params, 2)
                  extra_params := StrReplace(extra_params, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
                  ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length() "`nParam[ListParam.Length]=" Param[ListParam.Length()] "`nextra_params=" extra_params

                  ; 1. could be because of IfCommand with a same-line 'then' action
                  ;    such as  `IfEqual, x, 1, Sleep, 1`
                  ;    in which case we need to append these extra params later
                  if_cmds_allowing_sameline_action := "IfEqual|IfNotEqual|IfGreater|IfGreaterOrEqual|"
                                                    . "IfLess|IfLessOrEqual|IfInString|IfNotInString"
                  if RegExMatch(Command, "i)^(?:" if_cmds_allowing_sameline_action ")$")
                  {
                     same_line_action := true
                  }

                  ; 2. could be this:
                  ;       "Commas that appear within the last parameter of a command do not need
                  ;        to be escaped because the program knows to treat them literally."
                  ;    from:   https://autohotkey.com/docs/commands/_EscapeChar.htm
                  else
                  {
                     Param[ListParam.Length()] .= "," extra_params
                     ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length() "`nParam[ListParam.Length]=" Param[ListParam.Length()] "`nextra_params=" extra_params
                  }
               }

               ; if we detect TOO FEW PARAMS, fill with empty strings (see Issue #5)
               if ((param_num_diff := ListParam.Length() - Param.Length()) > 0)
               {
                  ;msgbox, % "Line:`n`n" Line "`n`nParam.Length=" Param.Length() "`nListParam.Length=" ListParam.Length() "`ndiff=" param_num_diff
                  Loop, param_num_diff
                     Param.Push("")
               }

               ; convert the params to expression or not
               Loop, % Param.Length()
               {
                  this_param := Param[A_Index]
                  this_param := StrReplace(this_param, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
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
                     if (this_param is "integer")                                               ; if this param is int
                     || (SubStr(this_param, 1, 2) = "`% ")                                      ; or the expression was forced
                     || ((SubStr(this_param, 1, 1) = "`%") && (SubStr(this_param, -1) = "`%"))  ; or var already wrapped in %%s
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

                  if (same_line_action)
                     Line := Indentation . format_v(Part[2], Param) . "," extra_params
                  else
                     Line := Indentation . format_v(Part[2], Param)

                  ; if empty params caused the line to end with extra commas, remove them
                  Line := RegExReplace(Line, "(?:,\s)*$", "")
               }
            }
         }
      }
      
      ; Remove lines we can't use
      If CommandMatch = 0 && !InCommentBlock
         Loop, Parse, %Remove%, `n, `r
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
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox text=%text%

   if InStr(Text, "`%")        ; deref   %var% -> var
   {
      ;msgbox %text%
      TOut := ""
      ;Loop % StrLen(Text)
      Loop, Parse, %Text%
      {
         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField
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
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . Text . qu
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
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox text=%text%

   if InStr(Text, "`%")        ; deref   %var% -> var
   {
      TOut := ""
      ;Loop % StrLen(Text)
      Loop, Parse, %Text%
      {
         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField
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
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . Text . qu
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

; check if a param is empty
IsEmpty(param)
{
   if (param = '') || (param = '""')   ; if its an empty string, or a string containing two double quotes
      return true
   return false
}

; =============================================================================
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
; =============================================================================
_WinGetActiveStats(p) {
   Out := format_v("WinGetTitle, {1}, A", p) . "`r`n"
   Out .= format_v("WinGetPos, {4}, {5}, {2}, {3}, A", p)
   return Out   
}

_EnvAdd(p) {
   if !IsEmpty(p[3])
      return format_v("{1} := DateAdd({1}, {2}, {3})", p)
   else
      return format_v("{1} += {2}", p)
}

_EnvSub(p) {
   if !IsEmpty(p[3])
      return format_v("{1} := DateDiff({1}, {2}, {3})", p)
   else
      return format_v("{1} -= {2}", p)
}

_StringGetPos(p)
{
   ;msgbox, % p.Length() "`n" p[1] "`n" p[2] "`n" p[3] "`n" p[4] "`n" p[5]
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format_v("{1} := InStr({2}, {3}) - 1", p)

   ; modelled off of:   https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script.cpp#L14181
   else
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
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format_v("{1} := SubStr({2}, {3})", p)
   else if IsEmpty(p[5])
      return format_v("{1} := SubStr({2}, {3}, {4})", p)
   else
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

   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format_v("StrReplace, {1}, `%{2}`%, {3},,, 1", p)
   else if IsEmpty(p[5])
      return format_v("StrReplace, {1}, `%{2}`%, {3}, {4},, 1", p)
   else
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
    while i := RegExMatch(f, O_ "\{((\w+)(?::([^*`%{}]*([scCdiouxXeEfgGaAp])))?|[{}])\}", &m, j)  ; For each {placeholder}.
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

