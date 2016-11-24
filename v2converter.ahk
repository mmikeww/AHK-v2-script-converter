; =============================================================================
; Script Converter
;    for converting scripts from v1 AutoHotkey to v2
; Use:
;    Run the script
;    Chose the file you want to convert in the file select dialog
;    A msgbox will popup telling you the script finished converting
;   If you gave the file MyScript.ahk, the output file will be MyScriptNew.ahk
;   Thats it, feel free to add to it and post changes here: http://www.autohotkey.com/forum/viewtopic.php?t=70266
; Uses format.ahk
; =============================================================================

Remove := "#AllowSameLineComments`n#MaxMem`nSoundGetWaveVolume`nSoundSetWaveVolume`n#NoEnv`n#Delimiter`nSetFormat`nA_FormatInteger`nA_FormatFloat"

Convert := "EnvAdd,InputVar,Value,TimeUnits | *EnvAdd`nEnvDiv,InputVar,Value | {1} /= {2}`nEnvMult,InputVar,Valut | {1} *= {2}`nEnvSub,InputVar,Value,TimeUnits | {1} -= {2}[, {3}]`nIfEqual,InputVar,value | If {1} = {2}`nIfNotEqual,InputVar,value | If {1} != {2}`nIfGreater,InputVar,value | If {1} > {2}`nIfGreaterOrEqual,InputVar,value | If {1} >= {2}`nIfLess,InputVar,value | If {1} < {2}`nIfLessOrEqual,InputVar,value | If {1} <= {2}`nStringLen,OutputVar,InputVar | {1} := StrLen({2})`nStringGetPos,OutputVar,InputVar,SearchText,Side, Offset | {1} := InStr({2}, {3}[][, false, {5}])`nStringMid,OutputVar,InputVar,StartChar,Count,L | {1} := SubStr({2}, {3}[, {4}][])`nStringLeft,OutputVar,InputVar,Count | {1} := SubStr({2}, 1, {3})`nStringRight,OutputVar,InputVar,Count | {1} := SubStr({2}, -{3}+1, {3})`nStringTrimLeft,OutputVar,InputVar,Count | {1} := SubStr({2}, 1, -{3})`nStringTrimRight,OutputVar,InputVar,Count | {1} := SubStr({2}, {3}+1)`nWinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *ActiveStats`nWinGetActiveTitle,OutputVar | WinGetTitle, {1}, A`nDriveSpaceFree,OutputVar,PathVar | DriveGet, {1}, SpaceFree, {2}"

Directives := "#Warn UseUnsetLocal`r`n#Warn UseUnsetGlobal"

SubStrFunction := "`r`n`r`n; This function may be removed if StartingPos is always > 0.`r`nCheckStartingPos(p) {`r`n   Return, p - (p <= 0)`r`n}`r`n`r`n"

; =============================================================================
; Main Part of program
;   Many changes can be made without altering this
; =============================================================================
if !Args
{
   FileSelectFile, FN,, %A_MyDocuments%
   If !FN
      ExitApp
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"
}
else If Args.MaxIndex() = 1 ; Allow a command line param for the file name ex. Run Convert.ahk "MyInputFile.ahk"
{
   FN := Trim(Args[1])
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"
}
else if Mod(Args.MaxIndex(), 2) = 0 ; Parse arguments with linux like syntax, ex. Run Convert.ahk --input "Inputfile.ahk" -o "OutputFile.ahk"
{
   for i, P in Args
   {
      If Mod(i,2) ; Odd parameter, identifier
      {
         If (P = "-o") || (P = "--output")
            Mode := 1
         else If (P = "-i") || (P = "--input")
            Mode := 2
         else
            Mode := 0
      }
      else if Mode != 0
      {
         If Mode = 1
            FNOut := Trim(P)
         else if Mode = 2
            FN := Trim(P)
      }
   }
}


If !FN
{
   Msgbox, 48, Conversion Error, The commandline parameters passed are invalid.  Please make sure they are correct and try again.  Now exiting.
   ExitApp
}
If !FNOut
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"


Output := FileOpen(FNOut, "w")
LoopRead, %FN%
{
   Skip := false
   Line := A_LoopReadLine
   FirstChar := SubStr( Trim(Line), 1, 1 )
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
   }
   
   else If InStr(Line, "SendMode") && InStr(Line, "Input")
      Skip := true
   
   else if ( FirstChar == "(" )
   {
      If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", Join)
         JoinBy := Join1
      else
         JoinBy := "``n"
      Cont := 1
      If InStr(LastLine, ":= """"")
      {
         Output.Seek(-4, 1) ; Remove the newline characters and double quotes
      }
      else
      {
         Output.Seek(-2, 1)
         Output.Write(" `% ")
      }
      continue ; Don't add to the output file
   }

   else if ( FirstChar == ")" )
   {
      Cont := 0
      continue
   }

   else if Cont
   {
      Line := ToExp(Line . JoinBy)
      If Cont > 1
         Line := ". " . Line
      Cont++
   }
   
   ; Replace = with := expression equivilents
   else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", Equation) ; Thanks Lexikos
      Line := RTrim(Equation1) . " := " . ToExp(Equation2)
   
   else If RegExMatch(Line, "i)^(\s*if\s+[a-z_][a-z_0-9]*[\s]*)=([^{;]*)(\s*{?)", Equation)
      Line := format_v("{variable} = {equation}{otb}", {variable: RTrim(Equation1), equation: ToExp(Equation2), otb: Equation3} )
   
   else ; Command replacing
   ; To add commands to be checked for, modify the list at the top of this file
   {
      CommandMatch := 0
      Line := RegExReplace(Line, ",\s+", ",")
      FirstDelim := RegExMatch(Line, "[,\s]") 
      Command := Trim( SubStr(Line, 1, FirstDelim-1) )
      Params := SubStr(Line, FirstDelim+1)
      ; Now we format the parameters into their v2 equivilents
      LoopParse, Convert, `n
      {
         StrSplit, Part, A_LoopField, |
         ListDelim := RegExMatch(Part1, "[,\s]")
         ListCommand := Trim( SubStr(Part1, 1, ListDelim-1) )
         If (ListCommand = Command)
         {
            CommandMatch := 1
            ListParams := RTrim( SubStr(Part1, ListDelim+1) )
            ListParam := Array()
            Param := Array() ; Parameters in expression form
            LoopParse, ListParams, `,
               ListParam[A_Index] := A_LoopField
            LoopParse, Params, `,
               If InStr(ListParam[A_Index], "var")
                  Param[A_Index] := A_LoopField
               else
                  Param[A_Index] := ToExp(A_LoopField)
            Part2 := Trim(Part2)
            If ( SubStr(Part2, 1, 1) == "*" )
            {
               FuncName := SubStr(Part2, 2)
               If IsFunc(FuncName)
                  Line := %FuncName%(Param)
            }
            else
            {
               If ParamDif := (ListParam.MaxIndex() - Param.MaxIndex() )
                  ; Remove all unused optional parameters
                  Part2 := RegExReplace(Part2, "\[[^\]]*\]", "", Count, ParamDif, 1)
               StrReplace, Part2, Part2, [,, All
               StrReplace, Part2, Part2, ],, All
               Line := format_v(Part2, Param)
            }
         }
      }
   }
   
   ; Remove lines we can't use
   If CommandMatch = 0 && !InCommentBlock
      LoopParse, Remove, `n, `r
         If InStr(A_LoopReadLine, A_LoopField)
            Skip := true
   
   ; TEMPORARY
   If !FoundSubStr && !InCommentBlock && InStr(Line, "SubStr") 
   {
      FoundSubStr := true
      Line .= " `; WARNING: SubStr conversion may change in the near future"
   }
   
   ; Put the directives after the first non-comment line
   If !FoundNonComment && !InCommentBlock && A_Index != 1 && FirstChar != ";" && FirstTwo != "*/"
   {
      Output.Write(Directives . "`r`n")
      FoundNonComment := true
   }
   

   If Skip
      Line := format_v("; REMOVED: {line}", {line: Line})
   Output.Write(Line . "`r`n")
   LastLine := Line
}

; The following will be uncommented at a a later time
;If FoundSubStr
;   Output.Write(SubStrFunction)

Output.Close()
If !Args.MaxIndex()
   MsgBox, Done!
ExitApp

; =============================================================================
; Convert traditional statements to expressions
;    Don't pass whole commands, instead pass one parameter at a time
; =============================================================================
ToExp(Text)
{
   static qu := """" ; Constant for double quotes
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
      TOut := Text+0
   }
   else
   {
      StrReplace, TOut, Text, % qu, % qu . qu, All
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
   Count := p.MaxIndex()
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

