#Requires AutoHotKey v2.0
#SingleInstance Force
CoordMode("tooltip", "screen")          ; for debugging msgs

; to do: strsplit (old command)
; requires should change the version :D
global   dbg         := 0
global   gV2Conv     := true            ; for testing separate V1,V2 conversions
global   gFilePath   := ''              ; TEMP, for testing

#Include lib/ClassOrderedMap.ahk
#Include lib/dbg.ahk
#Include Convert/1Commands.ahk
#Include Convert/2Functions.ahk
#Include Convert/3Methods.ahk
#Include Convert/4ArrayMethods.ahk
#Include Convert/5Keywords.ahk
#Include Convert/MaskCode.ahk                   ; 2024-06-26 ADDED AMB (masking support)
#Include Convert/ConvLoopFuncs.ahk              ; 2025-06-12 ADDED AMB (separated loop code)
#Include Convert/Conversion_CLS.ahk             ; 2025-06-12 ADDED AMB (future support of Class version)
#Include Convert/ContSections.ahk               ; 2025-06-22 ADDED AMB (for support dedicated to continuation sections)
#Include Convert/SplitConv/ConvV1_Funcs.ahk     ; 2025-07-01 ADDED AMB (for support of separated conversion)
#Include Convert/SplitConv/ConvV2_Funcs.ahk     ; 2025-07-01 ADDED AMB (for support of separated conversion)
#Include Convert/SplitConv/SharedCode.ahk       ; 2025-07-01 ADDED AMB (code shared for v1 or v2 converssion)
#Include Convert/SplitConv/PseudoHandling.ahk   ; 2025-07-01 ADDED AMB (temp while separating dual conversion)


;################################################################################
Convert(ScriptString)            ; MAIN ENTRY POINT for conversion process
;################################################################################
{
   ; PLEASE DO NOT PLACE ANY OF YOUR CODE IN THIS FUNCTION

   ; Please place any code that must be performed BEFORE _convertLines()...
   ;  ... into the following function
   Before_LineConverts(&ScriptString)

   ; DO NOT PLACE YOUR CODE HERE
   ; perform conversion of main/global portion of script only
   convertedCode := _convertLines(ScriptString)

   ; Please place any code that must be performed AFTER _convertLines()...
   ;  ... into the following function
   After_LineConverts(&convertedCode)

   return convertedCode ; . 'fail for debugging'
}
;################################################################################
Before_LineConverts(&code)
{
   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   ; initialize all global vars here so ALL code has access to them
   setGlobals()

   ; move any labels to their own line (if on same line as opening/closing brace)
   ; this makes them easier to find and deal with
   code := isolateLabels(code)                          ; 2025-06-22 AMB, ADDED

   ; 2024-07-09 AMB, UPDATED - for label renaming support
   ; these must also be declared global here because they are being updated here
   global gAllFuncNames    := getFuncNames(code)        ; comma-delim stringList of all function names
   global gAllV1LabelNames := getV1LabelNames(&code)    ; comma-delim stringList of all orig v1 label names
   ; captures all v1 labels from script...
   ;  ... converts v1 names to v2 compatible...
   ;  ... and places them in gmAllLabelsV1toV2 map for easy access
   global gmAllLabelsV1toV2 := map()
   getScriptLabels(code)

   ; 2024-07-02 AMB, for support of MenuBar detection
   global gMenuBarName     := getMenuBarName(code)      ; name of GUI main menubar

   ; turn masking on/off at top of SetGlobals()
   if (gUseMasking) {
      ; this masking also performs masking for all strings and comments temporarily...
      ; but they are restored prior to exiting this func (behind the scenes)
      Mask_T(&code, 'CSECT2')                           ; global masking of M2 continuation sections (2025-06-22)
      Mask_T(&code, 'FUNC&CLS')                         ; global masking of functions and classes
   }

   return   ; code by reference
}
;################################################################################
After_LineConverts(&code)
{
   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   ; turn masking on/off at top of SetGlobals()
   if (gUseMasking) {
      ; remove masking from classes, functions (returned as v2 converted)
      Mask_R(&code, 'Func&Cls')             ; remove masking from functions and classes
   }

   ; operations that must be performed last
   ; inspect to see whether your code is best placed here or in the following
   FinalizeConvert(&code)                   ; perform all final operations

   Mask_R(&code, 'CSect')                   ; restore remaining cont sects (returned as v2 converted)
   Mask_R(&code, 'C&S')                     ; ensure all comments/strings are restored (just in case)
   return    ; code by reference
}

;################################################################################
setGlobals()
{
; 2024-07-11 AMB, ADDED dedicated function for global declarations
;  ... so that they can be initialized prior to any other code...
;  ... this is being done to fix a bug between global masking and onMessage handling
;  ... and so all code within script has access to these globals prior to _convertLines() call

   global gUseMasking            := 1           ; 2024-06-26 - set to 0 to test without masking applied
   global gMenuBarName           := ""          ; 2024-07-02 - holds the name of the main gui menubar
   global gAllFuncNames          := ""          ; 2024-07-07 - comma-deliminated string holding the names of all functions
   global gmAllLabelsV1toV2      := map()       ; 2024-07-07 - map holding v1 labelNames (key) and their new v2 labelName (value)
   global gAllV1LabelNames       := ""          ; 2024-07-09 - comma-deliminated string holding the names of all v1 labels

   global gaScriptStrsUsed       := Array()     ; Keeps an array of interesting strings used in the script
   global gaWarnings             := Array()     ; Keeps track of global warning to add, see FinalizeConvert()
   global gaList_PseudoArr       := Array()     ; list of strings that should be converted from pseudoArray to Array
   global gaList_MatchObj        := Array()     ; list of strings that should be converted from Match Object V1 to Match Object V2
   global gaList_LblsToFuncO     := Array()     ; array of objects with the properties [label] and [parameters] that should be converted from label to Function
   global gaList_LblsToFuncC     := Array()     ; List of labels that were converted to funcs, automatically added when gaList_LblsToFuncO is pushed to
   global gEarlyLine             := ""          ; portion of line to process, prior to processing, will not include trailing comment
;   global gOScriptStr            := []          ; array of all the lines
   global gOScriptStr            := Object      ; now a ScriptCode class object (for future use)
   global gO_Index               := 0           ; current index of the lines
   global gIndent                := ""
   global gSingleIndent          := ""
   global gGuiNameDefault        := "myGui"
   global gGuiList               := "|"
   global gmGuiVList             := Map()       ; Used to list all variable names defined in a Gui
   global gGuiActiveFont         := ""
   global gGuiControlCount       := 0
   global gMenuList              := "|"
   global gmMenuCBChecks         := map()       ; 2024-06-26 AMB, for fix #131
   global gmGuiFuncCBChecks      := map()       ; same as above for gui funcs
   global gmGuiCtrlType          := map()       ; Create a map to return the type of control
   global gmGuiCtrlObj           := map()       ; Create a map to return the object of a control
   global gUseLastName           := False       ; Keep track of if we use the last set name in gGuiList
   global gmOnMessageMap         := map()       ; Create a map of OnMessage listeners
   global gmVarSetCapacityMap    := map()       ; A list of VarSetCapacity variables, with definition type
   global gmByRefParamMap        := map()       ; Map of FuncNames and ByRef params
   global gNL_Func               := ""          ; _Funcs can use this to add New Previous Line
   global gEOLComment_Func       := ""          ; _Funcs can use this to add comments at EOL
   global gEOLComment_Cont       := []          ; 2025-05-24 fix for #296 - comments for continuation sections
   global gfrePostFuncMatch      := False       ; ... to know their regex matched
   global gfNoSideEffect         := False       ; ... to not change global variables
   global gLVNameDefault         := "LV"
   global gTVNameDefault         := "TV"
   global gSBNameDefault         := "SB"
   global gFuncParams            := ""

   global gAhkCmdsToRemoveV1, gAhkCmdsToRemoveV2, gmAhkCmdsToConvertV1, gmAhkCmdsToConvertV2, gmAhkFuncsToConvert, gmAhkMethsToConvert
         , gmAhkArrMethsToConvert, gmAhkKeywdsToRename, gmAhkLoopRegKeywds
}
;################################################################################
; MAIN CONVERSION LOOP - handles each line separately
_convertLines(ScriptString)
;################################################################################
{
; 2025-06-12 AMB, UPDATED
;   moved most operations to external funcs for modular design (SEE ConvLoopFuncs.ahk)
;   removed finalize parameter and optional step at bottom of function
;   changed gOSriptStr from array to class object - prep for more functionaity later
;   added block-comment masking as a global condition for full ScriptString
;   changed many variable and function names

   Mask_T(&ScriptString, 'BC')      ; 2025-06-12 AMB, mask all block-comments globally

   global gmAltLabel                := GetAltLabelsMap(ScriptString)       ; Create a map of labels who are identical
   global gOrig_ScriptStr           := ScriptString
   global gEarlyLine                := ''
;   global gOScriptStr               := StrSplit(ScriptString, '`n', '`r') ; array for all the lines
   global gOScriptStr               := ScriptCode(ScriptString)            ; now a class object, for future use
   global gO_Index                  := 0                                   ; current index of the lines
   global gIndent                   := ''
   global gSingleIndent             := (RegExMatch(ScriptString, '(^|[\r\n])( +|\t)', &ws)) ? ws[2] : '    ' ; First spaces or single tab found
   global gNL_Func                  := ''                                  ; _Funcs can use this to add New Previous Line
   global gEOLComment_Func          := ''                                  ; _Funcs can use this to add comments at EOL
   global gEOLComment_Cont          := []                                  ; 2025-05-24 Banaanae, ADDED for fix #296
   global gaScriptStrsUsed

   ScriptOutput                     := ''
   gaScriptStrsUsed.ErrorLevel      := InStr(ScriptString, 'ErrorLevel')
   gaScriptStrsUsed.A_GuiControl    := InStr(ScriptString, "A_GuiControl")
   gaScriptStrsUsed.StringCaseSense := InStr(ScriptString, 'StringCaseSense') ; Both command and A_ variable

   ; parse each line of the input script, convert line as required
   Loop {
      gO_Index++

;      if (gOScriptStr.Length < gO_Index) {
      if (!gOScriptStr.HasNext) {
         ; This allows the user to add or remove lines if necessary
         ; Do not forget to change the gO_Index if you want to remove or add the line above or lines below
         break
      }

;      curLine           := gOScriptStr[gO_Index]                    ; current line string to be converted
      curLine           := gOScriptStr.GetNext                      ; current line string to be converted
      gIndent           := RegExReplace(curLine,'^(\h*).*','$1')    ; original line indentation (if present)
      EOLComment        := lp_DirectivesAndComment(&curLine)        ; process character directives and extract initial trailing comment from line
      lineOpen          := lp_SplitLine(&curLine)                   ; see lp_splitLine() for details
      gEarlyLine        := curLine                                  ; portion of line to process [prior to processing], has no trailing comment
      lineClose         := ''                                       ; initial value, used later
      gEOLComment_Cont  := [EOLComment]                             ; 2025-05-24 fix for #296 - support for multiple comments within line continuations

      ; TODO - for v1.0 -> v1.1 conversion idea... will need to separate v1 from v2 processing within most of the following operations
      ;     currently v1.0 -> v1.1 conversion is not possible until the operations are separated
      ;     this will happen in phase 2 of redesign
      ; ORDER MAY MATTER FOR FOLLOWING STEPS...
      addContsToLine(&curLine, &EOLComment)                         ; Adds continuation lines to current line - TODO - USE CONT-MASKING ??
      fixAssignments(&curLine)                                      ; line conversions related to assignments [var= and var:=] (v1/v2)
      v1_convert_Ifs(&curline, &lineOpen)                           ; line conversions related to IF (v1)
      v2_convert_Ifs(&curline, &lineOpen, &lineClose)               ; line conversions related to IF (v2)

      fCmdConverted := false                                        ; will be set by v2_AHKCommand() thru v2_Conversions() below
;      if (gV2Conv) {     ; 2025-07-03 - REMOVED TEMPORARILY        ; v2, but currently required for v1 conversion also
         v2_Conversions(&curLine, &lineOpen, &EOLComment            ; line conversions related to V2 only (currently required for v1 conv also)
                      , &fCmdConverted, scriptString)               ; SETS VALUE of fCmdConverted (indirectly)
;      }

      ; these must come AFTER v2_Conversions()
      lp_DisableInvalidCmds(&curLine, fCmdConverted)                ; disable commands no longer supported (turns them into comments)
      curLine := lineOpen . curLine . lineClose                     ; reassemble line parts
      lp_PostConversions(&curLine)                                  ; processing for current line that must be performed last
      ScriptOutput .= lp_PostLineMsgs(&curLine,&EOLComment)         ; update conversion messages (to user) for current line. This is final line output.
   }  ; END of individual-line conversions (loop)

   ; trim the very last (extra) newline from output string
   ScriptOutput := RegExReplace(ScriptOutput, '\r\n$',,,1)          ; 2025-06-12 MOVED to here to eliminate multiple 'finalize' paths/processing
   Mask_R(&ScriptOutput, 'BC')                                      ; 2025-06-12 AMB, Restore all block-comments
   return ScriptOutput
}
;################################################################################
FinalizeConvert(&code)
;################################################################################
{
; 2024-06-27 AMB, ADDED
; 2025-06-12 AMB, UPDATED
; Performs tasks that finalize overall conversion

   ; Add global warnings
   If gaWarnings.HasProp("AddedV2VRPlaceholder") && gaWarnings.AddedV2VRPlaceholder = 1 {
      code := "; V1toV2: Some mandatory VarRefs replaced with AHKv1v2_vPlaceholder`r`n" code
   }

   ; Convert labels listed in gaList_LblsToFuncO
   Loop gaList_LblsToFuncO.Length {
      if (gaList_LblsToFuncO[A_Index].label) {
         code := ConvertLabel2Func(code, gaList_LblsToFuncO[A_Index].label,    gaList_LblsToFuncO[A_Index].parameters
               , gaList_LblsToFuncO[A_Index].HasOwnProp("NewFunctionName")   ? gaList_LblsToFuncO[A_Index].NewFunctionName : ""
               , gaList_LblsToFuncO[A_Index].HasOwnProp("aRegexReplaceList") ? gaList_LblsToFuncO[A_Index].aRegexReplaceList : "")
         gaList_LblsToFuncC.Push(gaList_LblsToFuncO[A_Index].HasOwnProp("NewFunctionName")   ? gaList_LblsToFuncO[A_Index].NewFunctionName : "")
      }
   }

   ; convert labels for OnClipboardChange
   if (InStr(code, "OnClipboardChange:")) {
      code := "OnClipboardChange(ClipChanged)`r`n" . ConvertLabel2Func(code, "OnClipboardChange", "Type", "ClipChanged"
                                                   , [{NeedleRegEx: "i)^(.*)\b\QA_EventInfo\E\b(.*)$", Replacement: "$1Type$2"}])
   }

   ; Fix MinIndex() and MaxIndex() for arrays
   code := RegExReplace(code, "i)([^(\s]*\.)ϨMaxIndex\(placeholder\)Ϩ", '$1Length != 0 ? $1Length : ""')
   code := RegExReplace(code, "i)([^(\s]*\.)ϨMinIndex\(placeholder\)Ϩ", '$1Length != 0 ? 1 : ""') ; Can be done in 4ArrayMethods.ahk, but done here to add EOLComment

   try code := AddBracket(code)          ; Add Brackets to Hotkeys
   try code := UpdateGoto(code)          ; Update Goto Label when Label is converted to a func
   try code := UpdateGotoFunc(code)      ; Update Goto Label when Label is converted to a func
   try code := FixOnMessage(code)        ; Fix turning off OnMessage when defined after turn off
   try code := FixVarSetCapacity(code)   ; &buf -> buf.Ptr   &vssc -> StrPtr(vssc)
   try code := FixByRefParams(code)      ; Replace ByRef with & in func declarations and calls - see related fixFuncParams()
   try code := RemoveComObjMissing(code) ; Removes ComObjMissing() and variables

   addGuiCBArgs(&code)
   addMenuCBArgs(&code)                 ; 2024-06-26, AMB - Fix #131
   addOnMessageCBArgs(&code)            ; 2024-06-28, AMB - Fix #136

   return   ; code by reference
}
;################################################################################
; Convert a v1 function in a single script line to v2
;    Can be used from inside _Funcs for nested checks (e.g., function in a DllCall)
;    Set gfNoSideEffect to 1 to make some callable _Funcs to not change global vars
; 2025-06-12 AMB, UPDATED - changed func name and some var and funcCall names
V1toV2_Functions(ScriptString, Line, &retV2, &gotFunc) {
   global gFuncParams, gfrePostFuncMatch
   FuncsRemoved := 0 ; Number of functions that have been removed during conversion (e.g Arr.Length() -> Arr.Length)
   loop {
      if !InStr(Line, "(")
         break

      ;MsgBox FuncsRemoved
      oResult := V1ParSplitfunctions(Line, A_Index - FuncsRemoved)

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

      oPar := V1ParamSplit(oResult.Parameters)
      gFuncParams := oResult.Parameters

      ConvertList := gmAhkFuncsToConvert
      if (RegExMatch(oResult.Pre, "((?:\w+)|(?:\[.*\])|(?:{.*}))\.$", &Match)) {
         ObjectName := Match[1]
         if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\[|(Array|StrSplit)\()")) { ; Type Array().
            ConvertList := gmAhkArrMethsToConvert
         } else if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\{|(Object)\()")) { ; Type Object().
            ConvertList := gmAhkMethsToConvert
         } else if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(new\s+|(FileOpen|Func|ObjBindMethod|\w*\.Bind)\()")) { ; Type instance of class.
            ConvertList := [] ; Unspecified conversion patterns.
         } else if (RegExMatch(ScriptString, "i)(?<!\w)class\s(\Q" ObjectName "\E)(?!\w)")) { ; Type Class.
            ConvertList := [] ; Unspecified conversion patterns.
         } else {
            ConvertList := gmAhkMethsToConvert
            Loop gaList_MatchObj.Length {
               if (ObjectName = gaList_MatchObj[A_Index]) {
                  ConvertList := [] ; Conversions handled elsewhere.
                  Break
               }
            }
            Loop gaList_PseudoArr.Length {
               if (ObjectName = gaList_PseudoArr[A_Index].name) {
                  ConvertList := [] ; Conversions handled elsewhere.
                  Break
               }
            }
         }
      }
      StrReplace(Line, "()",,, &v1FuncCount)
      for v1, v2 in ConvertList
      {
         gfrePostFuncMatch := False
         ListDelim := InStr(v1, "(")
         ListFunction := Trim(SubStr(v1, 1, ListDelim - 1))
         rePostFunc := ""

         if (ListFunction = oResult.func) {
            ;MsgBox(ListFunction)
            v1DefParamsArr := SubStr(v1, ListDelim + 1, InStr(v1, ")") - ListDelim - 1)
            rePostFunc := SubStr(v1, InStr(v1,")")+1)
            oListParam := StrSplit(v1DefParamsArr, ",", " ")
            ; Fix for when v1DefParamsArr is empty
            if (v1DefParamsArr = "") {
               oListParam.Push("")
            }
            v1 := trim(v1)
            v2 := trim(v2)
            loop oPar.Length
            {
               if (A_Index > 1 && InStr(oListParam[A_Index - 1], "*")) {
                  oListParam.InSertAt(A_Index, oListParam[A_Index - 1])
               }
               ; Uses a function to format the parameters
               oPar[A_Index] := FormatParam(oListParam[A_Index], oPar[A_Index])
            }
            loop oListParam.Length
            {
               if (!oPar.Has(A_Index)) {
                  oPar.Push("")
               }
            }

            if (SubStr(v2, 1, 1) == "*")   ; if using a special function
            {
               if (rePostFunc != "")
               {
                  ; move post-function's regex match to _Func (it should return back if needed)
                  RegExMatch(oResult.Post, rePostFunc, &gfrePostFuncMatch)
                  oResult.Post := RegExReplace(oResult.Post, rePostFunc)
               }

               FuncName := SubStr(v2, 2)

               FuncObj := %FuncName%   ;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
               if (FuncObj is Func) {
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

            ; TODO: make this count "(" instead, fixes removed funcs with params
            ;       only breaks if script did Arr.Length(MeaninglessVar)
            StrReplace(Line, "()",,, &v2FuncCount)
            FuncsRemoved := Max(0, v1FuncCount - v2FuncCount)

            break ; Function/Method just found and processed.
         }
      }
      ; msgbox("[" oResult.Pre "]`n[" oResult.func "]`n[" oResult.Parameters "]`n[" oResult.Post "]`n[" oResult.Separator "]`n")
      ; Line := oResult.Pre oResult.func "(" oResult.Parameters ")" oResult.Post
   }
}
;################################################################################
; change   "text" -> text
RemoveSurroundingQuotes(text)
{
   if (SubStr(text, 1, 1) = "`"") && (SubStr(text, -1) = "`"")
      return SubStr(text, 2, -1)
   return text
}
;################################################################################
; change   %text% -> text
RemoveSurroundingPercents(text)
{
   if (SubStr(text, 1, 1) = "%") && (SubStr(text, -1) = "%")
      return SubStr(text, 2, -1)
   return text
}
;################################################################################
; check if a param is empty
IsEmpty(param)
{
   if (param = '') || (param = '""')   ; if its an empty string, or a string containing two double quotes
      return true
   return false
}
;################################################################################
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
_Catch(p) {
   if Trim(p[1], '{ `t') = '' {
      if InStr(p[1], '{')
         return 'Catch {'
      return 'Catch'
   } if !InStr(p[1], "Error as") {
      return "Catch Error as " p[1]
   }
   return "Catch " p[1]
}
;################################################################################
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
;################################################################################
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
         Out .= gIndent "loop o" p[1] ".length`r`n"
         Out .= gIndent "{`r`n"
         Out .= gIndent p[1] " .= A_index=1 ? `"`" : `"``n`"`r`n"   ; Attention do not add ``r!!!
         Out .= gIndent p[1] " .= o" p[1] "[A_Index] `r`n"
         Out .= gIndent "}"
      }
   }
   out := RegExReplace(Out, "[\s\,]*\)$", ")")

   Return out
}
;################################################################################
_ControlGetFocus(p) {

   Out := format("{1} := ControlGetClassNN(ControlGetFocus({2}, {3}, {4}, {5}))", p*)
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_CoordMode(p) {
   ; V1: CoordMode,TargetTypeT2E,RelativeToT2E | *_CoordMode
   p[2] := StrReplace(P[2], "Relative", "Window")
   Out := Format("CoordMode({1}, {2})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_Drive(p) {
   if (p[1] = "Label") {
      Out := Format("DriveSetLabel({2}, {3})", p[1], ToExp(p[2]), ToExp(p[3]))
   } else if (p[1] = "Eject") {
      if (p[3] = "0" || p[3] = "") {
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
;################################################################################
_EnvAdd(p) {
   if (!IsEmpty(p[3]))
      return format("{1} := DateAdd({1}, {2}, {3})", p*)
   else
      return format("{1} += {2}", p*)
}
;################################################################################
_EnvSub(p) {
   if (!IsEmpty(p[3]))
      return format("{1} := DateDiff({1}, {2}, {3})", p*)
   else
      return format("{1} -= {2}", p*)
}
;################################################################################
_FileCopyDir(p) {
   global gaScriptStrsUsed
   if (gaScriptStrsUsed.ErrorLevel) {
      Out := format("Try{`r`n"
      . gIndent "   DirCopy({1}, {2}, {3})`r`n"
      . gIndent "   ErrorLevel := 0`r`n"
      . gIndent "} Catch {`r`n"
      . gIndent "   ErrorLevel := 1`r`n"
      . gIndent "}", p*)
   } Else {
      out := format("DirCopy({1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_FileCopy(p) {
   global gaScriptStrsUsed
   ; We could check if Errorlevel is used in the next 20 lines
   if (gaScriptStrsUsed.ErrorLevel) {
      Out := format("Try{`r`n"
      . gIndent "   FileCopy({1}, {2}, {3})`r`n"
      . gIndent "   ErrorLevel := 0`r`n"
      . gIndent "} Catch as Err {`r`n"
      . gIndent "   ErrorLevel := Err.Extra`r`n"
      . gIndent "}", p*)
   } Else {
      out := format("FileCopy({1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_FileMove(p) {
   global gaScriptStrsUsed
   if (gaScriptStrsUsed.ErrorLevel) {
      Out := format("Try{`r`n"
      . gIndent "   FileMove({1}, {2}, {3})`r`n"
      . gIndent "   ErrorLevel := 0`r`n"
      . gIndent "} Catch as Err {`r`n"
      . gIndent "   ErrorLevel := Err.Extra`r`n"
      . gIndent "}", p*)
   } Else {
      out := format("FileMove({1}, {2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_FileRead(p) {
   ; FileRead, OutputVar, Filename
   ; OutputVar := FileRead(Filename , Options)
   if (InStr(p[2], "*")) {
      Options := RegExReplace(p[2], "^\s*(\*.*?)\s[^\*]*$", "$1")
      Filename := RegExReplace(p[2], "^\s*\*.*?\s([^\*]*)$", "$1")
      Options := StrReplace(Options, "*t", "``n")
      Options := StrReplace(Options, "*")
      if (InStr(options, "*P")) {
         OutputDebug("Conversion FileRead has not correct.`n")
      }
      ; To do: add encoding
      Return format("{1} := FileRead({2}, {3})", p[1], ToExp(Filename), ToExp(Options))
   }
   Return format("{1} := FileRead({2})", p[1], ToExp(p[2]))
}
;################################################################################
_FileReadLine(p) {
   global gIndent, gSingleIndent
   ; FileReadLine, OutputVar, Filename, LineNum
   ; Not really a good alternative, inefficient but the result is the same

   if (gaScriptStrsUsed.ErrorLevel) {
   indent := gIndent = "" ? gSingleIndent : gIndent

   cmd := ; Very bulky solution, only way for errorlevel
   (
   gIndent 'try {`r`n'
   gIndent indent 'Global ErrorLevel := 0, ' p[1] ' := StrSplit(FileRead(' p[2] '),`"``n`",`"``r`")[' p[3] ']`r`n'
   gIndent '} Catch {`r`n'
   gIndent indent p[1] ' := "", ErrorLevel := 1`r`n'
   gIndent '}'
   )

   Return cmd
   } else {
      Return p[1] " := StrSplit(FileRead(" p[2] "),`"``n`",`"``r`")[" P[3] "]"
   }
}
;################################################################################
_FileSelect(p) {
   ; V1: FileSelectFile, OutputVar [, Options, RootDir\Filename, Title, Filter]
   ; V2: SelectedFile := FileSelect([Options, RootDir\Filename, Title, Filter])
   global gO_Index
   global gEarlyLine
;   global gOScriptStr   ; array of all the lines
   global gIndent

   oPar := V1ParamSplit(RegExReplace(gEarlyLine, "i)^\s*FileSelectFile\s*[\s,]\s*(.*)$", "$1"))
   OutputVar := oPar[1]
   Options := oPar.Has(2) ? oPar[2] : ""
   RootDirFilename := oPar.Has(3) ? oPar[3] : ""
   Title := oPar.Has(4) ? trim(oPar[4]) : ""
   Filter := oPar.Has(5) ? trim(oPar[5]) : ""

   Parameters := ""
   if (Filter != "") {
      Parameters .= ToExp(Filter)
   }
   if (Title != "" || Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(Title) Parameters
   }
   if (RootDirFilename != "" || Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(RootDirFilename) Parameters
   }
   if (Options != "" || Parameters != "") {
      Parameters := Parameters != "" ? ", " Parameters : ""
      Parameters := ToExp(Options) Parameters
   }

   Line := format("{1} := FileSelect({2})", OutputVar, parameters)
   if (InStr(Options, "M")) {
      Line := format("{1} := FileSelect({2})", "o" OutputVar, parameters) "`r`n"
      Line .= gIndent p[1] " := `"`"`r`n"
      Line .= gIndent "for FileName in o" OutputVar "`r`n"
      Line .= gIndent "{`r`n"
      Line .= gIndent OutputVar " .= A_Index=1 ? RegExReplace(FileName, `"(.+)\\(.*)`", `"$1``r``n$2``r``n`") : RegExReplace(FileName, `".+\\(.*)`", `"$1``r``n`")`r`n"
      Line .= gIndent "}"
   }
   if (gaScriptStrsUsed.ErrorLevel) {
      Line .= "`r`n" gIndent "if (" OutputVar " = `"`") {`r`n"
      Line .= gIndent "ErrorLevel := 1`r`n"
      Line .= gIndent "} else {`r`n"
      Line .= gIndent "ErrorLevel := 0`r`n"
      Line .= gIndent "}"
   }
   return Line
}
;################################################################################
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
;################################################################################
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
;################################################################################
_Gosub(p) {
   ; 2024-07-07 AMB UPDATED - as part of label-to-function naming
   EOLComment := ""
   p[1] := RegExReplace(p[1], "%\s*([^%]+?)\s*$", "%$1%")
   If InStr(p[1], "%")
      EOLComment := " `; V1toV2: Some labels might not have converted to functions"
   v1LabelName  := p[1]
   v2FuncName   := trim(getV2Name(v1LabelName))
   gaList_LblsToFuncO.Push({label: v1LabelName, parameters: "", NewFunctionName: v2FuncName})
   Return v2FuncName . "()" . EOLComment
}
;################################################################################
_Gui(p) {
; 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object

   global gEarlyLine
   global gGuiNameDefault
   global gGuiControlCount
   global gLVNameDefault
   global gTVNameDefault
   global gSBNameDefault
   global gGuiList
   global gOrig_ScriptStr       ; array of all the lines
   global gOScriptStr           ; array of all the lines
   global gAllV1LabelNames      ; all label names (comma delim str)
   global gAllFuncNames         ; all func names (comma delim str)
   global gmGuiFuncCBChecks
   global gO_Index              ; current index of the lines
   global gmGuiVList
   global gGuiActiveFont
   global gmGuiCtrlObj

   static HowGuiCreated := Map()
   ;preliminary version

   SubCommand := RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newGuiName) = 0 ? Trim(p[1]) : newGuiName[1]
   GuiName := RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? "" : newGuiName[1]

   GuiLine := gEarlyLine
   LineResult := ""
   LineSuffix := ""
   if (RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$")) {
      ControlHwnd := ""
      ControlLabel := ""
      ControlName := ""
      ControlObject := ""
      GuiOpt := ""

      if (p[1] = "New" && gGuiList != "") {
         if (!InStr(gGuiList, gGuiNameDefault)) {
            GuiNameLine := gGuiNameDefault
         } else {
            loop {
               if (!InStr(gGuiList, gGuiNameDefault A_Index)) {
                  GuiNameLine := gGuiNameDefault := gGuiNameDefault A_Index
                  break
               }
            }
         }
         HowGuiCreated[GuiNameLine] := "New"
      } else if (RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")) {
         GuiNameLine := RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
         GuiLine := RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)
         if (GuiNameLine = "1") {
            GuiNameLine := "myGui"
         }
         gGuiNameDefault := GuiNameLine
         HowGuiCreated[GuiNameLine] := "Set"
      } else {
         GuiNameLine := gGuiNameDefault
         HowGuiCreated[GuiNameLine] := "Default"
      }
      if (RegExMatch(GuiNameLine, "^\d+$")) {
         GuiNameLine := "oGui" GuiNameLine
      }
      GuiOldName := GuiNameLine = "myGui" ? "" : GuiNameLine
      if (RegExMatch(GuiOldName, "^oGui\d+$"))
         GuiOldName := StrReplace(GuiOldName, "oGui")
      if (GuiOldName != "" and HowGuiCreated[GuiOldName] ~= "New|Default")
         GuiOldName := ""

      Var1 := RegExReplace(p[1], "i)^([^:]*):\s*(.*)$", "$2")
      Var2 := p[2]
      Var3 := p[3]
      Var4 := p[4]

      ; 2024-07-09 AMB, UPDATED needles to support all valid v1 label chars
      ; 2024-09-05 f2g: EDITED - Don't test Var3 for g-label if Var1 = "Show"
      if (RegExMatch(Var3, "i)^.*?\bg([^,\h``]+).*$") && !RegExMatch(Var1, "i)show|margin|font|new")) {
         ; Record and remove gLabel
         ControlLabel := RegExReplace(Var3, "i)^.*?\bg([^,\h``]+).*$", "$1")  ; get glabel name
         Var3 := RegExReplace(Var3, "i)^(.*?)\bg([^,\h``]+)(.*)$", "$1$3")    ; remove glabel
      } else if (Var2 = "Button") {
         ControlLabel := GuiOldName var2 RegExReplace(Var4, "[\s&]", "")
         ; dbgMsgBox(,, ControlLabel, InStr(gAllV1LabelNames, ControlLabel), InStr(gAllFuncNames, ControlLabel))
         if (!InStr(gAllV1LabelNames, ControlLabel) and !InStr(gAllFuncNames, ControlLabel))
            ControlLabel := ""
      }
      if ControlLabel != "" and !InStr(gAllV1LabelNames, ControlLabel) and InStr(gAllFuncNames, ControlLabel)
         gmGuiFuncCBChecks[ControlLabel] := true

      if (RegExMatch(Var3, "i)\bv[\w]+\b") && !(Var1 ~= "i)show|margin|font|new")) {
         ControlName := RegExReplace(Var3, "i)^.*\bv([\w]+)\b.*$", "$1")

         ControlObject := InStr(ControlName, SubStr(Var2, 1, 4)) ? "ogc" ControlName : "ogc" Var2 ControlName
         gmGuiCtrlObj[ControlName] := ControlObject
         if (Var2 != "Pic" && Var2 != "Picture" && Var2 != "Text" && Var2 != "Button" && Var2 != "Link" && Var2 != "Progress"
            && Var2 != "GroupBox" && Var2 != "Statusbar" && Var2 != "ActiveX") {   ; Exclude Controls from the submit (this generates an error)
            if (gmGuiVList.Has(GuiNameLine)) {
               gmGuiVList[GuiNameLine] .= "`r`n" ControlName
            } else {
               gmGuiVList[GuiNameLine] := ControlName
            }
         }
      }
      if (RegExMatch(Var3, "i)(?<=[^\w\n]|^)\+?HWND(\w*?)(?=`"|\s|$)", &match)) {
         ControlHwnd := match[1]
         Var3 := StrReplace(Var3, match[])
         if (ControlObject = "" && Var4 != "") {
            ControlObject := InStr(ControlHwnd, SubStr(Var4, 1, 4)) ? "ogc" StrReplace(ControlHwnd, "hwnd") : "ogc" Var4 StrReplace(ControlHwnd, "hwnd")
            ControlObject := RegExReplace(ControlObject, "\W")
         } else if (ControlObject = "") {
            gGuiControlCount++
            ControlObject := Var2 gGuiControlCount
         }
         gmGuiCtrlObj["%" ControlHwnd "%"] := ControlObject
         gmGuiCtrlObj["% " ControlHwnd] := ControlObject
      } else if (RegExMatch(Var2, "i)(?<=[^\w\n]|^)\+?HWND(.*?)(?:\h|$)", &match))
         && (RegExMatch(Var1, "i)(?<!\w)New")) {
            GuiOpt := Var2
            GuiOpt := StrReplace(GuiOpt, match[])
            LineSuffix .= ", " match[1] " := " GuiNameLine ".Hwnd"
      } else if (RegExMatch(Var1, "i)(?<!\w)New")) {
            GuiOpt := Var2
      }

      if (!InStr(gGuiList, "|" GuiNameLine "|")) {
         gGuiList .= GuiNameLine "|"
         LineResult := GuiNameLine " := Gui(" RegExReplace(ToExp(GuiOpt,1,1), '^""$') ")`r`n" gIndent

         ; Add the events if they are used.
         aEventRename := []
         aEventRename.Push({oldlabel: GuiOldName "GuiClose", event: "Close", parameters: "*", NewFunctionName: GuiOldName "GuiClose"})
         aEventRename.Push({oldlabel: GuiOldName "GuiEscape", event: "Escape", parameters: "*", NewFunctionName: GuiOldName "GuiEscape"})
         aEventRename.Push({oldlabel: GuiOldName "GuiSize"
                           , event: "Size", parameters: "thisGui, MinMax, A_GuiWidth, A_GuiHeight", NewFunctionName: GuiOldName "GuiSize"})
         aEventRename.Push({oldlabel: GuiOldName "GuiConTextMenu", event: "ConTextMenu", parameters: "*", NewFunctionName: GuiOldName "GuiConTextMenu"})
         aEventRename.Push({oldlabel: GuiOldName "GuiDropFiles"
                           , event: "DropFiles", parameters: "thisGui, Ctrl, FileArray, *", NewFunctionName: GuiOldName "GuiDropFiles"})
         Loop aEventRename.Length {
            if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" aEventRename[A_Index].oldlabel ":\s")) {
               if (gmAltLabel.Has(aEventRename[A_Index].oldlabel)) {
                  aEventRename[A_Index].NewFunctionName := gmAltLabel[aEventRename[A_Index].oldlabel]
                  ; Alternative label is available
               } else {
                  gaList_LblsToFuncO.Push({label: aEventRename[A_Index].oldlabel
                     , parameters: aEventRename[A_Index].parameters
                     , NewFunctionName: getV2Name(aEventRename[A_Index].NewFunctionName)})
               }
               LineResult .= GuiNameLine ".OnEvent(`"" aEventRename[A_Index].event "`", " getV2Name(aEventRename[A_Index].NewFunctionName) ")`r`n"
            }
         }
      }

      if (RegExMatch(Var1, "i)^tab[23]?$")) {
         Return LineResult "Tab.UseTab(" Var2 ")"
      }
      if (Var1 = "Show") {
         if (Var3 != "") {
            LineResult .= GuiNameLine ".Title := " ToExp(Var3,1,1) "`r`n" gIndent
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
         if (var2 = "TreeView" && ControlObject != "") {
            gTVNameDefault := ControlObject
         }
         if (var2 = "StatusBar") {
            if (ControlObject = "") {
               ControlObject := gSBNameDefault
            }
            gSBNameDefault := ControlObject
         }
         if (var2 ~= "i)(Button|ListView|TreeView)" || ControlLabel != "" || ControlObject != "") {
            if (ControlObject = "") {
               ControlObject := "ogc" var2 RegExReplace(Var4, "[^\w_]", "")
            }
            LineResult .= ControlObject " := "
            if (var2 = "ListView") {
               gLVNameDefault := ControlObject
            }
            if (var2 = "TreeView") {
               gTVNameDefault := ControlObject
            }
         }
         if (ControlObject != "") {
            gmGuiCtrlType[ControlObject] := var2   ; Create a map containing the type of control
         }
      } else if (var1 = "Color") {
         Return LineResult GuiNameLine ".BackColor := " ToExp(Var2,,1)
      } else if (var1 = "Margin") {
         Return LineResult GuiNameLine ".MarginX := " ToExp(Var2,,1) ", " GuiNameLine ".MarginY := " ToExp(Var3,,1)
      }  else if (var1 = "Font") {
         var1 := "SetFont"
         gGuiActiveFont := ToExp(Var2,,1) ", " ToExp(Var3,,1)
      } else if (Var1 = "Cancel") {
         Var1 := "Hide"
      } else if (var1 = "New") {
         LineResult := Trim(LineResult LineSuffix,"`n")
         GuiName :=  ", " ToExp(Var3,,1)
         LineResult := RegExReplace(LineResult, "(.*)\)(.*)", "$1" (GuiName != ', ""' ? GuiName ')' : ')') "$2")
         return RegExReplace(LineResult, '\r\n,', ',')
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
               While (RegExMatch(Var1, 'i)(?<=[^\w\n]|^)\+HWND(.*?)(?:\s|$)', &match)) {
                  LineSuffix .= ", " match[1] " := " GuiNameLine ".Hwnd"
                  Var1 := StrReplace(Var1, match[])
               }
               LineResult .= "Opt(" ToExp(Var1,,1)
            } Else {
               LineResult .= Var1 "("
            }
         }
         if (Var2 != "") {
            LineResult .= ToExp(Var2,,1)
         }
         if (Var3 != "") {
            LineResult .= ", " ToExp(Var3,,1)
         } else if (Var4 != "") {
            LineResult .= ", "
         }
         if (Var4 != "") {
            if (RegExMatch(Var2, "i)^tab[23]?$") || Var2 = "ListView" || Var2 = "DropDownList" || Var2 = "DDL" || Var2 = "ListBox" || Var2 = "ComboBox") {
               searchIdx := 1
;               while (gOScriptStr.Has(gO_Index + searchIdx) && SubStr(gOScriptStr[gO_Index + searchIdx], 1, 1) ~= "^(\||)$") {
               while (gOScriptStr.Has(gO_Index + searchIdx) && SubStr(gOScriptStr.GetLine(gO_Index + searchIdx), 1, 1) ~= "^(\||)$") {
;                  Var4 .= contStr := gOScriptStr[gO_Index + searchIdx]
                  Var4 .= contStr := gOScriptStr.GetLine(gO_Index + searchIdx)
                  nlCount := (SubStr(contStr, 1, 1) = "|" ? 0 : (IsSet(nlCount) ? nlCount : 0) + 1)
                  searchIdx++
               }
               if searchIdx != 1
                  gO_Index += (searchIdx - 1 - nlCount)
                  gOScriptStr.SetIndex(gO_Index)
               if RegExMatch(Var4, "%(.*)%", &match) {
                  LineResult .= ', StrSplit(' match[1] ', "|")'
                  LineSuffix .= " `; V1toV2: Check that this " Var2 " has the correct choose value"
               } else {
                  ObjectValue := "["
                  ChooseString := ""
                  if (!InStr(Var3, "Choose") && InStr(Var4, "||")) { ; ChooseN takes priority over ||
                     ;################################################################################
                     ; 2024-06-09 andymbody    fix for Gui_pr_137
                     dPipes    := StrSplit(var4, "||")
                     selIndex  := 0
                     for idx, str in dPipes {
                        if (idx=dPipes.length)
                           break
                        RegExReplace(str, "\|",,&curCount)
                        selIndex += curCount+1
                     }
                     LineResult := RegexReplace(LineResult, "`"$", " Choose" selIndex "`"")
                     if (Var3 = "")
                        LineResult .= "`"Choose" selIndex "`""
                     ;################################################################################
                     Var4 := RTrim(StrReplace(Var4, "||", "|"), "|")
                  } else if (InStr(Var3, "Choose")) {
                     Var4 := RegexReplace(Var4, "\|+", "|") ; Replace all pipe groups, this breaks empty choices
                  }
                  Loop Parse Var4, "|", " "
                  {
                     if (RegExMatch(Var2, "i)^tab[23]?$") && A_LoopField = "") {
                        ChooseString := "`" Choose" A_Index - 1 "`""
                        continue
                     }
                     ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,1,1) : ", " ToExp(A_LoopField,1,1)
                  }
                  ObjectValue .= "]"
                  LineResult .= ChooseString ", " ObjectValue
               }
            } else {
               LineResult .= ", " ToExp(Var4,1,1)
            }
         }
         if (Var1 != "") {
            LineResult .= ")"
         } else if (Var1 = "" && LineSuffix != "") {
            LineResult := RegExReplace(LineResult, 'm)^.*\.Opt\(""')
            LineSuffix := LTrim(LineSuffix, ", ")
         }

         if (var1 = "Submit") {
            ; This should be replaced by keeping a list of the v variables of a Gui and declare for each "vName := oSaved.vName"
            if (gmGuiVList.Has(GuiNameLine)) {
               Loop Parse, gmGuiVList[GuiNameLine], "`n", "`r"
               {
                  if (gmGuiVList[GuiNameLine])
                     LineResult .= "`r`n" gIndent A_LoopField " := oSaved." A_LoopField
               }
            }
         }

      }
      if (var1 = "Add" && var2 = "ActiveX" && ControlName != "") {
         ; Fix for ActiveX control, so functions of the ActiveX can be used
         LineResult .= "`r`n" gIndent ControlName " := " ControlObject ".Value"
      }

      if (ControlLabel != "") {
         if (gmAltLabel.Has(ControlLabel)) {
            ControlLabel := gmAltLabel[ControlLabel]
         }
         ControlEvent := "Change"

         if (gmGuiCtrlType.Has(ControlObject) && gmGuiCtrlType[ControlObject] ~= "i)(ListBox|ComboBox|ListView|TreeView)") {
            ControlEvent := "DoubleClick"
         }
         if (gmGuiCtrlType.Has(ControlObject) && gmGuiCtrlType[ControlObject] ~= "i)(Button|Checkbox|Link|Radio|Picture|Statusbar|Text)") {
            ControlEvent := "Click"
         }
         V1GuiControlEvent := ControlEvent = "Change" ? "Normal" : ControlEvent
         V1GuiControlEvent := V1GuiControlEvent = "Click" ? "Normal" : V1GuiControlEvent
         LineResult .= "`r`n" gIndent ControlObject ".OnEvent(`"" ControlEvent "`", " getV2Name(ControlLabel) ".Bind(`"" V1GuiControlEvent "`"))"
         gaList_LblsToFuncO.Push({label: ControlLabel, parameters: 'A_GuiEvent := "", A_GuiControl := "", Info := "", *', NewFunctionName: getV2Name(ControlLabel)})
      }
      if (ControlHwnd != "") {
         LineResult .= ", " ControlHwnd " := " ControlObject ".hwnd"
      }
   }
   DebugWindow("LineResult:" LineResult "`r`n")
   Out := format("{1}", LineResult LineSuffix)
   return Out
}
;################################################################################
_GuiControl(p) {
   global gGuiNameDefault
   global gGuiActiveFont
   SubCommand := RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[1]) : newSubCommand[1]
   GuiName := RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? gGuiNameDefault : newGuiName[1]
   ControlID := Trim(p[2])
   Value := Trim(p[3])
   Out := ""
   ControlObject := gmGuiCtrlObj.Has(ControlID) ? gmGuiCtrlObj[ControlID] : "ogc" ControlID

   Type := gmGuiCtrlType.Has(ControlObject) ? gmGuiCtrlType[ControlObject] : ""

   if (SubCommand = "") {
      if (Type = "Groupbox" || Type = "Button" || Type = "Link") {
         SubCommand := "Text"
      } else if (Type = "Radio" && (Value != "0" || Value != "1" || Value != "-1" || InStr(Value, "%"))) {
         SubCommand := "Text"
      }
   }
   if (SubCommand = "") {
      ; Not perfect, as this should be dependent on the type of control

      if (Type = "ListBox" || Type = "DropDownList" || Type = "ComboBox" || Type = "tab") {
         PreSelected := ""
         if (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" && A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
         }
         Return Out
      }
      if (InStr(Value, "|")) {

         PreSelected := ""
         if (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" && A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
         }
         Return Out
      }
      if (Type = "UpDown" || Type = "Slider" || Type = "Progress") {
         if (SubStr(Value, 1, 1) = "-") {
            return ControlObject ".Value -= " ToExp(Value)
         } else if (SubStr(Value, 1, 1) = "+") {
            return ControlObject ".Value += " ToExp(Value)
         }
         return ControlObject ".Value := " ToExp(Value)
      }
      return ControlObject ".Value := " ToExp(Value)
   } else if (SubCommand = "Text") {
      if (Type = "ListBox" || Type = "DropDownList" || Type = "tab" || Type ~= "i)tab\d") {
         PreSelected := ""
         if (SubStr(Value, 1, 1) = "|") {
            Value := SubStr(Value, 2)
            Out .= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
         }
         ObjectValue := "["
         Loop Parse Value, "|", " "
         {
            if (A_LoopField = "" && A_Index != 1) {
               PreSelected := LoopFieldPrev
               continue
            }
            ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
            LoopFieldPrev := A_LoopField
         }
         ObjectValue .= "]"
         Out .= ControlObject ".Add(" ObjectValue ")"
         if (PreSelected != "") {
            Out .= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
         }
         Return Out
      }
      Return ControlObject ".Text := " ToExp(Value)
   } else if (SubCommand = "Move" || SubCommand = "MoveDraw") {

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
      if (gGuiActiveFont != "") {
         Return ControlObject ".SetFont(" gGuiActiveFont ")"
      } else {
         Return "; V1toV2: Use " ControlObject ".SetFont(Options, FontName)"
      }
   } else if (RegExMatch(SubCommand, "^[+-].*")) {
      Return ControlObject ".Opt(" ToExp(SubCommand) ")"
   } else { ; Passed as variable, just output something that won't work
      if RegExMatch(SubCommand, "[+-].*")
         Return ControlObject ".Opt(" ToExp(SubCommand) ")"
      Return ControlObject ".%" ToExp(SubCommand) "%() `; V1toV2: SubCommand passed as variable, check variable contents and docs"
   }

   Return
}
;################################################################################
_GuiControlGet(p) {
   ; GuiControlGet, OutputVar , SubCommand, ControlID, Value
   global gGuiNameDefault
   OutputVar    := Trim(p[1])
   SubCommand   := RegExMatch(p[2], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[2]) : newSubCommand[1]
   GuiName      := RegExMatch(p[2], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? gGuiNameDefault : newGuiName[1]
   ControlID    := Trim(p[3])
   Value        := Trim(p[4])
   if (ControlID = "") {
      ControlID := OutputVar
   }

   Out := ""
   ControlObject := gmGuiCtrlObj.Has(ControlID) ? gmGuiCtrlObj[ControlID] : "ogc" ControlID
   Type := gmGuiCtrlType.Has(ControlObject) ? gmGuiCtrlType[ControlObject] : ""
   ;MsgBox("OutputVar: [" OutputVar "]`nControlObject: [" ControlObject "]`nmGuiCType[ControlObject]: [" gmGuiCtrlType[ControlObject] "]`nType: [" Type "]")

   if (SubCommand = "") {
      if (Value = "text" || Type = "ListBox") {
         ;MsgBox("Value: [" Value "]`nType: [" Type "]")
         Out := OutputVar " := " ControlObject ".Text"
      } else {
         Out := OutputVar " := " ControlObject ".Value"
      }
   } else if (SubCommand = "Pos") {
      Out := ControlObject ".GetPos(&" OutputVar "X, &" OutputVar "Y, &" OutputVar "W, &" OutputVar "H)"
   } else if (SubCommand = "Focus") {
      ; not correct
      Out := "; " OutputVar " := ControlGetFocus() `; V1toV2: Not really the same, this returns the HWND..."
   } else if (SubCommand = "FocusV") {
      ; not correct MyGui.FocusedCtrl
      Out := "; " OutputVar " := " GuiName ".FocusedCtrl `; V1toV2: Not really the same, this returns the focused gui control object..."
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
;################################################################################
_Hotkey(p) {
   LineSuffix := ""

   ;Convert label to function

   if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" p[2] ":(?!=)\s")) {
      gaList_LblsToFuncO.Push({label: p[2], parameters: "ThisHotkey"})
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
      if (P[2] = "on" || P[2] = "off" || P[2] = "Toggle" || P[2] ~= "^AltTab" || P[2] ~= "^ShiftAltTab") {
         p[2] := p[2] = "" ? "" : ToExp(p[2])
      }
      if InStr(p[3], "UseErrorLevel") {
         p[3] := Trim(StrReplace(p[3], "UseErrorLevel"))
         LineSuffix := " `; V1toV2: Removed UseErrorLevel"
      }
      p[3] := p[3] = "" ? "" : ToExp(p[3])
      Out := Format("Hotkey({1}, {2}, {3})", p*)
   }
   Out := RegExReplace(Out, "\s*`"`"\s*\)$", ")")
   Return RegExReplace(Out, "[\s\,]*\)$", ")") LineSuffix
}
;################################################################################
_Input(p) {
   Out := format("ih{1} := InputHook({2},{3},{4}), ih{1}.Start(), " (gaScriptStrsUsed.ErrorLevel ? "ErrorLevel := " : "") "ih{1}.Wait(), {1} := ih{1}.Input", p*)
   Return out := RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_InputBox(oPar) {
   ; V1: InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default]
   ; V2: Obj := InputBox(Prompt, Title, Options, Default)
   global gO_Index
   global gaScriptStrsUsed

;   global gOScriptStr   ; array of all the lines
   options := ""

   OutputVar    := oPar[1]
   Title        := oPar.Has(2) ? oPar[2] : ""
   Prompt       := oPar.Has(3) ? oPar[3] : ""
   Hide         := oPar.Has(4) ? trim(oPar[4]) : ""
   Width        := oPar.Has(5) ? trim(oPar[5]) : ""
   Height       := oPar.Has(6) ? trim(oPar[6]) : ""
   X            := oPar.Has(7) ? trim(oPar[7]) : ""
   Y            := oPar.Has(8) ? trim(oPar[8]) : ""
   Locale       := oPar.Has(9) ? trim(oPar[9]) : ""
   Timeout      := oPar.Has(10) ? trim(oPar[10]) : ""
   Default      := (oPar.Has(11) && oPar[11] != "") ? ToExp(trim(oPar[11])) : ""

   Parameters   := ToExp(Prompt)
   Title        := ToExp(Title)
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
   if (gaScriptStrsUsed.ErrorLevel) {
      Out .= ', ErrorLevel := IB.Result="OK" ? 0 : IB.Result="CANCEL" ? 1 : IB.Result="Timeout" ? 2 : "ERROR"'
   }

   Return Out
}
;################################################################################
_KeyWait(p) {
   ; Errorlevel is not set in V2
   if (gaScriptStrsUsed.ErrorLevel) {
      out := Format("ErrorLevel := !KeyWait({1}, {2})", p*)
   } else {
      out := Format("KeyWait({1}, {2})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_Loop(p) {

   line := ""
   BracketEnd := ""
   if (RegExMatch(p[1], "(^.*?)(\s*{.*$)", &Match)) {
      p[1] := Match[1]
      BracketEnd := Match[2]
   }
   else if (RegExMatch(p[2], "(^.*?)(\s*{.*$)", &Match)) {
   p[2] := Match[1]
   BracketEnd := Match[2]
   }
   else if (RegExMatch(p[3], "(^.*?)(\s*{.*$)", &Match)) {
      p[3] := Match[1]
      BracketEnd := Match[2]
   }
   if (InStr(p[1], "*") && InStr(p[1], "\")) {   ; Automatically switching to Files loop
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

   if (p[1] ~= "i)^(HKEY|HKLM|HKU|HKCR|HKCC|HKCU).*") {
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
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")   ; remove trailing ,\s and ,\s""
      return Line BracketEnd
   }

   if (p[1] = "Parse") {
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
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")   ; remove trailing ,\s and ,\s""
      return Line BracketEnd
   } else if (p[1] = "Files")
   {

      Line := format("Loop {1}, {2}, {3}", "Files", ToExp(p[2]), ToExp(p[3]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")   ; remove trailing ,\s and ,\s""
      return Line
   } else if (p[1] = "Read")
   {
      Line := p.Has(3) ? Trim(ToExp(p[3])) : ""
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(2) ? Trim(ToExp(p[2])) Line : "" Line
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(1) ? Trim(p[1]) Line : "" Line
      Line := "Loop " Line
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")   ; remove trailing ,\s and ,\s""
      return Line BracketEnd
   } else {

      Line := p[1] != "" ? "Loop " Trim(ToExp(p[1])) : "Loop"
      return Line BracketEnd
   }
   ; Else no changes need to be made

}
;################################################################################
_MsgBox(p) {
; 2025-07-03 AMB, CHANGED for dual conversion support
   return (gV2Conv) ? _MsgBox_V2(p) : _MsgBox_V1(p)
}
;################################################################################
_MsgBox_V1(p)
{
; 2025-07-03 AMB, ADDED for v1.1 conversion (WORK IN PROGRESS)
;   TODO - may merge with _MsgBox_V2() when done
; v1
; MsgBox, Text (1-parameter method)
; MsgBox [, Options, Title, Text, Timeout]

   if (RegExMatch(p[1], 'i)^((0x)?\d*\h*|\h*%\h*\w+%?\h*)$') && (p.Extra.OrigArr.Length > 1)) {

      options   := p[1]
      title     := ToExp(p[2])

      ; if param 4 is empty, OR is a number, OR has a var (%)
      if ( p.Length = 4 && (    IsEmpty(   p[4])
                           ||   IsNumber(  p[4])
                           ||   RegExMatch(p[4], '\h*%', &mVar)) ) {
         text   := (csStr := CSect.HasContSect(p[3])) ? csStr : ToExp(p[3])
         TmOut  := (IsEmpty(p[4])) ? '' : ToExp(p[4])  ; add timeout as needed
      }
      else {

         text       := ''
         loop p.Extra.OrigArr.Length - 2
            text    .= ',' p.Extra.OrigArr[A_Index + 2]
         text       := ToExp(SubStr(text, 2))
      }

      ; format output
      Out := format('MsgBox {1}, {2}, {3}', ToExp(options), (title = '""' ? '' : title), text)
      Out .= (TmOut) ? ', ' TmOut : ''
;      if (Check_IfMsgBox()) {
;         Out := 'msgResult := ' Out
;      }
      return Out
   }
   else {   ; only has 1 param - could be text, var, func call, or combo of these

      ; 2024-08-03 AMB, ADDED support for multiline text that may include variables
      if (csStr := CSect.HasContSect(p[1])) {  ; if has continuation section, converts it
         return 'MsgBox %' csStr
      }

      ; does not have continuation section
      param := p.Extra.OrigStr
      param := (param='') ? '""' : RegExReplace(ToExp(param), '^%\h+')
      Out   := format('MsgBox % {1}', param)
;      if (Check_IfMsgBox()) {
;         Out := 'msgResult := ' Out
;      }
      return Out
   }
}
;################################################################################
_MsgBox_V2(p)
{
; 2025-07-03 AMB, ADDED/UPDATED for dual conversion support (WORK IN PROGRESS)
;   TODO - may merge with _MsgBox_V1() when done
; v1
; MsgBox, Text (1-parameter method)
; MsgBox [, Options, Title, Text, Timeout]
; v2
; Result := MsgBox(Text, Title, Options)

   if (RegExMatch(p[1], 'i)^((0x)?\d*\h*|\h*%\h*\w+%?\h*)$') && (p.Extra.OrigArr.Length > 1)) {

      options   := p[1]
      title     := ToExp(p[2])

      ; if param 4 is empty, OR is a number, OR has a var (%)
      if ( p.Length = 4 && (    IsEmpty(   p[4])
                           ||   IsNumber(  p[4])
                           ||   RegExMatch(p[4], '\h*%', &mVar)) ) {
         text       := (csStr := CSect.HasContSect(p[3])) ? csStr : ToExp(p[3])
         options    .= (IsEmpty(p[4])) ? '' : ' " T" ' ToExp(p[4])  ; add timeout as needed
      }
      else {

         text       := ''
         loop p.Extra.OrigArr.Length - 2
            text    .= ',' p.Extra.OrigArr[A_Index + 2]
         text       := ToExp(SubStr(text, 2))
      }

      ; format output
      Out := format('MsgBox({1}, {2}, {3})', text, (title = '""' ? '' : title), ToExp(options))
      if (Check_IfMsgBox()) {
         Out := 'msgResult := ' Out
      }

      ; clean up options param
      if IsSet(mVar) {  ; If timeout is variable
         Out := RegExReplace(Out, '``" T``" (\w+)"\)', '" T" $1)')
      }
      Out := RegExReplace(Out, '``" T``" ', 'T')
      Out := RegExReplace(Out, '" " T', '" T')
      Out := RegExReplace(Out, '(,\h*"[^,]*?)\h*"([^,]*"[^,]*?\))$', '$1$2')

      return Out
   }
   else {   ; only has 1 param - could be text, var, func call, or combo of these

      ; 2024-08-03 AMB, ADDED support for multiline text that may include variables
      if (csStr := CSect.HasContSect(p[1])) {  ; if has continuation section, converts it
         return 'MsgBox(' csStr ')'
      }

      ; does not have continuation section
      param := p.Extra.OrigStr
      Out   := format('MsgBox({1})', ((param='') ? '' : ToExp(param)))
      if (Check_IfMsgBox()) {
         Out := 'msgResult := ' Out
      }
      return Out
   }
}
;################################################################################
_Menu(p) {
   global gEarlyLine
   global gMenuList
   global gIndent
   MenuLine := gEarlyLine
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
      ix)                       #
      ^\s*Menu \s*[,\s]\s*      #
      ([^,] *)     ,   \s*      # arg1 Tray {group $1}
      ([^,] *) \s* ,   \s*      # arg2 Add  {group $2}
      ([^,(]*  \(?              # % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
         (?(?<=\()[^)]*\))      #   nested function conditional
         [^,]*)    ,?  \s* :?   #   group $3 end}
      ([^;,(]*  \(?             # % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
         (?(?<=\()[^)]*\))      #   nested function conditional
         [^,]*)                 #   group $4 end}
       .*$                      #
      )"
      , "$4", &RegExCount4) ; =% func_arg4(nested_arg4a, nested_arg4b)
   Var5 := RegExReplace(MenuLine, "
      (
      ix)                       #
      ^\s*Menu \s*[,\s]\s*      #
      ([^,] *)     ,   \s*      # arg1 Tray {group $1}
      ([^,] *) \s* ,   \s*      # arg2 Add  {group $2}
      ([^,(]*  \(?              # % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
         (?(?<=\()[^)]*\))      #   nested function conditional
         [^,]*)    ,?  \s* :?   #   group $3 end}
      ([^;,(]*  \(?             # % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
         (?(?<=\()[^)]*\))      #   nested function conditional
         [^,]*)\s* ,?  \s*      #   group $4 end}
      ([^;,(]*  \(?             # % func_arg5(nested_arg5a, nested_arg5b) {group $5 start
         (?(?<=\()[^)]*\))      #   nested function conditional
         [^,] *)                #    group $5 end}
      .*$                       #
      )"
      , "$5", &RegExCount5) ; =% func_arg5(nested_arg5a, nested_arg5b)

   menuNameLine := Trim(menuNameLine)

   If (Var2 = "UseErrorLevel")
      return Format("; V1toV2: Removed {2} from Menu {1}", menuNameLine, Var2)

   ; 2024-06-08 andymbody   fix #179
   ; if systray root menu
   ; (menuNameLine "->" var3) should be a unique root->child id tag (hopefully)
   ;    this should distinguish between 'systray-root-menu' and 'child-menuItem/submenu'
   if (menuNameLine="Tray" && !InStr(gMenuList, "|" menuNameLine "->" var3 "|"))
   {
      ; should be dealing with the root-menu (not a child menu item)
      if (Var2 = "Tip") {           ; set tooltip for script sysTray root-menu
         Return LineResult .= "A_IconTip := " ToExp(Var3,,1)
      } else if (Var2 = "Icon") {   ; set icon for script systray root-menu
         LineResult .= "TraySetIcon(" ToExp(Var3,,1)
         LineResult .= Var4 ? "," ToExp(Var4,,1) : ""
         LineResult .= Var5 ? "," ToExp(Var5,,1) : ""
         LineResult .= ")"
         Return LineResult
      }
   }

   ; should be child menu item (not main systray-root-menu)
   if (!InStr(gMenuList, "|" menuNameLine "|"))
   {
      if (menuNameLine = "Tray") {
         LineResult .= menuNameLine ":= A_TrayMenu`r`n" gIndent     ; initialize/declare systray object (only once)
      } else {
         ; 2024-07-02, CHANGED, AMB - to support MenuBar detection and initialization
         global gMenuBarName     ; was set prior to any conversion taking place, see Before_LineConverts() and getMenuBarName()
         lineResult     .= (menuNameLine . " := Menu") . ((menuNameLine=gMenuBarName) ? "Bar" : "") . ("()`r`n" . gIndent)
         ; adj to flag that initialization has been completed (name will no longer match)
         ; not setting to "" just in case verifification of a menubar's existence is desired elsewhere
         gMenuBarName   .= (menuNameLine=gMenuBarName) ? "_iniDone" : ""
      }
      gMenuList .= menuNameLine "|"                                      ; keep track of sub-menu roots
   }

   LineResult .= menuNameLine "."

   Var2 := Trim(Var2)
   Var3 := Trim(Var3)
   Var4 := Trim(Var4)
   DebugWindow(gMenuList "`r`n")
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
   }
   if (Var2 = "DeleteAll") {
      return LineResult "Delete()"
   }
   if (Var2 = "Icon") {
      Var2 := "SetIcon"     ; child menuItem
   }
   if (Var2 = "Color") {
      Var2 := "SetColor"
   }
   if (Var2 = "Add" && RegExCount3 && !RegExCount4) {
      gMenuList .= menuNameLine "->" var3 "|"         ; 2024-06-08 ADDED for fix #179 (unique parent->child id tag)
      Var4 := Var3
      RegExCount4 := RegExCount3
   }

   if (RegExCount2) {
      LineResult .= Var2 "("
   }
   if (RegExCount3) {
      LineResult .= ToExp(Var3,,1)
   } else if (RegExCount4) {
      LineResult .= ", "
   }
   if (RegExCount4) {
      if (Var2 = "Add") {
         if (Var4 = "")
            Var4 := Var3
         gMenuList .= menuNameLine "->" var3 "|"        ; 2024-06-08 ADDED for fix #179 (unique parent->child id tag)
         FunctionName := RegExReplace(Var4, "&", "")    ; Removes & from labels
         if (gmAltLabel.Has(FunctionName)) {
            FunctionName := gmAltLabel[FunctionName]
         } else if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" Var4 ":\s")) {
            gaList_LblsToFuncO.Push({label: Var4, parameters: 'A_ThisMenuItem := "", A_ThisMenuItemPos := "", MyMenu := "", *', NewFunctionName: FunctionName})
         }
         if (Var4 != "") {
            ; 2024-06-26 ADDED by AMB for fix #131
            ; add CB func name to list - if the func exists, will add params (during final steps of conversion)
            global gmMenuCBChecks
            gmMenuCBChecks[Var4] := true
            LineResult .= ", " FunctionName
         }
      } else if (Var2 = "SetColor") {
         if (Var4 = "Single") {
            LineResult .= ", 0"
         }
      } else {
         if (Var4 != "") {
            LineResult .= ", " ToExp(Var4,,1)
         }
      }
   }
   if (RegExCount5) {
      if (Var2 = "Insert") {
         LineResult .= ", " Var5
      } else if (Var5 != "") {
         LineResult .= ", " ToExp(Var5,,1)
      } else if (Var5 = "" && p[6] != "") {
         LineResult .= ",, "
      }
   }

   if (p[6] != "") {
      if (Var5 != "") {
         LineResult .= ", "
      }
      LineResult .= p[6]
   }

   if (RegExCount1) {
      LineResult .= ")"
   }

   return LineResult
}
;################################################################################
_Pause(p) {
   ;V1 : Pause , OnOffToggle, OperateOnUnderlyingThread
   ; TODO handle OperateOnUnderlyingThread
   if (p[1]="") {
      p[1]=-1
   }
   Return Format("Pause({1})", p*)
}
;################################################################################
_PixelGetColor(p) {
   Out := p[1] " := PixelGetColor(" p[2] ", " p[3]
   if (p[4] != "") {
      mode := StrReplace(p[4], "RGB") ; We remove RGB because it is no longer used, while it doesn't error now it might error in the future
      if (Trim(Trim(mode, '"')) = "")
         Return Out ")"
      Return Out ", " Trim(mode) ")"
   } else {
      Return Out ") `; V1toV2: Now returns RGB instead of BGR"
   }
}
;################################################################################
_PixelSearch(p) {
   if (!InStr(p[9], "RGB")) {
      msg := " `; V1toV2: Converted colour to RGB format"
      FixedColour := RegExReplace(p[7], "i)0x(..)(..)(..)", "0x$3$2$1")
   } else msg := "", FixedColour := p[7]
   param8 := ""
   Out := Format("ErrorLevel := !PixelSearch({2}, {3}, {4}, {5}, {6}, {7}, {1}", FixedColour, p*)
   if (p[8] != "")
      param8 := ", " p[8]
   Return Out param8 ")" msg
}
;################################################################################
_Process(p) {
   ; V1: Process,SubCommand,PIDOrName,Value

   if (p[1] = "Priority") {
      if (gaScriptStrsUsed.ErrorLevel) {
         Out := Format("ErrorLevel := ProcessSetPriority({3}, {2})", p*)
      } else {
         Out := Format("ProcessSetPriority({3}, {2})", p*)
      }
   } else {
      if (gaScriptStrsUsed.ErrorLevel) {
         Out := Format("ErrorLevel := Process{1}({2}, {3})", p*)
      } else {
         Out := Format("Process{1}({2}, {3})", p*)
      }
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_SendMessage(p) {
   if (p[3] ~= "^&.*") {
     p[3] := SubStr(p[3],2)
     Out := format('if (type(' . p[3] . ')="Buffer") { `; V1toV2: If statement may be removed depending on type parameter`n`r'
         . gIndent . ' ErrorLevel := SendMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})', p*)
     Out := RegExReplace(Out, "[\s\,]*\)$", ")")
     Out .= format('`n`r' . gIndent . '} else{`n`r'
         . gIndent . ' ErrorLevel := SendMessage({1}, {2}, StrPtr({3}), {4}, {5}, {6}, {7}, {8}, {9})', p*)
     Out := RegExReplace(Out, "[\s\,]*\)$", ")")
     Out .= '`n`r' . gIndent . "}"
     return Out
   }
   if (p[3] ~= "^`".*") {
     p[3] := 'StrPtr(' . p[3] . ')'
   }

   Out := format("ErrorLevel := SendMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
 }
;################################################################################
_SetTimer(p) {
   if (p[2] = "Off") {
      Out := format("SetTimer({1},0)", p*)
   } else if (p[2] = 0) {
      Out := format("SetTimer({1},1)", p*) ; Change to 1, because 0 deletes timer instead of no delay
   } else {
      Out := format("SetTimer({1},{2},{3})", p*)
   }
   gaList_LblsToFuncO.Push({label: p[1], parameters: ""})

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_SendRaw(p) {
   p[1] := FormatParam("keysT2E","{Raw}" p[1])
   Return "Send(" p[1] ")"
}
;################################################################################
_Sort(p) {
   SortFunction := ""
   if (RegexMatch(p[2],"i)^(.*)\bF\s([a-z_][a-z_0-9]*)(.*)$",&Match)) {
      SortFunction := Match[2]
      p[2] := Match[1] Match[3]
      ; TODO Adding * to 3th parameter of sortfunction
   }
   p[2] := p[2]="`"`""? "" : p[2]
   Out := format("{1} := Sort({1}, {2}, " SortFunction ")", p*)

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_SoundGet(p) {
   ; SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E
   OutputVar := p[1]
   ComponentType := p[2]
   ControlType := p[3]
   DeviceNumber := p[4]
   if (ComponentType = "" && ControlType = "Mute") {
      out := Format("{1} := SoundGetMute({2}, {4})", p*)
   } else if (ComponentType = "Volume" || ComponentType = "Vol" || ComponentType = "") {
      out := Format("{1} := SoundGetVolume({2}, {4})", p*)
   } else if (ComponentType = "mute") {
      out := Format("{1} := SoundGetMute({2}, {4})", p*)
   } else {
      out := Format("; V1toV2: Not currently supported -> CV2 {1} := SoundGet{3}({2}, {4})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
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
      out := Format("; V1toV2: Not currently supported -> CV2 Soundset{3}({1}, {2}, {4})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_Random(p) {
   ; v1: Random, OutputVar, Min, Max
   if (p[1] = "") {
      Return "; V1toV2: Removed Random reseed"
   }
   Out := format("{1} := Random({2}, {3})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_RegRead(p) {
   ; Possible an error if old syntax is used without 5th parameter
   if (p[4] != "" || (InStr(p[3], "\") && !InStr(p[2], "\"))) {
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
;################################################################################
_RegWrite(p) {
   ; Possible an error if old syntax is used without 5th parameter
   if (p[5] != "" || (!InStr(p[2], "\") && InStr(p[3], "\"))) {
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
;################################################################################
_RegDelete(p) {
   ; Possible an error if old syntax is used without 3th parameter
   if (p[1] != "" && (p[3] != "" || (!InStr(p[1], "\") && InStr(p[2], "\")))) {
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
;################################################################################
_Run(p) {
   if (InStr(p[3], "UseErrorLevel")) {
      p[3] := RegExReplace(p[3], "i)(.*?)\s*\bUseErrorLevel\b(.*)", "$1$2")
      Out := format("{   ErrorLevel := `"ERROR`"`r`n" gIndent "   Try ErrorLevel := Run({1}, {2}, {3}, {4})`r`n" gIndent "}", p*)
   } else {
      Out := format("Run({1}, {2}, {3}, {4})", p*)
   }

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_StringCaseSense(p) {
   if p[1] = "Locale"    ; In conversions locale is treated as off
      p[1] := '"Locale"' ; this is just for is script checks in expressions, (and no unset var warnings)
   return "A_StringCaseSense := " p[1]
}
;################################################################################
_StringLower(p) {
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrLower({2})", p*)
}
;################################################################################
_StringUpper(p) {
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrUpper({2})", p*)
}
;################################################################################
_SuspendV2(p) {
   ;V1 Suspend , Mode

   p[1] := p[1]="toggle" ? -1 : p[1]
   if (p[1]="Permit") {
      Return "#SuspendExempt"
   }
   Out := "Suspend(" Trim(p[1]) ")"
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
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
;################################################################################
_WinGetActiveStats(p) {
   Out := format("{1} := WinGetTitle(`"A`")", p*) . "`r`n"
   Out .= format("WinGetPos(&{4}, &{5}, &{2}, &{3}, `"A`")", p*)
   return Out
}
;################################################################################
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
      p[1] := FormatParam("XCBE2E", p[1])
      p[2] := FormatParam("YCBE2E", p[2])
      Out := Format("WinMove({1}, {2})", p*)
   } else {
      ; Parameters over p[2] come already formated before reaching here.
      p[1] := FormatParam("WinTitleT2E", p[1])
      p[2] := FormatParam("WinTextT2E", p[2])
      Out := Format("WinMove({3}, {4}, {5}, {6}, {1}, {2}, {7}, {8})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_WinSet(p) {

   if (p[1] = "AlwaysOnTop" or p[1] = "TopMost") {
      p[1] := "AlwaysOnTop" ; Convert TopMost
      Switch p[2], False {
         Case '"on"':     p[2] := 1
         Case '"off"':    p[2] := 0
         Case '"toggle"': p[2] := -1
         Case '':         p[2] := -1
      }
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
;################################################################################
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
;################################################################################
_WinWait(p) {
   ; Created because else there where empty parameters.
   if (gaScriptStrsUsed.ErrorLevel) {
      out := Format("ErrorLevel := !WinWait({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWait({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ; remove trailing empty params
}
;################################################################################
_WinWaitActive(p) {
   ; Created because else there where empty parameters.
   if (gaScriptStrsUsed.ErrorLevel) {
      out := Format("ErrorLevel := !WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ; remove trailing empty params
}
;################################################################################
_WinWaitNotActive(p) {
   ; Created because else there where empty parameters.
   if (gaScriptStrsUsed.ErrorLevel) {
      out := Format("ErrorLevel := !WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ; remove trailing empty params
}
;################################################################################
_WinWaitClose(p) {
   ; Created because else there where empty parameters.
   if (gaScriptStrsUsed.ErrorLevel) {
      out := Format("ErrorLevel := !WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
   } else {
      out := Format("WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
   }
   Return RegExReplace(out, "[\s\,]*\)$", ")") ; remove trailing empty params
}
;################################################################################
_HashtagIfWinActivate(p) {
   if (p[1] = "" && p[2] = "") {
      Return "#HotIf"
   }
   Return format("#HotIf WinActive({1}, {2})", p*)
}
;################################################################################
_HashtagWarn(p) {
   ; #Warn {1}, {2}
   if (p[1] = "" && p[2] = "") {
      Return "#Warn"
   }
   Out := "#Warn "
   if (p[1] != "") {
      if (p[1] ~= "^((Use(Env|Unset(Local|Global)))|ClassOverwrite)$") { ; UseUnsetLocal, UseUnsetGlobal, UseEnv, ClassOverwrite
         Out := "; V1toV2: Removed " Out p[1]
         if (p[2] != "")
            Out .= ", " p[2]
         Return Out
      } else Out .= p[1]
   }
   if (p[2] != "")
      Out .= ", " p[2]
   Return Out
}
;################################################################################
; Checks if IfMsgBox is used in the next lines
Check_IfMsgBox() {
   ; Go further in the lines to get the next continuation section
   global gOScriptStr   ; array of all the lines
   global gO_Index   ; current index of the lines
   ; get Temporary index
   T_Index := gO_Index
   found := false

   loop {
      T_Index++
      if (gOScriptStr.Length < T_Index || A_Index = 40) {   ; check the next 40 lines
         break
      }
;      LineContSect := gOScriptStr[T_Index]
      LineContSect := gOScriptStr.GetLine(T_Index)
      if (RegExMatch(LineContSect, "i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)(.*)")) {
         found := true
         break
      } else if (RegExMatch(LineContSect, "i)^\s*MsgBox([,\s]|$)")) {
         break
      }
   }
   return found
}
;################################################################################
; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and separate the variables
; Input:
;   String - The string to parse.
; Output:
;   RETURN - array of the parsed commands.
; --------------------------------------------------------------------
; Returns an Array of the parameters, taking into account brackets and quotes
V1ParamSplit(String) {
   ; Created by Ahk_user
   ; Tries to split the parameters better because sometimes the , is part of a quote, function or object
   ; spinn-off from DeathByNukes from https://autohotkey.com/board/topic/35663-functions-to-get-the-original-command-line-and-parse-it/
   ; I choose not to trim the values as spaces can be valuable too
   ;MsgBox(String)
   oResult := Array()   ; Array to store result
   oIndex := 1   ; index of array
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
            ;  2024-06-24 andymbody - added double quote to Instr search just in case causing hidden issues
            if (A_Index = 1 || (oString.has(A_Index - 1) && Instr('(" ,', oString[A_Index - 1]))) {
               InQuote := 1
            } else {
               CheckQuotes := 0
            }
         } else {
            ;  2024-06-24 andymbody - added double quote to Instr search to fix failed test RegexMatch_O-Mode_ex2.ah1
            if (A_Index = oString.Length || (oString.has(A_Index + 1) && Instr(')" ,', oString[A_Index + 1]))) {
               InQuote := 0
            } else {
               CheckQuotes := 0     ; could also just remove this to fix RegexMatch_O-Mode_ex2.ah1
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
;################################################################################
; Purpose: Read a ahk v1 command line and return the function, parameters, post and pre text
; Input:
;     String - The string to parse.
;     FuctionTarget - The number of the function that you want to target
; Output:
;   oResult - array
;       oResult.pre           text before the function
;       oResult.func          function name
;       oResult.parameters    parameters of the function
;       oResult.post          text afther the function
;       oResult.separator     character before the function
; --------------------------------------------------------------------
; Returns an object of parameters in the function properties: pre, function, parameters, post & separator
V1ParSplitFunctions(String, FunctionTarget := 1) {
   ; Will try to extract the function of the given line
   ; Created by Ahk_user
   oResult          := Array()      ; Array to store result Pre func params post
   oIndex           := 1            ; index of array
   InArray          := 0
   InApostrophe     := false
   InQuote          := false
   Hook_Status      := 0

   FunctionNumber   := 0
   Searchstatus     := 0
   HE_Index         := 0
   oString          := StrSplit(String)
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

         if (Char = "(" && !InQuote && !InApostrophe) {
            FunctionNumber++
            if (FunctionNumber = FunctionTarget) {
               H_Index := A_Index
               ; loop to find function
               loop H_Index - 1 {
                  if (!IsNumber(oString[H_Index - A_Index]) && !IsAlpha(oString[H_Index - A_Index]) && !InStr("#_@$", oString[H_Index - A_Index])) {
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
         if (oString[A_Index] = "(" && !InQuote && !InApostrophe) {
            Hook_Status++
         } else if (oString[A_Index] = ")" && !InQuote && !InApostrophe) {
            Hook_Status--
         }
         if (Hook_Status = 0) {
            HE_Index := A_Index
            break
         }
      }
      oResult[oIndex]       := oResult[oIndex] Char
   }
   if (Searchstatus = 0) {
      oResult.Pre           := String
      oResult.Func          := ""
      oResult.Parameters    := ""
      oResult.Post          := ""
      oResult.Separator     := ""
      oResult.Found         := 0

   } else {
      oResult.Pre           := SubStr(String, 1, F_Index - 1)
      oResult.Func          := SubStr(String, F_Index, H_Index - F_Index)
      oResult.Parameters    := SubStr(String, H_Index + 1, HE_Index - H_Index - 1)
      oResult.Post          := SubStr(String, HE_Index + 1)
      oResult.Separator     := SubStr(String, F_Index - 1, 1)
      oResult.Found         := 1
   }
   oResult.Hook_Status      := Hook_Status
   return oResult
}
;################################################################################
; Function to debug
DebugWindow(Text, Clear := 0, LineBreak := 0, Sleep := 0, AutoHide := 0) {
   if (WinExist("AHK Studio")) {
      x := ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
      x.DebugWindow(Text, Clear, LineBreak, Sleep, AutoHide)
   } else {
      OutputDebug Text
   }
   return
}
;################################################################################
;// FormatParam:
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
;//          - param names ending in "V2VRM" would convert an output variable name to a v2 VarRef
;//              same as V2VR but adds a placeholder name if blank, only use if its mandatory param in v2
;//          - any other param name will not be converted
;//              this means that the literal text of the parameter is unchanged
;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
; Converts Parameter to different format T2E T2QE Q2T CBE2E CBE2T Q2T V2VR V2VRM
; 2025-06-12 AMB, UPDATED - changed function name, some var and funcCall names
FormatParam(ParName, ParValue) {
;   ParName := StrReplace(Trim(ParName), "*")  ; Remove the *, that indicate an array (2025-06-12 NOT USED)
   ParValue := Trim(ParValue)
   if (ParName ~= "V2VRM?$") {
      if (ParValue != "" && !InStr(ParValue, "&"))
         ParValue := "&" . ParValue
      else if (ParName ~= "M$" && ParValue = "" && !InStr(ParValue, "&"))
         ParValue := "&AHKv1v2_vPlaceholder", gaWarnings.AddedV2VRPlaceholder := 1
   } else if (ParName ~= "CBE2E$")            ; 'Can Be an Expression TO an Expression'
   {
      if (SubStr(ParValue, 1, 2) = "% ")      ; if this param expression was forced
         ParValue := SubStr(ParValue, 3)      ; remove the forcing
      else
         ParValue := RemoveSurroundingPercents(ParValue)
   } else if (ParName ~= "CBE2T$")            ; 'Can Be an Expression TO literal Text'
   {
      if (isInteger(ParValue))                ; if this param is int
         || (SubStr(ParValue, 1, 2) = "% ")   ; or the expression was forced
         || ((SubStr(ParValue, 1, 1) = "%") && (SubStr(ParValue, -1) = "%"))   ; or var already wrapped in %%s
      ParValue := ParValue   ; dont do any conversion
      else
         ParValue := "%" . ParValue . "%"     ; wrap in percent signs to evaluate the expr
   } else if (ParName ~= "Q2T$")              ; 'Can Be an quote TO literal Text'
   {
      if ((SubStr(ParValue, 1, 1) = "`"") && (SubStr(ParValue, -1) = "`""))   ;  var already wrapped in Quotes
         || ((SubStr(ParValue, 1, 1) = "`'") && (SubStr(ParValue, -1) = "`'"))   ;  var already wrapped in Quotes
         ParValue := SubStr(ParValue, 2, StrLen(ParValue) - 2)
      else
         ParValue := "%" ParValue "%"
   } else if (ParName ~= "T2E$")              ; 'Text TO Expression'
   {
      if (SubStr(ParValue, 1, 2) = "% ") {
         ParValue := SubStr(ParValue, 3)      ; remove '% '
      } else {
         ; 2025-06-12 AMB, ADDED support for continuation sections
         csStr := ''
         ParValue := (ParValue != "") ? ((csStr := CSect.HasContSect(ParValue)) ? csStr : ToExp(parValue)) : ""
      }
   } else if (ParName ~= "T2QE$")             ; 'Text TO Quote Expression'
   {
      ParValue := ToExp(ParValue)
   } else if (ParName ~= "i)On2True$")   ; 'Text TO Quote Expression'
   {
      ParValue := RegexReplace(ParValue, "^%\s*(.*?)%?$", "$1")
      ParValue := RegexReplace(RegexReplace(RegexReplace(ParValue, "i)\btoggle\b", "-1"), "i)\bon\b", "true"), "i)\boff\b", "false")
   } else if (ParName ~= "i)^StartingPos$")   ; Only parameters with this name. Found at InStr, SubStr, RegExMatch and RegExReplace.
   {
      if (ParValue != "") {
         if (IsNumber(ParValue)) {
            ParValue := ParValue<1 ? ParValue-1 : ParValue
         } else {
            ParValue := "(" ParValue ")<1 ? (" ParValue ")-1 : (" ParValue ")"
         }
      }
   } else{
      v2_DQ_Literals(&ParValue)
   }

   Return ParValue
}
;################################################################################
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
;################################################################################
; Function that converts specific label to string and adds brackets
; ScriptString        :  Script
; Label               :  Label to change to fuction
; Parameters          :  Parameters to use
; NewFunctionName     :  Name of new function
; aRegexReplaceList   :  Array with objects with NeedleRegEx and Replacement properties to be used in the label
;                         example: [{NeedleRegEx: "(.*)V1(.*)",Replacement : "$1V2$2"}]
; Function that converts specific label to string and adds brackets
; 2024-08-06 AMB, UPDATED
ConvertLabel2Func(ScriptString, Label, Parameters := "", NewFunctionName := "", aRegexReplaceList := "") {
; 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object

   Mask_T(&ScriptString, 'BC')
;   gOScriptStr  := StrSplit(ScriptString, "`n", "`r")
   ScriptStr    := ScriptCode(ScriptString)
   Result       := ""
   LabelPointer := 0                ; active searching for the end of the hotkey
   LabelStart   := 0                ; active searching for the beginning of the bracket
   RegexPointer := 0
   RestString   := ScriptString     ; used to have a string to look the rest of the file

   ; 2024-06-13 AMB - part of fix #193
   ; capture any trailing blank lines at end of string
   ; they will be added back prior to returning converted string
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

   if (NewFunctionName = "") {   ; Use Labelname if no FunctionName is defined
      NewFunctionName := Label
   }
   NewFunctionName := getV2Name(NewFunctionName)
   loop ScriptStr.Length {
;      Line := gOScriptStr[A_Index]
      Line := ScriptStr.GetLine(A_Index)

      if (LabelPointer = 1 || LabelStart = 1 || RegexPointer = 1) {
         if (IsObject(aRegexReplaceList)) {
            Loop aRegexReplaceList.Length {
               if (aRegexReplaceList[A_Index].NeedleRegEx)
                  Line := RegExReplace(Line, aRegexReplaceList[A_Index].NeedleRegEx, aRegexReplaceList[A_Index].Replacement)
               ;MsgBox(Line "`n" aRegexReplaceList[A_Index].NeedleRegEx "`n" aRegexReplaceList[A_Index].Replacement)
            }
         }
      }

      if (LabelPointer = 1 || RegexPointer = 1) {
         if (RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)\s*(`;[^\v]*|)(\s*){).*")) {   ; Function declaration detection
            ; not bulletproof perfect, but a start
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added bracket before function`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
      }
      if (RegExMatch(Line, "i)^(\s*;).*") || RegExMatch(Line, "i)^(\s*)$")) {   ; comment or empty
         ; Do nothing
      } else if (line ~= gPtn_HS_LWS || line ~= gPtn_HK_LWS) {   ; Hotkey or Hotstring
         if (LabelPointer = 1 || RegexPointer = 1) {
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
         if (line ~= gPtn_HS_LWS || line ~= gPtn_HK_LWS) {    ; Hotkey or Hotstring
            ; oneline detected do noting
            LabelPointer := 0
            RegexPointer := 0
         }
      } else if (LabelStart = 1) {
         if (RegExMatch(Line, "i)^\s*({).*")) {   ; Hotkey is already good :)
            LabelPointer := 0
         } else {
            Result .= "{ `; V1toV2: Added bracket`r`nglobal `; V1toV2: Made function global`r`n" ; Global - See #49
            RegExMatch(Result, '(.*)\r\n.*\r\n.*\r\n$', &match) ; Check if label is for a gui
            if InStr(match[1], 'A_GuiControl') && gaScriptStrsUsed.A_GuiControl
               Result .= 'A_GuiControl := HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl`r`n'
            LabelPointer := 1
         }
         LabelStart := 0
      }
      if (LabelPointer = 1 || RegexPointer = 1) {
         if (RestString ~= gPtn_HS_LWS || RestString ~= gPtn_HK_LWS) {   ; Hotkey or Hotstring
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         } else if (RegExMatch(RestString, "is)^(|;[^\n]*\n)*\s*\}?\s*([^;\s\{}\[\]\=:]+?\:\s).*") > 0
;                 && RegExMatch(gOScriptStr[A_Index - 1], "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
                 && RegExMatch(ScriptStr.GetLine(A_Index - 1), "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added Bracket before label`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         } else if (RegExMatch(RestString, "is)^\s*\}?\s*(`;[^\v]*|)(\s*)$") > 0
;                 && RegExMatch(gOScriptStr[A_Index - 1], "is)^\s*(return).*") > 0) {   ; Label
                 && RegExMatch(ScriptStr.GetLine(A_Index - 1), "is)^\s*(return).*") > 0) {   ; Label
            Result .= LabelPointer = 1 ? "} `; V1toV2: Added bracket in the end`r`n" : ""
            LabelPointer := 0
            RegexPointer := 0
         }
      }
      ; This check needs to be at the bottom.
      ; 2025-07-03 AMB, UPDATED detection to prevent var:= from being mistaken for a label
      if ((lbl:=isValidV1Label(line)) = Label ':') {    ; 2025-07-03 adj this and 2 needles below (as bkup)
         if (RegexMatch(Line, "is)^(\s*|.*\n\s*)(\Q" Label "\E):(?!=)(.*)", &Var)) {
            if (RegExMatch(Line, "is)(\s*)(\Q" Label "\E):(?!=)(\s*[^\s;].+)")) {
               ;Oneline detected
               Line := Var[1] NewFunctionName "(" Parameters "){`r`n   " Var[3] "`r`n}"
               if (IsObject(aRegexReplaceList)) {
                  Loop aRegexReplaceList.Length {
                     if (aRegexReplaceList[A_Index].NeedleRegEx)
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
      RestString    := SubStr(RestString, InStr(RestString, "`n") + 1)
      Result        .= Line . "`r`n"
   }

   ; 2024-06-13 AMB - part of fix #193
   result := RTrim(result, '`r`n')   ; first trim all blank lines from end of string
   if (LabelPointer = 1) {
      Result .= "`r`n} `; V1toV2: Added bracket in the end"     ; edited
   }
   result .= happyTrails    ; add ONLY original trailing blank lines back

   Mask_R(&result, 'BC')
   return Result
}
;################################################################################
/**
 * Adds brackets to script
 * @param {*} ScriptString string containing a script of multiple lines
 * 2024-08-06 AMB, UPDATED
 * 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object
 */
AddBracket(ScriptString) {

   Mask_T(&ScriptString, 'BC')

   ; 2024-07-09 AMB, ADDED - fix for trailing CRLF issue
   ; capture any trailing blank lines at end of string
   ; they will be added back prior to returning converted string
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

;   gOScriptStr      := StrSplit(ScriptString, "`n", "`r")
   ScriptStr        := ScriptCode(ScriptString)
   Result           := ""
   HotkeyPointer    := 0                ; active searching for the end of the hotkey
   HotkeyStart      := 0                ; active searching for the beginning of the bracket
   RestString       := ScriptString     ; used to have a string to look the rest of the file
   CommentCode      := 0


;   loop ScriptStr.Length {
   while (ScriptStr.HasNext) {
      Line := ScriptStr.GetNext

;      if (RegExMatch(Line, "i)^\s*(\/\*).*")) { ; Start commented code (starts with /*) => skip conversion
;         CommentCode:=1
;      }
;      if (CommentCode=0) {
         if (HotkeyPointer = 1) {
            if (RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)\s*(`;[^\v]*|)(\s*){).*")) {   ; Function declaration detection
               ; not bulletproof perfect, but a start
               Result .= "} `; V1toV2: Added bracket before function`r`n"
               HotkeyPointer := 0
            }
         }
         if (RegExMatch(Line, "i)^(\s*;).*") || RegExMatch(Line, "i)^(\s*)$")) {   ; comment or empty
            ; Do nothing
         } else if (line ~= gPtn_HS_LWS || line ~= gPtn_HK_LWS) {   ; Hotkey or Hotstring
            if (HotkeyPointer = 1) {
               Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
               HotkeyPointer := 0
            }
            if (line ~= gPtn_HS_LWS . '\h*[^\s;]+' || line ~= gPtn_HK_LWS . '\h*[^\s;]+') {   ; is command on same line as hotkey/hotstring ?
               ; oneline detected do noting
            } else {
               ; Hotkey detected start searching for start
               HotkeyStart := 1
            }
         } else if (HotkeyStart = 1) {
            if (RegExMatch(Line, "i)^\s*(#).*")) {   ; #if statement, skip this line
               HotkeyStart := 1
            } else {
               if (RegExMatch(Line, "i)^\s*([{\(]).*")) {   ; Hotkey is already good :)
                  HotkeyPointer := 0
               } else if (RegExMatch(RestString, "is)^\s*([\w]+?\([^\)]*\)\s*(`;[^\v]*|)(\s*){).*")) {   ; Function declaration detection
                  ; Named Function Hotkeys do not need brackets
                  ; https://lexikos.github.io/v2/docs/Hotstrings.htm
                  ; Maybe add an * to the function?
                  A_Index2 := A_Index - 1
;                  Loop gOScriptStr.Length - A_Index2 {
                  Loop ScriptStr.Length - A_Index2 {
                     if (RegExMatch(ScriptStr.GetLine(A_Index2 + A_Index), "i)^\s*([\w]+?\().*$")) {
;                        gOScriptStr[A_Index2 + A_Index] := RegExReplace(gOScriptStr[A_Index2 + A_Index], "i)(^\s*[\w]+?\()[\s]*(\).*)$", "$1*$2")
                        ScriptStr.SetLine(A_Index2 + A_Index, RegExReplace(ScriptStr.GetLine(A_Index2 + A_Index), 'i)(^\h*\w+?\()\h*(\).*)$', '$1*$2'))
                        if (A_Index = 1) {
;                           Line := gOScriptStr[A_Index2 + A_Index]
                           Line := ScriptStr.GetLine(A_Index2 + A_Index)
                        }
                        Break
                     }
                  }
                  RegExReplace(RestString, "is)^(\s*)([\w]+?\([^\)]*\)\s*(`;[^\v]*|)(\s*){).*", "$1")
                  HotkeyPointer := 0
               } else {
                  Result .= "{ `; V1toV2: Added bracket`r`nglobal `; V1toV2: Made function global`r`n" ; Global - See #49
                  HotkeyPointer := 1
               }
               HotkeyStart := 0
            }
         }
         if (HotkeyPointer = 1) {
            if (RestString ~= gPtn_HS_LWS || RestString ~= gPtn_HK_LWS) {   ; Hotkey or Hotstring
               Result .= "} `; V1toV2: Added Bracket before hotkey or Hotstring`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^\s*((:[\h\*\?BCKOPRSIETXZ0-9]*:|)[^;\s\{}\[\:]+?\:\:?\h).*") > 0
;                    && RegExMatch(gOScriptStr[A_Index - 1], "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
                    && RegExMatch(ScriptStr.GetLine(A_Index - 1), "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
               Result .= "} `; V1toV2: Added Bracket before label`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^\s*(`;[^\v]*|)(\s*)$") > 0
;                    && RegExMatch(gOScriptStr[A_Index - 1], "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
                    && RegExMatch(ScriptStr.GetLine(A_Index - 1), "is)^\s*(return|exitapp|exit|reload).*") > 0) {   ; Label
               Result .= "} `; V1toV2: Added bracket in the end`r`n"
               HotkeyPointer := 0
            } else if (RegExMatch(RestString, "is)^\s*(#hotif).*") > 0) { ; #Hotif statement
               Result .= "} `; V1toV2: Added bracket in the end`r`n"
               HotkeyPointer := 0
            }
         }
;      }

;      if (RegExMatch(Line, "i)^\s*(\*\/).*")) { ; End commented code (starts with /*)
;         CommentCode:=0
;      }

      ; Convert wrong labels
      ; 2024-07-07 AMB CHANGED to detect all v1 valid characters, and convert to valid v2 labels
      if (v1Label := getV1Label(Line)) {
         Label    := getV2Name(v1Label) . ":"
         Line     := RegexReplace(Line, "(\h*)\Q" v1Label "\E(.*)", "$1" Label "$2")
      }

      RestString    := SubStr(RestString, InStr(RestString, "`n") + 1)
;      Result        .= Line . ((A_Index != gOScriptStr.Length) ? "`r`n" : "")
      Result        .= Line . ((A_Index != ScriptStr.Length) ? "`r`n" : "")
   }
   if (HotkeyPointer = 1) {
      Result .= "`r`n} `; V1toV2: Added bracket in the end`r`n"
   }
   result := RTrim(Result, "`r`n") . happyTrails

   Mask_R(&result, 'BC')
   return result
}
;################################################################################
/**
 * Creates a Map of labels who can be replaced by other labels (if labels are defined above each other)
 * @param {*} ScriptString string containing a script of multiple lines
 * 2024-07-07, UPDATED to use common getV1Label() function that covers detection of all valid v1 label chars
 * 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object
*/
GetAltLabelsMap(ScriptString) {

   RemovePtn(ScriptString, 'BC')                                ; remove block-comments
;   ScriptStr := StrSplit(ScriptString, "`n", "`r")
   ScriptStr := ScriptCode(ScriptString)
   LabelPrev := ""
   mAltLabels := Map()
   loop ScriptStr.Length {
;      Line := ScriptStr[A_Index]
      Line := ScriptStr.GetLine(A_Index)

      if (trim(RemovePtn(line, 'LC'))='') {                     ; remove any line comments and whitespace
         continue ; is blank line or line comment
      } else if (v1Label := getV1Label(line)) {
         Label := SubStr(v1Label, 1, -1) ; remove colon
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
;################################################################################
/**
 * Converts Goto Label for label that have been converted to funcs
 * 2024-07-09 AMB, CHANGED - added support for label renaming that avoids conflicts
 */
UpdateGotoFunc(ScriptString)    ; the old UpdateGoto
{
   if (gaList_LblsToFuncC.Length = 0)
      return ScriptString

   ; 2024-07-09 AMB, ADDED - fix for trailing CRLF issue
   ; capture any trailing blank lines at end of string
   ; they will be added back prior to returning converted string
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

   retScript  := ""
   loop parse ScriptString, "`n", "`r" {
      line  := A_LoopField
      if (!InStr(line, "Goto", "On") or RegExMatch(Line, "^\s*;")) { ; Case sensitive because converter always converts to "Goto"
         retScript .= line . "`r`n"
         continue
      }
      for , v1Label in gaList_LblsToFuncC {
         v2LabelName    := getV2Name(v1Label)    ; rename to v2 compatible without conflict
         if (InStr(line, v1Label)) {
            retScript   .= StrReplace(line, 'Goto("' v1Label '")', v2LabelName "()`r`n")
            break
         } else {
            retScript   .= line . "`r`n"
            break
         }
      }
   }
   return RTrim(retScript, "`r`n") . happyTrails  ; add back just the trailing CRLFs that code came in with
}
;################################################################################
UpdateGoto(ScriptString) {
; 2024-07-09, ADDED support for renaming of regular goto labels

   ; 2024-07-09 AMB - fix for trailing CRLF issue
   ; capture any trailing blank lines at end of string
   ; they will be added back prior to returning converted string
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

   retScript  := ""
   loop parse ScriptString, "`n", "`r" {
      line      := A_LoopField
         ; if no goto command on this line, record line as is
      if (!InStr(line, "Goto", "On") or RegExMatch(Line, "^\s*;")) { ; Case sensitive because converter always converts to "Goto"
         retScript .= line . "`r`n"
         continue
      }
      ; has a goto on this line, make sure label name is v2 compatible
      v1Label       := RegExReplace(line, 'i)^[^g]*goto\("([^"]+)"\).*', '$1')
      v2LabelName   := getV2Name(v1Label)
      retScript     .= StrReplace(line, 'Goto("' v1Label '")', 'Goto("' v2LabelName '")`r`n')
   }
   return RTrim(retScript, "`r`n") . happyTrails   ; add back just the trailing CRLFs that code came in with
}
;################################################################################
/**
 * Fix turning off OnMessage when OnMessage is turned off
 * before it is assigned a callback (by eg using functions)
 */
FixOnMessage(ScriptString) {
   if (!InStr(ScriptString, Chr(1000) Chr(1000) "CallBack_Placeholder" Chr(1000) Chr(1000)))
      Return ScriptString

   ; 2024-07-09 AMB - fix for trailing CRLF issue
   ; capture any trailing blank lines at end of string
   ; they will be added back prior to returning converted string
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

   retScript := ""
   loop parse ScriptString, "`n", "`r" {
      Line := A_LoopField
      for i, v in gmOnMessageMap {
         if (RegExMatch(Line, 'OnMessage\(\s*((?:0x)?\d+)\s*,\s*ϨϨCallBack_PlaceholderϨϨ\s*(?:,\s*\d+\s*)?\)', &match)) { ; && (i = match[1]))) {
            Line := StrReplace(Line, "ϨϨCallBack_PlaceholderϨϨ", v,, &OutputVarCount)
         }
      }
      retScript .= Line "`r`n"
   }

   retScript := RegExReplace(retScript, "ϨϨCallBack_PlaceholderϨϨ(.*)", "$1 `; V1toV2: Put callback to turn off in param 2")

   return RTrim(retScript, "`r`n") . happyTrails   ; add back just the trailing CRLFs that code came in with
}
;################################################################################
/**
 * Updates VarSetCapacity target var
 * &BufferObj -> BufferObj.Ptr
 * &VarSetStrCapacityObj -> StrPtr(VarSetStrCapacityObj)
 */
FixVarSetCapacity(ScriptString) {
   retScript := ""
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]

   loop parse ScriptString, "`n", "`r" {
      Line := A_LoopField
      StrReplace(Line, "&",,, &ReplacementCount)
      Loop (ReplacementCount) {
         if (RegExMatch(Line, "(?<!VarSetStrCapacity\()(?<=\W)&(\w+)", &match))
            and !RegExMatch(Line, "^\s*;") {
            for vName, vType in gmVarSetCapacityMap {
               ;MsgBox "v: " vName "`nm1: " match[1]
               if (vName = match[1]) {
                  if (vType = "B")
                     Line := StrReplace(Line, "&" match[1], match[1] ".Ptr")
                  else if (vType = "V")
                     Line := StrReplace(Line, "&" match[1], "StrPtr(" match[1] ")")
               }
            }
         }
      }
      retScript .= Line "`r`n"
   }
   return RTrim(retScript, "`r`n") . happyTrails
}
;################################################################################
/**
 * Finds function calls with ByRef params
 * and appends an &
 */
FixByRefParams(ScriptString) {
   retScript := ""
   EOLComment := ""
   happyTrails := ''
   if (RegExMatch(ScriptString, '.*(\R+)$', &m))
      happyTrails := m[1]
   loop parse ScriptString, "`n", "`r" {
      Line := A_LoopField
      replacement := false
      for func, v in gmByRefParamMap {
         if (RegExMatch(Line, "(\h+`;.*)$", &EOLComment)) {
            EOLComment := EOLComment[1]
            Line       := RegExReplace(Line, "(\h+`;.*)$")
         }
         if RegExMatch(Line, "(^|.*\W)\Q" func "\E\((.*)\)(.*?)$", &match) ; Nested functions break and cont. sections this
            && !InStr(Line, "&") ; Not defining a function
            && !RegExMatch(Line, "^\s*;") { ; Comment
            retLine := match[1] func "("
            params := match[2]
            while pos := RegExMatch(params, "[^,]+", &MatchFuncParams) {
               if v[A_Index] {
                  retLine .= "&" RegExReplace(LTrim(MatchFuncParams[]), "i)^ByRef ") ", "
               } else {
                  retLine .= MatchFuncParams[] ", "
               }
               params := StrReplace(params, MatchFuncParams[],,,, 1)
            }
            retLine := RTrim(retLine, ", ") ")" match[3]
            replacement := true
         }
      }
      if !replacement
         retScript .= Line EOLComment "`r`n"
      else
         retScript .= retLine EOLComment "`r`n"
   }
   return RTrim(retScript, "`r`n") . happyTrails
}
;################################################################################
/**
 * Removes ComObjMissing and references to it from functions
 * Eg ComValue(0x10, ComObjMissing()) => ComValue(0x10)
 *    ComValue(0x20, VarForComObjMissing) => ComValue(0x20)
 */
RemoveComObjMissing(ScriptString) {
   if !InStr(ScriptString, 'ComObjMissing()')
      return ScriptString
   Mask_T(&ScriptString, 'STR')
   VarsToRemove := []
   EOLComments := Map()
   Lines := StrSplit(ScriptString, "`n", "`r")

   for i, Line in Lines {
      Line := separateComment(Line, &comment:='')
      EOLComments[i] := comment

      first := true
      while InStr(Line, 'ComObjMissing()') {
         if RegExMatch(Line, "(\w+)\s*:=\s*ComObjMissing\(\)", &assignMatch)
            VarsToRemove.Push(assignMatch[1])

         Mask_T(&Line, 'FC')
         parts := StrSplit(Line, ",")

         if parts.Length > 1 {
            Line := ""
            for , part in parts {
               Mask_R(&part, 'FC')
               if InStr(part, "ComObjMissing()") {
                  if first {
                     EOLComments[i] .= " `; V1toV2: Removed"
                     first := false
                  }
                  EOLComments[i] .= " " Trim(part) ","
               } else {
                  Line .= part ","
               }
            }
            Line := RTrim(Line, ",")
         } else {
            Mask_R(&Line, 'FC')
            Line := RegExReplace(Line, "(.*?)((?:\w+\s*:=\s*)?ComObjMissing\(\))(.*)", "$1$3" Chr(0x8787) "$2")
            sLine := StrSplit(Line, Chr(0x8787))
            Line := sLine[1]
            EOLComments[i] .= " `; V1toV2: Removed " sLine[2]
            Line := RegExReplace(Line, "[\s,]+\)", ")")
         }
         Line := RTrim(Line, ",")
      }
      Lines[i] := Line
   }

   for i, Line in Lines {
      for , var in VarsToRemove {
         if RegExMatch(Line, "\b" var "\b") {
            Line := RegExReplace(Line, "\b" var "\b")
            Line := RegExReplace(Line, "[\s,]+\)", ")")
            EOLComments[i] .= " `; V1toV2: Removed ComObjMissing() variable " var
         }
      }
      Lines[i] := Line
   }
   final := ""
   for i, Line in Lines {
      finalLine := Line RTrim(EOLComments.Get(i, ""), ",")
      finalLine := RegExReplace(finalLine, "^(\s*) (; V1toV2: Removed [^;]*ComObjMissing\(\))", "$1$2")
      final .= finalLine "`r`n"
   }
   Mask_R(&final, 'STR')
   return RegExReplace(final, '\r\n$')
}
;################################################################################
ConvertDblQuotes2(&Line, eqRSide) {
; 2024-06-13 andymbody - ADDED/CHANGED
; provides conversion of double quotes (multiple styles)

   masks := []  ; for temporarily masking changes

   ; isolated quote ("""" to "`"")
      eqRSide := RegExReplace(eqRSide, '""""', '"``""')
      ; mask temporarily to avoid conflicts with other conversions below
      m := []
      while (pos := RegexMatch(eqRSide, '"``""', &m)) {
         masks.push(m[])
         eqRSide := StrReplace(eqRSide, m[], Chr(0x2605) "Q_" masks.Length Chr(0x2605),,, 1)
      }

   ; escaped quotes within a string ("" to `" and """ to `"")
      eqRSide := ConvertEscapedQuotesInStr(eqRSide)
      ; mask temporarily to avoid conflicts with other conversions below
      m := []
      while (pos := RegexMatch(eqRSide, '``""?+', &m)) {
         masks.push(m[])
         eqRSide := StrReplace(eqRSide, m[], Chr(0x2605) "Q_" masks.Length Chr(0x2605),,, 1)
      }

   ; forced quotes around char-string
      eqRSide := RegExReplace(eqRSide, '(")?("")([^"\v]+)("")(")?', '$1``"$3``"$5')

   ; remove masks
      for i, v in masks
         eqRSide := StrReplace(eqRSide, Chr(0x2605) "Q_" i Chr(0x2605), v)

   ; update line with conversion
   line .= eqRSide
   return
}
;################################################################################
ConvertEscapedQuotesInStr(srcStr) {
; 2024-06-13 AMB - ADDED
; 2024-07-15 AMB - UPDATED to fix issue 253
; escaped quotes within a string ("" to `" and """ to `"")

   retStr := '', idx := 1, inStrg := 0
   Loop
   {
      ; if reached end of string, exit loop
      if (idx>StrLen(srcStr))
         break

      curChar := SubStr(srcStr, idx, 1)     ; get next character

      ; if reached a DQ and not already in a quoted string, flag now in quoted string
      if (curChar='"' && !inStrg) {
         inStrg := 1, retStr .= curChar, idx++
      }
      ; if reached a DQ and already in a quoted string, check for 3 DQs, convert if found, and flag close quoted string
      else if (curChar='"' && inStrg && subStr(srcStr, idx, 3) = '"""') {
         inStrg := 0, retStr .= '``""', idx+=3
      }
      ; if reached a DQ and already in a quoted string, check for 2 DQs, convert if found
      else if (curChar='"' && inStrg && subStr(srcStr, idx, 2) = '""') {
         inStrg := 1, retStr .= '``"', idx+=2
      }
      ; if reached a DQ and already in a quoted string, and none of the above are true, this should be the closing DQ
      else if (curChar='"' && inStrg) {
         inStrg := 0, retStr .= '"', idx++
      }
      ; if not a DQ, just add char to return string
      else {
         retStr .= curChar, idx++
      }
   }
   return retStr
}
;################################################################################
addGuiCBArgs(&code) {
   global gmGuiFuncCBChecks
   for key, val in gmGuiFuncCBChecks {
      code := RegExReplace(code, 'im)^(\s*' key ')\((.*?)\)(\s*\{)', '$1(A_GuiEvent := "", A_GuiControl := "", Info := "", *)$3 `; V1toV2: Handle params: $2')
      code := RegExReplace(code, 'm) `; V1toV2: Handle params: (A_GuiEvent := "", A_GuiControl := "", Info := "", \*)?$')
   }
}
;################################################################################
addMenuCBArgs(&code) {
; 2024-06-26, AMB - ADDED to fix issue #131
; 2025-06-12, AMB - UPDATED to fix interference with IF/LOOP/WHILE

   ; add menu args to callback functions
   nCommon  := '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
   nFUNC    := RegExReplace(gPtn_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')     ; 2025-06-12, remove exclusion
   m := [], declare := []
   for key, val in gmMenuCBChecks
   {
       nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', key)    ; target specific function name
;       nTargFunc := RegExReplace(nPtn_FUNC, 'i)\Q?<fName>[_a-z]\w*+\E', '?<fName>' key)    ; target specific function name
       if (pos := RegExMatch(code, nTargFunc, &m)) {
         ; target function found
         nDeclare   := '(?im)' nCommon '\))(?<trail>.*)'
         nArgs      := '(?im)' nCommon '\K\)).*'
         if (RegExMatch(m[], nDeclare, &declare)) { ; get just declaration line
            argList    := declare.fArgG, trail := declare.trail
            if (instr(argList, 'A_ThisMenuItem') && instr(argList, 'A_ThisMenuItemPos') && instr(argList, 'MyMenu'))
               continue ; skip converted labels
            newArgs    := '(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""' . ((m.Args='') ? ')' : ', ' SubStr(argList,2))
            ;arg        := (argList ~= '\(\h*\)') ? '*)' : ',*)'               ; add * or place it at the end of arg list
            ;addArgs    := RegExReplace(m[], nArgs, arg . trail,, 1)
            addArgs    := RegExReplace(m[],  '\Q' argList '\E', newArgs,,1)    ; replace function args
            code       := RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)    ; replace function within the code
         }
       }
   }
   return ; code by reference
}
;################################################################################
addOnMessageCBArgs(&code) {
; 2024-06-28, AMB - ADDED to fix issue #136
; 2025-06-12, AMB - UPDATED to fix interference with IF/LOOP/WHILE

   ; add menu args to callback functions
   nCommon  := '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
   nFUNC    := RegExReplace(gPtn_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')     ; 2025-06-12, remove exclusion
   m := [], declare := []
   for key, funcName in gmOnMessageMap
   {
      nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', funcName)     ; target specific function name
;      nTargFunc := RegExReplace(nPtn_FUNC, 'i)\Q?<fName>[_a-z]\w*+\E', '?<fName>' funcName)     ; target specific function name
      If (pos := RegExMatch(code, nTargFunc, &m)) {
         ; target function found
         nDeclare   := '(?im)' nCommon '\))(?<trail>.*)'
         nArgs      := '(?im)' nCommon '\K\)).*'
         if (RegExMatch(m[], nDeclare, &declare)) { ; get just declaration line
            argList    := declare.fArgG, trail := declare.trail
            cleanArgs  := RegExReplace(argList, '(?i)(?:\b(?:wParam|lParam|msg|hwnd)\b(\h*,\h*)?)+')
            ;newArgs   := '(wParam:="", lParam:="", msg:="", hwnd:=""' . ((cleanArgs='()') ? ')' : ', ' SubStr(cleanArgs,2))
            newArgs    := '(wParam, lParam, msg, hwnd' . ((cleanArgs='()') ? ')' : ', ' SubStr(cleanArgs,2))
            addArgs    := RegExReplace(m[],  '\Q' argList '\E', newArgs,,1)    ; replace function args
            code       := RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)    ; replace function within the code
         }
       }
   }
   return ; code by reference
}
;################################################################################
getMenuBarName(srcStr) {
; 2024-07-02 ADDED, AMB - for detection and initialization of MenuBar...
;   when the menu is created prior to GUI official declaration
;   not perfect - requires 'gui' to be in the name of script gui control, which is common
   needle := '(?im)^\h*\w*GUI\w*\b,?\h*\bMENU\b\h*,\h*(\w+)'
   if (RegExMatch(srcStr, needle, &m))
      return m[1]
   return ''
}
;################################################################################
getV1Label(srcStr, returnColon:=true) {
; 2024-07-07 AMB, ADDED
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; returns extracted label if it resembles a valid v1 label
; 2025-06-12 AMB, UPDATED - calls new function now

   if (label := isValidV1Label(srcStr)) {
      return ((returnColon) ? label : SubStr(label, 1, -1))
   }
   return ''   ; not a valid v1 label
}
;################################################################################
getV2Name(v1LabelName)
{
; 2024-07-07 AMB, ADDED - Replaces GetV2Label()

   nameNoColon := RegExReplace(v1LabelName, "^(.*):", "$1") ; remove any colon if present
   return (gmAllLabelsV1toV2.Has(nameNoColon)) ? gmAllLabelsV1toV2[nameNoColon] : nameNoColon
}
;################################################################################
_getUniqueV2Name(v1LabelName)
{
; 2024-07-07 AMB, ADDED - Ensures name is unique (support for v1 to v2 label naming)
; 2024-07-09 AMB, UPDATED to check existing label names also

   global gAllFuncNames, gAllV1LabelNames

   holdName := newName := v1LabelName
   ; if labelName is already being used by another label or function, change the name
   ; keep renaming until unique name is created
   while (InStr(gAllFuncNames, newName . ",") || InStr(gAllV1LabelNames, newName . ",")) {
      newName := holdName . "_" . A_Index+1
   }
   ; add to labelName list if not already
   if (!InStr(gAllV1LabelNames, newName . ",")) {
      gAllV1LabelNames .= newName . ","
   }
   ; TO DO - add support for v1 to v2 function naming
;   ; add to function list if not already
;   if (!InStr(gAllFuncNames, newName . ",")) {
;      gAllFuncNames .= newName . ","
;   }
   return newName
}
;################################################################################
_convV1LblToV2FuncName(srcStr, returnColon:=true) {
; 2024-07-07 AMB, ADDED
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; returns valid v2 label with or without colon based on flag [returnColon]
; makes sure returned name is unique and does not conflict with existing function names

   ; makes sure it is a valid v1 label first
   if (!v1Label := getV1Label(srcStr))
      return ''

   ; convert to valid v2 label
   LabelName   := RegExReplace(v1Label, "^(.*):$", "$1")   ; remove colon if present
   newName     := ""
   Loop Parse LabelName {
      char     := A_LoopField    ; inspect one char at a time
      needle   := (A_Index=1) ? "(?i)(?:[^[:ascii:]]|[a-z_])" : "(?i)(?:[^[:ascii:]]|\w)" ; is char valid v2 char?
      newName  .= ((char~=needle) ? char : ((A_Index=1 && char~="\d") ? "_" char : "_"))  ; replace invalid chars
   }
   newName := (LabelName=newName) ? newName : _getUniqueV2Name(newName)
   return (newName . ((newName!="" && returnColon) ? ":" : ""))
}
;################################################################################
getV1LabelNames(&code)
{
   v1LabelNames := ""
   for idx, line in StrSplit(code, "`n", "`r") {
      if (v1Label := getV1Label(line, returnColon:=false)) {
         v1LabelNames .= v1Label . ","
      }
   }
   return v1LabelNames
}
;################################################################################
getScriptLabels(code)
{
; 2024-07-07 AMB, ADDED - captures all v1 labels from script...
;  ... converts v1 names to v2 compatible...
;  ... and places them in gmAllLabelsV1toV2 map for easy access
; 2025-06-12 AMB, UPDATED - changed some var and funcCall names

   global gmAllLabelsV1toV2 := map()

   contents := code                                 ; script contents
   contents := RemovePtn(contents, 'BC')            ; remove BLOCK comments only
   contents := RemovePtn(contents, 'v1LegMLS')      ; remove v1 legacy multi-line var string assignments

   ; convert v1 labelNames to v2 compatible, store as map in gmAllLabelsV1toV2
   corrections := ''
   for idx, lineStr in StrSplit(contents, '`n', '`r') {
      if ((v1Label := getV1Label(lineStr, returnColon:=true)) && (v2Name := _convV1LblToV2FuncName(v1Label, false)))
      {
         v1LabelName := RegExReplace(v1Label, '^(.*):$', '$1')          ; remove trailing colon
         gmAllLabelsV1toV2[v1LabelName] := v2Name                       ; name has no colon
;         corrections .= '`n[ ' . v1Label . ' ]`t[ ' . v2Name . ' ]'    ; for debugging
      }
   }
   ; for debugging
   if (corrections) {
 ;     MsgBox "[" corrections "]"
   }
   return
}
;################################################################################
isolateLabels(code)
{
; 2025-06-22 AMB, ADDED - to move labels to their own line...
;   ... when they are on same line as opening/closing brace
; can be adjusted o handle occurences for any other trailing item as well
;   (to make sure braces are isolated to their own line)

   outCode  := ''
   for idx, line in StrSplit(code, '`n', '`r') {                    ; for each line in code string...
      tempLine := line                                              ; in case we need to revert back to orig
      if (RegExMatch(line, '^(\h*)([{}][\h}{]*)(.*)', &m)) {        ; separate leading brace(s) from rest of line
         indent     := m[1]                                         ; preserve indentation
         brace      := m[2]                                         ; leading brace(s)
         trail      := m[3]                                         ; rest of line
         tempLine   := RTrim(indent . brace)                        ; set initial value
         clnTrail   := Trim(RemovePtn(trail, 'LC'))                 ; clean trailing string - remove line comment and ws
         if (isValidV1Label(clnTrail)) {                            ; if a label is found, move it to its own line
;         ; THIS CAN BE USED TO HANDLE OTHER ITEMS (protects HKs)
;         if (clnTrail && !(clnTrail ~= '::$' )) {                   ; if not empty, and not a hotkey
            tempLine .= '`r`n' . indent . trim(trail)               ; drop trailer str below brace (to next line)
		 }
         else {                                                     ; no label found on same line as brace(s)
            tempLine := line                                        ; restore line to original
         }
      }
      outCode .= tempLine . '`r`n'                                  ; build output string
   }
   outCode := RegExReplace(outCode, '\r\n$',,,1)                    ; remove final CRLF (added in loop)
   return outCode
}
;################################################################################
Class NULL { ; solution for absence of value
;   static ToString() => "[NULL]"
}
;################################################################################
; 2025-06-12 AMB, ADDED to support dual/multiple "layers" of scriptCode...
; ... each with its own properties. Will be used more in future version of converter
;################################################################################
Class ScriptCode
{
   _origStr  := ''
   _lineArr  := []
   _curIdx   := 0

   ; acts as constuctor
   __new(str) {
      this._origStr := str
      this.__fillArray()
   }

   ; Public
   AddAt(lines, position := -1) {
      pos   := (position > 0 && position <= this.Length +1)
            ? position
            : this._lineArr.Length + 1

      if (Type(lines)="Array")
         this._lineArr.InsertAt(pos, lines*)
      else
         this._lineArr.InsertAt(pos, lines)
   }

   ; Public
   Has(index) {
      return this._lineArr.has(index)
   }

   ; Public
   SetLine(index, val) {
      if (this.Has(index))
         this._lineArr[index] := val
   }

   ; Public
   GetLine(index) {
      if (this.Has(index))
         return this._lineArr[index]
      return Null
   }

   ; Public
   GetNext {
      get {
         this._curIdx++
         return this.GetLine(this._curIdx)
      }
   }

   ; Public
   ; Param 1 - set current index to passed val
   ; Param 2 - adj current index by passed val (+ or -)
   ; Param 3 - set NEXT    index to passed val (curIdx will be set to val-1)
   SetIndex(setCur := -1, adjVal := 0, setNext := 0) {
      if (IsNumber(setCur) && setCur >= 0) {
         this._curIdx := setCur
      }
      if (adjVal != 0 && (adjVal ~= '[+-]' || IsNumber(adjVal))) {
         this._curIdx += adjVal
      }
      if (IsNumber(setNext) && setNext >= 1){
         this._curIdx := setNext-1
      }
      ; ensure valid index
      this._curIdx := max(this._curIdx, 0)
      this._curIdx := min(this._curIdx, this.Length)
   }

   ; Public
   CurIndex => this._curIdx
   Length   => this._lineArr.Length
   HasNext  => this._curIdx < this.Length

   ; Private
   __fillArray() {
      this._lineArr := StrSplit(this._origStr, '`n', '`r')
   }
}