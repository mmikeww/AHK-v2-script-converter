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
#Include Convert/MaskCode.ahk                   ; 2024-06-26 ADDED AMB (masking support)
#Include Convert/1Commands.ahk
#Include Convert/2Functions.ahk
#Include Convert/3Methods.ahk
#Include Convert/4ArrayMethods.ahk
#Include Convert/5Keywords.ahk
#Include Convert/ConvLoopFuncs.ahk              ; 2025-06-12 ADDED AMB (separated loop code)
#Include Convert/Conversion_CLS.ahk             ; 2025-06-12 ADDED AMB (future support of Class version)
#Include Convert/ContSections.ahk               ; 2025-06-22 ADDED AMB (for support dedicated to continuation sections)
#Include Convert/SplitConv/ConvV1_Funcs.ahk     ; 2025-07-01 ADDED AMB (for support of separated conversion)
#Include Convert/SplitConv/ConvV2_Funcs.ahk     ; 2025-07-01 ADDED AMB (for support of separated conversion)
#Include Convert/SplitConv/SharedCode.ahk       ; 2025-07-01 ADDED AMB (code shared for v1 or v2 converssion)
#Include Convert/SplitConv/PseudoHandling.ahk   ; 2025-07-01 ADDED AMB (temp while separating dual conversion)
#Include Convert/SplitConv/LabelAndFunc.ahk     ; 2025-07-06 ADDED AMB
#Include Convert/SplitConv/GuiAndMenu.ahk       ; 2025-07-06 ADDED AMB


; 2025-07-06 AMB, ERROR related to combination of recursion AND global scope
; will cause error when called using a global var, AND performing recursion
; must call from inside a function that has a "copy" of the var (local scope)
; See Mask_T() and Mask_R() within MaskCode.ahk for more info
;   globalVar := "This is a test"
;   Mask_T(&globalVar, 'C&S') ; mask comments and strings (uses recursion)


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
   code := isolateLabels(code)                                      ; 2025-06-22 AMB, ADDED

   ; these must also be declared global here because they are being updated here
   global gAllFuncNames     := getFuncNames(code)                   ; comma-delim stringList of all function names
   global gAllClassNames    := getClassNames(code)                  ; comma-delim stringList of all class names (2025-10-08)
   global gAllV1LabelNames  := getV1LabelNames(code)                ; comma-delim stringList of all orig v1 label names
   global gmAllV2LablNames  := getV2LabelNames(gAllV1LabelNames)    ; map of v1 label names converted to V2 label/funcNames
   global gMenuBarName      := getMenuBarName(code)                 ; name of GUI main menubar

   ; turn masking on/off at top of SetGlobals()
   if (gUseMasking) {
      ; this masking also performs masking for all strings and comments temporarily...
      ; but they are restored prior to exiting this func (behind the scenes)
      Mask_T(&code, 'CSECT2')                                       ; global masking of M2 continuation sections (2025-06-22)
      Mask_T(&code, 'FUNC&CLS')                                     ; global masking of functions and classes
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
      Mask_R(&code, 'FUNC&CLS')             ; remove masking from functions and classes
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
   ; func and label
   global gAllFuncNames          := ""          ; 2024-07-07 - comma-deliminated string holding the names of all functions
   global gAllClassNames         := ""          ; 2024-10-08 - comma-deliminated string holding the names of all classes
   global gAllV1LabelNames       := ""          ; 2024-07-09 - comma-deliminated string holding the names of all v1 labels
   global gmAllV2LablNames       := map()       ; 2024-07-07 - map holding v1 labelNames (key) and their new v2 label/FuncName (value)
   global gmList_LblsToFunc      := map()       ; 2025-10-05 - replaces gaList_LblsToFuncO and gaList_LblsToFuncC
   global gmList_GosubToFunc     := map()       ; 2025-10-05 - AMB, ADDED - tracks gosubs that need to be converted to func calls
   global gmList_HKCmdToFunc     := map()       ; 2025-10-12 - AMB, ADDED - tracks funcs that should be called using 'hotkey' cmd
   global gFuncParams            := ""
   global gmByRefParamMap        := map()       ; Map of FuncNames and ByRef params
   ; gui and menu
   global gMenuBarName           := ""          ; 2024-07-02 - holds the name of the main gui menubar
   global gMenuList              := "|"
   global gmMenuCBChecks         := map()       ; 2024-06-26 AMB, for fix #131
   global gGuiActiveFont         := ""
   global gGuiControlCount       := 0
   global gmGuiCtrlObj           := map()       ; Create a map to return the object of a control
   global gmGuiCtrlType          := map()       ; Create a map to return the type of control
   global gmGuiFuncCBChecks      := map()       ; for gui funcs
   global gGuiList               := "|"
   global gGuiNameDefault        := "myGui"
   global gmGuiVList             := Map()       ; Used to list all variable names defined in a Gui
   global gUseLastName           := False       ; Keep track of if we use the last set name in gGuiList

   global gaScriptStrsUsed       := Array()     ; Keeps an array of interesting strings used in the script
   global gOScriptStr            := Object()    ; now a ScriptCode class object (for future use)
;   global gOScriptStr            := []          ; array of all the lines
   global gEarlyLine             := ""          ; portion of line to process, prior to processing, will not include trailing comment
   global gO_Index               := 0           ; current index of the lines
   global gIndent                := ""
   global gSingleIndent          := ""

   global gEOLComment_Cont       := []          ; 2025-05-24 fix for #296 - comments for continuation sections
   global gEOLComment_Func       := ""          ; _Funcs can use this to add comments at EOL
   global gNL_Func               := ""          ; _Funcs can use this to add New Previous Line
   global gfrePostFuncMatch      := False       ; _Funcs can use this to know their regex matched

   global goWarnings             := Object()    ; global object [with props] to keep track of warnings to add, see FinalizeConvert()
   global gaList_PseudoArr       := Array()     ; list of strings that should be converted from pseudoArray to Array
   global gaList_MatchObj        := Array()     ; list of strings that should be converted from v1 Match Object to v2 Match Object

   global gmOnMessageMap         := map()       ; list of OnMessage listeners
   global gmVarSetCapacityMap    := map()       ; list of VarSetCapacity variables, with definition type
   global gfLockGlbVars          := False       ; flag used to prevent global vars from being changed

   global gLVNameDefault         := "LV"
   global gTVNameDefault         := "TV"
   global gSBNameDefault         := "SB"
   global gaFileOpenVars         := []          ; 2025-10-12 AMB - callection of FileOpen object names

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
; 2024-06-27 ADDED, 2025-06-12 UPDATED, 2025-10-05 UPDATED
; Performs tasks that finalize overall conversion

   ; Add global warnings
   If goWarnings.HasProp("AddedV2VRPlaceholder") && goWarnings.AddedV2VRPlaceholder = 1 {
      code := "; V1toV2: Some mandatory VarRefs replaced with AHKv1v2_vPlaceholder`r`n" code
   }

   ; Fix MinIndex() and MaxIndex() for arrays
   ; 2025-10-05 AMB, UPDATED mask chars
   code := RegExReplace(code, "i)([^(\s]*\.)" gMXPH, '$1Length != 0 ? $1Length : ""')
   code := RegExReplace(code, "i)([^(\s]*\.)" gMNPH, '$1Length != 0 ? 1 : ""')          ; Can be done in 4ArrayMethods.ahk, but done here to add EOLComment

   ; labels named 'OnClipboardChange' require a name change (since OnClipboardChange is now a built in AHK function)
   ; see validV2LabelName() in LabelAndFunc.ahk for the name change to 'OnClipboardChange_v2'
   ; add OnClipboardChange(OnClipboardChange_v2) to top of script, and provide a way to update A_EventInfo within the func, as needed
   ; Update_LBL_HK_HS() below will do the rest
   ; 2025-10-05 AMB, UPDATED
   maskedCode := code, Mask_T(&maskedCode, 'C&S')   ; prevent false positives (for Instr) within strings and comments
   if (InStr(maskedCode, 'OnClipboardChange:')) {
      code := 'OnClipboardChange(OnClipboardChange_v2)`r`n' . code      ; add this to top of script
      gmList_LblsToFunc['OnClipboardChange_v2'] := ConvLabel('OCC', 'OnClipboardChange_v2', 'dataType:=""', 'OnClipboardChange_v2'
                                                , {NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$", Replacement: "$1dataType$2"})
   }

   code := Update_LBL_HK_HS(code)       ; 2025-10-05 AMB, UPDATED conversion for labels,HKs,HSs to v2 format
   Mask_T(&code, 'C&S')                 ; 2025-10-10 AMB, first attempt to improve efficiency of conversion (WORK IN PROGRESS)
   code := FixOnMessage(code)           ; Fix turning off OnMessage when defined after turn off
   code := FixVarSetCapacity(code)      ; &buf -> buf.Ptr   &vssc -> StrPtr(vssc)
   code := FixByRefParams(code)         ; Replace ByRef with & in func declarations and calls - see related fixFuncParams()
   code := FixIncDec(code)              ; 2025-10-10 AMB, ADDED to cover issue #350
   code := RemoveComObjMissing(code)    ; Removes ComObjMissing() and variables

   addGuiCBArgs(&code)
   addMenuCBArgs(&code)                 ; 2024-06-26, AMB - Fix #131
   addOnMessageCBArgs(&code)            ; 2024-06-28, AMB - Fix #136
   addHKCmdCBArgs(&code)                ; 2025-10-12, AMB - Fix #328
   updateFileOpenProps(&code)           ; 2025-10-12, AMB - support for #358

   return   ; code by reference
}
;################################################################################
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
_Catch(p) {
   if (Trim(p[1], '{ `t') = '') {
      if (InStr(p[1], '{'))
         return 'Catch {'
      return 'Catch'
   } if (!InStr(p[1], "Error as")) {
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
_Hotkey(p) {
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-10-12 AMB, UPDATED - to fix issue #328
   LineSuffix := ""
   global gmList_LblsToFunc

   ;Convert label to function

   if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" p[2] ":(?!=)\s")) {
      gmList_LblsToFunc[p[2]] := ConvLabel('HK', p[2], 'ThisHotkey:=""', p[2])
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
      if (SubStr(Trim(P[2]),1,1) = '%') {       ; 2025-10-12 AMB - fix for #328
         p[2]       := ToExp(p[2])              ; remove %, (but we needed to know this was a var and not a str)
         funcName   := addHKCmdFunc(p[2])       ; link var name and func it points to
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
   Out := RegExReplace(Out, "[\h\,]*\)", ")")
   Return Out
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
_Random(p) {
   ; v1: Random, OutputVar, Min, Max
   if (p[1] = "") {
      Return "; V1toV2: Removed Random reseed"
   }
   Out := format("{1} := Random({2}, {3})", p*)
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
_SendRaw(p) {
   p[1] := FormatParam("keysT2E","{Raw}" p[1])
   Return "Send(" p[1] ")"
}
;################################################################################
_SetTimer(p) {
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
   if (p[2] = "Off") {
      Out := format("SetTimer({1},0)", p*)
   } else if (p[2] = 0) {
      Out := format("SetTimer({1},1)", p*) ; Change to 1, because 0 deletes timer instead of no delay
   } else {
      Out := format("SetTimer({1},{2},{3})", p*)
   }
   gmList_LblsToFunc[p[1]] := ConvLabel('ST', p[1], '')

   Return RegExReplace(Out, "[\s\,]*\)$", ")")
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
         ParValue := "&AHKv1v2_vPlaceholder", goWarnings.AddedV2VRPlaceholder := 1
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
/**
 * Removes ComObjMissing and references to it from functions
 * Eg ComValue(0x10, ComObjMissing()) => ComValue(0x10)
 *    ComValue(0x20, VarForComObjMissing) => ComValue(0x20)
 * 2025-10-10 AMB, UPDATED- moved STR masking to FinalizeConvert()
 */
RemoveComObjMissing(ScriptString) {
   if !InStr(ScriptString, 'ComObjMissing()')
      return ScriptString
;   Mask_T(&ScriptString, 'STR')    ; 2025-10-10 - now handled in FinalizeConvert()
   VarsToRemove := []
   EOLComments := Map()
   Lines := StrSplit(ScriptString, "`n", "`r")

   for i, Line in Lines {
      Line := separateComment(Line, &com:=''), EOLComments[i] := com            ; separate comment from line
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
   return RegExReplace(final, '\r\n$')

}