#Requires AutoHotKey v2.0
#SingleInstance Force

; to do: strsplit (old command)
; requires should change the version :D
global dbg:=0
global gQuotedStrings := []     ; 2024-04-08 ADDED, andymbody

#Include lib/ClassOrderedMap.ahk
#Include lib/dbg.ahk

#Include Convert/1Commands.ahk
#Include Convert/2Functions.ahk
#Include Convert/3Methods.ahk
#Include Convert/4ArrayMethods.ahk
#Include Convert/5Keywords.ahk

Convert(ScriptString)
{

   global ScriptStringsUsed := Array()	; Keeps an array of interesting strings used in the script
   ScriptStringsUsed.ErrorLevel := InStr(ScriptString, "ErrorLevel")
   global aListPseudoArray := Array()     	; list of strings that should be converted from pseudoArray to Array
   global aListMatchObject := Array()     	; list of strings that should be converted from Match Object V1 to Match Object V2
   global aListLabelsToFunction := Array()	; array of objects with the properties [label] and [parameters] that should be converted from label to Function
   global Orig_Line
   global Orig_Line_NoComment
   global Orig_ScriptString := ScriptString
   global oScriptString	; array of all the lines
   global O_Index := 0	; current index of the lines
   global Indentation
   global SingleIndent := RegExMatch(ScriptString, "(^|[\r\n])( +|\t)", &SingleIndent) ? SingleIndent[2] : "    " ; First spaces or single tab found.
   global GuiNameDefault
   global GuiList
   global GuiVList	; Used to list all variable names defined in a Gui
   global MenuList
   global mAltLabel   := GetAltLabelsMap(ScriptString)	; Create a map of labels who are identical
   global mGuiCType   := map()                        	; Create a map to return the type of control
   global mGuiCObject := map()                        	; Create a map to return the object of a control
   global NL_Func          := ""                      	; _Funcs can use this to add New Previous Line
   global EOLComment_Func  := ""                      	; _Funcs can use this to add comments at EOL
   global grePostFuncMatch := False                   	; ... to know their regex matched
   global noSideEffect     := False                   	; ... to not change global variables

   global ListViewNameDefault
   global TreeViewNameDefault
   global StatusBarNameDefault
   global gFunctPar

   global CommandsToConvertM
   global FunctionsToConvertM
   global MethodsToConvertM
   global ArrayMethodsToConvertM
   global KeywordsToRenameM

   GuiNameDefault := "myGui"
   ListViewNameDefault := "LV"
   TreeViewNameDefault := "TV"
   StatusBarNameDefault := "SB"
   GuiList := "|"
   MenuList := "|"
   GuiVList := Map()

   ;Directives := "#Warn UseUnsetLocal`r`n#Warn UseUnsetGlobal"
   ; Splashtexton and Splashtextoff is removed, but alternative gui code is available
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
      SetBatchLines
      SetFormat
      SoundGetWaveVolume
      SoundSetWaveVolume
      SplashImage
      A_FormatInteger
      A_FormatFloat
      AutoTrim
   )"

   ScriptOutput := ""
   InCommentBlock := false
   InCont := 0
   Cont_String := 0
   oScriptString := {}
   oScriptString := StrSplit(ScriptString, "`n", "`r")

   ; parse each line of the input script
   Loop
   {
      O_Index++
      if (oScriptString.Length < O_Index) {
         ; This allows the user to add or remove lines if necessary
         ; Do not forget to change the O_index if you want to remove or add the line above or lines below
         break
      }
      O_Loopfield := oScriptString[O_Index]

      Skip := false

      Line := O_Loopfield
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
      } else if (FirstChar == ";")
      {
         EOLComment := Line
         Line := ""
      } else
         EOLComment := ""

      CommandMatch := -1

      ; get PreLine of line with hotkey and hotstring definition, String will be temporary removed form the line
      ; Prelines is code that does not need to changes anymore, but coud prevent correct command conversion
      PreLine := ""

      if RegExMatch(Line, "^\s*(.*[^\s]::).*$") {
         LineNoHotkey := RegExReplace(Line, "(^\s*).+::(.*$)", "$2")
         if (LineNoHotkey != "") {
            PreLine .= RegExReplace(Line, "^(\s*.+::).*$", "$1")
            Line := LineNoHotkey
         }
      }
      if RegExMatch(Line, "^\s*({\s*).*$") {
         LineNoHotkey := RegExReplace(Line, "(^\s*)({\s*)(.*$)", "$3")
         if (LineNoHotkey != "") {
            PreLine .= RegExReplace(Line, "(^\s*)({\s*)(.*$)", "$1$2")
            Line := LineNoHotkey
         }
      }
      if RegExMatch(Line, "i)^\s*(}?\s*(Try|Else)\s*[\s{]\s*).*$") {
         LineNoHotkey := RegExReplace(Line, "i)(^\s*)(}?\s*(Try|Else)\s*[\s{]\s*)(.*$)", "$4")
         if (LineNoHotkey != "") {
            PreLine .= RegExReplace(Line, "i)(^\s*)(}?\s*(Try|Else)\s*[\s{]\s*)(.*$)", "$1$2")
            Line := LineNoHotkey
         }
      }

      Orig_Line := Line

      ; Remove comma after flow commands
      If RegExMatch(Line, "i)^(.*)(else|for|if|loop|return|while)(\s*,\s*|\s+)(.*)$", &Equation) {
         Line := Equation[1] Equation[2] " " Equation[4]
      }

      ; Fix lines with preceeding }
      LinePrefix := ""
      If RegExMatch(Line, "i)^\s*}(?!\s*else|\s*\n)\s*", &Equation) {
         Line := StrReplace(Line, Equation[],,,, 1)
         LinePrefix := Equation[]
      }

      ; Handle return % var -> return var
      If RegExMatch(Line, "i)^(.*)(return)(\s+%\s*\s+)(.*)$", &Equation) {
         Line := Equation[1] Equation[2] " " Equation[4]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; skip comment blocks with one statement
      ;
      else if (FirstTwo == "/*") {
         line .= EOLComment ; done here because of the upcoming "continue"
         EOLComment := ""
         loop {
            O_Index++
            if (oScriptString.Length < O_Index) {
               break
            }
            LineContSect := oScriptString[O_Index]
            Line .= "`r`n" . LineContSect
            FirstTwo := SubStr(LTrim(LineContSect), 1, 2)
            if (FirstTwo == "*/") {
               ; End Comment block
               break
            }
         }
         ScriptOutput .= Line . "`r`n"
         ; Output and NewInput should become arrays, NewInput is a copy of the Input, but with empty lines added for easier comparison.
         LastLine := Line
         continue	; continue with the next line
      }

      ; Check for , continuation sections add them to the line
      ; https://www.autohotkey.com/docs/Scripts.htm#continuation
      loop
      {
         if (oScriptString.Length < O_Index + 1) {
            break
         }
         FirstNextLine := SubStr(LTrim(oScriptString[O_Index + 1]), 1, 1)
         FirstTwoNextLine := SubStr(LTrim(oScriptString[O_Index + 1]), 1, 1)
         TreeNextLine := SubStr(LTrim(oScriptString[O_Index + 1]), 1, 1)
         if (FirstNextLine ~= "[,\.]" or FirstTwoNextLine ~= "[\?:]\s" or FirstTwoNextLine = "||" or FirstTwoNextLine = "&&" or FirstTwoNextLine = "or" or TreeNextLine = "and") {
            O_Index++
            ; Known effect : removes the linefeeds and comments of continuation sections
            Line .= RegExReplace(oScriptString[O_Index], "(\s+`;.*)$", "")
         } else {
            break
         }
      }

      ; Loop the functions
      noSideEffect := False
      subLoopFunctions(ScriptString, Line, &LineFuncV2, &gotFunc:=False)
      if gotFunc {
         Line := LineFuncV2
      }

      ; Remove case from switch to ensure conversion works
      CaseValue := ""
      if RegExMatch(Line, "i)^\s*(?:case .*?|default):(?!=)", &Equation) {
         CaseValue := Equation[]
         Line := StrReplace(Line, CaseValue,,,, 1)
      }

      ; -------------------------------------------------------------------------------
      ; 2024-04-08 - andymbody - RELOCATED code into its own function - RenameKeywords()
      ; also moved the function call near the bottom of this loop...
      ; ... so that strings that have been converted can be masked prior to replacing keywords.
      ; ... This prevents keywords found in strings from being converted by mistake
      ;
;      ; replace any renamed vars
;      ; Known Error: converts also the text
;      for v1, v2 in KeywordsToRenameM
;      {
;         srchtxt := Trim(v1)
;         rplctxt := Trim(v2)

;         if InStr(Line, srchtxt)
;         {
;            Line := RegExReplace(Line, "i)([^\w]|^)\Q" . srchtxt . "\E([^\w]|$)", "$1" . rplctxt . "$2")
;            ;MsgBox(Line "`n" srchtxt "`n" rplctxt)
;         }
;      }

      Orig_Line_NoComment := Line

      ; -------------------------------------------------------------------------------
      ;
      ; check if this starts a continuation section
      ;
      ; no idea what that RegEx does, but it works to prevent detection of ternaries
      ; got that RegEx from Coco here: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/EnumIncludes.ahk#L65
      ; and modified it slightly
      ;

      if (FirstChar == "(")
         && RegExMatch(Line, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$")
      {
         InCont := 1
         ;If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", &Join)
         ;JoinBy := Join[1]
         ;else
         ;JoinBy := "``n"
         ;MsgBox, Start of continuation section`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nScriptOutput:`n[`n%ScriptOutput%`n]
         If InStr(LastLine, ':= ""')
         {
            ; if LastLine was something like:                                  var := ""
            ; that means that the line before conversion was:                  var =
            ; and this new line is an opening ( for continuation section
            ; so remove the last quote and the newline `r`n chars so we get:   var := "
            ; and then re-add the newlines
            ScriptOutput := SubStr(ScriptOutput, 1, -3) . "`r`n"
            ;MsgBox, Output after removing one quote mark:`n[`n%ScriptOutput%`n]
            Cont_String := 1
            ;;;Output.Seek(-4, 1) ; Remove the newline characters and double quotes
         } else
         {
            ;;;Output.Seek(-2, 1)
            ;;;Output.Write(" `% ")
         }
         ;continue ; Don't add to the output file
      } else if (FirstChar == ")")
      {
         ;MsgBox "End Cont. Section`n`nLine:`n" Line "`n`nLastLine:`n" LastLine "`n`nScriptOutput:`n[`n" ScriptOutput "`n]"
         InCont := 0
         if (Cont_String = 1)
         {
            if (FirstTwo != ")`"") {	; added as an exception for quoted continuation sections
               Line := RegExReplace(Line, "\)", ")`"", , 1)
            }

            ScriptOutput .= Line . "`r`n"
            LastLine := Line
            continue
         }
      } else if InCont
      {
         ;Line := ToExp(Line . JoinBy)
         ;If InCont > 1
         ;Line := ". " . Line
         ;InCont++
         Line := RegexReplace(Line, "%(.*?)%", "`" $1 `"")
         ;MsgBox "Inside Cont. Section`n`nLine:`n" Line "`n`nLastLine:`n" LastLine "`n`nScriptOutput:`n[`n" ScriptOutput "`n]"
         ScriptOutput .= Line . "`r`n"
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
      else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", &Equation)	; Thanks Lexikos
      {
         ; msgbox("assignment regex`norigLine: " Line "`norig_left=" Equation[1] "`norig_right=" Equation[2] "`nconv_right=" ToStringExpr(Equation[2]))
         Line := RTrim(Equation[1]) . " := " . ToStringExpr(Equation[2])	; regex above keeps the indentation already
      }
      Else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*):=([\s\t]*)$", &Equation) ; var := should become var := ""
      {
         Line := RTrim(Equation[1]) . ' := ""' . Equation[2]
      }
      else if RegexMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*[:\.]=\s*)(.*)", &Equation) ; Line is a variable assignment, check for ""
      { ; Replace "" with `", see #111
         if InStr(Line, "`"`"") {
            Line := Equation[1]
            val := Equation[2]
            funcArray := []
            while (pos := RegexMatch(val, "\w+\(.*?\)", &match)) {
               funcArray.push(match[])
               val := StrReplace(val, match[], Chr(1000) funcArray.Length Chr(1000) Chr(932),,, 1)
            }
            regex := 'i)(\w[\w\d]*[^"]*)?("(?:"")?(?:(?:""|[^"])*)*?(?:"")?")([ \t]*[a-z]*[ \t]*)'
            if (pos := RegExMatch(val, regex, &match) != 0) { ; https://regex101.com/r/tpJlSH/1
               arr := []
               while pos != 0 {
                  i := 1
                  Loop(match.Count) {
                     if SubStr(match[i], 1, 1) = "`"" { ; If match is a string
                        str := "`"" StrReplace(RegexReplace(match[i], "`"(.*)`"", "$1"), "`"`"", "```"") "`""
                        arr.Push(str)
                     } else {
                        arr.Push(match[i])
                     }
                     i++
                  }
                  val := StrReplace(val, match[])
                  pos := RegExMatch(val, regex, &match)
               }
               for i, v in arr {
                  Line .= v
               }
            }
            if (Line = Equation[1])
               Line .= val
            for i, v in funcArray {
               Line := StrReplace(Line, Chr(1000) i Chr(1000) Chr(932), v,, &replacements, 1)
               if (replacements = 0) ; First Chr(1000) not included with match[i]
                  Line := StrReplace(Line, i Chr(1000) Chr(932), v,,, 1) ; This is a horrible fix
            }
         }
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Traditional-if to Expression-if
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%`n6: %Equation[6]%
         ; Line := Indentation . format_v("{else}if {not}({variable} {op} {value}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , not: Equation[2]
         ;                                  , variable: RTrim(Equation[3])
         ;                                  , op: Equation[4]
         ;                                  , value: ToExp(Equation[5])
         ;                                  , otb: Equation[6] } )
         op := (Equation[4] = "<>") ? "!=" : Equation[4]

         ; not used,
         ; Line := Indentation . format("{1}if {2}({3} {4} {5}){6}"
         ;                                                         , Equation[1]          ;else
         ;                                                         , Equation[2]          ;not
         ;                                                         , RTrim(Equation[3])   ;variable
         ;                                                         , op                   ;op
         ;                                                         , ToExp(Equation[5])   ;value
         ;                                                         , Equation[6] )        ;otb
         ; Preline hack for furter commands
         PreLine := Indentation PreLine . format("{1}if {2}({3} {4} {5}){6}"
            , Equation[1]	;else
            , Equation[2]	;not
            , RTrim(Equation[3])	;variable
            , op	;op
            , ToExp(Equation[5])	;value
            , Equation[6])	;otb

         Line := Equation[7]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var between
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?between ([^{;]*) and ([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({var} >= {val1} && {var} <= {val2}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , var: Equation[2]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , val1: ToExp(Equation[4])
         ;                                  , val2: ToExp(Equation[5])
         ;                                  , otb: Equation[6] } )
         val1 := ToExp(Equation[4])
         val2 := ToExp(Equation[5])

         if (isNumber(val1) && isNumber(val2)) || InStr(Equation[4], "%") || InStr(Equation[5], "%")
         {
            PreLine .= Indentation . format("{1}if {3}({2} >= {4} && {2} <= {5}){6}"
               , Equation[1]	;else
               , Equation[2]	;var
               , (Equation[3]) ? "!" : ""	;not
               , val1	;val1
               , val2	;val2
               , Equation[6])	;otb
         } else	; if not numbers or variables, then compare alphabetically with StrCompare()
         {
            ;if ((StrCompare(var, "blue") >= 0) && (StrCompare(var, "red") <= 0))
            PreLine .= Indentation . format("{1}if {3}((StrCompare({2}, {4}) >= 0) && (StrCompare({2}, {5}) <= 0)){6}"
               , Equation[1]	;else
               , Equation[2]	;var
               , (Equation[3]) ? "!" : ""	;not
               , val1	;val1
               , val2	;val2
               , Equation[6])	;otb
         }
         Line := Equation[7]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var in
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?in ([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({var} in {val1}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , var: Equation[2]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , val1: ToExp(Equation[4])
         ;                                  , otb: Equation[6] } )
         if RegExMatch(Equation[4], "^%") {
            val1 := "`"^(?i:`" RegExReplace(RegExReplace(" ToExp(Equation[4]) ",`"[\\\.\*\?\+\[\{\|\(\)\^\$]`",`"\$0`"),`"\s*,\s*`",`"|`") `")$`""
         } else if RegExMatch(Equation[4], "^[^\\\.\*\?\+\[\{\|\(\)\^\$]*$") {
            val1 := "`"^(?i:" RegExReplace(Equation[4], "\s*,\s*", "|") ")$`""
         } else {
            val1 := "`"^(?i:" RegExReplace(RegExReplace(Equation[4], "[\\\.\*\?\+\[\{\|\(\)\^\$]", "\$0"), "\s*,\s*", "|") ")$`""
         }
         PreLine .= Indentation . format("{1}if {3}({2} ~= {4}){5}"
            , Equation[1]	;else
            , Equation[2]	;var
            , (Equation[3]) ? "!" : ""	;not
            , val1	;val1
            , Equation[5])	;otb

         Line := Equation[6]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var contains
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?contains ([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({var} contains {val1}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , var: Equation[2]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , val1: ToExp(Equation[4])
         ;                                  , otb: Equation[6] } )
         if RegExMatch(Equation[4], "^%") {
            val1 := "`"i)(`" RegExReplace(RegExReplace(" ToExp(Equation[4]) ",`"[\\\.\*\?\+\[\{\|\(\)\^\$]`",`"\$0`"),`"\s*,\s*`",`"|`") `")`""
         } else if RegExMatch(Equation[4], "^[^\\\.\*\?\+\[\{\|\(\)\^\$]*$") {
            val1 := "`"i)(" RegExReplace(Equation[4], "\s*,\s*", "|") ")`""
         } else {
            val1 := "`"i)(" RegExReplace(RegExReplace(Equation[4], "[\\\.\*\?\+\[\{\|\(\)\^\$]", "\$0"), "\s*,\s*", "|") ")`""
         }
         PreLine .= Indentation . format("{1}if {3}({2} ~= {4}){5}"
            , Equation[1]	;else
            , Equation[2]	;var
            , (Equation[3]) ? "!" : ""	;not
            , val1	;val1
            , Equation[5])	;otb

         Line := Equation[6]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var is type
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) is (not\s+)?([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({variable} is {type}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , variable: Equation[2]
         ;                                  , type: ToStringExpr(Equation[4])
         ;                                  , otb: Equation[5] } )
         PreLine .= Indentation . format("{1}if {3}is{4}({2}){5}"
            , Equation[1]	;else
            , Equation[2]	;var
            , (Equation[3]) ? "!" : ""	;not
            , StrTitle(Equation[4])	;type
            , Equation[5])	;otb
         Line := Equation[6]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Replace all switch variations with Switch SwitchValue
      ;
      else if RegExMatch(Line, "i)^\s*switch,?\s*\(?(.*)\)?\s*\{?", &Equation)
      {
         Line := "Switch " Equation[1]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Replace = with := in function default params
      ;
      else if RegExMatch(Line, "i)^\s*(\w+)\((.+)\)", &MatchFunc)
         && !(MatchFunc[1] ~= "i)\b(if|while)\b")	; skip if(expr) and while(expr) when no space before paren
      ; this regex matches anything inside the parentheses () for both func definitions, and func calls :(
      {
         ; Changing the ByRef parameters to & signs.
         Line := RegExReplace(Line, "i)(\bByRef\s+)", "&")

         AllParams := MatchFunc[2]
         ;msgbox, % "function line`n`nLine:`n" Line "`n`nAllParams:`n" AllParams

         ; first replace all commas and question marks inside quoted strings with placeholders
         ;  - commas: because we will use comma as delimeter to parse each individual param
         ;  - question mark: because we will use that to determine if there is a ternary
         pos := 1, quoted_string_match := ""
         while (pos := RegExMatch(AllParams, '".*?"', &MatchObj, pos + StrLen(quoted_string_match)))	; for each quoted string
         {
            quoted_string_match := MatchObj[0]
            ;msgbox, % "quoted_string_match=" quoted_string_match "`nlen=" StrLen(quoted_string_match) "`npos=" pos
            string_with_placeholders := StrReplace(quoted_string_match, ",", "MY_COMMª_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "?", "MY_¿¿¿_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "=", "MY_ÈQÜAL§_PLA¢E_HOLDER")
            ;msgbox, %string_with_placeholders%
            Line := StrReplace(Line, quoted_string_match, string_with_placeholders, "Off", &Cnt, 1)
         }
         ;msgbox, % "Line:`n" Line

         ; get all the params again, this time from our line with the placeholders
         if RegExMatch(Line, "i)^\s*\w+\((.+)\)", &MatchFunc2)
         {
            AllParams2 := MatchFunc2[1]
            pos := 1, match := ""
            Loop Parse, AllParams2, ","	; for each individual param (separate by comma)
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
                     Line := StrReplace(Line, ParamWithEquals[0], TempParam, "Off", &Cnt, 1)
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
         Params := SubStr(Line, FirstDelim + 2)
         if RegExMatch(Params, "^%\w+%$")	; if the var is wrapped in %%, then remove them
         {
            Params := SubStr(Params, 2, -1)
            Line := Indentation . "return " . Params . EOLComment	; 'return' is the only command that we won't use a comma before the 1st param
         }
      }

      ; Moving the if/else/While statement to the preline
      ;
      else If RegExMatch(Line, "i)(^\s*[\}]?\s*(else|while|if)[\s\(][^\{]*{\s*)(.*$)", &Equation) {
         PreLine .= Equation[1]
         Line := Equation[3]
      }
      If RegExMatch(Line, "i)(^\s*)([a-z_][a-z_0-9]*)\s*\+=\s*(.*?)\s*,\s*([SMHD]\w*)(.*$)", &Equation) {

         Line := Equation[1] Equation[2] " := DateAdd(" Equation[2] ", " ParameterFormat("ValueCBE2E", Equation[3]) ", '" Equation[4] "')" Equation[5]
      } else If RegExMatch(Line, "i)(^\s*)([a-z_][a-z_0-9]*)\s*\-=\s*(.*?)\s*,\s*([SMHD]\w*)(.*$)", &Equation) {
         Line := Equation[1] Equation[2] " := DateDiff(" Equation[2] ", " ParameterFormat("ValueCBE2E", Equation[3]) ", '" Equation[4] "')" Equation[5]
      }

      ; Convert Assiociated Arrays to Map Maybe not always wanted...
      If RegExMatch(Line, "i)^(\s*)((global|local|static)\s+)?([a-z_0-9]+)(\s*:=\s*)(\{[^;]*)", &Equation) {
         ; Only convert to a map if for in statement is used for it
         if RegExMatch(ScriptString, "is).*for\s[\s,a-z0-9_]*\sin\s" Equation[4] "[^\.].*") {
            Line := AssArr2Map(Line)
         }
      }

      ; Fixing ternary operations [var ?  : "1"] => [var ? "" : "1"]
      if RegExMatch(Line, "i)^(.*)(\s\?\s*\:\s*)(.*)$", &Equation) {
         Line := RegExReplace(Line, "i)^(.*\s*)\?\s*\:(\s*)(.*)$", '$1? "" :$3')
      }
      ; Fixing ternary operations [var ? "1" : ] => [var ? "1" : ""]
      if RegExMatch(Line, "i)^(.*\s\?.*\:\s*)(\)|$)", &Equation) {
         Line := RegExReplace(Line, "i)^(.*\s\?.*\:\s*)(\)|$)", '$1 ""$2')
      }

      LabelRedoCommandReplacing:
         ; -------------------------------------------------------------------------------
         ;
         ; Command replacing
         ;if (!InCont)
         ; To add commands to be checked for, modify the list at the top of this file
         {
            CommandMatch := 0
            FirstDelim := RegExMatch(Line, "\w([ \t]*[, \t])", &Match) ; doesn't use \s to not consume line jumps

            if (FirstDelim > 0)
            {
               Command := Trim(SubStr(Line, 1, FirstDelim))
               Params := SubStr(Line, FirstDelim + StrLen(Match[1])+1)
            } else
            {
               Command := Trim(SubStr(Line, 1))
               Params := ""
            }
            ; msgbox("Line=" Line "`nFirstDelim=" FirstDelim "`nCommand=" Command "`nParams=" Params)

            ; Now we format the parameters into their v2 equivilents
            if (Command~="i)^#?[a-z]+$" and FindCommandDefinitions(Command, &v1, &v2))
            {
               ListDelim := RegExMatch(v1, "[,\s]|$")
               ListCommand := Trim(SubStr(v1, 1, ListDelim - 1))

               If (ListCommand = Command)
               {
                  CommandMatch := 1
                  same_line_action := false
                  ListParams := RTrim(SubStr(v1, ListDelim + 1))

                  ListParam := Array()
                  Param := Array()	; Parameters in expression form
                  Param.Extra := {}	; To attach helpful info that can be read by custom functions
                  Loop Parse, ListParams, ","
                     ListParam.Push(A_LoopField)

                  oParam := V1ParSplit(Params)

                  Loop oParam.Length
                     Param.Push(oParam[A_index])

                  ; Checks for continuation section
                  if (oScriptString.Length > O_Index and (SubStr(Trim(oScriptString[O_Index + 1]), 1, 1) = "(" or RegExMatch(Trim(oScriptString[O_Index + 1]), "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))) {

                     ContSect := oParam[oParam.Length] "`r`n"

                     loop {
                        O_Index++
                        if (oScriptString.Length < O_Index) {
                           break
                        }
                        LineContSect := oScriptString[O_Index]
                        FirstChar := SubStr(Trim(LineContSect), 1, 1)
                        if ((A_index = 1) && (FirstChar != "(" or !RegExMatch(LineContSect, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))) {
                           ; no continuation section found
                           O_Index--
                           return ""
                        }
                        if (FirstChar == ")") {

                           ; to simplify, we just add the comments to the back
                           if RegExMatch(LineContSect, "(\s+`;.*)$", &EOLComment2)
                           {
                              EOLComment := EOLComment " " EOLComment2[1]
                              LineContSect := RegExReplace(LineContSect, "(\s+`;.*)$", "")
                           } else
                              EOLComment2 := ""

                           Params .= "`r`n" LineContSect

                           oParam2 := V1ParSplit(LineContSect)
                           Param[Param.Length] := ContSect oParam2[1]

                           Loop oParam2.Length - 1
                              Param.Push(oParam2[A_index + 1])

                           break
                        }
                        ContSect .= LineContSect "`r`n"
                        Params .= "`r`n" LineContSect
                     }
                  }

                  ; save a copy of some data before formating
                  Param.Extra.OrigArr := Param.Clone()
                  Param.Extra.OrigStr := Params

                  ; Params := StrReplace(Params, "``,", "ESCAPED_COMMª_PLA¢E_HOLDER")     ; ugly hack
                  ; Loop Parse, Params, ","
                  ; {
                  ; populate array with the params
                  ; only trim preceeding spaces off each param if the param index is within the
                  ; command's number of allowable params. otherwise, dont trim the spaces
                  ; for ex:  `IfEqual, x, h, e, l, l, o`   should be   `if (x = "h, e, l, l, o")`
                  ; see ~10 lines below
                  ;    if (A_Index <= ListParam.Length)
                  ;       Param.Push(LTrim(A_LoopField))   ; trim leading spaces off each param
                  ;    else
                  ;       Param.Push(A_LoopField)
                  ; }

                  ; msgbox("Line:`n`n" Line "`n`nParam.Length=" Param.Length "`nListParam.Length=" ListParam.Length)

                  ; if we detect TOO MANY PARAMS, could be for 2 reasons
                  if ((param_num_diff := Param.Length - ListParam.Length) > 0)
                  {
                     ; msgbox("too many params")
                     extra_params := ""
                     Loop param_num_diff
                        extra_params .= "," . Param[ListParam.Length + A_Index]
                     extra_params := SubStr(extra_params, 2)
                     extra_params := StrReplace(extra_params, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
                     ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length "`nParam[ListParam.Length]=" Param[ListParam.Length] "`nextra_params=" extra_params

                     ; 1. could be because of IfCommand with a same line action
                     ;    such as  `IfEqual, x, 1, Sleep, 1`
                     ;    in which case we need to append these extra params later
                     same_line_action := false
                     if_cmds_allowing_sameline_action := "IfEqual|IfNotEqual|IfGreater|IfGreaterOrEqual|"
                        . "IfLess|IfLessOrEqual|IfInString|IfNotInString|IfMsgBox"
                     if RegExMatch(Command, "i)^(?:" if_cmds_allowing_sameline_action ")$")
                     {
                        if RegExMatch(extra_params, "^\s*(\w+)([\s,]|$)", &next_word)
                        {
                           next_word := next_word[1]
                           if (next_word ~= "i)^(break|continue|return|throw)$")
                              same_line_action := true
                           else
                              same_line_action := FindCommandDefinitions(next_word)
                        }
                        if (same_line_action)
                           extra_params := LTrim(extra_params)
                     }

                     ; 2. could be this:
                     ;       "Commas that appear within the last parameter of a command do not need
                     ;        to be escaped because the program knows to treat them literally."
                     ;    from:   https://autohotkey.com/docs/commands/_EscapeChar.htm
                     if (not same_line_action and ListParam.Length != 0)
                     {
                        Param[ListParam.Length] .= "," extra_params
                        ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length "`nParam[ListParam.Length]=" Param[ListParam.Length] "`nextra_params=" extra_params
                     }
                  }

                  ; if we detect TOO FEW PARAMS, fill with empty strings (see Issue #5)
                  if ((param_num_diff := ListParam.Length - Param.Length) > 0)
                  {
                     ;msgbox, % "Line:`n`n" Line "`n`nParam.Length=" Param.Length "`nListParam.Length=" ListParam.Length "`ndiff=" param_num_diff
                     Loop param_num_diff
                        Param.Push("")
                  }

                  ; convert the params to expression or not
                  Loop Param.Length
                  {
                     this_param := Param[A_Index]
                     this_param := StrReplace(this_param, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
                     if (A_Index > ListParam.Length)
                     {
                        Param[A_Index] := this_param
                        continue
                     }
                     if (A_Index > 1 and InStr(ListParam[A_Index - 1], "*")) {
                        ListParam.InsertAt(A_Index, ListParam[A_Index - 1])
                     }
                     ; uses a function to format the parameters
                     ; trimming is also being handled here
                     Param[A_Index] := ParameterFormat(ListParam[A_Index], Param[A_Index])
                  }

                  v2 := Trim(v2)
                  If (SubStr(v2, 1, 1) == "*")	; if using a special function
                  {
                     FuncName := SubStr(v2, 2)
                     ;msgbox("FuncName=" FuncName)
                     FuncObj := %FuncName%	;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
                     If FuncObj is Func
                        Line := Indentation . FuncObj(Param)
                  } else	; else just using the replacement defined at the top
                  {
                     Line := Indentation . format(v2, Param*)
                     ; msgbox("Line after format:`n`n" Line)

                     ; if empty trailing optional params caused the line to end with extra commas, remove them
                     if SubStr(LTrim(Line), 1, 1) = "#"
                        Line := RegExReplace(Line, "[\s\,]*$", "")
                     else
                        Line := RegExReplace(Line, "[\s\,]*\)$", ")")
                  }

                  if (same_line_action) {
                     PreLine .= Line "`r`n"
                     Indentation .= SingleIndent
                     Line := Indentation . extra_params
                     Goto LabelRedoCommandReplacing
                  }
               }
            }
         }

      if RegexMatch(Line, "i)A_Caret(X|Y)", &Equation) {
         if RegexMatch(Line, "i)A_CaretX") and RegexMatch(Line, "i)A_CaretY") {
            Param := "&A_CaretX, &A_CaretY"
         } else {
            Equation[1] = "X" ? Param := "&" Equation[] : Param := ", &" Equation[]
         }
         Line := "CaretGetPos(" Param ")`n" Line
      }

      ; Add back Case if exists
      if (CaseValue != "") {
         Line := CaseValue " " Line
      }

         ; Remove lines we can't use
      If CommandMatch = 0 && !InCommentBlock
      {
         Loop Parse, Remove, "`n", "`r"
         {
            If InStr(Orig_Line, A_LoopField)
            {
               ;msgbox, skip removed line`nOrig_Line=%Orig_Line%`nA_LoopField=%A_LoopField%
               Skip := true
            }
         }

         if (Line ~= "^\s*(local)\s*$")	; only force-local
            Skip := true
      }

         ; Put the directives after the first non-comment line
         ;If !FoundNonComment && !InCommentBlock && A_Index != 1 && FirstChar != ";" && FirstTwo != "*/"
         ;{
         ;Output.Write(Directives . "`r`n")
         ;msgbox, directives
         ;ScriptOutput .= Directives . "`r`n"
         ;FoundNonComment := true
         ;}

      If Skip
      {
         ;msgbox Skipping`n%Line%
         Line := format("; REMOVED: {1}", Line)
      }

      Line := PreLine Line

      ; Add back LinePrefix if exists
      if (LinePrefix != "") {
         ;MsgBox("LinePrefix Add Back`nLine: [" Line "]`nOG Line: [" Orig_Line "]`nPrefix: [" LinePrefix "]`nScript Output: [" LinePrefix Line "]", "LinePrefix Add Back")
         Line := LinePrefix Line
      }

      ; Correction PseudoArray to Array
      Loop aListPseudoArray.Length {
         if (InStr(Line, aListPseudoArray[A_Index].name))
            Line := ConvertPseudoArray(Line, aListPseudoArray[A_Index])
      }

      ; Correction MatchObject to Array
      Loop aListMatchObject.Length {
         if (InStr(Line, aListMatchObject[A_Index]))
            Line := ConvertMatchObject(Line, aListMatchObject[A_Index])
      }

      ; Convert <> to !=
      if (InStr(Line, "<>"))
         Line := CorrectNEQ(Line)

      ; Remove New keyword from classes
      if (InStr(Line, "new"))
         Line := RemoveNewKeyword(line)
      Line := RenameKeywords(Line)
      Line := RenameLoopRegKeywords(line)

      ; VerCompare when using A_AhkVersion.
      Line := RegExReplace(Line, 'i)\b(A_AhkVersion)(\s*[!=<>]+\s*)"?(\d[\w\-\.]*)"?', 'VerCompare($1, "$3")${2}0')

      if NL_Func {         ; add a newline if exists
         NL_Func .= "`r`n"
      }
      if EOLComment_Func {     ; prepend a `; comment symbol if missing
         if SubStr(StrReplace(EOLComment_Func, A_Space), 1, 1) != "`;" {
            EOLComment_Func := " `; " . EOLComment_Func
         }
      }
      ScriptOutput .= NL_Func . Line . EOLComment . EOLComment_Func . "`r`n"
      NL_Func:="", EOLComment_Func:="" ; reset global variables
      ; Output and NewInput should become arrays, NewInput is a copy of the Input, but with empty lines added for easier comparison.
      LastLine := Line

   }

   ; Convert labels listed in aListLabelsToFunction
   Loop aListLabelsToFunction.Length {
      if aListLabelsToFunction[A_Index].label
         ScriptOutput := ConvertLabel2Func(ScriptOutput, aListLabelsToFunction[A_Index].label, aListLabelsToFunction[A_Index].parameters, aListLabelsToFunction[A_Index].HasOwnProp("NewFunctionName") ? aListLabelsToFunction[A_Index].NewFunctionName : "", aListLabelsToFunction[A_Index].HasOwnProp("aRegexReplaceList") ? aListLabelsToFunction[A_Index].aRegexReplaceList : "")

   }

   If InStr(ScriptOutput, "OnClipboardChange:") {
      ;ScriptOutput :=  RegExReplace(ScriptOutput, "is)^(.*\n[\s\t]*)(OnClipboardChange:)(.*)$" , "$1ClipChanged:$3")
      ScriptOutput := "OnClipboardChange(ClipChanged)`r`n" ConvertLabel2Func(ScriptOutput, "OnClipboardChange", "Type", "ClipChanged", [{NeedleRegEx: "i)^(.*)\b\QA_EventInfo\E\b(.*)$", Replacement: "$1Type$2"}])
   }

   ; trim the very last newline that we add to every line (a few code lines above)
   if (SubStr(ScriptOutput, -2) = "`r`n")
      ScriptOutput := SubStr(ScriptOutput, 1, -2)

   ; Add Brackets to Hotkeys
   ScriptOutput := AddBracket(ScriptOutput)

   return ScriptOutput
}

; =================================================================================
; Convert a v1 function in a single script line to v2
;    Can be used from inside _Funcs for nested checks (e.g., function in a DllCall)
;    Set noSideEffect to 1 to make some callable _Funcs to not change global vars
; =================================================================================
subLoopFunctions(ScriptString, Line, &retV2, &gotFunc) {
   global gFunctPar, grePostFuncMatch
   loop {
      oResult := V1ParSplitfunctions(Line, A_Index)

      if (oResult.Found = 0) {
         break
      }
      if (oResult.Hook_Status > 0) {
         ; This means that the function dit not close, probably a continuation section
         ;MsgBox("Hook_Status: " oResult.Hook_Status "line:" line)
         break
      }
      if (oResult.Func = "") {
         continue ; Not a function only parenthesis
      }

      oPar := V1ParSplit(oResult.Parameters)
      gFunctPar := oResult.Parameters

      ConvertList := FunctionsToConvertM
      if RegExMatch(oResult.Pre, "(\w+)\.$", &Match) {
         ObjectName := Match[1]
         If RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\[|(Array|StrSplit)\()") { ; Type Array().
            ConvertList := ArrayMethodsToConvertM
         } else If RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\{|(Object)\()") { ; Type Object().
            ConvertList := MethodsToConvertM
         } else If RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(new\s+|(FileOpen|Func|ObjBindMethod|\w*\.Bind)\()") { ; Type instance of class.
            ConvertList := [] ; Unspecified conversion patterns.
         } else If RegExMatch(ScriptString, "i)(?<!\w)class\s(\Q" ObjectName "\E)(?!\w)") { ; Type Class.
            ConvertList := [] ; Unspecified conversion patterns.
         } else {
            ConvertList := MethodsToConvertM
            Loop aListMatchObject.Length {
               if (ObjectName = aListMatchObject[A_Index]) {
                  ConvertList := [] ; Conversions handled elsewhere.
                  Break
               }
            }
            Loop aListPseudoArray.Length {
               if (ObjectName = aListPseudoArray[A_Index].name) {
                  ConvertList := [] ; Conversions handled elsewhere.
                  Break
               }
            }
         }
      }
      for v1, v2 in ConvertList
      {
         grePostFuncMatch := False
         ListDelim := InStr(v1, "(")
         ListFunction := Trim(SubStr(v1, 1, ListDelim - 1))
         rePostFunc := ""

         If (ListFunction = oResult.func) {
            ;MsgBox(ListFunction)
            ListParam := SubStr(v1, ListDelim + 1, InStr(v1, ")") - ListDelim - 1)
            rePostFunc := SubStr(v1, InStr(v1,")")+1)
            oListParam := StrSplit(ListParam, "`,", " ")
            ; Fix for when ListParam is empty
            if (ListParam = "") {
               oListParam.Push("")
            }
            v1 := trim(v1)
            v2 := trim(v2)
            loop oPar.Length
            {
               if (A_Index > 1 and InStr(oListParam[A_Index - 1], "*")) {
                  oListParam.InSertAt(A_Index, oListParam[A_Index - 1])
               }
               ; Uses a function to format the parameters
               oPar[A_Index] := ParameterFormat(oListParam[A_Index], oPar[A_Index])
            }
            loop oListParam.Length
            {
               if !oPar.Has(A_Index) {
                  oPar.Push("")
               }
            }

            If (SubStr(v2, 1, 1) == "*")	; if using a special function
            {
               If (rePostFunc != "")
               {
                  ; move post-function's regex match to _Func (it should return back if needed)
                  RegExMatch(oResult.Post, rePostFunc, &grePostFuncMatch)
                  oResult.Post := RegExReplace(oResult.Post, rePostFunc)
               }

               FuncName := SubStr(v2, 2)

               FuncObj := %FuncName%	;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
               If FuncObj is Func {
                  NewFunction := FuncObj(oPar)
               }
            } Else {
               FormatString := Trim(v2)
               NewFunction := Format(FormatString, oPar*)
            }

            ; Remove the empty variables
            NewFunction := RegExReplace(NewFunction, "[\s\,]*\)$", ")")
            ; MsgBox("found:" A_LoopField)
            Line := oResult.Pre NewFunction oResult.Post

            retV2 := Line
            gotFunc:=True

            break ; Function/Method just found and processed.
         }
      }
      ; msgbox("[" oResult.Pre "]`n[" oResult.func "]`n[" oResult.Parameters "]`n[" oResult.Post "]`n[" oResult.Separator "]`n")
      ; Line := oResult.Pre oResult.func "(" oResult.Parameters ")" oResult.Post
   }
}

; =============================================================================
; Convert traditional statements to expressions
;    Don't pass whole commands, instead pass one parameter at a time
; =============================================================================
ToExp(Text)
{
   text := ReplaceQuotes(text)
   static qu := '"' 	; Constant for double quotes
   static bt := "``"	; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")                      	; If text is empty
      return (qu . qu)                 	; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")	; if this param was a forced expression
      return SubStr(Text, 3)           	; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)  	; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")	; then remove escape char for comma
   ;msgbox text=%text%

   if InStr(Text, "%")	; deref   %var% -> var
   {
      ;msgbox %text%
      TOut := ""
      DeRef := 0
      Symbol_Prev := ""
      ;Loop % StrLen(Text)
      Loop Parse, Text
      {

         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField

         if (Symbol_Prev="``"){
            TOut .= Symbol
            Symbol_Prev := "" ; if the next symbol is another ` treat it like a normal symbol
            continue
         } else If (Symbol == "%")
         {
            If (DeRef := !DeRef) && (A_Index != 1)
               TOut .= qu . " "	;TOut .= qu . " . "
            else If (!DeRef) && (A_Index != StrLen(Text))
               TOut .= " " . qu	;TOut .= " . " . qu
         } else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
         Symbol_Prev := Symbol
      }
      If (Symbol != "%")
         TOut .= (qu)	; One double quote
   } else if isNumber(Text)
   {
      ;msgbox %text%
      TOut := Text + 0
   } else	; wrap anything else in quotes
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
   text := ReplaceQuotes(text)
   static qu := '"' 	; Constant for double quotes
   static bt := "``"	; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")                      	; If text is empty
      return (qu . qu)                 	; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")	; if this param was a forced expression
      return SubStr(Text, 3)           	; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)  	; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")	; then remove escape char for comma
   ;msgbox("text=" text)

   if InStr(Text, "%")	; deref   %var% -> var
   {
      TOut := ""
      DeRef := 0
      ;Loop % StrLen(Text)
      Loop Parse, Text
      {
         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField
         If Symbol == "%"
         {
            If (DeRef := !DeRef) && (A_Index != 1)
               TOut .= qu . " . "
            else If (!DeRef) && (A_Index != StrLen(Text))
               TOut .= " . " . qu
         } else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }

      If Symbol != "%"
         TOut .= (qu)	; One double quote
   }
   ;else if type(Text+0) != "String"
   ;{
   ;msgbox %text%
   ;TOut := Text+0
   ;}
   else	; wrap anything else in quotes
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

; Replaces "" by `"
ReplaceQuotes(Text){
    aText :=StrSplit(Text)
    InExpr := false
    Skip := false
    TOut :=""
    loop aText.Length
    {
        if Skip{
            Skip := false
        } else{
            if(aText[A_Index]='"'){
                if(aText.has(A_Index+1) and aText[A_Index+1]='"' and InExpr){
                    aText[A_Index] := '``'
                } else {
                    InExpr := !InExpr
                }
            }
            if(aText[A_Index]='``'){
                Skip := true
            }
        }
        TOut .= aText[A_Index]
    }
    return TOut
}

; check if a param is empty
IsEmpty(param)
{
   if (param = '') || (param = '""')	; if its an empty string, or a string containing two double quotes
      return true
   return false
}

; =============================================================================
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
; =============================================================================
_Control(p) {
   ; Control, SubCommand , Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText

   if (p[1] = "Check") {
      p[1] := "SetChecked"
      p[2] := 1
   } else if (p[1] = "UnCheck") {
      p[1] := "SetChecked"
      p[2] := 0
   } else if (p[1] = "Enable") {
      p[1] := "SetEnabled"
      p[2] := 1
   } else if (p[1] = "Disable") {
      p[1] := "SetEnabled"
      p[2] := 0
   } else if (p[1] = "Add") {
      p[1] := "AddItem"
   } else if (p[1] = "Delete") {
      p[1] := "DeleteItem"
   } else if (p[1] = "Choose") {
      p[1] := "ChooseIndex"
   } else if (p[1] = "ChooseString") {
      p[1] := "ChooseString"
   }
   Out := format("Control{1}({2},{3},{4},{5},{6})", p*)
   if (p[1] = "EditPaste") {
      Out := format("EditPaste({2},{3},{4},{5},{6})", p*)
   } else if (p[1] = "Show" || p[1] = "ShowDropDown" || p[1] = "HideDropDown" || p[1] = "Hide") {
      Out := format("Control{1}({3},{4},{5},{6})", p*)
   }
   return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_ControlGet(p) {
   ;ControlGet, OutputVar, SubCommand , Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText
   ; unfinished

   if (p[2] = "Tab" || p[2] = "FindString") {
      p[2] := "Index"
   }
   if (p[2] = "Checked" || p[2] = "Enabled" || p[2] = "Visible" || p[2] = "Index" || p[2] = "Choice" || p[2] = "Style" || p[2] = "ExStyle") {
      Out := format("{1} := ControlGet{2}({4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "LineCount") {
      Out := format("{1} := EditGetLineCount({4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "CurrentLine") {
      Out := format("{1} := EditGetCurrentLine({4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "CurrentCol") {
      Out := format("{1} := EditGetCurrentCol({4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "Line") {
      Out := format("{1} := EditGetLine({3}, {4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "Selected") {
      Out := format("{1} := EditGetSelectedText({4}, {5}, {6}, {7}, {8})", p*)
   } else if (p[2] = "Hwnd") {
      Out := format("{1} := ControlGet{2}({4}, {5}, {6}, {7}, {8})", p*)
   } else {
      Out := format("{1} := ControlGet{2}({3}, {4}, {5}, {6}, {7}, {8})", p*)
   }

   if (p[2] = "List") {
      if (p[3] != "") {
         Out := format("{1} := ListViewGetContent({3}, {4}, {5}, {6}, {7}, {8})", p*)
      } Else {
         p[2] := "Items"
         Out := format("o{1} := ControlGet{2}({4}, {5}, {6}, {7}, {8})", p*) "`r`n"
         Out .= Indentation "loop o" p[1] ".length`r`n"
         Out .= Indentation "{`r`n"
         Out .= Indentation p[1] " .= A_index=1 ? `"`" : `"``n`"`r`n"	; Attenttion do not add ``r!!!
         Out .= Indentation p[1] " .= o" p[1] "[A_Index] `r`n"
         Out .= Indentation "}"
      }

   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_ControlGetFocus(p) {

   Out := format("{1} := ControlGetClassNN(ControlGetFocus({2}, {3}, {4}, {5}))", p*)
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}

_CoordMode(p) {
   ; V1: CoordMode,TargetTypeT2E,RelativeToT2E | *_CoordMode
   p[2] := StrReplace(P[2], "Relative", "Window")
   Out := Format("CoordMode({1}, {2})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_Drive(p) {
   if (p[1] = "Label") {
      Out := Format("DriveSetLabel({2}, {3})", p[1], ToExp(p[2]), ToExp(p[3]))
   } else if (p[1] = "Eject") {
      if (p[3] = "0" or p[3] = "") {
         Out := Format("DriveEject({2})", p*)
      } else {
         Out := Format("DriveRetract({2})", p*)
      }
   } else {
      p[2] := p[2] = "" ? "" : ToExp(p[2])
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("Drive{1}({2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_EnvAdd(p) {
   if !IsEmpty(p[3])
      return format("{1} := DateAdd({1}, {2}, {3})", p*)
   else
      return format("{1} += {2}", p*)
}

_EnvSub(p) {
   if !IsEmpty(p[3])
      return format("{1} := DateDiff({1}, {2}, {3})", p*)
   else
      return format("{1} -= {2}", p*)
}

_FileCopyDir(p) {
   global ScriptStringsUsed
   if ScriptStringsUsed.ErrorLevel {
      Out := format("Try{`r`n" Indentation "   DirCopy({1}, {2}, {3})`r`n" Indentation "   ErrorLevel := 0`r`n" Indentation "} Catch {`r`n" Indentation "   ErrorLevel := 1`r`n" Indentation "}", p*)
   } Else {
      out := format("DirCopy({1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
_FileCopy(p) {
   global ScriptStringsUsed
   ; We could check if Errorlevel is used in the next 20 lines
   if ScriptStringsUsed.ErrorLevel {
      Out := format("Try{`r`n" Indentation "   FileCopy({1}, {2}, {3})`r`n" Indentation "   ErrorLevel := 0`r`n" Indentation "} Catch as Err {`r`n" Indentation "   ErrorLevel := Err.Extra`r`n" Indentation "}", p*)
   } Else {
      out := format("FileCopy({1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
_FileRead(p) {
   ; FileRead, OutputVar, Filename
   ; OutputVar := FileRead(Filename , Options)
   if InStr(p[2], "*") {
      Options := RegExReplace(p[2], "^\s*(\*.*?)\s[^\*]*$", "$1")
      Filename := RegExReplace(p[2], "^\s*\*.*?\s([^\*]*)$", "$1")
      Options := StrReplace(Options, "*t", "``n")
      Options := StrReplace(Options, "*")
      If InStr(options, "*P") {
         OutputDebug("Conversion FileRead has not correct.`n")
      }
      ; To do: add encoding
      Return format("{1} := Fileread({2}, {3})", p[1], ToExp(Filename), ToExp(Options))
   }
   Return format("{1} := Fileread({2})", p[1], ToExp(p[2]))
}
_FileReadLine(p) {
   ; FileReadLine, OutputVar, Filename, LineNum
   ; Not really a good alternative, inefficient but the result is the same

   Return p[1] " := StrSplit(FileRead(" p[2] "),`"``n`",`"``r`")[" P[3] "]"
}
_FileSelect(p) {
   ; V1: FileSelectFile, OutputVar [, Options, RootDir\Filename, Title, Filter]
   ; V2: SelectedFile := FileSelect([Options, RootDir\Filename, Title, Filter])
   global O_Index
   global Orig_Line_NoComment
   global oScriptString	; array of all the lines
   global Indentation

   oPar := V1ParSplit(RegExReplace(Orig_Line_NoComment, "i)^\s*FileSelectFile\s*[\s,]\s*(.*)$", "$1"))
   OutputVar := oPar[1]
   Options := oPar.Has(2) ? oPar[2] : ""
   RootDirFilename := oPar.Has(3) ? oPar[3] : ""
   Title := oPar.Has(4) ? trim(oPar[4]) : ""
   Filter := oPar.Has(5) ? trim(oPar[5]) : ""

   Parameters := ""
   if (Filter != "") {
      Parameters .= ToExp(Filter)
   }
   if (Title != "" or Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(Title) Parameters
   }
   if (RootDirFilename != "" or Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(RootDirFilename) Parameters
   }
   if (Options != "" or Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(Options) Parameters
   }

   Line := format("{1} := FileSelect({2})", OutputVar, parameters)
   if InStr(Options, "M") {
      Line := format("{1} := FileSelect({2})", "o" OutputVar, parameters) "`r`n"
      Line .= Indentation "for FileName in o " OutputVar "`r`n"
      Line .= Indentation "{`r`n"
      Line .= Indentation OutputVar " .= A_index=2 ? `"``r`n`" : `"`"`r`n"
      Line .= Indentation OutputVar " .= A_index=1 ? FileName : Regexreplace(FileName,`"^.*\\([^\\]*)$`" ,`"$1`") `"``r``n`"`n"
      Line .= Indentation "}"
   }
   return Line
}

_FileSetAttrib(p) {
   ; old V1 : FileSetAttrib, Attributes , FilePattern, OperateOnFolders?, Recurse?
   ; New V2 : FileSetAttrib Attributes , FilePattern, Mode (DFR)
   OperateOnFolders := P[3]
   Recurse := P[4]
   P[3] := OperateOnFolders = 1 ? "DF" : OperateOnFolders = 2 ? "D" : ""
   P[3] .= Recurse = 1 ? "R" : ""
   P[3] := P[3] = "" ? "" : ToExp(P[3])
   Out := format("FileSetAttrib({1}, {2}, {3})", p*)
   Return out := RegExReplace(Out, "[\s\,]*\)", ")")
}
_FileSetTime(p) {
   ; old V1 : FileSetTime, YYYYMMDDHH24MISS, FilePattern, WhichTime, OperateOnFolders?, Recurse?
   ; New V2 : YYYYMMDDHH24MISS, FilePattern, WhichTime, Mode (DFR)
   OperateOnFolders := P[4]
   Recurse := P[5]
   P[4] := OperateOnFolders = 1 ? "DF" : OperateOnFolders = 2 ? "D" : ""
   P[4] .= Recurse = 1 ? "R" : ""
   P[4] := P[4] = "" ? "" : ToExp(P[4])
   Out := format("FileSetTime({1}, {2}, {3}, {4})", p*)
   Return out := RegExReplace(Out, "[\s\,]*\)", ")")
}

_Gosub(p) {
   ; Need to convert label into a function
   if RegexMatch(Orig_ScriptString, "\n(\s*)" p[1] ":\s") {
      aListLabelsToFunction.Push({label: p[1], parameters: ""})
   }
   Return trim(p[1]) "()"
}

_Gui(p) {

   global Orig_Line_NoComment
   global GuiNameDefault
   global ListViewNameDefault
   global TreeViewNameDefault
   global StatusbarNameDefault
   global GuiList
   global Orig_ScriptString	; array of all the lines
   global oScriptString	; array of all the lines
   global O_Index	; current index of the lines
   global GuiVList
   global mGuiCObject
   ;preliminary version

   SubCommand := RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newGuiName) = 0 ? Trim(p[1]) : newGuiName[1]
   GuiName := RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? "" : newGuiName[1]

   GuiLine := Orig_Line_NoComment
   LineResult := ""
   if RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$") {
      ControlHwnd := ""
      ControlLabel := ""
      ControlName := ""
      ControlObject := ""

      if RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")
      {
         GuiNameLine := RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
         GuiLine := RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)
         if (GuiNameLine = "1") {
            GuiNameLine := "myGui"
         }
         GuiNameDefault := GuiNameLine
      } else {
         GuiNameLine := GuiNameDefault
      }
      if (RegExMatch(GuiNameLine, "^\d+$")) {
         GuiNameLine := "oGui" GuiNameLine
      }
      GuiOldName := GuiNameLine = "myGui" ? "" : GuiNameLine
      if RegExMatch(GuiOldName, "^oGui\d+$") {
         GuiOldName := StrReplace(GuiOldName, "oGui")
      }
      Var1 := RegExReplace(p[1], "i)^([^:]*):(.*)$", "$2")
      Var2 := p[2]
      Var3 := p[3]
      Var4 := p[4]

      if RegExMatch(Var3, "\bg[\w]*\b") {
         ; Remove the goto option g....
         ControlLabel := RegExReplace(Var3, "^.*\bg([\w]*)\b.*$", "$1")
         Var3 := RegExReplace(Var3, "^(.*)\bg([\w]*)\b(.*)$", "$1$3")
      } else if (Var2 = "Button") {
         ControlLabel := GuiOldName var2 RegExReplace(Var4, "[\s&]", "")
      }
      if RegExMatch(Var3, "\bv[\w]*\b") {
         ControlName := RegExReplace(Var3, "^.*\bv([\w]*)\b.*$", "$1")

         ControlObject := InStr(ControlName, SubStr(Var2, 1, 4)) ? "ogc" ControlName : "ogc" Var2 ControlName
         mGuiCObject[ControlName] := ControlObject
         if (Var2 != "Pic" and Var2 != "Picture" and Var2 != "Text" and Var2 != "Button" and Var2 != "Link" and Var2 != "Progress" and Var2 != "GroupBox" and Var2 != "Statusbar" and Var2 != "ActiveX") {	; Exclude Controls from the submit (this generates an error)
            if (GuiVList.Has(GuiNameLine)) {
               GuiVList[GuiNameLine] .= "`r`n" ControlName
            } else {
               GuiVList[GuiNameLine] := ControlName
            }
         }
      }
      if RegExMatch(Var3, "i)\b\+?\bhwnd[\w]*\b") {
         ControlHwnd := RegExReplace(Var3, "i)^.*\b\+?\bhwnd([\w]*)\b.*$", "$1")
         Var3 := RegExReplace(Var3, "i)^(.*?)\s?\+?\bhwnd([\w]*)\b(.*)$", "$1$3")
         if (ControlObject = "") {
            ControlObject := InStr(ControlHwnd, SubStr(Var4, 1, 4)) ? "ogc" StrReplace(ControlHwnd, "hwnd") : "ogc" Var4 StrReplace(ControlHwnd, "hwnd")
         }
         mGuiCObject["%" ControlHwnd "%"] := ControlObject
         mGuiCObject["% " ControlHwnd] := ControlObject
      }

      if !InStr(GuiList, "|" GuiNameLine "|") {
         GuiList .= GuiNameLine "|"
         LineResult := GuiNameLine " := Gui()`r`n" Indentation

         ; Add the events if they are used.
         aEventRename := []
         aEventRename.Push({oldlabel: GuiOldName "GuiClose", event: "Close", parameters: "*", NewFunctionName: GuiOldName "GuiClose"})
         aEventRename.Push({oldlabel: GuiOldName "GuiEscape", event: "Escape", parameters: "*", NewFunctionName: GuiOldName "GuiEscape"})
         aEventRename.Push({oldlabel: GuiOldName "GuiSize", event: "Size", parameters: "thisGui, MinMax, A_GuiWidth, A_GuiHeight", NewFunctionName: GuiOldName "GuiSize"})
         aEventRename.Push({oldlabel: GuiOldName "GuiConTextMenu", event: "ConTextMenu", parameters: "*", NewFunctionName: GuiOldName "GuiConTextMenu"})
         aEventRename.Push({oldlabel: GuiOldName "GuiDropFiles", event: "DropFiles", parameters: "thisGui, Ctrl, FileArray, *", NewFunctionName: GuiOldName "GuiDropFiles"})
         Loop aEventRename.Length {
            if RegexMatch(Orig_ScriptString, "\n(\s*)" aEventRename[A_Index].oldlabel ":\s") {
               if mAltLabel.Has(aEventRename[A_Index].oldlabel) {
                  aEventRename[A_Index].NewFunctionName := mAltLabel[aEventRename[A_Index].oldlabel]
                  ; Alternative label is available
               } else {
                  aListLabelsToFunction.Push({label: aEventRename[A_Index].oldlabel, parameters: aEventRename[A_Index].parameters, NewFunctionName: GetV2Label(aEventRename[A_Index].NewFunctionName)})
               }
               LineResult .= GuiNameLine ".OnEvent(`"" aEventRename[A_Index].event "`", " GetV2Label(aEventRename[A_Index].NewFunctionName) ")`r`n"
            }
         }
      }

      if (RegExMatch(Var1, "i)^tab[23]?$")) {
         Return LineResult "Tab.UseTab(" Var2 ")"
      }
      if (Var1 = "Show") {
         if (Var3 != "") {
            LineResult .= GuiNameLine ".Title := " ToStringExpr(Var3) "`r`n" Indentation
            Var3 := ""
         }
      }

      if (RegExMatch(Var2, "i)^tab[23]?$")) {
         LineResult .= "Tab := "
      }
      if (var1 = "Submit") {
         LineResult .= "oSaved := "
         if (InStr(var2, "NoHide")) {
            var2 := "0"
         }
      }

      if (var1 = "Add") {
         if (var2 = "TreeView" and ControlObject != "") {
            TreeViewNameDefault := ControlObject
         }
         if (var2 = "StatusBar") {
            if (ControlObject = "") {
               ControlObject := StatusBarNameDefault
            }
            StatusBarNameDefault := ControlObject
         }
         if (var2 ~= "i)(Button|ListView|TreeView)" or ControlLabel != "" or ControlObject != "") {
            if (ControlObject = "") {
               ControlObject := "ogc" var2 RegExReplace(Var4, "[^\w_]", "")
            }
            LineResult .= ControlObject " := "
            if (var2 = "ListView") {
               ListViewNameDefault := ControlObject
            }
            if (var2 = "TreeView") {
               TreeViewNameDefault := ControlObject
            }
         }
         If (ControlObject != "") {
            mGuiCType[ControlObject] := var2	; Create a map containing the type of control
         }
      } else if (var1 = "Color") {
         Return LineResult GuiNameLine ".BackColor := " ToStringExpr(Var2)
      } else if (var1 = "Margin") {
         Return LineResult GuiNameLine ".MarginX := " ToStringExpr(Var2) ", " GuiNameLine ".MarginY := " ToStringExpr(Var3)
      }  else if (var1 = "Font") {
         var1 := "SetFont"
      } else if (var1 = "New") {
         return Trim(LineResult,"`n")
      }

      LineResult .= GuiNameLine "."

      if (Var1 = "Menu") {
         ; To do: rename the output of the convert function to a global variable ( cOutput)
         ; Why? output is a to general name to use as a global variable. To fragile for errors.
         ; Output := StrReplace(Output, trim(Var3) ":= Menu()", trim(Var3) ":= MenuBar()")

         LineResult .= "MenuBar := " Var2
      } else {
         if (Var1 != "") {
            if (RegExMatch(Var1, "^\s*[-\+]\w*")) {
               LineResult .= "Opt(" ToStringExpr(Var1)
            } Else {
               LineResult .= Var1 "("
            }
         }
         if (Var2 != "") {
            LineResult .= ToStringExpr(Var2)
         }
         if (Var3 != "") {
            LineResult .= ", " ToStringExpr(Var3)
         } else if (Var4 != "") {
            LineResult .= ", "
         }
         if (Var4 != "") {
            if (RegExMatch(Var2, "i)^tab[23]?$") or Var2 = "ListView" or Var2 = "DropDownList" or Var2 = "DDL" or Var2 = "ListBox" or Var2 = "ComboBox") {
               ObjectValue := "["
               ChooseString := ""
               if (!InStr(Var3, "Choose") && InStr(Var4, "||")) { ; ChooseN takes priority over ||
                  RegexReplace(RegexReplace(Var4, "\|\|.*"), "\|",, &OptionsBefore)
                  LineResult := RegexReplace(LineResult, "`"$", " Choose" OptionsBefore + 1 "`"")
                  if (Var3 = "")
                     LineResult .= "`"Choose" OptionsBefore + 1 "`""
                  Var4 := RTrim(StrReplace(Var4, "||", "|"), "|")
               } else if (InStr(Var3, "Choose")) {
                  Var4 := RegexReplace(Var4, "\|+", "|") ; Replace all pipe groups, this breaks empty choices
               }
               Loop Parse Var4, "|", " "
               {
                  if (RegExMatch(Var2, "i)^tab[23]?$") and A_LoopField = "") {
                     ChooseString := "`" Choose" A_Index - 1 "`""
                     continue
                  }
                  ObjectValue .= ObjectValue = "[" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
               }
               ObjectValue .= "]"
               LineResult .= ChooseString ", " ObjectValue
            } else {
               LineResult .= ", " ToStringExpr(Var4)
            }
         }
         if (Var1 != "") {
            LineResult .= ")"
         }

         if (var1 = "Submit") {
            ; This should be replaced by keeping a list of the v variables of a Gui and declare for each "vName := oSaved.vName"
            if (GuiVList.Has(GuiNameLine)) {
               Loop Parse, GuiVList[GuiNameLine], "`n", "`r"
               {
                  if GuiVList[GuiNameLine]
                     LineResult .= "`r`n" Indentation A_LoopField " := oSaved." A_LoopField
               }
            }

            ; Shorter alternative, but this results in warning that variables are never assigned
            ; LineResult.= "`r`n" Indentation "`; Hack to define variables`n`r" Indentation "for VariableName,Value in oSaved.OwnProps()`r`n" Indentation "   %VariableName% := Value"
         }

      }
      if (var1 = "Add" and var2 = "ActiveX" and ControlName != "") {
         ; Fix for ActiveX control, so functions of the ActiveX can be used
         LineResult .= "`r`n" Indentation ControlName " := " ControlObject ".Value"
      }

      if (ControlLabel != "") {
         if mAltLabel.Has(ControlLabel) {
            ControlLabel := mAltLabel[ControlLabel]
         }
         ControlEvent := "Change"

         if (mGuiCType.Has(ControlObject) and mGuiCType[ControlObject] ~= "i)(ListBox|ComboBox|ListView|TreeView)") {
            ControlEvent := "DoubleClick"
         }
         if (mGuiCType.Has(ControlObject) and mGuiCType[ControlObject] ~= "i)(Button|Checkbox|Link|Radio|Picture|Statusbar|Text)") {
            ControlEvent := "Click"
         }
         V1GuiControlEvent := ControlEvent = "Change" ? "Normal" : ControlEvent
         V1GuiControlEvent := V1GuiControlEvent = "Click" ? "Normal" : ControlEvent
         LineResult .= "`r`n" Indentation ControlObject ".OnEvent(`"" ControlEvent "`", " GetV2Label(ControlLabel) ".Bind(`"" V1GuiControlEvent "`"))"
         aListLabelsToFunction.Push({label: ControlLabel, parameters: "A_GuiEvent, GuiCtrlObj, Info, *", NewFunctionName: GetV2Label(ControlLabel)})
      }
      if (ControlHwnd != "") {
         LineResult .= "`r`n" Indentation ControlHwnd " := " ControlObject ".hwnd"
      }
   }
   DebugWindow("LineResult:" LineResult "`r`n")
   Out := format("{1}", LineResult)
   return Out
}

_GuiControl(p) {
   global GuiNameDefault
   SubCommand := RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[1]) : newSubCommand[1]
   GuiName := RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? GuiNameDefault : newGuiName[1]
   ControlID := Trim(p[2])
   Value := Trim(p[3])
   Out := ""
   ControlObject := mGuiCObject.Has(ControlID) ? mGuiCObject[ControlID] : "ogc" ControlID

   Type := mGuiCType.Has(ControlObject) ? mGuiCType[ControlObject] : ""

   if (SubCommand = "") {
      if (Type = "Groupbox" or Type = "Button" or Type = "Link") {
         SubCommand := "Text"
      } else if (Type = "Radio" and (Value != "0" or Value != "1" or Value != "-1" or InStr(Value, "%"))) {
         SubCommand := "Text"
      }
   }
   if (SubCommand = "") {
      ; Not perfect, as this should be dependent on the type of control

      if (Type = "ListBox" or Type = "DropDownList" or Type = "ComboBox" or Type = "tab") {
         PreSelected := ""
         If (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `;Clean the list`r`n" Indentation
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" and A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" Indentation ControlID ".ChooseString(" ToStringExpr(PreSelected) ")"
         }
         Return Out
      }
      if InStr(Value, "|") {

         PreSelected := ""
         If (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `;Clean the list`r`n" Indentation
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" and A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" Indentation ControlID ".ChooseString(" ToStringExpr(PreSelected) ")"
         }
         Return Out
      }
      if (Type = "UpDown" or Type = "Slider" or Type = "Progress") {
         if (SubStr(Value, 1, 1) = "-") {
            return ControlObject ".Value -= " ToExp(Value)
         } else if (SubStr(Value, 1, 1) = "+") {
            return ControlObject ".Value += " ToExp(Value)
         }
         return ControlObject ".Value := " ToExp(Value)
      }
      return ControlObject ".Value := " ToExp(Value)
   } else if (SubCommand = "Text") {
      if (Type = "ListBox" or Type = "DropDownList" or Type = "tab" or Type ~= "i)tab\d") {
         PreSelected := ""
         If (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `;Clean the list`r`n" Indentation
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" and A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" Indentation ControlID ".ChooseString(" ToStringExpr(PreSelected) ")"
         }
         Return Out
      }
      Return ControlObject ".Text := " ToExp(Value)
   } else if (SubCommand = "Move" or SubCommand = "MoveDraw") {

      X := RegExMatch(Value, "i)^.*\bx`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newX) = 0 ? "" : newX[1]
      Y := RegExMatch(Value, "i)^.*\by`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newY) = 0 ? "" : newY[1]
      W := RegExMatch(Value, "i)^.*\bw`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newW) = 0 ? "" : newW[1]
      H := RegExMatch(Value, "i)^.*\bh`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newH) = 0 ? "" : newH[1]

      if (X = "") {
         X := RegExMatch(Value, "i)^.*\bx([\w]*)\b.*$", &newX) = 0 ? "" : newX[1]
      }
      if (X = "") {
         X := RegExMatch(Value, "i)^.*\bx%([\w]*)\b%.*$", &newX) = 0 ? "" : newX[1]
      }
      if (Y = "") {
         Y := RegExMatch(Value, "i)^.*\bY([\w]*)\b.*$", &newY) = 0 ? "" : newY[1]
      }
      if (Y = "") {
         Y := RegExMatch(Value, "i)^.*\bY%([\w]*)\b%.*$", &newY) = 0 ? "" : newY[1]
      }
      if (W = "") {
         W := RegExMatch(Value, "i)^.*\bw([\w]*)\b.*$", &newW) = 0 ? "" : newW[1]
      }
      if (W = "") {
         W := RegExMatch(Value, "i)^.*\bw%([\w]*)\b%.*$", &newW) = 0 ? "" : newW[1]
      }
      if (H = "") {
         H := RegExMatch(Value, "i)^.*\bh([\w]*)\b.*$", &newH) = 0 ? "" : newH[1]
      }
      if (H = "") {
         H := RegExMatch(Value, "i)^.*\bh%([\w]*)\b%.*$", &newH) = 0 ? "" : newH[1]
      }

      Out := ControlObject "." SubCommand "(" X ", " Y ", " W ", " H ")"
      Out := RegExReplace(Out, "[\s\,]*\)$", ")")
      Return Out
   } else if (SubCommand = "Focus") {
      Return ControlObject ".Focus()"
   } else if (SubCommand = "Disable") {
      Return ControlObject ".Enabled := false"
   } else if (SubCommand = "Enable") {
      Return ControlObject ".Enabled := true"
   } else if (SubCommand = "Hide") {
      Return ControlObject ".Visible := false"
   } else if (SubCommand = "Show") {
      Return ControlObject ".Visible := true"
   } else if (SubCommand = "Choose") {
      Return ControlObject ".Choose(" Value ")"
   } else if (SubCommand = "ChooseString") {
      Return ControlObject ".Choose(" ToExp(Value) ")"
   } else if (SubCommand = "Font") {
      Return ";to be implemented"
   } else if (RegExMatch(SubCommand, "^[+-].*")) {
      Return ControlObject ".Options(" ToExp(SubCommand) ")"
   }

   Return
}

_GuiControlGet(p) {
   ; GuiControlGet, OutputVar , SubCommand, ControlID, Value
   global GuiNameDefault
   OutputVar := Trim(p[1])
   SubCommand := RegExMatch(p[2], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[2]) : newSubCommand[1]
   GuiName := RegExMatch(p[2], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? GuiNameDefault : newGuiName[1]
   ControlID := Trim(p[3])
   Value := Trim(p[4])
   If (ControlID = "") {
      ControlID := OutputVar
   }

   Out := ""
   ControlObject := mGuiCObject.Has(ControlID) ? mGuiCObject[ControlID] : "ogc" ControlID
   Type := mGuiCType.Has(ControlObject) ? mGuiCType[ControlObject] : ""
   ;MsgBox("OutputVar: [" OutputVar "]`nControlObject: [" ControlObject "]`nmGuiCType[ControlObject]: [" mGuiCType[ControlObject] "]`nType: [" Type "]")

   if (SubCommand = "") {
      if (Value = "text" or Type = "ListBox") {
         ;MsgBox("Value: [" Value "]`nType: [" Type "]")
         Out := OutputVar " := " ControlObject ".Text"
      } else {
         Out := OutputVar " := " ControlObject ".Value"
      }
   } else if (SubCommand = "Pos") {
      Out := ControlObject ".GetPos(&" OutputVar "X, &" OutputVar "Y, &" OutputVar "W, &" OutputVar "H)"
   } else if (SubCommand = "Focus") {
      ; not correct
      Out := "; " OutputVar " := ControlGetFocus() `; Not really the same, this returns the HWND..."
   } else if (SubCommand = "FocusV") {
      ; not correct MyGui.FocusedCtrl
      Out := "; " OutputVar " := " GuiName ".FocusedCtrl `; Not really the same, this returns the focused gui control object..."
   } else if (SubCommand = "Enabled") {
      Out := OutputVar " := " ControlObject ".Enabled"
   } else if (SubCommand = "Visible") {
      Out := OutputVar " := " ControlObject ".Visible"
   } else if (SubCommand = "Name") {
      Out := OutputVar " := " ControlObject ".Name"
   } else if (SubCommand = "Hwnd") {
      Out := OutputVar " := " ControlObject ".Hwnd"
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_Hotkey(p) {

   ;Convert label to function

   if RegexMatch(Orig_ScriptString, "\n(\s*)" p[2] ":\s") {
      aListLabelsToFunction.Push({label: p[2], parameters: "ThisHotkey"})
   }

   if (p[1] = "IfWinActive") {
      p[2] := p[2] = "" ? "" : ToExp(p[2])
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("HotIfWinActive({2}, {3})", p*)
   } else if (p[1] = "IfWinNotActive") {
      p[2] := p[2] = "" ? "" : ToExp(p[2])
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("HotIfWinNotActive({2}, {3})", p*)
   } else if (p[1] = "IfWinExist") {
      p[2] := p[2] = "" ? "" : ToExp(p[2])
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("HotIfWinExist({2}, {3})", p*)
   } else if (p[1] = "IfWinNotExist") {
      p[2] := p[2] = "" ? "" : ToExp(p[2])
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("HotIfWinNotExist({2}, {3})", p*)
   } else if (p[1] = "If") {
      Out := Format("HotIf({2}, {3})", p*)
   } else {
      p[1] := p[1] = "" ? "" : ToExp(p[1])
      if (P[2] = "on" or P[2] = "off" or P[2] = "Toggle" or P[2] ~= "^AltTab" or P[2] ~= "^ShiftAltTab") {
         p[2] := p[2] = "" ? "" : ToExp(p[2])
      }
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("Hotkey({1}, {2}, {3})", p*)
   }
   Out := RegExReplace(Out, "\s*`"`"\s*\)$", ")")
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_IfGreater(p) {
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) > 0)", p*)
}

_IfGreaterOrEqual(p) {
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) >= 0)", p*)
}

_IfLess(p) {
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) < 0)", p*)
}

_IfLessOrEqual(p) {
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) <= 0)", p*)
}

_Input(p) {
   Out := format("ih{1} := InputHook({2},{3},{4}), ih{1}.Start(), ih{1}.Wait(), {1} := ih{1}.Input", p*)
   Return out := RegExReplace(Out, "[\s\,]*\)", ")")
}

_InputBox(oPar) {
   ; V1: InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default]
   ; V2: Obj := InputBox(Prompt, Title, Options, Default)
   global O_Index
   global ScriptStringsUsed

   global oScriptString	; array of all the lines
   options := ""

   OutputVar := oPar[1]
   Title := oPar.Has(2) ? oPar[2] : ""
   Prompt := oPar.Has(3) ? oPar[3] : ""
   Hide := oPar.Has(4) ? trim(oPar[4]) : ""
   Width := oPar.Has(5) ? trim(oPar[5]) : ""
   Height := oPar.Has(6) ? trim(oPar[6]) : ""
   X := oPar.Has(7) ? trim(oPar[7]) : ""
   Y := oPar.Has(8) ? trim(oPar[8]) : ""
   Locale := oPar.Has(9) ? trim(oPar[9]) : ""
   Timeout := oPar.Has(10) ? trim(oPar[10]) : ""
   Default := oPar.Has(11) and oPar[11] != "" ? ToExp(trim(oPar[11])) : ""

   Parameters := ToExp(Prompt)
   Title := ToExp(Title)
   if (Hide = "hide") {
      Options .= "Password"
   }
   if (Width != "") {
      Options .= Options != "" ? " " : ""
      Options .= "w"
      Options .= IsNumber(Width) ? Width : "`" " Width " `""
   }
   if (Height != "") {
      Options .= Options != "" ? " " : ""
      Options .= "h"
      Options .= IsNumber(Height) ? Height : "`" " Height " `""
   }
   if (x != "") {
      Options .= Options != "" ? " " : ""
      Options .= "x"
      Options .= IsNumber(x) ? x : "`" " x " `""
   }
   if (y != "") {
      Options .= Options != "" ? " " : ""
      Options .= "y"
      Options .= IsNumber(y) ? y : "`" " y " `""
   }
   if (Timeout != "") {
      Options .= Options != "" ? " " : ""
      Options .= "t"
      Options .= IsNumber(Timeout) ? Timeout : "`" " Timeout " `""
   }
   Options := Options = "" ? "" : "`"" Options "`""

   Out := format("IB := InputBox({1}, {3}, {4}, {5})", parameters, OutputVar, Title, Options, Default)
   Out := RegExReplace(Out, "[\s\,]*\)$", ")")
   Out .= ", " OutputVar " := IB.Value"
   if ScriptStringsUsed.ErrorLevel {
      Out .= ', ErrorLevel := IB.Result="OK" ? 0 : IB.Result="CANCEL" ? 1 : IB.Result="Timeout" ? 2 : "ERROR"'
   }

   Return Out
}

_KeyWait(p) {
   ; Errorlevel is not set in V2
   if ScriptStringsUsed.ErrorLevel {
      out := Format("ErrorLevel := !KeyWait({1}, {2})", p*)
   } else {
      out := Format("KeyWait({1}, {2})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_Loop(p) {

   line := ""
   BracketEnd := ""
   if RegExMatch(p[1], "(^.*?)(\s*{.*$)", &Match){
      p[1] := Match[1]
      BracketEnd := Match[2]
   }
   else if RegExMatch(p[2], "(^.*?)(\s*{.*$)", &Match) {
   p[2] := Match[1]
   BracketEnd := Match[2]
   }
   else if RegExMatch(p[3], "(^.*?)(\s*{.*$)", &Match) {
      p[3] := Match[1]
      BracketEnd := Match[2]
   }
   if (InStr(p[1], "*") and InStr(p[1], "\")) {	; Automatically switching to Files loop
      IncludeFolders := p[2]
      Recurse := p[3]
      p[3] := ""
      if (IncludeFolders = 1) {
         p[3] .= "FD"
      } else if (IncludeFolders = 2) {
         p[3] .= "D"
      }
      if (Recurse = 1) {
         p[3] .= "R"
      }
      p[2] := p[1]
      p[1] := "Files"
   }

   If (p[1] ~= "i)^(HKEY|HKLM|HKU|HKCR|HKCC|HKCU).*") {
      p[3] := p[2]
      p[2] := p[1]
      p[1] := "Reg"
      Line := p.Has(3) ? Trim(ToExp(p[3])) : ""
      Line := Line != "" ? ' . "\" . ' Line : ""
      Line := p.Has(2) ? Trim(ToExp(p[2])) Line : "" Line
      Line := StrReplace(Line, '" . "')
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(1) ? Trim(p[1]) Line : "" Line
      Line := "Loop " Line
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")	; remove trailing ,\s and ,\s""
      return Line BracketEnd
   }

   if (p[1] = "Parse"){
      Line := p.Has(4) ? Trim(ToExp(p[4])) : ""
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(3) ? Trim(ToExp(p[3])) Line : "" Line
      Line := Line != "" ? ", " Line : ""
      if (Substr(Trim(p[2]), 1, 2) = "% ") {
         p[2] := Substr(Trim(p[2]), 3)
      }
      Line := ", " Trim(p[2]) Line
      Line := "Loop Parse" Line
      ; Line := format("Loop {1}, {2}, {3}, {4}",p[1], p[2], ToExp(p[3]), ToExp(p[4]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")	; remove trailing ,\s and ,\s""
      return Line BracketEnd
   } else if (p[1] = "Files")
   {

      Line := format("Loop {1}, {2}, {3}", "Files", ToExp(p[2]), ToExp(p[3]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")	; remove trailing ,\s and ,\s""
      return Line
   } else if (p[1] = "Read")
   {
      Line := p.Has(3) ? Trim(ToExp(p[3])) : ""
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(2) ? Trim(ToExp(p[2])) Line : "" Line
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(1) ? Trim(p[1]) Line : "" Line
      Line := "Loop " Line
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")	; remove trailing ,\s and ,\s""
      return Line BracketEnd
   } else {

      Line := p[1] != "" ? "Loop " Trim(ToExp(p[1])) : "Loop"
      return Line BracketEnd
   }
   ; Else no changes need to be made

}


_MsgBox(p) {
   ; v1
   ; MsgBox, Text (1-parameter method)
   ; MsgBox [, Options, Title, Text, Timeout]
   ; v2
   ; Result := MsgBox(Text, Title, Options)
   Check_IfMsgBox()
   if RegExMatch(p[1], "i)^(0x)?\d*\s*$") && (p.Extra.OrigArr.Length > 1) {
      options := p[1]
      if ( p.Length = 4 && (IsEmpty(p[4]) || IsNumber(p[4])) ) {
         text := ToExp(p[3])
         if (!IsEmpty(p[4]))
            options .= " T" p[4]
         title := ToExp(p[2])
      } else {
         text := ""
         loop p.Extra.OrigArr.Length - 2
            text .= "," p.Extra.OrigArr[A_Index + 2]
         text := ToExp(SubStr(text, 2))
         title := ToExp(p[2])
      }
      Out := format("MsgBox({1}, {2}, {3})", text, title, ToExp(options))
      if Check_IfMsgBox() {
         Out := "msgResult := " Out
      }
      return Out
   } else {
      p[1] := p.Extra.OrigStr
      Out := format("MsgBox({1})", p[1] = "" ? "" : ToExp(p[1]))
      if Check_IfMsgBox() {
         Out := "msgResult := " Out
      }
      return Out
   }
}

_Menu(p) {
   global Orig_Line_NoComment
   global MenuList
   global Indentation
   MenuLine := Orig_Line_NoComment
   LineResult := ""
   menuNameLine := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
   ; e.g.: Menu, Tray, Add, % func_arg3(nested_arg3a, nested_arg3b), % func_arg4(nested_arg4a, nested_arg4b), % func_arg5(nested_arg5a, nested_arg5b)
   Var2 := Trim(RegExReplace(MenuLine, "
      (
      ix)                  # case insensitive, extended mode to ignore space and comments
      ^\s*Menu\s*[,\s]\s*  #
      ([^,]*) \s* ,   \s*  # arg1 Tray {group $1}
      ([^,]*)              # arg2 Add  {group $2}
      .*                   #
      )"
      , "$2", &RegExCount2)) ; =Add
   Var3 := RegExReplace(MenuLine, "
      (
      ix)                   #
      ^\s*Menu \s*[,\s]\s*  #
      ([^,] *)     ,   \s*  # arg1 Tray {group $1}
      ([^,] *) \s* ,   \s*  # arg2 Add  {group $2}
      ([^,(]*  \(?          # % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
         (?(?<=\()[^)]*\))  #   nested function conditional, if matched ( then match everything up to and including the )
         [^,]*)             #   group $3 end}
      .*$                   #
      )"
      , "$3", &RegExCount3) ; =% func_arg3(nested_arg3a, nested_arg3b)

   Var4 := RegExReplace(MenuLine, "
      (
      ix)                    	#
      ^\s*Menu \s*[,\s]\s*   	#
      ([^,] *)     ,   \s*   	# arg1 Tray {group $1}
      ([^,] *) \s* ,   \s*   	# arg2 Add  {group $2}
      ([^,(]*  \(?           	# % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
         (?(?<=\()[^)]*\))   	#   nested function conditional
         [^,]*)    ,?  \s* :?	#   group $3 end}
      ([^;,(]*  \(?          	# % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
         (?(?<=\()[^)]*\))   	#   nested function conditional
         [^,]*)              	#   group $4 end}
       .*$                   	#
      )"
      , "$4", &RegExCount4) ; =% func_arg4(nested_arg4a, nested_arg4b)
   Var5 := RegExReplace(MenuLine, "
      (
      ix)                    	#
      ^\s*Menu \s*[,\s]\s*   	#
      ([^,] *)     ,   \s*   	# arg1 Tray {group $1}
      ([^,] *) \s* ,   \s*   	# arg2 Add  {group $2}
      ([^,(]*  \(?           	# % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
         (?(?<=\()[^)]*\))   	#   nested function conditional
         [^,]*)    ,?  \s* :?	#   group $3 end}
      ([^;,(]*  \(?          	# % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
         (?(?<=\()[^)]*\))   	#   nested function conditional
         [^,]*)\s* ,?  \s*   	#   group $4 end}
      ([^;,(]*  \(?          	# % func_arg5(nested_arg5a, nested_arg5b) {group $5 start
         (?(?<=\()[^)]*\))   	#   nested function conditional
         [^,] *)             	#    group $5 end}
      .*$                    	#
      )"
      , "$5", &RegExCount5) ; =% func_arg5(nested_arg5a, nested_arg5b)

   menuNameLine := Trim(menuNameLine)
   if !InStr(menuList, "|" menuNameLine "|") {
      if (menuNameLine = "Tray") {
         if (Var2 = "Tip") {
            Return LineResult .= "A_IconTip := " ToStringExpr(Var3)
         }
         else if (Var2 = "Icon"){
               Var2 := "SetIcon"
               LineResult .= "TraySetIcon(" ToStringExpr(Var3)
               LineResult .= Var4 ? "," ToStringExpr(Var4) : ""
               LineResult .= Var5 ? "," ToStringExpr(Var5) : ""
               LineResult .= ")"
               Return LineResult
         }
         LineResult .= menuNameLine ":= A_TrayMenu`r`n" Indentation
      } else {
         LineResult .= menuNameLine " := Menu()`r`n" Indentation
      }

      menuList .= menuNameLine "|"
   }

   LineResult .= menuNameLine "."

   Var2 := Trim(Var2)
   Var3 := Trim(Var3)
   Var4 := Trim(Var4)
   DebugWindow(menuList "`r`n")
   if (Var2 = "Default") {
      return LineResult "Default := " ToExp(Var3)
   }
   if (Var2 = "NoDefault") {
      return LineResult "Default := `"`""
   }
   if (Var2 = "Standard") {
      return LineResult "AddStandard()"
   }
   if (Var2 = "NoStandard") {
      ; maybe keep track of added items, if menu is new, just Delete everything
      return LineResult "Delete() `; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning"
      ; alternative line:
      ; return menuNameLine ".Delete(`"&Open`")`r`n" indentation menuNameLine ".Delete(`"&Help`")`r`n" indentation menuNameLine ".Delete(`"&Window Spy`")`r`n" indentation menuNameLine ".Delete(`"&Reload Script`")`r`n" indentation menuNameLine ".Delete(`"&Edit Script`")`r`n" indentation menuNameLine ".Delete(`"&Suspend Hotkeys`")`r`n" indentation menuNameLine ".Delete(`"&Pause Script`")`r`n" indentation menuNameLine ".Delete(`"E&xit`")`r`n"
   }
   if (Var2 = "DeleteAll") {
      return LineResult "Delete()"
   }
   if (Var2 = "Icon") {
      Var2 := "SetIcon"
   }
   if (Var2 = "Color") {
      Var2 := "SetColor"
   }
   if (Var2 = "Add" and RegExCount3 and !RegExCount4) {
      Var4 := Var3
      RegExCount4 := RegExCount3
   }

   if (RegExCount2) {
      LineResult .= Var2 "("
   }
   if (RegExCount3) {
      LineResult .= ToStringExpr(Var3)
   } else if (RegExCount4) {
      LineResult .= ", "
   }
   if (RegExCount4) {
      if (Var2 = "Add") {
         FunctionName := RegExReplace(Var4, "&", "")	; Removes & from labels
         if mAltLabel.Has(FunctionName) {
            FunctionName := mAltLabel[FunctionName]
         } else if RegexMatch(Orig_ScriptString, "\n(\s*)" Var4 ":\s") {
            aListLabelsToFunction.Push({label: Var4, parameters: "A_ThisMenuItem, A_ThisMenuItemPos, MyMenu", NewFunctionName: FunctionName})
         }
         if Var4 != "" {
            LineResult .= ", " FunctionName
         }
      } else if (Var2 = "SetColor") {
         if (Var4 = "Single") {
            LineResult .= ", 0"
         }
      } else {
         if Var4 != "" {
            LineResult .= ", " ToStringExpr(Var4)
         }
      }
   }
   if (RegExCount5) {
      if Var2 = "Insert" {
         LineResult .= ", " Var5
      } else if Var5 != "" {
         LineResult .= ", " ToStringExpr(Var5)
      } else if Var5 = "" && p[6] != "" {
         LineResult .= ",, "
      }
   }

   if (p[6] != "") {
      if Var5 != "" {
         LineResult .= ", "
      }
      LineResult .= p[6]
   }

   if (RegExCount1) {
      LineResult .= ")"
   }

   return LineResult
}

_OnExit(p) {
   ;V1 OnExit,Func,AddRemove
   if RegexMatch(Orig_ScriptString, "\n(\s*)" p[1] ":\s") {
      aListLabelsToFunction.Push({label: p[1], parameters: "A_ExitReason, ExitCode", aRegexReplaceList: [{NeedleRegEx: "i)^(.*)\bReturn\b([\s\t]*;.*|)$", Replacement: "$1Return 1$2"}]})

   }
   ; return needs to be replaced by return 1 inside the exitcode
   Return Format("OnExit({1}, {2})", p*)
}

_Pause(p) {
   ;V1 : Pause , OnOffToggle, OperateOnUnderlyingThread
   ; TODO handle OperateOnUnderlyingThread
   if (p[1]=""){
      p[1]=-1
   }
   Return Format("Pause({1})", p*)
}

_Process(p) {
   ; V1: Process,SubCommand,PIDOrName,Value

   if (p[1] = "Priority") {
      if ScriptStringsUsed.ErrorLevel {
         Out := Format("ErrorLevel := ProcessSetPriority({3}, {2})", p*)
      } else {
         Out := Format("ProcessSetPriority({3}, {2})", p*)
      }
   } else {
      if ScriptStringsUsed.ErrorLevel {
         Out := Format("ErrorLevel := Process{1}({2}, {3})", p*)
      } else {
         Out := Format("Process{1}({2}, {3})", p*)
      }
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SetTimer(p) {
   if (p[2] = "Off") {
      Out := format("SetTimer({1},0)", p*)
   } else {
      Out := format("SetTimer({1},{2},{3})", p*)
      aListLabelsToFunction.Push({label: p[1], parameters: ""})
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SendRaw(p) {
   p[1] := ParameterFormat("keysT2E","{Raw}" p[1])
   Return "Send(" p[1] ")"
}

_Sort(p){
   SortFunction := ""
   if RegexMatch(p[2],"i)^(.*)\bF\s([a-z_][a-z_0-9]*)(.*)$",&Match){
      SortFunction := Match[2]
      p[2] := Match[1] Match[3]
      ; TODO Adding * to 3th parameter of sortfunction
   }
   p[2] := p[2]="`"`""? "" : p[2]
   Out := format("{1} := Sort({1}, {2}, " SortFunction ")", p*)

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SoundGet(p) {
   ; SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E
   OutputVar := p[1]
   ComponentType := p[2]
   ControlType := p[3]
   DeviceNumber := p[4]
   if (ComponentType = "" and ControlType = "Mute") {
      out := Format("{1} := SoundGetMute({2}, {4})", p*)
   } else if (ComponentType = "Volume" || ComponentType = "Vol" || ComponentType = "") {
      out := Format("{1} := SoundGetVolume({2}, {4})", p*)
   } else if (ComponentType = "mute") {
      out := Format("{1} := SoundGetMute({2}, {4})", p*)
   } else {
      out := Format(";REMOVED CV2 {1} := SoundGet{3}({2}, {4})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SoundSet(p) {
   ; SoundSet,NewSetting,ComponentTypeT2E,ControlType,DeviceNumberT2E
   ; Not 100% verified, more examples would be helpfull.
   NewSetting := p[1]
   ComponentType := p[2]
   ControlType := p[3]
   DeviceNumber := p[4]
   if (ControlType = "mute") {
      if (p[2] = "`"Microphone`"") {
         p[4] := "`"Microphone`""
         p[2] := ""
      }
      out := Format("SoundSetMute({1}, {2}, {4})", p*)
   } else if (ComponentType = "Volume" || ComponentType = "Vol" || ComponentType = "") {
      p[1] := InStr(p[1], "+") ? "`"" p[1] "`"" : p[1]
      out := Format("SoundSetVolume({1}, {2}, {4})", p*)
   } else {
      out := Format(";REMOVED CV2 Soundset{3}({1}, {2}, {4})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SplashTextOn(p) {
   ;V1 : SplashTextOn,Width,Height,TitleT2E,TextT2E
   ;V2 : Removed
   P[1] := P[1] = "" ? 200: P[1]
   P[2] := P[2] = "" ? 0: P[2]
   Return "SplashTextGui := Gui(`"ToolWindow -Sysmenu Disabled`", " p[3] "), SplashTextGui.Add(`"Text`",, " p[4] "), SplashTextGui.Show(`"w" p[1] " h" p[2] "`")"
}

_SplashImage(p) {
   ;V1 : SplashImage, ImageFile, Options, SubText, MainText, WinTitle, FontName
   ;V1 : SplashImage, Off
   ;V2 : Removed
   ; To be improved to interpreted the options

   if (p[1] = "Off") {
      Out := "SplashImageGui.Destroy"
   } else if (p[1] = "Show") {
      Out := "SplashImageGui.Show()"
   } else {
      mOptions := GetMapOptions(p[1])
      width := mOptions.Has("W") ? mOptions["W"] : 200
      Out := "SplashImageGui := Gui(`"ToolWindow -Sysmenu Disabled`")"
      Out .= p[5] != "" ? ", SplashImageGui.Title := " p[5] " " : ""
      Out .= p[4] = "" and p[3] = "" ? ", SplashImageGui.MarginY := 0, SplashImageGui.MarginX := 0" : ""
      Out .= p[4] != "" ? ", SplashImageGui.SetFont(`"bold`"," p[6] "), SplashImageGui.AddText(`"w" width " Center`", " p[4] ")" : ""
      Out .= ", SplashImageGui.AddPicture(`"w" width " h-1`", " p[1] ")"
      Out .= p[4] != "" and p[3] != "" ? ", SplashImageGui.SetFont(`"norm`"," p[6] ")" : p[3] != "" and p[6] != "" ? ", SplashImageGui.SetFont(," p[6] ")" : ""
      Out .= p[3] != "" ? ", SplashImageGui.AddText(`"w" width " Center`", " p[3] ")" : ""
      Out .= ", SplashImageGui.Show()"
   }
   Out := RegExReplace(Out, "[\s\,]*\)", ")")
   Return Out
}

_Progress(p) {
   ;V1 : Progress, ProgressParam1, SubTextT2E, MainTextT2E, WinTitleT2E, FontNameT2E
   ;V1 : Progress , Off
   ;V2 : Removed
   ; To be improved to interpreted the options

   if (p[1] = "Off") {
      Out := "ProgressGui.Destroy"
   } else if (p[1] = "Show") {
      Out := "ProgressGui.Show()"
   } else if (p[2] = "" && p[3] = "" && p[4] = "" && p[5] = "") {
      Out := "gocProgress.Value := " p[1]
   } else {
      width := 200
      mOptions := GetMapOptions(p[1])
      width := mOptions.Has("W") ? mOptions["W"] : 200
      GuiOptions := ""
      GuiShowOptions := ""
      SubTextFontOptions := ""
      MainTextFontOptions := ""
      ProgressOptions := ""
      ProgressStart := ""
      if (mOptions.Has("M")) {
         if (mOptions["M"] = "") {
            GuiOptions := "ToolWindow -Sysmenu"
         } else if (mOptions["M"] = "1") {
            GuiOptions := "ToolWindow -Sysmenu +Resize"
         } else if (mOptions["M"] = "2") {
            GuiOptions := "+Resize"
         }
      } else {
         GuiOptions := "ToolWindow -Sysmenu Disabled"
      }
      if (mOptions.Has("B")) {
         if (mOptions["B"] = "") {
            GuiOptions := "-Caption"
         } else if (mOptions["B"] = "1") {
            GuiOptions := "-Caption +Border"
         } else if (mOptions["B"] = "2") {
            GuiOptions := "-Border"
         }
      }
      GuiShowOptions .= mOptions.Has("X") ? " X" mOptions["X"] : ""
      GuiShowOptions .= mOptions.Has("Y") ? " Y" mOptions["Y"] : ""
      GuiShowOptions .= mOptions.Has("W") ? " W" mOptions["W"] : ""
      GuiShowOptions .= mOptions.Has("H") ? " H" mOptions["H"] : ""
      MainTextFontOptions := mOptions.Has("WM") ? "W" mOptions["WM"] : "Bold"
      MainTextFontOptions .= mOptions.Has("FM") ? " S" mOptions["FM"] : ""
      SubTextFontOptions := mOptions.Has("WS") ? "W" mOptions["WS"] : mOptions.Has("WM") ? " W400" : ""
      SubTextFontOptions .= mOptions.Has("FS") ? " S" mOptions["FS"] : mOptions.Has("FM") ? " S8" : ""
      ProgressOptions .= mOptions.Has("R") ? " Range" mOptions["R"] : ""
      ProgressStart .= mOptions.Has("P") ? mOptions["P"] : ""

      Out := "ProgressGui := Gui(`"" GuiOptions "`")"
      Out .= p[4] != "" ? ", ProgressGui.Title := " p[4] " " : ""
      Out .= (p[3] = "" and p[2] = "") or mOptions.Has("FM") or mOptions.Has("FS") ? ", ProgressGui.MarginY := 5, ProgressGui.MarginX := 5" : ""
      Out .= p[3] != "" ? ", ProgressGui.SetFont(" ToExp(MainTextFontOptions) "," p[5] "), ProgressGui.AddText(`"x0 w" width " Center`", " p[3] ")" : ""
      Out .= ", gocProgress := ProgressGui.AddProgress(`"x10 w" width - 20 " h20" ProgressOptions "`", " ProgressStart ")"
      Out .= p[3] != "" and p[2] != "" ? ", ProgressGui.SetFont(" ToExp(SubTextFontOptions) "," p[5] ")" : p[2] != "" and p[5] != "" ? ", ProgressGui.SetFont(," p[5] ")" : ""
      Out .= p[2] != "" ? ", ProgressGui.AddText(`"x0 w" width " Center`", " p[2] ")" : ""
      Out .= ", ProgressGui.Show(" ToExp(GuiShowOptions) ")"
   }
   Out := RegExReplace(Out, "[\s\,]*\)", ")")
   Return Out
}

_Random(p) {
   ; v1: Random, OutputVar, Min, Max
   if (p[1] = "") {
      Return "; REMOVED Random reseed"
   }
   Out := format("{1} := Random({2}, {3})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_RegRead(p) {
   ; Possible an error if old syntax is used without 5th parameter
   if (p[4] != "" or (InStr(p[3], "\") and !InStr(p[2], "\"))) {
      ; Old V1 syntax RegRead, ValueType, RootKey, SubKey , ValueName, Value
      p[2] := ToExp(p[2] "\" p[3])
      p[3] := ToExp(p[4])
   } else {
      ; New V1 syntax RegRead, ValueType, KeyName , ValueName, Value
      p[2] := ToExp(p[2])
      p[3] := ToExp(p[3])
   }
   p[3] := p[3] = "`"`"" ? "" : p[3]
   p[2] := p[2] = "`"`"" ? "" : p[2]
   Out := format("{1} := RegRead({2}, {3})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_RegWrite(p) {
   ; Possible an error if old syntax is used without 5th parameter
   if (p[5] != "" or (!InStr(p[2], "\") and InStr(p[3], "\"))) {
      ; Old V1 syntax RegWrite, ValueType, RootKey, SubKey , ValueName, Value
      Out := format("RegWrite({5}, {1}, {2} `"\`" {3}, {4})", p*)
      ; Cleaning up the code
      Out := StrReplace(Out, "`" `"\`" `"", "\")
      Out := StrReplace(Out, "`"\`" `"", "`"\")
      Out := StrReplace(Out, "`" `"\`"", "\`"")
   } else {
      ; New V1 syntax RegWrite, ValueType, KeyName , ValueName, Value
      Out := format("RegWrite({4}, {1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_RegDelete(p) {
   ; Possible an error if old syntax is used without 3th parameter
   if (p[1] != "" and (p[3] != "" or (!InStr(p[1], "\") and InStr(p[2], "\")))) {
      ; Old V1 syntax RegDelete, RootKey, SubKey, ValueName
      p[1] := ToExp(p[1] "\" p[2])
      p[2] := ToExp(p[3])
   } else {
      ; New V1 syntax RegDelete, KeyName, ValueName
      p[1] := ToExp(p[1])
      p[2] := ToExp(p[2])
   }
   p[1] := p[1] = "`"`"" ? "" : p[1]
   p[2] := p[2] = "`"`"" ? "" : p[2]
   p[3] := p[3] = "`"`"" ? "" : p[3]
   Out := format("RegDelete({1}, {2})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_Run(p) {
   if InStr(p[3], "UseErrorLevel") {
      p[3] := RegExReplace(p[3], "i)(.*?)\s*\bUseErrorLevel\b(.*)", "$1$2")
      Out := format("{   ErrorLevel := `"ERROR`"`r`n" Indentation "   Try ErrorLevel := Run({1}, {2}, {3}, {4})`r`n" Indentation "}", p*)
   } else {
      Out := format("Run({1}, {2}, {3}, {4})", p*)
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_StringLower(p) {
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrLower({2})", p*)
}
_StringUpper(p) {
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrUpper({2})", p*)
}
_StringGetPos(p) {
   global Indentation

   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format("{1} := InStr({2}, {3}) - 1", p*)

   ; modelled off of:
   ; https://github.com/Lexikos/AutoHotkey_L/blob/9a88309957128d1cc701ca83f1fc5cca06317325/source/script.cpp#L14732
   else
   {
      p[5] := p[5] ? p[5] : 0	; 5th param is 'Offset' aka starting position. set default value if none specified

      p4FirstChar := SubStr(p[4], 1, 1)
      p4LastChar := SubStr(p[4], -1)
      ; msgbox(p[4] "`np4FirstChar=" p4FirstChar "`np4LastChar=" p4LastChar)
      if (p4FirstChar = "`"") && (p4LastChar = "`"")	; remove start/end quotes, would be nice if a non-expr was passed in
      {
         ; the text param was already conveted to expr based on the SideT2E param definition
         ; so this block handles cases such as "L2" or "R1" etc
         p4noquotes := SubStr(p[4], 2, -1)
         p4char1 := SubStr(p4noquotes, 1, 1)
         occurences := SubStr(p4noquotes, 2)
         ;msgbox, % p[4]
         ; p[4] := occurences ? occurences : 1

         if (StrUpper(p4char1) = "R")
         {
            ; only add occurrences param to InStr func if occurrences > 1
            if isInteger(occurences) && (occurences > 1)
               return format("{1} := InStr({2}, {3},, -1*(({5})+1), -" . occurences . ") - 1", p*)
            else
               return format("{1} := InStr({2}, {3},, -1*(({5})+1)) - 1", p*)
         } else
         {
            if isInteger(occurences) && (occurences > 1)
               return format("{1} := InStr({2}, {3},, ({5})+1, " . occurences . ") - 1", p*)
            else
               return format("{1} := InStr({2}, {3},, ({5})+1) - 1", p*)
         }
      } else if (p[4] = 1)
      {
         ; in v1 if occurrences param = "R" or "1" conduct search right to left
         ; "1" sounds weird but its in the v1 source, see link above
         return format("{1} := InStr({2}, {3},, -1*(({5})+1)) - 1", p*)
      } else if (p[4] = "")
      {
         return format("{1} := InStr({2}, {3},, ({5})+1) - 1", p*)
      } else
      {
         ; msgbox( p.Length "`n" p[1] "`n" p[2] "`n" p[3] "`n[" p[4] "]`n[" p[5] "]")
         ; else then a variable was passed (containing the "L#|R#" string),
         ;      or literal text converted to expr, something like:   "L" . A_Index
         ; output something anyway even though it won't work, so that they can see something to fix
         return format("{1} := InStr({2}, {3},, ({5})+1, {4}) - 1", p*)
      }
   }
}
_StringMid(p) {
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format("{1} := SubStr({2}, {3})", p*)
   else if IsEmpty(p[5])
      return format("{1} := SubStr({2}, {3}, {4})", p*)
   else
   {
      ;msgbox, % p[5] "`n" SubStr(p[5], 1, 2)
      ; any string that starts with 'L' is accepted
      if (StrUpper(SubStr(p[5], 2, 1) = "L"))
         return format("{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*)
      else
      {
         out := format("if (SubStr({5}, 1, 1) = `"L`")", p*) . "`r`n"
         out .= format("    {1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*) . "`r`n"
         out .= format("else", p) . "`r`n"
         out .= format("    {1} := SubStr({2}, {3}, {4})", p*)
         return out
      }
   }
}

_StringReplace(p) {
   ; v1
   ; StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
   ; v2
   ; ReplacedStr := StrReplace(Haystack, Needle [, ReplaceText, CaseSense, OutputVarCount, Limit])
   global Indentation, SingleIndent
   comment := "; StrReplace() is not case sensitive`r`n" Indentation "; check for StringCaseSense in v1 source script`r`n"
   comment .= Indentation "; and change the CaseSense param in StrReplace() if necessary`r`n"

   if IsEmpty(p[4]) && IsEmpty(p[5])
      Out := comment Indentation . format("{1} := StrReplace({2}, {3},,,, 1)", p*)
   else if IsEmpty(p[5])
      Out := comment Indentation . format("{1} := StrReplace({2}, {3}, {4},,, 1)", p*)
   else
   {
      p5char1 := SubStr(p[5], 1, 1)
      ; MsgBox(p[5] "`n" p5char1)

      if (p[5] = "UseErrorLevel")	; UseErrorLevel also implies ReplaceAll
         Out := comment Indentation . format("{1} := StrReplace({2}, {3}, {4},, &ErrorLevel)", p*)
      else if (p5char1 = "1") || (StrUpper(p5char1) = "A")
      ; if the first char of the ReplaceAll param starts with '1' or 'A'
      ; then all of those imply 'replace all'
      ; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
         Out := comment Indentation . format("{1} := StrReplace({2}, {3}, {4})", p*)
      else
      {
         Out := comment Indentation . "if (not " ToExp(p[5]) ")"
         Out .= "`r`n" . Indentation . SingleIndent . format("{1} := StrReplace({2}, {3}, {4},,, 1)", p*)
         Out .= "`r`n" . Indentation . "else"
         Out .= "`r`n" . Indentation . SingleIndent . format("{1} := StrReplace({2}, {3}, {4},, &ErrorLevel)", p*)
      }
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_StringSplit(p) {
   ;V1 StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E
   ; Output should be checked to replace OutputArray\d to OutputArray[\d]
   global aListPseudoArray
   VarName := Trim(p[1])
   aListPseudoArray.Push({name: VarName})
   aListPseudoArray.Push({strict: true, name: VarName "0", newname: VarName ".Length"})
   Out := Format("{1} := StrSplit({2},{3},{4})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_SuspendV2(p) {
   ;V1 Suspend , Mode

   p[1] := p[1]="toggle" ? -1 : p[1]
   if (p[1]="Permit"){
      Return "#SuspendExempt"
   }
   Out := "Suspend(" Trim(p[1]) ")"
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SysGet(p) {
   ; SysGet,OutputVar,SubCommand,Value
   if (p[2] = "MonitorCount") {
      Return Format("{1} := MonitorGetCount()", p*)
   } else if (p[2] = "MonitorPrimary") {
      Return Format("{1} := MonitorGetPrimary()", p*)
   } else if (p[2] = "Monitor") {
      Return Format("MonitorGet({3}, &{1}Left, &{1}Top, &{1}Right, &{1}Bottom)", p*)
   } else if (p[2] = "MonitorWorkArea") {
      Return Format("MonitorGetWorkArea({3}, &{1}Left, &{1}Top, &{1}Right, &{1}Bottom)", p*)
   } else if (p[2] = "MonitorName") {
      Return Format("{1} := MonitorGetName({3})", p*)
   }
   p[2] := ToExp(p[2])
   Return Format("{1} := SysGet({2})", p*)
}

_Transform(p) {

   if (p[2] ~= "i)^(Asc|Chr|Mod|Exp|sqrt|log|ln|Round|Ceil|Floor|Abs|Sin|Cos|Tan|ASin|ACos|Atan)") {
      p[2] := p[2] ~= "i)^(Asc)" ? "Ord" : p[2]
      Out := format("{1} := {2}({3}, {4})", p*)
      Return RegExReplace(Out, "[\s\,]*\)$", ")")
   }
   p[3] := p[3] ~= "^-.*" ? "(" p[3] ")" : P[3]
   p[4] := p[4] ~= "^-.*" ? "(" p[4] ")" : P[4]
   if (p[2] ~= "i)^(Pow)") {
      Return format("{1} := {3}**{4}", p*)
   }
   if (p[2] ~= "i)^(BitNot)") {
      Return format("{1} := {3}~{4}", p*)
   }
   if (p[2] ~= "i)^(BitAnd)") {
      Return format("{1} := {3}&{4}", p*)
   }
   if (p[2] ~= "i)^(BitOr)") {
      Return format("{1} := {3}|{4}", p*)
   }
   if (p[2] ~= "i)^(BitXOr)") {
      Return format("{1} := {3}^{4}", p*)
   }
   if (p[2] ~= "i)^(BitShiftLeft)") {
      Return format("{1} := {3}<<{4}", p*)
   }
   if (p[2] ~= "i)^(BitShiftRight)") {
      Return format("{1} := {3}>>{4}", p*)
   }
   Return format("; Removed : Transform({1}, {2}, {3}, {4})", p*)
}

_WinGetActiveStats(p) {
   Out := format("{1} := WinGetTitle(`"A`")", p*) . "`r`n"
   Out .= format("WinGetPos(&{4}, &{5}, &{2}, &{3}, `"A`")", p*)
   return Out
}

_WinGet(p) {
   global Indentation
   p[2] := p[2] = "ControlList" ? "Controls" : p[2]

   Out := format("{1} := WinGet{2}({3},{4},{5},{6})", p*)
   if (P[2] = "Class" || P[2] = "Controls" || P[2] = "ControlsHwnd" || P[2] = "ControlsHwnd") {
      Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
      Out .= Indentation "For v in o" P[1] "`r`n"
      Out .= Indentation "{`r`n"
      Out .= Indentation "   " P[1] " .= A_index=1 ? v : `"``r``n`" v`r`n"
      Out .= Indentation "}"
   }
   if (P[2] = "List") {
      Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
      Out .= Indentation "a" P[1] " := Array()`r`n"
      Out .= Indentation P[1] " := o" P[1] ".Length`r`n"
      Out .= Indentation "For v in o" P[1] "`r`n"
      Out .= Indentation "{   a" P[1] ".Push(v)`r`n"
      Out .= Indentation "}"
      aListPseudoArray.Push({name: P[1], newname: "a" P[1]})
      aListPseudoArray.Push({strict: true, name: P[1], newname: "a" P[1] ".Length"})
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_WinMove(p) {
   ;V1 : WinMove, WinTitle, WinText, X, Y , Width, Height, ExcludeTitle, ExcludeText
   ;V1 : WinMove, X, Y
   ;V2 : WinMove X, Y , Width, Height, WinTitle, WinText, ExcludeTitle, ExcludeText
   lastpos := 0
   for i, v in p {
      if (v != "")
         lastpos := i
   }
   if (lastpos <= 2) {
      p[1] := ParameterFormat("XCBE2E", p[1])
      p[2] := ParameterFormat("YCBE2E", p[2])
      Out := Format("WinMove({1}, {2})", p*)
   } else {
      ; Parameters over p[2] come already formated before reaching here.
      p[1] := ParameterFormat("WinTitleT2E", p[1])
      p[2] := ParameterFormat("WinTextT2E", p[2])
      Out := Format("WinMove({3}, {4}, {5}, {6}, {1}, {2}, {7}, {8})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_WinSet(p) {

   if (p[1] = "AlwaysOnTop") {
      p[2] := p[2] = "`"on`"" ? 1: p[2] = "`"off`"" ? 0 : p[2] = "`"toggle`"" ? -1 : p[2]
   }
   if (p[1] = "Bottom") {
      Out := format("WinMoveBottom({2}, {3}, {4}, {5}, {6})", p*)
   } else if (p[1] = "Top") {
      Out := format("WinMoveTop({2}, {3}, {4}, {5}, {6})", p*)
   } else if (p[1] = "Disable") {
      Out := format("WinSetEnabled(0, {3}, {4}, {5}, {6})", p*)
   } else if (p[1] = "Enable") {
      Out := format("WinSetEnabled(1, {3}, {4}, {5}, {6})", p*)
   } else if (p[1] = "Redraw") {
      Out := format("WinRedraw({3}, {4}, {5}, {6})", p*)
   } else {
      Out := format("WinSet{1}({2}, {3}, {4}, {5}, {6})", p*)
   }
   Out := RegExReplace(Out, "[\s\,]*\)$", ")")
   return Out
}

_WinSetTitle(p) {
   ; V1: WinSetTitle, NewTitle
   ; V1 (alternative): WinSetTitle, WinTitle, WinText, NewTitle , ExcludeTitle, ExcludeText
   ; V2: WinSetTitle NewTitle , WinTitle, WinText, ExcludeTitle, ExcludeText
   if (P[3] = "") {
      Out := format("WinSetTitle({1})", p*)
   } else {
      Out := format("WinSetTitle({3}, {1}, {2}, {4}, {5})", p*)
   }
   Out := RegExReplace(Out, "[\s\,]*\)$", ")")
   return Out
}

_WinWait(p) {
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel {
      out := Format("ErrorLevel := !WinWait({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWait({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ;remove trailing empty params
}
_WinWaitActive(p) {
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel {
      out := Format("ErrorLevel := !WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ;remove trailing empty params
}
_WinWaitNotActive(p) {
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel {
      out := Format("ErrorLevel := !WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ;remove trailing empty params
}
_WinWaitClose(p) {
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel {
      out := Format("ErrorLevel := !WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ;remove trailing empty params
}

_HashtagIfWinActivate(p) {
   if (p[1] = "" and p[2] = "") {
      Return "#HotIf"
   }
   Return format("#HotIf WinActive({1}, {2})", p*)
}

; =============================================================================

Convert_GetContSect() {
   ; Go further in the lines to get the next continuation section
   global oScriptString	; array of all the lines
   global O_Index	; current index of the lines

   result := ""

   loop {
      O_Index++
      if (oScriptString.Length < O_Index) {
         break
      }
      LineContSect := oScriptString[O_Index]
      FirstChar := SubStr(Trim(LineContSect), 1, 1)
      if ((A_index = 1) && (FirstChar != "(" or !RegExMatch(LineContSect, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))) {
         ; no continuation section found
         O_Index--
         return ""
      }
      if (FirstChar == ")") {
         result .= LineContSect
         break
      }
      result .= LineContSect "`r`n"
   }
   DebugWindow("contsect:" result "`r`n", Clear := 0)

   return "`r`n" result
}

; Checks if IfMsgBox is used in the next lines
Check_IfMsgBox() {
   ; Go further in the lines to get the next continuation section
   global oScriptString	; array of all the lines
   global O_Index	; current index of the lines
   ; get Temporary index
   T_Index := O_Index
   found := false

   loop {
      T_Index++
      if (oScriptString.Length < T_Index or A_Index = 40) {	; check the next 40 lines
         break
      }
      LineContSect := oScriptString[T_Index]
      if (RegExMatch(LineContSect, "i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)(.*)")) {
         found := true
         break
      } else if (RegExMatch(LineContSect, "i)^\s*MsgBox([,\s]|$)")) {
         break
      }
   }
   return found
}

; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and separate the variables
; Input:
;   String - The string to parse.
; Output:
;   RETURN - array of the parsed commands.
; --------------------------------------------------------------------
; Returns an Array of the parameters, taking into account brackets and quotes
V1ParSplit(String) {
   ; Created by Ahk_user
   ; Tries to split the parameters better because sometimes the , is part of a quote, function or object
   ; spinn-off from DeathByNukes from https://autohotkey.com/board/topic/35663-functions-to-get-the-original-command-line-and-parse-it/
   ; I choose not to trim the values as spaces can be valuable too
   ;MsgBox(String)
   oResult := Array()	; Array to store result
   oIndex := 1	; index of array
   InArray := 0
   InApostrophe := false
   InFunction := 0
   InObject := 0
   InQuote := false

   ; Checks if an even number was found, not bulletproof, fixes 50%
   ;StrReplace(String, '"', , , &NumberQuotes)
   RegexReplace(" " String, '[^``]"',, &NumberQuotes) ; Use regex to ignore `"
   CheckQuotes := Mod(NumberQuotes + 1, 2)
   ;MsgBox(CheckQuotes "`n" NumberQuotes)

   StrReplace(String, "'", , , &NumberApostrophes)
   CheckApostrophes := Mod(NumberApostrophes + 1, 2)

   oString := StrSplit(String)
   oResult.Push("")
   Loop oString.Length
   {
      Char := oString[A_Index]
      if (!InQuote && !InObject && !InArray && !InApostrophe && !InFunction) {
         if (Char = "," && (A_Index = 1 || oString[A_Index - 1] != "``")) {
            oIndex++
            oResult.Push("")
            Continue
         }
      }

      if (Char = "`"" && !InApostrophe && CheckQuotes) {
         if (!InQuote) {
            if (A_Index = 1 || (oString.has(A_Index - 1) && Instr("( ,", oString[A_Index - 1]))) {
               InQuote := 1
            } else {
               CheckQuotes := 0
            }
         } else {
            if (A_Index = oString.Length || (oString.has(A_Index + 1) && Instr(") ,", oString[A_Index + 1]))) {
               InQuote := 0
            } else {
               CheckQuotes := 0
            }
         }

      } else if (Char = "`'" && !InQuote && CheckApostrophes) {
         if (!InApostrophe) {
            if (A_Index != 1 || (oString.has(A_Index - 1) && Instr("( ,", oString[A_Index - 1]))) {
               CheckApostrophes := 0
            } else {
               InApostrophe := 1
            }
         } else {
            if (A_Index != oString.Length || (oString.has(A_Index + 1) && Instr(") ,", oString[A_Index + 1]))) {
               CheckApostrophes := 0
            } else {
               InApostrophe := 0
            }
         }
      } else if (!InQuote && !InApostrophe) {
         if (Char = "{") {
            InObject++
         } else if (Char = "}" && InObject) {
            InObject--
         } else if (Char = "[") {
            InArray--
         } else if (Char = "]" && InArray) {
            InArray++
         } else if (Char = "(") {
            InFunction++
         } else if (Char = ")" && InFunction) {
            InFunction--
         }
      }
      oResult[oIndex] := oResult[oIndex] Char
   }
   ;for i, v in oResult
   ;   MsgBox v
   return oResult
}

; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and return the function, parameters, post and pre text
; Input:
;     String - The string to parse.
;     FuctionTaget - The number of the function that you want to target
; Output:
;   oResult - array
;       oResult.pre           text before the function
;       oResult.function      function name
;       oResult.parameters    parameters of the function
;       oResult.post          text afther the function
;       oResult.separator     character before the function
; --------------------------------------------------------------------
; Returns an object of parameters in the function properties: pre, function, parameters, post & separator
V1ParSplitFunctions(String, FunctionTarget := 1) {
   ; Will try to extract the function of the given line
   ; Created by Ahk_user
   oResult := Array()	; Array to store result Pre func params post
   oIndex := 1	; index of array
   InArray := 0
   InApostrophe := false
   InQuote := false
   Hook_Status := 0

   FunctionNumber := 0
   Searchstatus := 0
   HE_Index := 0
   oString := StrSplit(String)
   oResult.Push("")

   Loop oString.Length
   {
      Char := oString[A_Index]

      if (Char = "'" && !InQuote) {
         InApostrophe := !InApostrophe
      } else if (Char = "`"" && !InApostrophe) {
         InQuote := !InQuote
      }
      if (Searchstatus = 0) {

         if (Char = "(" and !InQuote and !InApostrophe) {
            FunctionNumber++
            if (FunctionNumber = FunctionTarget) {
               H_Index := A_Index
               ; loop to find function
               loop H_Index - 1 {
                  if (!IsNumber(oString[H_Index - A_Index]) and !IsAlpha(oString[H_Index - A_Index]) And !InStr("#_@$", oString[H_Index - A_Index])) {
                     F_Index := H_Index - A_Index + 1
                     Searchstatus := 1
                     break
                  } else if (H_Index - A_Index = 1) {
                     F_Index := 1
                     Searchstatus := 1
                     break
                  }
               }
            }
         }
      }
      if (Searchstatus = 1) {
         if (oString[A_Index] = "(" and !InQuote and !InApostrophe) {
            Hook_Status++
         } else if (oString[A_Index] = ")" and !InQuote and !InApostrophe) {
            Hook_Status--
         }
         if (Hook_Status = 0) {
            HE_Index := A_Index
            break
         }
      }
      oResult[oIndex] := oResult[oIndex] Char
   }
   if (Searchstatus = 0) {
      oResult.Pre := String
      oResult.Func := ""
      oResult.Parameters := ""
      oResult.Post := ""
      oResult.Separator := ""
      oResult.Found := 0

   } else {
      oResult.Pre := SubStr(String, 1, F_Index - 1)
      oResult.Func := SubStr(String, F_Index, H_Index - F_Index)
      oResult.Parameters := SubStr(String, H_Index + 1, HE_Index - H_Index - 1)
      oResult.Post := SubStr(String, HE_Index + 1)
      oResult.Separator := SubStr(String, F_Index - 1, 1)
      oResult.Found := 1
   }
   oResult.Hook_Status := Hook_Status
   return oResult
}

; Function to debug
DebugWindow(Text, Clear := 0, LineBreak := 0, Sleep := 0, AutoHide := 0) {
   if WinExist("AHK Studio") {
      x := ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
      x.DebugWindow(Text, Clear, LineBreak, Sleep, AutoHide)
   } else {
      OutputDebug Text
   }
   return
}

Format2(FormatStr, Values*) {
   ; Removes empty values
   return Format(FormatStr, Values*)
}

;// Param format:
;//          - param names ending in "T2E" will convert a literal Text param TO an Expression
;//              this would be used when converting a Command to a Func or otherwise needing an expr
;//              such as      word -> "word"      or      %var% -> var
;//              Changed: empty strings will return an emty string
;//              like the 'value' param in those  `IfEqual, var, value`  commands
;//          - param names ending in "T2QE" will convert a literal Text param TO an Quoted Expression
;//              this would be used when converting a Command to a expr
;//              This is the same as T2E, but will return an "" if empty.
;//          - param names ending in "Q2T" will convert a Quoted Text param TO text
;//              this would be used when converting a function variable that holds a label or function
;//              "WM_LBUTTONDOWN" => WM_LBUTTONDOWN
;//          - param names ending in "CBE2E" would convert parameters that 'Can Be an Expression TO an EXPR'
;//              this would only be used if the conversion goes from Command to Func
;//              we'd need to strip a preceeding "% " which was used to force an expr when it was unnecessary
;//          - param names ending in "CBE2T" would convert parameters that 'Can Be an Expression TO literal TEXT'
;//              this would be used if the conversion goes from Command to Command
;//              because in v2, those command parameters can no longer optionally be an expression.
;//              these will be wrapped in %%s, so   expr+1   is now    %expr+1%
;//          - param names ending in "Q2T" would convert parameters that 'Can Be an quoted TO literal TEXT'
;//               "var" => var
;//               'var' => var
;//                var => var
;//          - param names ending in "V2VR" would convert an output variable name to a v2 VarRef
;//              basically it will just add an & at the start. so var -> &var
;//          - any other param name will not be converted
;//              this means that the literal text of the parameter is unchanged
;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
; Converts Parameter to different format T2E T2QE Q2T CBE2E CBE2T Q2T V2VR
ParameterFormat(ParName, ParValue) {
   ParName := StrReplace(Trim(ParName), "*")	; Remove the *, that indicate an array
   ParValue := Trim(ParValue)
   if (ParName ~= "V2VR$") {
      if (ParValue != "" and !InStr(ParValue, "&"))
         ParValue := "&" . ParValue
   } else if (ParName ~= "CBE2E$")	; 'Can Be an Expression TO an Expression'
   {
      if (SubStr(ParValue, 1, 2) = "% ")	; if this param expression was forced
         ParValue := SubStr(ParValue, 3)	; remove the forcing
      else
         ParValue := RemoveSurroundingPercents(ParValue)
   } else if (ParName ~= "CBE2T$")	; 'Can Be an Expression TO literal Text'
   {
      if isInteger(ParValue)	; if this param is int
         || (SubStr(ParValue, 1, 2) = "% ")	; or the expression was forced
         || ((SubStr(ParValue, 1, 1) = "%") && (SubStr(ParValue, -1) = "%"))	; or var already wrapped in %%s
      ParValue := ParValue	; dont do any conversion
      else
         ParValue := "%" . ParValue . "%"	; wrap in percent signs to evaluate the expr
   } else if (ParName ~= "Q2T$")	; 'Can Be an quote TO literal Text'
   {
      if ((SubStr(ParValue, 1, 1) = "`"") && (SubStr(ParValue, -1) = "`""))	;  var already wrapped in Quotes
         || ((SubStr(ParValue, 1, 1) = "`'") && (SubStr(ParValue, -1) = "`'"))	;  var already wrapped in Quotes
         ParValue := SubStr(ParValue, 2, StrLen(ParValue) - 2)
      else
         ParValue := "%" ParValue "%"
   } else if (ParName ~= "T2E$")	; 'Text TO Expression'
   {
      if (SubStr(ParValue, 1, 2) = "% ") {
         ParValue := SubStr(ParValue, 3)
      } else {
         ParValue := ParValue != "" ? ToExp(ParValue) : ""
      }
   } else if (ParName ~= "T2QE$")	; 'Text TO Quote Expression'
   {
      ParValue := ToExp(ParValue)
   } else if (ParName ~= "i)On2True$")	; 'Text TO Quote Expression'
   {
      ParValue := RegexReplace(ParValue, "^%\s*(.*?)%?$", "$1")
      ParValue := RegexReplace(RegexReplace(RegexReplace(ParValue, "i)\btoggle\b", "-1"), "i)\bon\b", "true"), "i)\boff\b", "false")
   } else if (ParName ~= "i)^StartingPos$")	; Only parameters with this name. Found at InStr, SubStr, RegExMatch and RegExReplace.
   {
      if (ParValue != "") {
         if (IsNumber(ParValue)) {
            ParValue := ParValue<1 ? ParValue-1 : ParValue
         } else {
            ParValue := "(" ParValue ")<1 ? (" ParValue ")-1 : (" ParValue ")"
         }
      }
   } else{
      ParValue := ReplaceQuotes(ParValue)
   }

   Return ParValue
}

;//  Example array123 => array[123]
;//  Example array%A_index% => array[A_index]
;//  Special cases in RegExMatch   => {OutVar: OutVar[0],     OutVar0: ""           }
;//  Special cases in StringSplit  => {OutVar: "",            OutVar0: OutVar.Length}
;//  Special cases in WinGet(List) => {OutVar: OutVar.Length, OutVar0: ""           }
;// Converts PseudoArray to Array
ConvertPseudoArray(ScriptStringInput, PseudoArrayName) {
   ; The caller does a fast InStr before calling.
   ; Summary of suffix variations depending on sources:
   ;  - StringSplit      => OutVar:Blank;  OutVar0:Length; OutVarN:Items;
   ;  - WinGet-List      => OutVar:Length; OutVar0:Blank;  OutVarN:Items;
   ;  - RegExMatch-Mode1 => OutVar:Text;   OutVar0:Blank;  OutVarN:Items;
   ;  - RegExMatch-Mode2 => OutVar:Length; OutVar0:Blank;  OutVarN:Blank; OutVarPosN:Item-pos; OutVarLenN:Item-len;
   ;  - RegExMatch-Mode3 => OutVar:Object; OutVar0:Blank;  OutVarN:Blank;

   ArrayName := PseudoArrayName.name
   NewName := PseudoArrayName.HasOwnProp("newname") ? PseudoArrayName.newname : ArrayName
   if RegexMatch(ScriptStringInput,"i)^\s*(local|global|static)\s"){
      ; Expecting situations like "local x,v0,v1" to end up as "local x,v".
      ScriptStringInput := RegExReplace(ScriptStringInput, "is)\b(" ArrayName ")(\d*\s*,\s*(?1)\d*)+\b", NewName)
   } else if (PseudoArrayName.HasOwnProp("strict") && PseudoArrayName.strict) {
      ; Replacement without allowing suffix.
      ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "(?!\w|%|\.|\[|\s*:=)", NewName)
   } else {
      ; General replacement for numerical suffixes and percent signs.
      ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "([1-9]\d*)(?!\w|\.|\[)", NewName "[$1]")
      ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&|\.)" ArrayName "%(\w+)%(?!\w|\.|\[)", NewName "[$1]")
   }

   Return ScriptStringInput
}

;//  Example ObjectMatch.Value(N) => ObjectMatch[N]
;//  Example ObjectMatch.Len(N) => ObjectMatch.Len[N]
;//  Example ObjectMatch.Mark() => ObjectMatch.Mark
;//  Special case ObjectMatch.Name(N) => ObjectMatch.Name(N)
;//  Special case ObjectMatch.Name => ObjectMatch["Name"]
;// Converts Object Match V1 to Object Match V2
ConvertMatchObject(ScriptStringInput, ObjectMatchName) {
   ; The caller does a fast InStr before calling.
   ; We try to catch group-names before methods turn into properties.
   ; ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(\d+)\b", '$1[$2]') ; Matter of preference.
   ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(?=\w*[a-z_])(\w+)(?!\w|\()", '$1["$2"]')
   ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(Value)\((.*?)\)", "$1[$3]")
   ScriptStringInput := RegExReplace(ScriptStringInput, "is)(?<!\w|&)(" ObjectMatchName ")\.(Mark|Count)\(\)", "$1.$2")
   Return ScriptStringInput
}

; Returns a Map of options like x100 y200 ...
GetMapOptions(Options) {
   mOptions := Map()
   Loop parse, Options, " "
   {
      if (StrLen(A_LoopField) > 0) {
         mOptions[SubStr(StrUpper(A_LoopField), 1, 1)] := SubStr(A_LoopField, 2)
      }
      if (StrLen(A_LoopField) > 2) {
         mOptions[SubStr(StrUpper(A_LoopField), 1, 2)] := SubStr(A_LoopField, 3)
      }
   }
   Return mOptions
}

; Converts arrays to maps (fails currently if more then one level)
AssArr2Map(ScriptString) {
   if RegExMatch(ScriptString, "is)^.*?\{\s*[^\s:]+?\s*:\s*([^\}]*)\s*.*") {
      Key := RegExReplace(ScriptString, "is)(^.*?)\{\s*([^\s:]+?)\s*:\s*([^\,}]*)\s*(.*)", "$2")
      Value := RegExReplace(ScriptString, "is)(^.*?)\{\s*([^\s:]+?)\s*:\s*([^\,}]*)\s*(.*)", "$3")
      ScriptStringBegin := RegExReplace(ScriptString, "is)(^.*?)\{\s*([^\s:]+?)\s*:\s*([^\,}]*)\s*(.*)", "$1")
      Key := (InStr(Key, '"')) ? Key : ToExp(Key)
      ScriptString1 := ScriptStringBegin "map(" Key ", " Value
      ScriptStringRest := RegExReplace(ScriptString, "is)(^.*?)\{\s*([^\s:]+?)\s*:\s*([^\,}]*)\s*(.*$)", "$4")
      loop {

         ; if RegExMatch(ScriptStringRest, "is)^\s*,\s*[^\s:]+?\s*:\s*([^\},]*)\s*.*") {
         ;    OutputDebug("match 1 : " ScriptStringRest "`n")
         ;    Key := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?)\s*:\s*([^\},]*)\s*(.*)", "$1")
         ;    Value := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?)\s*:\s*([^\},]*)\s*(.*)", "$2")
         ;    Key := (InStr(Key, '"')) ? Key : ToExp(Key)
         ;    ScriptString1 .= ", " Key ", " Value
         ;    ScriptStringRest := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?)\s*:\s*([^\},]*)\s*(.*$)", "$3")
         ; } else {
         if RegExMatch(ScriptStringRest, "is)^\s*,\s*([^\s:]+?|`"[^:`"]`"+?)\s*:\s*([^\},]*)\s*.*") {
            OutputDebug("match 1 : " ScriptStringRest "`n")
            Key := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?|`"[^:`"]`"+?)\s*:\s*([^\},]*)\s*(.*)", "$1")
            Value := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?|`"[^:`"]`"+?)\s*:\s*([^\},]*)\s*(.*)", "$2")
            Key := (InStr(Key, '"')) ? Key : ToExp(Key)
            ScriptString1 .= ", " Key ", " Value
            ScriptStringRest := RegExReplace(ScriptStringRest, "is)^\s*,\s*([^\s:]+?|`"[^:`"]`"+?)\s*:\s*([^\},]*)\s*(.*$)", "$3")
         } else {
            OutputDebug("match 2 : " ScriptStringRest "`n")
            if RegExMatch(ScriptStringRest, "is)^\s*(\})\s*.*") {
               OutputDebug("{{{}}}:" ScriptStringRest "`n")
               ScriptStringRest := RegExReplace(ScriptStringRest, "is)^\s*(\})(\s*.*$)", ")$2")
            }
            break
         }
      }
      ScriptString := ScriptString1 ScriptStringRest
   } else {
      ScriptString := RegExReplace(ScriptString, "(\w+\s*:=\s*)\{\}", "$1map()")
   }
   return ScriptString
}

; Function that converts specific label to string and adds brackets
; ScriptString        :  Script
; Label               :  Label to change to fuction
; Parameters          :  Parameters to use
; NewFunctionName     :  Name of new function
; aRegexReplaceList   :  Array with objects with NeedleRegEx and Replacement properties to be used in the label
;                         example: [{NeedleRegEx: "(.*)V1(.*)",Replacement : "$1V2$2"}]
; Function that converts specific label to string and adds brackets
ConvertLabel2Func(ScriptString, Label, Parameters := "", NewFunctionName := "", aRegexReplaceList := "") {
   oScriptString := StrSplit(ScriptString, "`n", "`r")
   Result := ""
   LabelPointer := 0	; active searching for the end of the hotkey
   LabelStart := 0	; active searching for the beginning of the bracket
   RegexPointer := 0
   RestString := ScriptString	;Used to have a string to look the rest of the file
   if (NewFunctionName = "") {	; Use Labelname if no FunctionName is defined
      NewFunctionName := Label
   }
   NewFunctionName := GetV2Label(NewFunctionName)
   loop oScriptString.Length {
      Line := oScriptString[A_Index]

      if (LabelPointer = 1 or LabelStart = 1 or RegexPointer = 1) {
         if IsObject(aRegexReplaceList) {
            Loop aRegexReplaceList.Length {
               if aRegexReplaceList[A_Index].NeedleRegEx
                  Line := RegExReplace(Line, aRegexReplaceList[A_Index].NeedleRegEx, aRegexReplaceList[A_Index].Replacement)
               ;MsgBox(Line "`n" aRegexReplaceList[A_Index].NeedleRegEx "`n" aRegexReplaceList[A_Index].Replacement)
            }
         }
      }

      if (LabelPointer = 1 or RegexPointer = 1) {
         if RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)[\s\n\r]*(`;[^\r\n]*|)([\s\n\r]*){).*") {	; Function declaration detection
            ; not bulletproof perfect, but a start
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added bracket before function`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
      }
      if (RegExMatch(Line, "i)^(\s*;).*") or RegExMatch(Line, "i)^(\s*)$")) {	; comment or empty
         ; Do noting
      } else if (RegExMatch(Line, "i)^\s*[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:).*") > 0) {	; Hotkey or string
         if (LabelPointer = 1 or RegexPointer = 1) {
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
         if (RegExMatch(Line, "i)^\s*[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:\s*[^\s;].+)") > 0) {
            ; oneline detected do noting
            LabelPointer := 0
            RegexPointer := 0
         }
      } else If (LabelStart = 1) {
         if (RegExMatch(Line, "i)^\s*({).*")) {	; Hotkey is already good :)
            LabelPointer := 0
         } else {
            Result .= "{ `; V1toV2: Added bracket`r`n"
            LabelPointer := 1
         }
         LabelStart := 0
      }
      if (LabelPointer = 1 or RegexPointer = 1) {
         if (RegExMatch(RestString, "is)^[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\:).*") > 0) {	; Hotkey or string
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         } else if (RegExMatch(RestString, "is)^(|;[^\n]*\n)*[\s`n`r\t]*\}?[\s`n`r\t]*([^;`n`r\s\{}\[\]\=:]+?\:\s).*") > 0 and RegExMatch(oScriptString[A_Index - 1], "is)^[\s`n`r\t]*(return|exitapp|exit).*") > 0) {	; Label
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before label`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         } else if (RegExMatch(RestString, "is)^[\s`n`r\t]*\}?[\s`n`r\t]*(`;[^\r\n]*|)([\s\n\r\t]*)$") > 0 and RegExMatch(oScriptString[A_Index - 1], "is)^[\s`n`r\t]*(return).*") > 0) {	; Label
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added bracket in the end`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
      }
      ; This check needs to be at the bottom.
      if Instr(Line, Label ":") {
         If RegexMatch(Line, "is)^(\s*|.*\n\s*)(\Q" Label "\E):(.*)", &Var) {
            if RegExMatch(Line, "is)(\s*)(\Q" Label "\E):(\s*[^\s;].+)") {
               ;Oneline detected
               Line := Var[1] NewFunctionName "(" Parameters "){`r`n   " Var[3] "`r`n}"
               if IsObject(aRegexReplaceList) {
                  Loop aRegexReplaceList.Length {
                     if aRegexReplaceList[A_Index].NeedleRegEx
                        Line := RegExReplace(Line, aRegexReplaceList[A_Index].NeedleRegEx, aRegexReplaceList[A_Index].Replacement)
                     ;MsgBox(Line "`n" aRegexReplaceList[A_Index].NeedleRegEx "`n" aRegexReplaceList[A_Index].Replacement)
                  }
               }
            } else {
               Line := Var[1] NewFunctionName "(" Parameters ")" Var[3]
               LabelStart := 1
               RegexPointer := 1
            }
         }
      }
      RestString := SubStr(RestString, InStr(RestString, "`n") + 1)
      Result .= Line
      Result .= "`r`n"
   }
   if (LabelPointer = 1) {
      Result .= "} `; Added bracket in the end`r`n"
   }
   return Result
}

/**
 * Adds brackets to script
 * @param {*} ScriptString string containing a script of multiple lines
 */
AddBracket(ScriptString) {
   oScriptString := StrSplit(ScriptString, "`n", "`r")
   Result := ""
   HotkeyPointer := 0	; active searching for the end of the hotkey
   HotkeyStart := 0	; active searching for the beginning of the bracket
   RestString := ScriptString	;Used to have a string to look the rest of the file
   CommentCode := 0

   loop oScriptString.Length {
      Line := oScriptString[A_Index]

      if (RegExMatch(Line, "i)^\s*(\/\*).*")){ ; Start commented code (starts with /*) => skip conversion
         CommentCode:=1
      }
      if (CommentCode=0){
         if (HotkeyPointer = 1) {
            if RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)[\s\n\r]*(`;[^\r\n]*|)([\s\n\r]*){).*") {	; Function declaration detection
               ; not bulletproof perfect, but a start
               Result .= "} `; Added bracket before function`r`n"
               HotkeyPointer := 0
            }
         }
         if (RegExMatch(Line, "i)^(\s*;).*") or RegExMatch(Line, "i)^(\s*)$")) {	; comment or empty
            ; Do noting
         } else if (RegExMatch(Line, "i)^\s*[\s\n\r\t]*((:[\s\*\?BCKOPRSIETXZ0-9]*:|)[^;\n\r\{}\[\:]+?\:\:).*") > 0) {	; Hotkey or string
            if (HotkeyPointer = 1) {
               Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
               HotkeyPointer := 0
            }
            if (RegExMatch(Line, "i)^\s*[\s\n\r\t]*((:[\s\*\?BCKOPRSIETXZ0-9]*:|)[^;\n\r\{}\[\:]+?\:\:\s*[^\s;].+)") > 0) {
               ; oneline detected do noting
            } else {
               ; Hotkey detected start searching for start
               HotkeyStart := 1
            }
         } else If (HotkeyStart = 1) {
            if (RegExMatch(Line, "i)^\s*(#).*")) {	; #if statement, skip this line
               HotkeyStart := 1
            } else {
               if (RegExMatch(Line, "i)^\s*([{\(]).*")) {	; Hotkey is already good :)
                  HotkeyPointer := 0
               } else if RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)[\s\n\r]*(`;[^\r\n]*|)([\s\n\r]*){).*") {	; Function declaration detection
                  ; Named Function Hotkeys do not need brackets
                  ; https://lexikos.github.io/v2/docs/Hotstrings.htm
                  ; Maybe add an * to the function?
                  A_Index2 := A_Index - 1
                  Loop oScriptString.Length - A_Index2 {
                     if RegExMatch(oScriptString[A_Index2 + A_Index], "i)^\s*([\w]+?\().*$") {
                        oScriptString[A_Index2 + A_Index] := RegExReplace(oScriptString[A_Index2 + A_Index], "i)(^\s*[\w]+?\()[\s]*(\).*)$", "$1*$2")
                        if (A_Index = 1) {
                           Line := oScriptString[A_Index2 + A_Index]
                        }
                        Break
                     }
                  }
                  RegExReplace(RestString, "is)^(\s*)([\w]+?\([^\)]*\)[\s\n\r]*(`;[^\r\n]*|)([\s\n\r]*){).*", "$1")
                  HotkeyPointer := 0
               } else {
                  Result .= "{ `; V1toV2: Added bracket`r`n"
                  HotkeyPointer := 1
               }
               HotkeyStart := 0
            }
         }
         if (HotkeyPointer = 1) {
            if (RegExMatch(RestString, "is)^[\s\n\r\t]*((:[\s\*\?BCKOPRSIETXZ0-9]*:|)[^;\n\r\{}\[\]\=:]+?\:\:).*") > 0) {	; Hotkey or string
               Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^[\s\n\r\t]*((:[\s\*\?BCKOPRSIETXZ0-9]*:|)[^;\n\r\s\{}\[\:]+?\:\:?\s).*") > 0 and RegExMatch(oScriptString[A_Index - 1], "is)^[\s\n\r\t]*(return|exit|exitapp).*") > 0) {	; Label
               Result .= "} `; V1toV2: Added Bracket before label`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^[\s\n\r\t]*(`;[^\r\n]*|)([\s\n\r\t]*)$") > 0 and RegExMatch(oScriptString[A_Index - 1], "is)^[\s\n\r\t]*(return|exit|exitapp).*") > 0) {	; Label
               Result .= "} `; V1toV2: Added bracket in the end`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^[\s\n\r\t]*(#hotif).*") > 0){ ; #Hotif statement
               Result .= "} `; V1toV2: Added bracket in the end`r`n"
               HotkeyPointer := 0
            }
         }
      }

      if (RegExMatch(Line, "i)^\s*(\*\/).*")){ ; End commented code (starts with /*)
         CommentCode:=0
      }

      ; Convert wrong labels
      if RegexMatch(Line, "is)^\s*([^:\s\t,\{\}\[\]\(\)]+):(\s.*|)$") {
         Label := GetV2Label(RegExReplace(Line, "is)(^\s*)([^:\s\t,\{\}\[\]\(\)]+):(\s.*|)$", "$2"))
         Line := Regexreplace(Line, "is)(^\s*)([^:\s\t,\{\}\[\]\(\)]+):(\s.*$|$)", "$1" Label ":$3")
      }

      RestString := SubStr(RestString, InStr(RestString, "`n") + 1)
      Result .= Line
      Result .= A_Index != oScriptString.Length ? "`r`n" : ""
   }
   if (HotkeyPointer = 1) {
      Result .= "`r`n} `; V1toV2: Added bracket in the end`r`n"
   }

   return Result
}

/**
 * Creates a Map of labels who can be replaced by other labels (if labels are defined above each other)
 * @param {*} ScriptString string containing a script of multiple lines
 */
GetAltLabelsMap(ScriptString) {
   oScriptString := StrSplit(ScriptString, "`n", "`r")
   LabelPrev := ""
   mAltLabels := Map()
   loop oScriptString.Length {
      Line := oScriptString[A_Index]

      if (RegExMatch(Line, "i)^(\s*;).*") or RegExMatch(Line, "i)^(\s*)$")) {	; comment or empty
         continue
      } else if (RegExMatch(Line, "is)^[\s\t]*([^;`n`r\s\{}\[\]\=:]+?\:)\s*(;.*|)$") > 0) {	; Label (no oneline)
         Label := RegExReplace(Line, "is)^[\s\t]*([^;`n`r\s\{}\[\]\=:]+?)\:\s*(;.*|)$", "$1")
         Result .= Label "-" LabelPrev "`r`n"
         if (LabelPrev = "") {
            LabelPrev := Label
         } else {
            mAltLabels[Label] := LabelPrev
         }
      } else {
         LabelPrev := ""
      }
   }
   ; For testing
   ; for k, v in mAltLabels
   ; {
   ;     MsgBox(k "-" v)
   ; }
   return mAltLabels
}

; Corrects labels by adding "_" before it if it is not allowed. Other rules can be added later on like replacement of forbidden characters
GetV2Label(LabelName) {
   NewLabelName := RegExReplace(LabelName, "^(\d.*)", "_$1")	; adds "_" before label if first char is number
   return NewLabelName
}

;################################################################################
															 maskStrings(&srcStr)
;################################################################################
{
; 2024-04-08 ADDED, andymbody
; masks quoted-strings, stores the orig text in gQuotedStrings global array

   global gQuotedStrings

    ; ini
	pref	:= '#TAG' chr(1000) 'MS_', trail := chr(1000) '#'    ; unique tag
	pattern := '(?<!")"[^"]+"(?!")'   ; characters surrounded by double quotes, treats each set separately


	; find all target strings (one at a time), replace them with tags
	pos := 0, m := []
	while (pos  := RegExMatch(srcStr, pattern, &m, pos+1)) {
		gQuotedStrings.push(m[])    ; save original text into array
		tag		:= pref . gQuotedStrings.Length . trail
		srcStr	:= StrReplace(srcStr, m[], tag,,, 1)	; replace only one at a time
 	}
	return
}
;################################################################################
														  restoreStrings(&srcStr)
;################################################################################
{
; 2024-04-08 ADDED, andymbody
; restores orig strings that were masked by maskStrings()

   global gQuotedStrings

	; ini
	pref    := '#TAG' chr(1000) 'MS_', trail := chr(1000) '#'    ; unique tag
	tag		:= pref . '\d+' . trail		; tag pattern

	; find all tags (one at a time), then replace them with orig
    pos := 0, m := []
	while (pos  := RegExMatch(srcStr, tag, &m))
	{
		; tag found - get orig text, then replace tag with it
		RegExMatch(m[], '\d+', &idx)
		orig    := gQuotedStrings[idx[]]
		srcStr  := StrReplace(srcStr, m[], orig)
	}
	return
}
;################################################################################
														   RemoveNewKeyword(line)
;################################################################################
{
; 2024-04-09, andymbody - MODIFIED to prevent "new" within strings from being removed

   ; orig
   ;If RegExMatch(Line, "i)^(.*)(:=|\(|,)(\s*)new\s(\s*\w.*)$", &Equation) {
   ;   Line := Equation[1] Equation[2] Equation[3] Equation[4]
   ;}

   maskStrings(&Line)   ; prevent "new" within strings from being removed
   If RegExMatch(Line, "i)^(.+?)(:=|\(|,)(\h*)new\h(\h*\w.*)$", &Equation)
   {
      Line := Equation[1] Equation[2] Equation[3] Equation[4]
   }
   restoreStrings(&Line)
   return line
}

;################################################################################
                                         CorrectNEQ(line)
;################################################################################
{
   maskStrings(&Line)   ; prevent "<>" within strings from being removed
   Line := StrReplace(Line, "<>", "!=")
   restoreStrings(&Line)
   return Line
}

;################################################################################
													  RenameLoopRegKeywords(line)
;################################################################################
{
; 2024-04-08 ADDED, andymbody
; separated LoopReg keywords from KeywordsToRenameM map...
;   so that they can be treated differently - See 5Keywords.ahk

   for v1, v2 in LoopRegKeywords
   {
      srchtxt := Trim(v1)
      rplctxt := Trim(v2)

      if InStr(Line, srchtxt)
      {
         Line := RegExReplace(Line, "i)([^\w]|^)\Q" . srchtxt . "\E([^\w]|$)", "$1" . rplctxt . "$2")
      }
   }
	return line
}
;################################################################################
															 RenameKeywords(Line)
;################################################################################
{
; 2024-04-08 ADDED, andymbody
; moved this code from main loop to it's own function
; also separated LoopReg keywords from KeywordsToRenameM map...
;   so that they can be treated differently - See 5Keywords.ahk
; Added the ability to mask the line-strings so that Keywords found within
;   strings are no longer converted along with Keyword vars

   ; replace any renamed vars
   ; Fixed - NO LONGER converts text found in strings
   masked := false
   for v1, v2 in KeywordsToRenameM
   {
      srchtxt := Trim(v1)
      rplctxt := Trim(v2)

      if InStr(Line, srchtxt)
      {
         if (!masked)
         {
            masked := true, maskStrings(&Line)   ; masking is slow, so only do this as necessary
         }
         Line := RegExReplace(Line, "i)([^\w]|^)\Q" . srchtxt . "\E([^\w]|$)", "$1" . rplctxt . "$2")
      }
   }

   if (masked)
      restoreStrings(&Line)

   return Line
}
