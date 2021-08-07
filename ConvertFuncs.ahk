#Requires AutoHotKey v2.0-beta.1
#SingleInstance Force

; Added a mapkey to test on the fly
XButton1::
{
	ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.
	A_Clipboard := ""
	Send "^c"

	if !ClipWait(3){
		DebugWindow( "error`n",Clear:=0)
		return
	}
	Clipboard1 := A_Clipboard
	A_Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of A_Clipboard (not ClipboardAll).
	ClipSaved := ""  ; Free the memory in case the clipboard was very large.

	ConvertedCode := Convert(Clipboard1)
	DebugWindow(ConvertedCode "`n",Clear:=0) ; For AHK Studio Users
	;~ MsgBox(ConvertedCode)
	A_Clipboard := ConvertedCode
   if WinExist("Convert tester"){
      WinClose("Convert tester")
   }
   
	MyGui := Gui(,"Convert tester")
	V1Edit := MyGui.Add("Edit", "w600 vvCodeV1", Clipboard1)  ; Add a fairly wide edit control at the top of the window.
	MyGui.Add("Button", "default", "Run V1").OnEvent("Click", RunV1)
	MyGui.Add("Button", "default x+10 yp", "Convert again").OnEvent("Click", ButtonConvert)
	V2Edit := MyGui.Add("Edit", "xm w600 vvCodeV2", ConvertedCode)  ; Add a fairly wide edit control at the top of the window.
	MyGui.Add("Button", "default", "Run V2").OnEvent("Click", RunV2)
	MyGui.Show

	return
	RunV1(*){
		TempAhkFile := A_MyDocuments "\testV1.ahk"
		AhkV1Exe :=  "C:\Program Files\AutoHotkey\AutoHotkey.exe"
		oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
		try {
			FileDelete TempAhkFile
		}
		FileAppend oSaved.vCodeV1 , TempAhkFile
		Run AhkV1Exe " " TempAhkFile
	}
	RunV2(*){
		TempAhkFile := A_MyDocuments "\testV2.ahk"
		AhkV2Exe := "C:\Program Files\AutoHotkey V2\AutoHotkey64.exe"
		oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
		try {
			FileDelete TempAhkFile
		}
		FileAppend oSaved.vCodeV2 , TempAhkFile
		Run AhkV2Exe " " TempAhkFile
	}
   ButtonConvert(*){
      oSaved := MyGui.Submit(0)
      V2Edit.Value := Convert(oSaved.vCodeV1)
   }
}	

Convert(ScriptString)
{
   global Orig_Line
   global Orig_Line_NoComment
   global oScriptString ; array of all the lines
   global O_Index :=0 ; current index of the lines
   global Indentation
   global GuiNameDefault
   global GuiList
   GuiNameDefault := "myGui"
   GuiList := "|"
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
   ;//          - param names ending in "V2VR" would convert an output variable name to a v2 VarRef
   ;//              basically it will just add an & at the start. so var -> &var
   ;//          - any other param name will not be converted
   ;//              this means that the literal text of the parameter is unchanged
   ;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
   ;// Replacement format:
   ;//          - use {1} which corresponds to Param1, etc
   ;//          - use asterisk * and a function name to call, for custom processing when the params dont directly match up
   CommandsToConvert := "
   (
      DriveSpaceFree,OutputVar,PathT2E | {1} := DriveGetSpaceFree({2})
      EnvAdd,var,valueCBE2E,TimeUnitsT2E | *_EnvAdd
      EnvSub,var,valueCBE2E,TimeUnitsT2E | *_EnvSub
      EnvDiv,var,valueCBE2E | {1} /= {2}
      EnvMult,var,valueCBE2E | {1} *= {2}
      EnvUpdate | SendMessage, `% WM_SETTINGCHANGE := 0x001A, 0, Environment,, `% "ahk_id " . HWND_BROADCAST := "0xFFFF"
      FileAppend,textT2E,fileT2E,encT2E | FileAppend({1}, {2}, {3})
      FileCopyDir,source,dest,flag | DirCopy, {1}, {2}, {3}
      FileCreateDir,dir | DirCreate, {1}
      FileGetSize,OutputVar,filenameT2E,unitsT2E | {1} := FileGetSize({2}, {3})
      FileMoveDir,source,dest,flag | DirMove, {1}, {2}, {3}
      FileRemoveDir,dir,recurse | DirDelete, {1}, {2}
      FileSelectFolder,var,startingdir,opts,prompt | DirSelect, {1}, {2}, {3}, {4}
      FileSelectFile,var,opts,rootdirfile,prompt,filter | FileSelect, {1}, {2}, {3}, {4}, {5}
      FormatTime,outVar,dateT2E,formatT2E | {1} := FormatTime({2}, {3})
      Gui,SubCommand,Value1,Value2,Value3 | *_Gui
      IfEqual,var,valueT2E | if ({1} = {2})
      IfNotEqual,var,valueT2E | if ({1} != {2})
      IfGreater,var,valueT2E | *_IfGreater
      IfGreaterOrEqual,var,valueT2E | *_IfGreaterOrEqual
      IfLess,var,valueT2E | *_IfLess
      IfLessOrEqual,var,valueT2E | *_IfLessOrEqual
      IfInString,var,valueT2E | if InStr({1}, {2})
      IfNotInString,var,valueT2E | if !InStr({1}, {2})
      IfExist,fileT2E | if FileExist({1})
      IfNotExist,fileT2E | if !FileExist({1})
      IfWinExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinExist({1}, {2}, {3}, {4})
      IfWinNotExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinExist({1}, {2}, {3}, {4})
      IfWinActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinActive({1}, {2}, {3}, {4})
      IfWinNotActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinActive({1}, {2}, {3}, {4})
      Loop,one,two,three,four | *_Loop
      Menu,MenuName,SubCommand,Value1,Value2,Value3,Value4 | *_Menu
      MsgBox,TextOrOptions,Title,Text,Timeout | *_MsgBox
      SetEnv,var,valueT2E | {1} := {2}
      Sleep,delayCBE2E | Sleep({1})
      Sort,var,optionsT2E | {1} := Sort({1}, {2})
      SplitPath,varCBE2E,filenameV2VR,dirV2VR,extV2VR,name_no_extV2VR,drvV2VR | SplitPath({1}, {2}, {3}, {4}, {5}, {6})
      StringCaseSense,paramT2E | StringCaseSense({1})
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringGetPos,OutputVar,InputVar,SearchTextT2E,SideT2E,OffsetCBE2E | *_StringGetPos
      StringMid,OutputVar,InputVar,StartCharCBE2E,CountCBE2E,L_T2E | *_StringMid
      StringLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, {3})
      StringRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, -1*({3}))
      StringTrimLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, ({3})+1)
      StringTrimRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, -1*({3}))
      StringUpper,OutputVar,InputVar,TT2E| *_StringUpper
      StringLower,OutputVar,InputVar,TT2E| *_StringLower
      StringReplace,OutputVar,InputVar,SearchTxtT2E,ReplTxtT2E,ReplAll | *_StringReplace
      ToolTip,txtT2E,xCBE2E,yCBE2E,whichCBE2E | ToolTip({1}, {2}, {3}, {4})
      WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *_WinGetActiveStats
      WinGetActiveTitle,OutputVar | {1} := WinGetTitle("A")
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
   InCommentBlock := false
   InCont := 0
   Cont_String := 0
   oScriptString := {}
   oScriptString := StrSplit(ScriptString , "`n", "`r")

   Loop
   {
      O_Index++
      if (oScriptString.Length < O_Index){
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
      }
      else
         EOLComment := ""

      Orig_Line_NoComment := Line
      CommandMatch := -1


      ; -------------------------------------------------------------------------------
      ;
      ; first replace any renamed vars/funcs
      ;
      Loop Parse, KeywordsToRename, "`n"
      {
         Part := StrSplit(A_LoopField, "|")
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
         If InStr(LastLine, ':= ""')
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
            Line_With_Quote_After_Paren := RegExReplace(Line, "\)", ")`"",, 1)
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
         ; msgbox("assignment regex`norigLine: " Line "`norig_left=" Equation[1] "`norig_right=" Equation[2] "`nconv_right=" ToStringExpr(Equation[2]))
         Line := RTrim(Equation[1]) . " := " . ToStringExpr(Equation[2])   ; regex above keeps the indentation already
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Traditional-if to Expression-if
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?)", &Equation)
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
         Line := Indentation . format("{1}if {2}({3} {4} {5}){6}"
                                                                 , Equation[1]          ;else
                                                                 , Equation[2]          ;not
                                                                 , RTrim(Equation[3])   ;variable
                                                                 , op                   ;op
                                                                 , ToExp(Equation[5])   ;value
                                                                 , Equation[6] )        ;otb
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var between
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?between ([^{;]*) and ([^{;]*)(\s*{?)", &Equation)
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
            Line := Indentation . format("{1}if {3}({2} >= {4} && {2} <= {5}){6}"
                                                                   , Equation[1]                 ;else
                                                                   , Equation[2]                 ;var
                                                                   , (Equation[3]) ? "!" : ""    ;not
                                                                   , val1                        ;val1
                                                                   , val2                        ;val2
                                                                   , Equation[6] )               ;otb
         }
         else  ; if not numbers or variables, then compare alphabetically with StrCompare()
         {
            ;if ((StrCompare(var, "blue") > 0) && (StrCompare(var, "red") < 0))
            Line := Indentation . format("{1}if {3}((StrCompare({2}, {4}) > 0) && (StrCompare({2}, {5}) < 0)){6}"
                                                                   , Equation[1]                 ;else
                                                                   , Equation[2]                 ;var
                                                                   , (Equation[3]) ? "!" : ""    ;not
                                                                   , val1                        ;val1
                                                                   , val2                        ;val2
                                                                   , Equation[6] )               ;otb
         }
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var is type
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) is (not\s+)?([^{;]*)(\s*{?)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({variable} is {type}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , variable: Equation[2]
         ;                                  , type: ToStringExpr(Equation[4])
         ;                                  , otb: Equation[5] } )
         Line := Indentation . format("{1}if {3}is{4}({2}){5}"
                                                                , Equation[1]                 ;else
                                                                , Equation[2]                 ;var
                                                                , (Equation[3]) ? "!" : ""    ;not
                                                                , StrTitle(Equation[4])       ;type
                                                                , Equation[5] )               ;otb
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
         while (pos := RegExMatch(AllParams, '".*?"', &MatchObj, pos+StrLen(quoted_string_match)))  ; for each quoted string
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
            Loop Parse, AllParams2, ","   ; for each individual param (separate by comma)
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
         Params := SubStr(Line, FirstDelim+2)
         if RegExMatch(Params, "^%\w+%$")       ; if the var is wrapped in %%, then remove them
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
         ; msgbox("Line=" Line "`nFirstDelim=" FirstDelim "`nCommand=" Command "`nParams=" Params)
         ; Now we format the parameters into their v2 equivilents
         Loop Parse, CommandsToConvert, "`n"
         {
            Part := StrSplit(A_LoopField, "|")
            ; msgbox(A_LoopField "`n[" part[1] "]`n[" part[2] "]")
            ListDelim := RegExMatch(Part[1], "[,\s]")
            ListCommand := Trim( SubStr(Part[1], 1, ListDelim-1) )
            If (ListCommand = Command)
            {
               CommandMatch := 1
               same_line_action := false
               ListParams := RTrim( SubStr(Part[1], ListDelim+1) )
               ; if (Command = "FileAppend")
               ;    msgbox("CommandMatch`nListCommand=" ListCommand "`nListParams=" ListParams)
               ListParam := Array()
               Param := Array() ; Parameters in expression form
               Loop Parse, ListParams, ","
                  ListParam.Push(A_LoopField)
               Params := StrReplace(Params, "``,", "ESCAPED_COMMª_PLA¢E_HOLDER")     ; ugly hack
               Loop Parse, Params, ","
               {
                  ; populate array with the params
                  ; only trim preceeding spaces off each param if the param index is within the
                  ; command's number of allowable params. otherwise, dont trim the spaces
                  ; for ex:  `IfEqual, x, h, e, l, l, o`   should be   `if (x = "h, e, l, l, o")`
                  ; see ~10 lines below
                  if (A_Index <= ListParam.Length)
                     Param.Push(LTrim(A_LoopField))   ; trim leading spaces off each param
                  else
                     Param.Push(A_LoopField)
               }
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
                  ; if (Command = "IfEqual")
                  ;    msgbox("Line=" Line "`nIndex=" A_Index)
                  if (A_Index > ListParam.Length)
                  {
                     Param[A_Index] := this_param
                     continue
                  }
                  else if (ListParam[A_Index] ~= "T2E$")           ; 'Text TO Expression'
                  {
                     Param[A_Index] := ToExp(this_param)
                     ; msgbox("text2expression`nthis_param=" this_param "`nconverted=" Param[A_Index])
                  }
                  else if (ListParam[A_Index] ~= "CBE2E$")    ; 'Can Be an Expression TO an Expression'
                  {
                     if (SubStr(this_param, 1, 2) = "% ")            ; if this param expression was forced
                        Param[A_Index] := SubStr(this_param, 3)       ; remove the forcing
                     else
                        Param[A_Index] := RemoveSurroundingPercents(this_param)
                  }
                  else if (ListParam[A_Index] ~= "CBE2T$")    ; 'Can Be an Expression TO literal Text'
                  {
                     if isInteger(this_param)                                               ; if this param is int
                     || (SubStr(this_param, 1, 2) = "% ")                                      ; or the expression was forced
                     || ((SubStr(this_param, 1, 1) = "%") && (SubStr(this_param, -1) = "%"))  ; or var already wrapped in %%s
                        Param[A_Index] := this_param                  ; dont do any conversion
                     else
                        Param[A_Index] := "%" . this_param . "%"    ; wrap in percent signs to evaluate the expr
                  }
                  else if (ListParam[A_Index] ~= "V2VR$")
                  {
                     if (Param[A_Index] != "")
                        Param[A_Index] := "&" . Param[A_Index]
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
                  ;msgbox("FuncName=" FuncName)
                  FuncObj := %FuncName%  ;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
                  If FuncObj is Func
                     Line := Indentation . FuncObj(Param)
               }
               else                               ; else just using the replacement defined at the top
               {
                  ; if (Command = "FileAppend")
                  ; {
                  ;    paramsstr := ""
                  ;    Loop Param.Length
                  ;       paramsstr .= "Param[" A_Index "]: " Param[A_Index] "`n"
                  ;    msgbox("in else`nLine: " Line "`nPart[2]: " Part[2] "`n`nListParam.Length: " ListParam.Length "`nParam.Length: " Param.Length "`n`n" paramsstr)
                  ; }

                  if (same_line_action)
                     Line := Indentation . format(Part[2], Param*) . "," extra_params
                  else
                     Line := Indentation . format(Part[2], Param*)

                  ; msgbox("Line after format:`n`n" Line)
                  ; if empty trailing optional params caused the line to end with extra commas, remove them
                  if SubStr(Line, -1) = ")"
                     Line := RegExReplace(Line, '(?:, "?"?)*\)$', "") . ")"
                  else
                     Line := RegExReplace(Line, "(?:,\s)*$", "")
               }
            }
         }
      }
      
      ; Remove lines we can't use
      If CommandMatch = 0 && !InCommentBlock
         Loop Parse, Remove, "`n", "`r"
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
      ;If !FoundNonComment && !InCommentBlock && A_Index != 1 && FirstChar != ";" && FirstTwo != "*/"
      ;{
         ;Output.Write(Directives . "`r`n")
         ;msgbox, directives
         ;Output .= Directives . "`r`n"
         ;FoundNonComment := true
      ;}
      

      If Skip
      {
         ;msgbox Skipping`n%Line%
         Line := format("; REMOVED: {1}", Line)
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
   static qu := '"'  ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")       ; If text is empty
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox text=%text%

   if InStr(Text, "%")        ; deref   %var% -> var
   {
      ;msgbox %text%
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
         }
         else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }
      If Symbol != "%"
         TOut .= (qu) ; One double quote
   }
   else if isNumber(Text)
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
   static qu := '"'  ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")       ; If text is empty
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox("text=" text)

   if InStr(Text, "%")        ; deref   %var% -> var
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
         }
         else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }

      If Symbol != "%"
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

_Gui(p)
{

   global Orig_Line_NoComment
   global GuiNameDefault := "myGui"
   global GuiList
   ;preliminary version
   DebugWindow("GuiList:" GuiList "`n",Clear:=0)
   GuiLine := Orig_Line_NoComment
   LineResult:=""
   if RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$"){
      ControlLabel:=""
      ControlName:=""
      ControlObject:=""

      if RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")
      {
         GuiNameLine := RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
         GuiLine := RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)   
         GuiNameDefault := GuiNameLine
      }
      else{
         GuiNameLine:= GuiNameDefault
      }
      if (RegExMatch(GuiNameLine, "^\d$")){
         GuiNameLine := "Gui" GuiNameLine
      }
      Var1 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
      Var2 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*)\s*,\s*([^,]*).*", "$2", &RegExCount2)
      Var3 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*).*$", "$3", &RegExCount3)
      Var4 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),([^;]*).*", "$4", &RegExCount4)
      Var1 := Trim(Var1)
      Var2 := Trim(Var2)
      Var3 := Trim(Var3)
      Var4 := Trim(Var4)

      if RegExMatch(Var3, "\bg[\w]*\b"){
         ; Remove the goto option g....
         ControlLabel:= RegExReplace(Var3, "^.*\bg([\w]*)\b.*$", "$1")
         Var3:= RegExReplace(Var3, "^(.*)\bg([\w]*)\b(.*)$", "$1$3")
      }
      else if ((Var2="Button") and RegExCount4){
         ControlLabel:= var2 RegExReplace(Var4, "\s", "")
         DebugWindow("ControlLabel:" ControlLabel "`n")
      }
      if RegExMatch(Var3, "\vg[\w]*\b"){
         ControlName:= RegExReplace(Var3, "^.*\vg([\w]*)\b.*$", "$1")
      }

      if !InStr(GuiList, "|" GuiNameLine "|"){
         GuiList .= GuiNameLine "|"
         LineResult := GuiNameLine " := Gui()`n" Indentation
      }

      if(RegExMatch(Var1, "i)^tab[23]?$")){
         LineResult.= "Tab.UseTab(" Var2 ")`n"

      }
      if(Var1="Show"){
         if (RegExCount3){
            LineResult.= GuiNameLine ".Name := " ToStringExpr(Var3) "`n" Indentation
            Var3:=""
            RegExCount3:=0
         }
      }

      if(RegExMatch(Var2, "i)^tab[23]?$")){
         LineResult.= "Tab := " 
      }
      if(var1 = "Submit"){
         LineResult.= "oSaved := " 
      }

      if(var1 = "Add" and (var2="Button" or ControlLabel!="")){
         ControlObject := "my" var2
         LineResult.= ControlObject " := " 
      }

      LineResult.= GuiNameLine "." 

      if (Var1="Menu"){
         LineResult.=  "MenuBar := " Var2
      }
      else{
         if (RegExCount1){
            if (RegExMatch(Var1, "^\s*[-\+]\w*")){
               LineResult.= "Opt(" ToStringExpr(Var1)
            }
            Else{
               LineResult.= Var1 "("
            }
         }
         if (RegExCount2){
            LineResult.= ToStringExpr(Var2)
         }
         if (RegExCount3){
            LineResult.= ", " ToStringExpr(Var3)
         }
         else if (RegExCount4){
            LineResult.= ", "
         }
         if (RegExCount4){
            if(RegExMatch(Var2, "i)^tab[23]?$") or Var2="ListView"){
               LineResult.= ", [" 
               oVar4 :=""
               Loop Parse Var4, "|", " "
               {
                  oVar4.= oVar4="" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
               }
               LineResult.= oVar4 "]"
            }
            else{
               LineResult.= ", " ToStringExpr(Var4)
            }
         }
         if (RegExCount1){
            LineResult.= ")"
         }

      }

      if(ControlObject!=""){
         LineResult.= "`n" Indentation ControlObject ".OnEvent(`"Click`", " ControlLabel ")"
      }
   }
   DebugWindow("LineResult:" LineResult "`n")
   Out := format("{1}", LineResult)
   return Out   
}

_MsgBox(p)
{
   global O_Index
   global Orig_Line_NoComment
   ; v1
   ; MsgBox, Text (1-parameter method)
   ; MsgBox [, Options, Title, Text, Timeout]
   ; v2
   ; Result := MsgBox(Text, Title, Options)

   DebugWindow("p[1]:" p[1] "`n",Clear:=0)
   if RegExMatch(p[1], "i)^\dx?\d*\s*"){
      DebugWindow("MsgBox long`n",Clear:=0)
      text:=""
      title:=""
      options:=p[1]
      if (p[3]=""){
         ContSection := Convert_GetContSect()
         if (ContSection!=""){
            LastParIndex := p.Length
            text :=  "`"`r`n" RegExReplace(ContSection,"s)^(.*\n\s*\))[^\n]*$", "$1") "`"`r`n"
            Timeout := RegExReplace(ContSection,"s)^.*\n\s*\)\s*,\s*(\d*)\s*$", "$1", &RegExCount)
            ; delete the empty parameter
            if (RegExCount){
               options.= " T" Timeout
            }
            title:= ToExp(p[2])

         }
      }
      else if (isNumber(p[p.Length]) and p.Length>3){
         text := ToExp(RegExReplace(Orig_Line, "i)MsgBox\s*,?[^,]*,[^,]*,(.*),.*?$", "$1"))
         options.= " T" p[p.Length]
         title:= ToExp(p[2])
      }
      else{
         text := ToExp(RegExReplace(Orig_Line_NoComment, "i)MsgBox\s*,?[^,]*,[^,]*,(.*)$", "$1"))
      }

      return format("msgResult := MsgBox({1}, {2}, {3})",  text , title, ToExp(options) )
   }
   else if RegExMatch(p[1], "i)^\s*.*"){
      text := RegExReplace(Orig_Line, "i)MsgBox\s*,?\s*(.*)", "$1")
      if (text=""){
         ContSection := Convert_GetContSect()
         return format( "{1}", "msgResult := MsgBox(`"`r`n" ContSection "`")" )
      }
      return format("msgResult := MsgBox({1})",  ToExp(text) )
   }

}

_Menu(p)
{
   global Orig_Line_NoComment
   static MenuList := "|"
   MenuLine := Orig_Line_NoComment
   LineResult:=""
   menuNameLine := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
   Var2 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*)\s*,\s*([^,]*).*", "$2", &RegExCount2)
   Var3 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*).*$", "$3", &RegExCount3)
   Var4 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),\s*:?([^;,]*).*", "$4", &RegExCount4)
   Var5 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),\s*:?([^;,]*)\s*,\s*([^,]*).*", "$5", &RegExCount5)
   menuNameLine := Trim(menuNameLine)
   Var2 := Trim(Var2)
   Var3 := Trim(Var3)
   Var4 := Trim(Var4)

   if (Var2="Add" and RegExCount3 and !RegExCount4){
      Var4 := Var3
      RegExCount4 := RegExCount3
   }
   if (Var3="Icon"){
      Var3 := "SetIcon"
   }
   if !InStr(menuList, "|" menuNameLine "|"){
      menuList.= menuNameLine "|"

      if (menuNameLine="Tray"){
         LineResult.= menuNameLine ":= A_TrayMenu`n"
      }
      else{
         LineResult.= menuNameLine ":= Menu()`n"
      }
   }

   LineResult.= menuNameLine "." 

   if (RegExCount2){
      LineResult.= Var2 "("
   }
   if (RegExCount3){
      LineResult.= ToStringExpr(Var3)
   }
   else if (RegExCount4){
      LineResult.= ", "
   }
   if (RegExCount4){
      if (Var2="Add"){
         LineResult.= ", " Var4
      }
      else{
         LineResult.= ", " ToStringExpr(Var4)
      }
   }
   if (RegExCount5){
      LineResult.= ", " ToStringExpr(Var5)
   }
   if (RegExCount1){
      LineResult.= ")"
   }
   Out := format("{1}", LineResult)
   return Out  
}

_StringGetPos(p)
{
   ;msgbox, % p.Length "`n" p[1] "`n" p[2] "`n" p[3] "`n" p[4] "`n" p[5]
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format("{1} := InStr({2}, {3}) - 1", p*)

   ; modelled off of:
   ; https://github.com/Lexikos/AutoHotkey_L/blob/9a88309957128d1cc701ca83f1fc5cca06317325/source/script.cpp#L14732
   else
   {
      p[5] := p[5] ? p[5] : 0   ; 5th param is 'Offset' aka starting position. set default value if none specified

      p4FirstChar := SubStr(p[4], 1, 1)
      p4LastChar := SubStr(p[4], -1)
      ; msgbox(p[4] "`np4FirstChar=" p4FirstChar "`np4LastChar=" p4LastChar)
      if (p4FirstChar = "`"") && (p4LastChar = "`"")   ; remove start/end quotes, would be nice if a non-expr was passed in
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
         }
         else
         {
            if isInteger(occurences) && (occurences > 1)
               return format("{1} := InStr({2}, {3},, ({5})+1, " . occurences . ") - 1", p*)
            else
               return format("{1} := InStr({2}, {3},, ({5})+1) - 1", p*)
         }
      }
      else if (p[4] = 1)
      {
         ; in v1 if occurrences param = "R" or "1" conduct search right to left
         ; "1" sounds weird but its in the v1 source, see link above
         return format("{1} := InStr({2}, {3},, -1*(({5})+1)) - 1", p*)
      }
      else
      {
         ; else then a variable was passed (containing the "L#|R#" string),
         ;      or literal text converted to expr, something like:   "L" . A_Index
         ; output something anyway even though it won't work, so that they can see something to fix
         return ";probably incorrect conversion`r`n" . format("{1} := InStr({2}, {3},, ({5})+1, {4}) - 1", p*)
      }
   }
}


_StringMid(p)
{
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


_StringReplace(p)
{
   ; v1
   ; StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
   ; v2
   ; ReplacedStr := StrReplace(Haystack, Needle [, ReplaceText, CaseSense, OutputVarCount, Limit])

   comment := "; StrReplace() is not case sensitive`r`n; check for StringCaseSense in v1 source script`r`n"
   comment .= "; and change the CaseSense param in StrReplace() if necessary`r`n"

   if IsEmpty(p[4]) && IsEmpty(p[5])
      return comment . format("{1} := StrReplace({2}, {3},,,, 1)", p*)
   else if IsEmpty(p[5])
      return comment . format("{1} := StrReplace({2}, {3}, {4},,, 1)", p*)
   else
   {
      p5char1 := SubStr(p[5], 1, 1)
      ; MsgBox(p[5] "`n" p5char1)

      if (p[5] = "UseErrorLevel")    ; UseErrorLevel also implies ReplaceAll
         return comment . format("{1} := StrReplace({2}, {3}, {4},, &ErrorLevel)", p*)
      else if (p5char1 = "1") || (StrUpper(p5char1) = "A")
         ; if the first char of the ReplaceAll param starts with '1' or 'A'
         ; then all of those imply 'replace all'
         ; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
         return comment . format("{1} := StrReplace({2}, {3}, {4})", p*)
   }
}


_IfGreater(p)
{
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) > 0)", p*)
}

_IfGreaterOrEqual(p)
{
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) >= 0)", p*)
}

_IfLess(p)
{
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) < 0)", p*)
}

_IfLessOrEqual(p)
{
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) <= 0)", p*)
}


_Loop(p)
{
   ; msgbox(p[2] "`n" ToExp(p[2]))
   if (p[1] = "Files")
   {
      Line := format("Loop Files, {2}, {3}",, ToExp(p[2]), ToExp(p[3]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "") ; remove trailing ,\s and ,\s""
      return Line
   }
}


_StringLower(p)
{
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrLower({2})", p*)
}

_StringUpper(p)
{
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrUpper({2})", p*)
}

_WinGetActiveStats(p) {
   Out := format("{1} := WinGetTitle(`"A`")", p*) . "`r`n"
   Out .= format("WinGetPos(&{4}, &{5}, &{2}, &{3}, `"A`")", p*)
   return Out   
}


; =============================================================================

Convert_GetContSect(){
	; Go further in the lines to get the next continuation section
	global oScriptString ; array of all the lines
	global O_Index  ; current index of the lines

	result:= ""

	loop {
		O_Index++
		if (oScriptString.Length < O_Index){
			break
		}
		LineContSect := oScriptString[O_Index]
		FirstChar := SubStr(Trim(LineContSect), 1, 1)
		if ((A_index=1) && (FirstChar != "(" or !RegExMatch(LineContSect, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))){
			; no continuation section found
			O_Index--
			return ""
		}
      if ( FirstChar == ")" ){
			result .= LineContSect
         break
		}
		result .= LineContSect "`r`n"
		
	}
	DebugWindow("contsect:" result "`n",Clear:=0)

	return result
}

; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and separate the variables
; Input:
;   String - The string to parse.
; Output:
;   RETURN - array of the parsed commands.
; --------------------------------------------------------------------
V1ParSplit(String){
	; Created by Ahk_user
	; spinn-off from DeathByNukes from https://autohotkey.com/board/topic/35663-functions-to-get-the-original-command-line-and-parse-it/
	
	oResult:= Array() ; Array to store result
	oIndex:=1 ; index of array
	InArray := 0
	InApostrophe := false
	InFunction := 0
	InObject := 0
	InQuotes := false
	
	oString := StrSplit(String)
	oResult.Push("")
	Loop oString.Length
	{
		Char := oString[A_Index]
		if ( !InQuotes && !InObject && !InArray && !InApostrophe && !InFunction){
			if (Char="," && oString[A_Index-1] !="``"){
				oIndex++
				oResult.Push("")
				Continue
			}
		}
		
		if ( Char = "`"" && !InApostrophe){
			InQuotes := !InQuotes
		}
		else if ( Char = "`'" && !InQuotes){
			InApostrophe := !InApostrophe
		}
		else if (!InQuotes && !InApostrophe && (A_Index =1 || oString[A_Index-1] !="``")){
			if ( Char = "{"){
				InObject++
			}
			else if ( Char = "}" && InObject){
				InObject--
			}
			else if ( Char = "[" && !InArray){
				InArray--
			}
			else if ( Char = "]" && InArray){
				InArray++
			}
			else if ( Char = "(" && !InFunction){
				InFunction++
			}
			else if ( Char = ")" && InFunction){
				InFunction--
			}
		}
		oResult[oIndex] := oResult[oIndex] Char
	}
	return oResult
}

; Function to debug
DebugWindow(Text,Clear:=0,LineBreak:=0,Sleep:=0,AutoHide:=0){
	if WinExist("AHK Studio"){
		x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
		x.DebugWindow(Text,Clear,LineBreak,Sleep,AutoHide)
	}
	else{
		OutputDebug Text
	}
	return
}
