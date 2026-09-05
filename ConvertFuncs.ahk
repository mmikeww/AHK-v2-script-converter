#Requires AutoHotKey v2.0
#SingleInstance Force
CoordMode("tooltip", "screen")                                                          ; for debugging msgs

; 2025-12-24 AMB, MOVED Dynamic Conversion Funcs to AhkLangConv.ahk
#Include Global_Declare.ahk                                                             ; global definitions, classes, etc

; 2025-07-06 AMB, ERROR related to combination of recursion AND global scope
; 2026-05-06 AMB, THIS ERROR SHOULD BE FIXED WITH AHK V2.0.25 PER LEXIKOS
; https://www.autohotkey.com/boards/viewtopic.php?f=14&t=140561#p618103
; will cause error when called using a global var, AND performing recursion
; must call from inside a function that has a "copy" of the var (local scope)
; See Mask_T() and Mask_R() within MaskCode.ahk for more info
;   globalVar := '"This is a test" `; comment'
;   Mask_T(&globalVar, 'C&S') ; mask comments and strings (uses recursion)
;   MsgBox "[" globalVar "]"

;################################################################################
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-24 AMB, UPDATED to support progress-gui
Convert(code)                                                                           ; MAIN ENTRY POINT for conversion process
{
   ;####  PLEASE DO NOT PLACE ANY OF YOUR CODE IN THIS FUNCTION  #####

   ; Please place any code that must be performed BEFORE _convertLines()...
   ;  ... into the following function
   Before_LineConverts(&code)
   Prog.ULog(10)                                                                        ; update UI - 10% complete

   ; DO NOT PLACE YOUR CODE HERE
   ; perform line conversions
   ; [to test WITHOUT using Macro Scope, change fUseScope flag to 0 (below)]
   code := (fUseScope:=1) ? convertLines_UseScope(code,50)
                          : convertLines_NoScope(code,40)
   Prog.ULog(60)                                                                        ; update UI - 60% complete

   ; Please place any code that must be performed AFTER _convertLines()...
   ;  ... into the following function
   After_LineConverts(&code)
   Prog.ULog(100)                                                                       ; update UI - 100% complete

   return code                                                                          ; . 'fail for debugging'
}
;################################################################################
; Provides option for testing without using Macro Scope
; 2025-11-01 AMB, ADDED
; 2026-05-06 AMB, UPDATED to provide progress tracking
convertLines_NoScope(code,tProg:=0)
{
   Prog.ULog(,'Restoring masks...'), Mask_R(&code,['MLPBT','IWTLFS','C&S'])             ; remove all masking except V1MLS
   Prog.ULog(12,'Masking continuation sections...'), Mask_T(&code,'CSECT2')             ; mask all method-2 continuation sections
   Prog.ULog(15,'Masking classes and functions...'), Mask_T(&code,'FUNC&CLS')           ; mask funcs/classes
   Prog.ULog(20,'Converting lines...')
   return _convertLines(code,tProg)                                                     ; convert lines from top to bottom
}
;################################################################################
; Supports processing global-code first (by default)
;  change fGblOrder flag to 0 to test orig-order processing
; 2025-11-01 AMB, ADDED to support Scope
; 2026-01-24 AMB, UPDATED to support progress-gui
; 2026-05-26 AMB, UPDATED as part of fix for #488
convertLines_UseScope(code,tProg)
{
   curProg          := Prog.curProg                                                     ; get current progress percentage
   Prog.ULog(,'Getting Script Sections...')                                             ; update UI
   sects            := GetScopeSections(code)                                           ; get Macro-Scope sections
   Prog.ULog(,'Processing Script Sections...')                                          ; update UI

   if (fGblOrder    :=1) {                                                              ; if global code should be processed first...
      origOrder     := Map_I()                                                          ; [will keep track of orig section order]
      gblOrder      := StrSplit(clsSectList.OrderGlobal(sects), ',')                    ; get global-first index ordering
      gfNewScope    := false                                                            ; ini
      sectCount     := gblOrder.Length, progInc := (tProg/sectCount)                    ; calc average progress percent for each section
      for idx, index in gblOrder {                                                      ; for each order index...
         Prog.ULog(,'Processing Section ' idx ' of ' sectCount '...')                   ; ... update UI
         curSect        := sects[index].sectCode                                        ; ... grab section code for that index
         curType        := sects[index].sectType                                        ; ... grab section type for that index
         Mask_T(&curSect,'CSECT2'), Mask_T(&curSect,'FUNC&CLS')                         ; ... mask M2 continuation sections, funcs/classes
         convSect       := _convertLines(curSect)                                       ; ... convert lines within section
         mKey           := format('{:04}', index)                                       ; [ensures orig section order is maintained when reassembled]
         origOrder[mKey]:= convSect                                                     ; place converted section into map
         curProg        += progInc, Prog.ULog(curProg)                                  ; update UI with progress percent
      }
      outStr := ''                                                                      ; [will become reassembled/output script string]
      for idx, convSect in origOrder {                                                  ; for each converted section...
         outStr .= convSect                                                             ; ... add it to output, reassemble script string
      }
   }
   else {   ; process sections in orig order (top to bottom)
      outStr    := ''                                                                   ; [will become reassembled/output script string]
      sectCount := sects.Length, progInc := (tProg/sectCount)                           ; calc average progress percent for each section
      for idx, sect in sects {                                                          ; for each section (original order)...
         sectStr := sect.sectCode                                                       ; ... grab sect code
         Prog.ULog(,'Processing Section ' idx ' of ' sectCount '...')                   ; ... update UI
         Mask_T(&sectStr,'CSECT2'), Mask_T(&sectStr,'FUNC&CLS')                         ; ... mask M2 continuation sections, funcs/classes
         convSect := _convertLines(sectStr)                                             ; ... convert lines within section
         outStr   .= convSect                                                           ; ... add converted sect to output, reassemble script string
         curProg  += progInc, Prog.ULog(curProg)                                        ; ... update UI with progress percent
      }
   }
   Prog.ULog(,'Processing Sections - COMPLETE')                                         ; update UI - sections complete
   Mask_R(&outStr,'CSECT2')                                                             ; 2026-05-26, part of fix for #488
   return outStr                                                                        ; return converted/output str
}
;################################################################################
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-24 AMB, UPDATED to support progress-gui
Before_LineConverts(&code)
{
   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   pp := 'Pre Process - '
   Prog.UPath(gFilePath), Prog.ULog(,,A_ThisFunc ' [IN]'            )                   ; update UI - file path and debug
   Prog.ULog(1, pp 'Set Globals...'                                 )                   ; update UI - 1% complete
      setGlobals()                                                                      ; initialize all global vars here so ALL code has access to them
   Prog.ULog(,  pp 'Isolated labels...'                             )                   ; update UI
      code := isolateLabels(code)                                                       ; 2025-06-22 AMB, move labels to their own line as needed
   Prog.ULog(,  pp 'Get Func names...'                              )                   ; update UI
      global gAllFuncNames     := getFuncNames(code)                                    ; comma-delim stringList of all function names
   Prog.ULog(2, pp 'Get Class names...'                             )                   ; update UI - 2% complete
      global gAllClassNames    := getClassNames(code)                                   ; comma-delim stringList of all class names (2025-10-08)
   Prog.ULog(4, pp 'Get V1 Label names...'                          )                   ; update UI - 4% complete
      global gAllV1LabelNames  := getV1LabelNames(code)                                 ; comma-delim stringList of all orig v1 label names
   Prog.ULog(5, pp 'Get V1 Variable names...'                        )                  ; 2026-09-05 LOCAL (breakage #12)
      global gAllVarNames      := collectVarNames(code)                                 ; 2026-09-05 - identifiers used as variables (label-turned-function cannot collide)
   Prog.ULog(6, pp 'Get V2 Label names...'                          )                   ; update UI - 6% complete
      global gmAllV2LablNames  := getV2LabelNames(gAllV1LabelNames)                     ; map of v1 label names converted to V2 label/funcNames
   Prog.ULog(7, pp 'Get MenuBar name...'                            )                   ; update UI - 7% complete
      global gMenuBarName      := getMenuBarName(code)                                  ; name of GUI main menubar
      ;global gmAltLabel        := GetAltLabelsMap(code)                                ; 2025-11-28 AMB - no longer needed, causes gLabel routing issues
   Prog.ULog(8, pp 'Goto/Gui/HK/Ternary...'                         )                   ; update UI - 8% complete
      PreProcessLines(&code)   ; changes orig code                                      ; 2025-11-23 AMB, ADDED as part of fix for #413
      global gOrigScript       := code                                                  ; 2025-11-01 AMB, ADDED as part of Scope support
   Prog.ULog(9, pp 'Get V1 Flags...'                                )                   ; update UI - 9% complete
      getScriptStringsUsed(code)                                                        ; 2025-11-01 AMB, ADDED as part of Scope support
   Prog.ULog(,  '',A_ThisFunc ' [OUT]'                              )                   ; update UI - debug
   return                                                                               ; code by reference
}
;################################################################################
; 2025-11-01 AMB, UPDATED as part of Scope support
After_LineConverts(&code)
{
   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   ; operations that must be performed last
   ; inspect to see whether your code is best placed here or in the following
   FinalizeConvert(&code)                                                               ; perform all final operations

   return    ; code by reference
}
;################################################################################
; Pre-processing of certain commands via single-iteration of script lines
; 2025-11-23 AMB, ADDED - part of fix for #413
; 2026-03-11 AMB, UPDATED to detect dynamic naming requirements for Gui/GuiControls
; 2026-03-14 AMB, UPDATED to ensure dynamic include file is found
PreProcessLines(&code)
{
   global gDynGuiNaming, gfHasDynamicGui ;, gAutoGuiNaming

   gfHasDynamicGui  := false
   gDynGuiNaming    := (!gAutoGuiNaming) ? gDynGuiNaming : false                        ; set dynamic-naming to DISABLED (initially) when naming is set to Auto

   Mask_T(&code, 'C&S')
   nGoto       := '(?im)^(\h*)(GOTO)(.+)'                                               ; needle for 'Goto, Label'
   nHK         := '(?im)^(\h*)' gPtn_HOTKEY . '(?<cmd>.*)'                              ; needle for full HK line
   nTernary    := '\?[^:]+:.+'
   lines       := StrSplit(code, '`n', '`r')                                            ; separate all lines within Code
   outStr      := ''                                                                    ; ini output
   ternaryList := ''
   TagQS       := UniqueTag('QS\w+')
   boundQSL    := '(?<!^|\h|,|:|\(|\{|\[|<|=)' TagQS
   boundQSR    := TagQS '(?!\h|,|:|\.|\)|\}|\]|>|$)'
   for idx, line in lines {                                                             ; for each line in script...
      if (line ~= nGoto) {                                                              ; if line has a Goto command...
         line := convertGoto(line, idx, &lines)                                         ; ... convert Goto
      }
      ; HOTKEY
      else if (RegExMatch(line, nHK, &m) && m.cmd) {                                    ; if line is HK with possible cmd on same line...
         line := HK1LToML(line, idx, &lines)                                            ; ... see if cmd needs multi-line instead
      }
      ; GUI related
      else if (line ~= '(?i)GUI') {                                                     ; if line has 'GUI' string
         if (detectDynamicGuiState(line)                                                ; if line has dynamic gui content...
         &&  !dynIncludeExist()) {  ; see GuiAlt.ahk                                    ; ... BUT dynamic Include file is missing...
			ExitApp                                                                     ; ... terminate conversion (redundant - terminates as part of call)
         }
      }
      outStr  .= line '`r`n'                                                            ; add line to output str
   }
   clsGuiObj.ResetDefaultGuiNames()
   code := RegExReplace(outStr, '\r\n$',,,1)                                            ; update code (also remove very last CRLF)
   code := UnZip(code, 'GOTORET')                                                       ; handle GotoReturn - add braces to IF/ELSEIF/ELSE as needed
   return                                                                               ; return Code by reference
}
;################################################################################
; scopeCode - can be entire script string, or a limited portion of code
; when term is NOT specified...
;   sets global flags as needed (scopeCode param should be entire script)
; when term is specified...
;   scopeCode param should be set to code of limited scope
;   sets flag for term (output-option one)
;   also returns whether term was found in scopeCode
; 2025-11-01 AMB, ADDED as part of Scope support
getScriptStringsUsed(scopeCode, term:='')
{
   global gaScriptStrsUsed

   ; First, remove false positives hiding in comments and strings
   maskStr := scopeCode                                                                 ; ini
   Mask_T(&maskStr, 'C&S',1), Mask_T(&maskStr, 'V1MLS')                                 ; hide comments/strings

   ; set flags as needed
   if (!term) { ; target all these within entire script
      gaScriptStrsUsed.ErrorLevel      := EL    := !!InStr(maskStr, 'ErrorLevel')       ; if Errorlevel   is found in script
      gaScriptStrsUsed.A_GuiControl    := AGC   := !!InStr(maskStr, "A_GuiControl")     ; if A_GuiControl is found in script
      gaScriptStrsUsed.StringCaseSense := SCS   := !!InStr(maskStr, 'StringCaseSense')  ; Both command and A_ variable
      return (EL||AGC||SCS)
   }
   gaScriptStrsUsed.%term%             := found := !!InStr(maskStr, term)               ; set flag in case caller does not set it manually
   return found                                                                         ; return true if 'term' is found in scopeCode
}
;################################################################################
; MAIN CONVERSION LOOP - handles each line separately
; 2025-06-12 AMB, UPDATED
;   moved most operations to external funcs for modular design (SEE ConvLoopFuncs.ahk)
;   removed finalize parameter and optional step at bottom of function
;   changed gOSriptStr from array to class object - prep for more functionality later
;   added block-comment masking as a global condition for full ScriptString
;   changed many variable and function names
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-01 AMB, UPDATED - changed global gEarlyLine to gV1Line
; 2026-01-24 AMB, UPDATED to support progress-gui
; 2025-05-06 AMB, UPDATED with optional progress update
_convertLines(ScriptString,tProg:=0)
{
   Mask_T(&ScriptString, 'BC')                                                          ; 2025-06-12 AMB, mask all block-comments globally

   global gOrig_ScriptStr   := ScriptString
   global gaList_PseudoArr  := []                                                       ; 2025-11-01 AMB, ADDED here as part of Scope support
   global gV1Line           := ''                                                       ; 2026-01-01 changed name from gEarlyLine
;   global gOScriptStr       := StrSplit(ScriptString, '`n', '`r')                      ; array for all the lines
   global gOScriptStr       := ScriptCode(ScriptString)                                 ; now a class object, for future use
   global gO_Index          := 0                                                        ; current index of the lines
   global gIndent           := ''
   global gSingleIndent     := (RegExMatch(ScriptString, '(^|[\r\n])( +|\t)', &ws))     ; first spaces or single tab found
                            ?  ws[2]
                            : '    '
          gSingleIndent     := StrLen(gSingleIndent) > 4 ? '    ' : gSingleIndent       ; in case of unusual LWS
   global gNL_Func          := ''                                                       ; _Funcs can use this to add New Previous Line
   global gEOLComment_Func  := ''                                                       ; _Funcs can use this to add comments at EOL
   global gEOLComment_Cont  := []                                                       ; 2025-05-24 Banaanae, ADDED for fix #296
   global gaScriptStrsUsed

   ; 2025-05-06 AMB, ADDED optional progress update
   if (tProg) {
      lineCount := gOScriptStr.Length
      curProg   := Prog.curProg
      progInc   := (tProg/lineCount)
   }
   ScriptOutput                     := ''
   getScriptStringsUsed(ScriptString, 'IfMsgBox')                                       ; 2025-10-28 Banaanae (limit scope boundary to current section only)

   ; parse each line of the input script, convert line as required
   Loop {
      gO_Index++

;      if (gOScriptStr.Length < gO_Index) {
      if (!gOScriptStr.HasNext) {
         ; This allows the user to add or remove lines if necessary
         ; Do not forget to change the gO_Index if you want to remove
         ;   or add the line above or lines below
         break
      }

      ; 2025-05-06 AMB, ADDED optional progress update
      if (tProg) {
         msg := 'Processing Line ', curProg += progInc                                  ; update prog details
         Prog.ULog(curProg, msg gO_Index ' of ' lineCount '...')                        ; update UI
	  }

      ;curLine           := gOScriptStr[gO_Index]                                        ; current line string to be converted
      curLine           := gOScriptStr.GetNext                                          ; current line string to be converted
      Prog.ULog(,,,gO_Index,Trim(curLine))                                              ; update UI - debug
      gIndent           := RegExReplace(curLine,'^(\h*).*','$1')                        ; original line indentation (if present)
      EOLComment        := lp_DirectivesAndComment(&curLine)                            ; process character directives and extract initial trailing comment from line
      lineOpen          := lp_SplitLine(&curLine)                                       ; see lp_splitLine() for details
      ; TODO - set to LTrim(curLine) instead ?
      gV1Line           := curLine                                                      ; portion of line to process [prior to processing], has no trailing comment
      lineClose         := ''                                                           ; initial value, used later
      gEOLComment_Cont  := [EOLComment]                                                 ; 2025-05-24 fix for #296 - support for multiple comments within line continuations

      /*
      TODO - for v1.0 -> v1.1 conversion idea... will need to separate v1 from v2
         processing within most of the following operations. Currently v1.0 -> v1.1
         conversion is not possible until the operations are separated. This will
         happen in phase 2 of redesign
      */
      ; ORDER MAY MATTER FOR FOLLOWING STEPS...
      addContsToLine(&curLine, &EOLComment)                                             ; Adds continuation lines to current line - TODO - USE CONT-MASKING ??
      fixAssignments(&curLine)                                                          ; line conversions related to assignments [var= and var:=] (v1/v2)
      v1_convert_Ifs(&curLine, &lineOpen)                                               ; line conversions related to IF (v1)
      v2_convert_Ifs(&curLine, &lineOpen, &lineClose)                                   ; line conversions related to IF (v2)

      fCmdConverted := false                                                            ; will be set by v2_AHKCommand() thru v2_Conversions() below
;      if (gV2Conv) {     ; 2025-07-03 - REMOVED TEMPORARILY                            ; v2, but currently required for v1 conversion also
         v2_Conversions(&curLine, &lineOpen, &EOLComment                                ; line conversions related to V2 only (currently required for v1 conv also)
                      , &fCmdConverted, scriptString)                                   ; SETS VALUE of fCmdConverted (indirectly)
;      }

      ; these must come AFTER v2_Conversions()
      lp_DisableInvalidCmds(&curLine, fCmdConverted)                                    ; disable commands no longer supported (turns them into comments)
      curLine := lineOpen . curLine . lineClose                                         ; reassemble line parts
      lp_PostConversions(&curLine)                                                      ; processing for current line that must be performed last
      ScriptOutput .= lp_PostLineMsgs(&curLine,&EOLComment)                             ; update conversion messages (to user) for current line. This is final line output.
   }  ; END of individual-line conversions (loop)

   ; trim the very last (extra) newline from output string
   ScriptOutput := RegExReplace(ScriptOutput, '\r\n$',,,1)                              ; 2025-06-12 MOVED to here to eliminate multiple 'finalize' paths/processing
   Mask_R(&ScriptOutput, 'BC')                                                          ; 2025-06-12 AMB, Restore all block-comments
   return ScriptOutput
}
;################################################################################
; Performs tasks that finalize overall conversion
; 2024-06-27 ADDED, 2025-06-12, 2025-10-05, 2026-01-01 UPDATED
; 2026-01-24 AMB, UPDATED to support progress-gui
; 2026-03-08 AMB, UPDATED to add static kywd to methods as needed
; 2026-03-14 AMB, UPDATED to copy dynamic include file to global library, as needed
; 2026-03-29 AMB, UPDATED to move dynamic gui support to dedicated func
FinalizeConvert(&code)
{
   pp := 'Post Process - '
   Prog.ULog(,  pp 'Restore Classes/Funcs...', A_ThisFunc       )                       ; update UI - current operation, debug
      Mask_R(&code, 'FUNC&CLS')                                                         ; remove masking from classes/funcs (returned as v2 converted)
   Prog.ULog(65,pp 'Expand zipped lines...'                     )                       ; update UI - current operation - 65% complete
      code := UnZip(code)                                                               ; 2025-11-30 AMB, expand ML code added by converter, add braces to blocks as needed
   Prog.ULog(,  pp 'VarRefs and OnClipboardChange...'           )                       ; update UI - current operation
      code := addToCode(code)                                                           ; 2026-01-01 AMB, add messages and directives to code
   Prog.ULog(70,pp 'Labels/Hotkeys/Hotstrings...'               )                       ; update UI - current operation - 70% complete
      code := Update_LBL_HK_HS(code)                                                    ; 2025-10-05 AMB, UPDATED conversion for labels,HKs,HSs to v2 format
   Prog.ULog(80,pp 'Premask Comments/Strings...'                )                       ; update UI - current operation - 85% complete
      Mask_T(&code, 'C&S')                                                              ; 2025-10-10 AMB, first attempt to improve efficiency of conversion (WORK IN PROGRESS)
   Prog.ULog(,  pp 'Fix Min/MaxIndex...'                        )                       ; update UI - current operation
      code := FixMinMaxIndex(code)                                                      ; 2025-12-21 AMB, MOVED to dedicated func
   Prog.ULog(,  pp 'Fix OnMessage...'                           )                       ; update UI - current operation
      code := FixOnMessage(code)                                                        ; Fix turning off OnMessage when defined after turn off
   Prog.ULog(,  pp 'Fix VarSetCapacity...'                      )                       ; update UI - current operation
      code := FixVarSetCapacity(code)                                                   ; &buf -> buf.Ptr   &vssc -> StrPtr(vssc)
   Prog.ULog(,  pp 'Fix ByRef Params...'                        )                       ; update UI - current operation
      code := FixByRefParams(code)                                                      ; Replace ByRef with & in func declarations and calls - see related fixFuncParams()
   Prog.ULog(,  pp 'Fix Increment/Decrement...'                 )                       ; update UI - current operation
      code := FixIncDec(code)                                                           ; 2025-10-10 AMB, ADDED to cover issue #350
   Prog.ULog(,  pp 'Fix string + concat...'                     )                       ; 2026-09-05 LOCAL (breakage #11)
      FixStrPlusConcat(&code)                                                           ; "text"+var -> "text" . var (v2 forbids + after a literal string)
   Prog.ULog(,  pp 'Fix empty ternary condition...'             )                       ; 2026-09-05 LOCAL (breakage #7)
      FixEmptyTernaryCond(&code)                                                        ; '() ? a : b' -> '(false) ? a : b'
   Prog.ULog(,  pp 'Fix empty first param...'                   )                       ; 2026-09-05 LOCAL (breakage #7)
      FixEmptyFirstParam(&code)                                                         ; 'F(, x)' -> 'F("", x)' (comma hole is a v2 load error)
   Prog.ULog(,  pp 'Fix map literals...'                        )                       ; 2026-09-05 LOCAL (breakage #25)
      FixMapLiterals(&code)                                                             ; '{} / Object() -> Map() + read/remove shims (fork: no __Item)
   Prog.ULog(,  pp 'Fix chained assignment...'                  )                       ; 2026-09-05 LOCAL (breakage #17)
      FixChainedAssign(&code)                                                           ; 'a := f() := b' -> 'a := b' (assignment-chain to a call)
   Prog.ULog(,  pp 'Fix func/var name conflicts...'             )                       ; 2026-09-05 LOCAL (breakage #12)
      FixFuncVarConflict(&code)                                                         ; func name == variable name -> rename the func
   Prog.ULog(,  pp 'Fix reserved var names...'                   )                       ; 2026-09-05 LOCAL (breakage #13)
      FixReservedVarNames(&code)                                                        ; v2 builtin class used as variable -> suffix _v
   Prog.ULog(,  pp 'Remove ComObjMissing...'                    )                       ; update UI - current operation
      code := RemoveComObjMissing(code)                                                 ; Removes ComObjMissing() and variables
   Prog.ULog(,  pp 'Add CB Args for Gui...'                     )                       ; update UI - current operation
      addGuiCBArgs(&code)                                                               ; Add args to Gui callback funcs
   Prog.ULog(,  pp 'Add CB Args for Menu...'                    )                       ; update UI - current operation
      addMenuCBArgs(&code)                                                              ; 2024-06-26, AMB - Fix #131
   Prog.ULog(,  pp 'Add CB Args for OnMessage...'               )                       ; update UI - current operation
      addOnMessageCBArgs(&code)                                                         ; 2024-06-28, AMB - Fix #136
   Prog.ULog(,  pp 'Add CB Args for Hotkey Command...'          )                       ; update UI - current operation
      addHKCmdCBArgs(&code)                                                             ; 2025-10-12, AMB - Fix #328
   Prog.ULog(,  pp 'Add Static keyword to methods...'           )                       ; update UI - current operation
      addStaticKywdToMethod(&code)                                                      ; 2026-03-08, AMB - add static keyword to methods that require it
   Prog.ULog(,  pp 'Update FileOpen Properties...'              )                       ; update UI - current operation
      updateFileOpenProps(&code)                                                        ; 2025-10-12, AMB - support for #358
   Prog.ULog(,  pp 'Add support for Dynamic Gui...'             )                       ; update UI - current operation
      addDynGuiSupport(&code)                                                           ; add support for dynamic Gui, as needed
   Prog.ULog(,  pp 'Restore Continuation Sections...'           )                       ; update UI - current operation
      Mask_R(&code, 'CSect')                                                            ; restore remaining cont sects (returned as v2 converted)
   Prog.ULog(,  pp 'Restore Multi-line Parentheses Blocks...'   )                       ; update UI - current operation
      Mask_R(&code, 'MLPBT')                                                            ; restore remaining ML parentheses blocks (with opt trailer)
   Prog.ULog(,  pp 'Restore V1 Multi-line String Blocks...'     )                       ; update UI - current operation
      Mask_R(&code, 'V1MLS')                                                            ; restore remaining V1 ML strings
   Prog.ULog(,pp 'Adding return before HKs...'                  )                       ; update UI - current operation
      HKReturn(&code)                                                                   ; add return before each HK
   Prog.ULog(,pp 'Removing redundant exit commands...'          )                       ; update UI - current operation
      FixRedundantExits(&code)                                                          ; remove redundant/unnecessary exit commands
   Prog.ULog(,pp 'Fix one-line empty Catch blocks...'           )                       ; update UI - current operation
      FixEmptyCatch(&code)                                                              ; }catch{} -> }catch{`r`n} (illegal in v2)
   Prog.ULog(,pp 'Fix orphan Try+comment lines...'              )                       ; update UI - current operation
      FixOrphanTryComment(&code)                                                         ; try ;comment -> try { ;comment } (illegal in v2)
   Prog.ULog(,pp 'Fix $ variable names...'                      )                       ; update UI - current operation
      FixDollarVars(&code)                                                               ; $var -> Dollar_var (illegal in v2)
   Prog.ULog(90,pp 'Restore Comments/Strings...'                )                       ; update UI - current operation - 90% complete
      Mask_R(&code, 'C&S')                                                              ; ensure all comments/strings are restored (just in case)
   Prog.ULog(,  pp 'Fix semicolons in strings...'                )                      ; 2026-09-05 LOCAL
      FixSemiInStrings(&code)                                                           ; fork: raw ' ;' inside strings starts a comment (see func)
   Prog.ULog(,  pp 'Fix HotIf in functions...'                   )                      ; 2026-09-05 LOCAL (breakage #16)
      FixHotIfInFunc(&code)                                                             ; '#HotIf' packaged into a GblCode func -> lift to top level
   Prog.ULog(,  pp 'Fix leading-digit vars...'                   )                      ; 2026-09-05 LOCAL (breakage #14)
      FixLeadingDigitVars(&code)                                                        ; '32770Hwnd' -> 'Hwnd32770' (v2 rejects digit-leading names)
   Prog.ULog(,  pp 'Fix ptr addr args...'                       )                       ; 2026-09-05 LOCAL (breakage #3/#18)
      FixPtrAddrArgs(&code)                                                             ; multiline-DllCall '&var' ptr args + missing output '&'
                                                                                         ; NB: must run on RESTORED text - the C&S mask hides the
                                                                                         ; quoted type strings ('"ptr"') this sweep matches.
   Prog.ULog(,  pp 'Add V1toV2 helpers...'                       )                      ; 2026-09-05 LOCAL
      code := AddV1toV2Helpers(code)                                                    ; prepend shim funcs flagged during conversion

   return                                                                               ; code by reference
}
;################################################################################
; Adds global warnings, etc
; 2026-01-01 AMB, ADDED
addToCode(code) {

   If (goWarnings.HasProp("AddedV2VRPlaceholder") && goWarnings.AddedV2VRPlaceholder = 1) {
      code := "; V1toV2: Some mandatory VarRefs replaced with AHKv1v2_vPlaceholder`r`n" code
   }
   ; 2025-12-24 AMB, ADDED - Moved code here from FinalizeConvert
   ; labels named 'OnClipboardChange' require a name change
   ; see validV2LabelName() in LabelAndFunc.ahk for the name change to 'OnClipboardChange_v2'
   ; add OnClipboardChange(OnClipboardChange_v2) to top of script, and provide a way to update A_EventInfo within the func, as needed
   maskedCode := code, Mask_T(&maskedCode, 'C&S')   ; prevent false positives (for Instr) within strings and comments
   if (InStr(maskedCode, 'OnClipboardChange:')) {
      code := 'OnClipboardChange(OnClipboardChange_v2)`r`n' . code      ; add this to top of script
      gmList_LblsToFunc['OnClipboardChange_v2'] := clsConvLabel('OCC', 'OnClipboardChange_v2', 'dataType:=""', 'OnClipboardChange_v2'
                                                , {NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$", Replacement: "$1dataType$2"})
   }
   return code
}
;################################################################################
; Adds final elements to support dynamic gui handling
; 2026-03-29 AMB, ADDED
; https://www.autohotkey.com/docs/v2/Scripts.htm#lib
addDynGuiSupport(&code) {                                                               ; Adds support for dynamic gui handling (if needed)
   if (!gfHasDynamicGui)                                                                ; if script does not have dynamic gui elements...
      return                                                                            ; ... do not add this support
   cd := code, trail := '', funcStr := '', str := '', indent := '    '                  ; ini
   if (funcStr := buildCtrlVarAssignFunc(indent))                                       ; if script has gui ctrl vars...
      cd := separateTrailCWS(code, &trail,1)                                            ; ... separate trailing comments from main script code
   str   .= '#Include <v2DynGui> `; V1toV2: v2DynGui.ahk in library folder`r`n'         ; add dynamic include (
   str   .= (funcStr) ? gGuiCtrlVarAssignFN : ''                                        ; add ctrlvarIni func CALL as needed
   str   .= (funcStr) ? ' `; V1toV2: initialize gui ctrl vars`r`n' : ''                 ; add msg for func call
   trail := (funcStr) ? ('`r`n' funcStr trail) : trail                                  ; add ctrlvarIni FUNC      as needed
   code  := str . cd . trail                                                            ; add dynamic strings to code
   dynIncludeToLib()                                                                    ; copy dynamic include file to global library, as needed
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
; Updates MnxIndex handling
; 2025-12-21 AMB, ADDED
FixMinMaxIndex(code) {
   nStrSplit    := '(?i)(STRSPLIT' gPtn_PrnthBlk '\.)'
   nSqBktArr    := '(?i)((?<!\w)' gPtn_SqrBkts '\.)'
   nOther       := '(?i)(([\w.]|\[[^\]]*+\])+\.)'
   nMinIdx      := 'MinIndex\(\)',  nMaxIdx := 'MaxIndex\(\)'
   nMinRepl     := '(($1Length) ? 1 : 0)', nMaxRepl := '$1Length'
   code         := RegExReplace(code, nStrSplit . nMinIdx, nMinRepl)
   code         := RegExReplace(code, nStrSplit . nMaxIdx, nMaxRepl)
   code         := RegExReplace(code, nSqBktArr . nMinIdx, nMinRepl)
   code         := RegExReplace(code, nSqBktArr . nMaxIdx, nMaxRepl)
   code         := RegExReplace(code, nOther    . gMNPH, nMinRepl)
   code         := RegExReplace(code, nOther    . gMXPH, nMaxRepl)
   return       code
}
;################################################################################
; Processing of character directives and line comment
; 2025-06-12 AMB, ADDED
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
lp_DirectivesAndComment(&lineStr) {
   ; if current line is char-directive declaration, grab the attributes
   if (RegExMatch(lineStr, 'i)^\h*#(CommentFlag|EscapeChar|DerefChar|Delimiter)\h+.')) {
      _grabCharDirectiveAttribs(lineStr)
      return ''                                                                         ; might need to change this to actual line comment (EOLComment)
   }
   ; not a char-directive declaration - update comment character on current line
   if (HasProp(gaScriptStrsUsed, 'CommentFlag')) {
      char    := HasProp(gaScriptStrsUsed, 'EscapeChar') ? gaScriptStrsUsed.EscapeChar : '``'
      lineStr := RegExReplace(lineStr, '(?<!\Q' char '\E)\Q' gaScriptStrsUsed.CommentFlag '\E', ';')
   }

   ; separate trailing comment from current line temporarily, will put it back later
   lineStr    := separateComment(lineStr, &EOLComment:='')

   ; update EscapeChar, DeRefChar, Delimiter for current line
   deref := '``'
   if (HasProp(gaScriptStrsUsed, 'EscapeChar')) {
      deref    := gaScriptStrsUsed.EscapeChar
      lineStr  := StrReplace(lineStr, '``', '``````')
      lineStr  := StrReplace(lineStr, gaScriptStrsUsed.EscapeChar, '``')
   }
   if (HasProp(gaScriptStrsUsed, 'DerefChar')) {
      lineStr  := RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.DerefChar '\E', '%')
   }
   if (HasProp(gaScriptStrsUsed, 'Delimiter')) {
      lineStr  := RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.Delimiter '\E', ',')
   }

   return EOLComment                                                                    ; return trailing comment for current line

   ;############################################################################
   ; Processing of character directives
   ;  (for cleaner conversion loop, and v1.0 => v1.1 conversion)
   ; only one of these directives may be found on current line
   ; sets data within gaScriptStrsUsed for use later
   ; 2025-06-12 AMB, ADDED
   ; 2025-12-24 AMB, UPDATED - converted to internal func
   _grabCharDirectiveAttribs(lineStr) {
      global gaScriptStrsUsed

      ; does line contain #CommentFlag directive?
      if (RegExMatch(lineStr, 'i)^\h*+#CommentFlag\h++(\S{1,15})', &m)) {
         gaScriptStrsUsed.CommentFlag := m[1]
         return
      }
      ; does line contain #EscapeChar directive?
      if (RegExMatch(lineStr, 'i)^\h*+#EscapeChar\h++(\S)', &m)) {
         gaScriptStrsUsed.EscapeChar := m[1]
         return
      }
      ; does line contain #DerefChar directive?
      if (RegExMatch(lineStr, 'i)^\h*+#DerefChar\h++(\S)', &m)) {
         gaScriptStrsUsed.DerefChar := m[1]
         return
      }
      ; does line contain #Delimiter directive?
      if (RegExMatch(lineStr, 'i)^\h*+#Delimiter\h++(\S)', &m)) {
         gaScriptStrsUsed.Delimiter := m[1]
         return
      }
      return   ; nothing
   }
}
;################################################################################
; Purpose: Remove/Disable incompatible commands (that are no longer allowed)
; V1 and V2, but with different commands for each version
; 2025-06-12 AMB, MOVED to dedicated routine for cleaner convert loop
; 2025-10-08 AMB, UPDATED to fix #375
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
; 2026-01-01 AMB, UPDATED - changed global gEarlyLine to gV1Line
; 2026-03-08 AMB, UPDATED - added LTrim to gV1Line
lp_DisableInvalidCmds(&lineStr, fCmdConverted) {
   fDisableLine := false
   if (!fCmdConverted) {                                                                ; if a targeted command was found earlier...
      Loop Parse, gAhkCmdsToRemoveV1, '`n', '`r' {                                      ; [check for v1 deprecated]
         targStr:= escRegexChars(A_LoopField)                                           ; prep for regex check
         lead   := (A_LoopField ~= '^#') ? '' : '\b'                                    ; add word boundary to beginning of needle, but only when hash char not present
         nTarg  := '(?i)' lead targStr '\b'                                             ; needle to cover all scenarios in gAhkCmdsToRemoveV1
         if (LTrim(gV1Line) ~= nTarg)                                                   ; ... is that command invalid after v1.0?
            fDisableLine := true                                                        ; flag it as invalid
      }
      if (gV2Conv) {                                                                    ; v2
         Loop Parse, gAhkCmdsToRemoveV2, '`n', '`r' {                                   ; [check for v2 deprecated]
            targStr := escRegexChars(A_LoopField)                                       ; prep for regex check
            lead    := (A_LoopField ~= '^#') ? '' : '\b'                                ; add word boundary to beginning of needle, but only when hash char not present
            nTarg   := '(?i)' lead targStr '\b'                                         ; needle to cover all scenarios in gAhkCmdsToRemoveV2
            if (LTrim(gV1Line) ~= nTarg)                                                ; ... is that command invalid after v2?
               fDisableLine := true                                                     ; flag it as invalid
         }
         if (lineStr ~= '^\h*(\blocal\b)\h*$')  {                                       ; V2 Only - only force-local
            fDisableLine := true                                                        ; flag it as invalid
         }
      }
   }
   ; Remove commands by turning line into a comment that describes the removed item
   if (fDisableLine) {
      if (lineStr ~= 'Sound(Get)|(Set)Wave') {
         lineStr := format('; V1toV2: Not currently supported -> {1}', lineStr)
      } else {
         lineStr := format('; V1toV2: Removed {1}', lineStr)
      }
   }
   return      ; lineStr by reference
}
;################################################################################
; 2025-06-12 AMB, MOVED to dedicated routine for cleaner convert loop
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
;   TODO - See if these can be combined in v2_Conversions
lp_PostConversions(&lineStr) {
   v1v2_FixNEQ(&lineStr)                                                                ; Convert <> to !=
   v2_PseudoAndRegexMatchArrays(&lineStr)                                               ; mostly v2 (separating...)
   v2_RemoveNewKeyword(&lineStr)                                                        ; V2 ONLY! Remove New keyword from classes
   v2_RenameKeywords(&lineStr)                                                          ; V2 ONLY
   v2_RenameLoopRegKeywords(&lineStr)                                                   ; V2 ONLY! Can this be combined with keywords step above?
   v2_VerCompare(&lineStr)                                                              ; V2 ONLY
   return                                                                               ; lineStr by reference
}
;################################################################################
; Updates conversion communication messages to user, for current line
; currently the LAST step performed for a line
; 2025-06-12 AMB, MOVED to dedicated routine for cleaner convert loop
; 2025-10-05 AMB, UPDATED - changed source of mask chars
; 2025-11-30 AMB, UPDATED - added Try to prevent index errors in certain situations
; 2025-12-21 AMB, UPDATED - MinIndex, MaxIndex messages
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
lp_PostLineMsgs(&lineStr, &EOLComment) {
   global gEOLComment_Cont, gEOLComment_Func, gNL_Func

   ; add a leading semi-colon to func comment string if it doesn't already exist
   gEOLComment_Func := (trim(gEOLComment_Func))                                         ; if not empty string
   ? RegExReplace(gEOLComment_Func, '^(\h*[^;].*)$', ' `; $1')                          ; ensure it has a leading semicolon
   : gEOLComment_Func                                                                   ; semi-colon already exists

   ; V2 ONLY !
   ; Add warning for Array.MinIndex(), Array.MaxIndex()
   ; 2025-12-21 AMB, UPDATED
   nMinIdxTag  := '\.' gMNPH, nMaxIdxTag := '\.' gMXPH                                  ; see MaskCode.ahk
   hasMin      := (lineStr ~= nMinIdxTag), hasMax := (lineStr ~= nMaxIdxTag)
   if (hasMin && hasMax) {
      EOLComment .= ' `; V1toV2: Verify V2 values match V1 Min/MaxIndex'
   }
   else if (hasMin) {
      EOLComment .= ' `; V1toV2: Verify V2 value matches V1 MinIndex'
   }
   else if (hasMax) {
      EOLComment .= ' `; V1toV2: Verify V2 Length value = V1 MaxIndex'
   }

   ; 2025-05-24 Banaanae, ADDED for fix #296
   gNL_Func .= (gNL_Func) ? '`r`n' : ''                                                 ; ensure this has a trailing CRLF
   nco := gNL_Func lineStr 'v1v2EOLCommentCont' EOLComment gEOLComment_Func
   OutSplit := StrSplit(nco, '`r`n')

   ; TEMP - DEBUGGING
   ; THESE TWO LENGTHS DO NOT MATCH SOMETIMES - CAUSES SCRIPT RUN ERRORS
   ; ... ESPECIALLY IN OLD VERSION OF CONVERTER
   if (OutSplit.Length < gEOLComment_Cont.Length)
   {
       ;MsgBox "[" nco "]`n`n" OutSplit.Length "`n`n" gEOLComment_Cont.Length
   }
   for idx, comment in gEOLComment_Cont {
      if (idx != OutSplit.Length) {                                                     ; if not last element
         ; 2025-11-30 AMB, ADDED Try to prevent index errors...
         ; ... when script lines are added by converter (or hidden with Zip())
         try {
            OutSplit[idx] := OutSplit[idx] comment                                      ; add comment to proper line
         }
      }
      else
         OutSplit[idx] := StrReplace(OutSplit[idx], 'v1v2EOLCommentCont', comment)
   }
   finalLine := ''
   for , v in OutSplit {
      finalLine .= v '`r`n'
   }
   finalLine := StrReplace(finalLine, 'v1v2EOLCommentCont')
   gNL_Func  := '', gEOLComment_Func := ''                                              ; reset global variables
   return    finalLine
}
;################################################################################
; Separates non-convert portion of line from portion to be converted
; returns non-convert portion in 'lineOpen' (HK decl, open-brace, Try\Else, etc)
; returns rest of line (that requires conversion) in 'lineStr'
; 2025-06-12 AMB, MOVED to dedicated routine for cleaner convert loop
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
lp_SplitLine(&lineStr) {
   v1v2_noKywdCommas(&lineStr)                                                          ; first remove trailing commas from keywords (including Switch)
   lineOpen := ''                                                                       ; will become non-convert portion of line
   firstTwo := subStr(lineStr, 1, 2)

   ; if line is not a HS, but is single-line HK with cmd,
   ;    separate HK from cmd temporarily so the cmd can be processed alone.
   ;    The HK will be re-combined with cmd after it is converted.
   ; nHotKey := gPtn_HOTKEY . '(.*)'
   ; TODO - need to update needle for more accurate targetting
   nHotKey := '((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
   if ((firstTwo != '::') && RegExMatch(LineStr, nHotKey, &m)) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }

   ; if line begins with switch, separate any value following it temporarily....
   ;    so the cmd can be processed alone. The opening part will be re-combined
   ;    with cmd after it is converted. Any trailing comma for switch statement
   ;    should have already been removed via noKywdCommas()
   nSwitch := 'i)^(\h*\bswitch\h*+)(.*+)'
   if (RegExMatch(LineStr, nSwitch, &m)) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }

   ; if line begins with case/default, separate any cmd following it temporarily...
   ;    so the cmd can be processed alone. The opening part will be re-combined
   ;    with cmd after it is converted.
   nCaseDefault := 'i)^(\h*(?:case .*?|default):(?!=)\h*+)(.*+)$'
   if (RegExMatch(LineStr, nCaseDefault, &m)) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }

   ; if line begins with try/else, separate any cmd that may follow temporarily...
   ;    so the cmd can be processed alone. The try/else will be re-combined with
   ;    cmd after it is converted.
   nTryElse := 'i)^(\h*+}?\h*+(?:Try|Else)\h*[\h{]\h*+)(.*+)$'
   if (RegExMatch(LineStr, nTryElse, &m) && m[2]) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }

   ; if line begins with {, separate any cmd following it temporarily...
   ;    so the cmd can be processed alone. The { will be re-combined with
   ;    cmd after it is converted.
   if (RegExMatch(LineStr, '^(\h*+{\h*+)(.*+)$', &m)) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }

   ; if line begins with } (but not else), separate any cmd following it temp'y...
   ;    so the cmd can be processed alone. The } will be re-combined with
   ;    cmd after it is converted.
   if (RegExMatch(LineStr, 'i)^(\h*}(?!\h*else|\h*\n)\h*)(.*+)$', &m)) {
      lineOpen   := m[1]                                                                ; non-convert portion
      LineStr    := m[2]                                                                ; portion to convert
      return lineOpen
   }
   return lineOpen
}
;################################################################################
; Removes ComObjMissing and references to it from functions
; Eg ComValue(0x10, ComObjMissing())     => ComValue(0x10)
;    ComValue(0x20, VarForComObjMissing) => ComValue(0x20)
; 2025-10-10 AMB, UPDATED - moved STR masking to FinalizeConvert()
RemoveComObjMissing(ScriptString) {
   if !InStr(ScriptString, 'ComObjMissing()')
      return ScriptString
   ;Mask_T(&ScriptString, 'STR')                                                        ; 2025-10-10 - now handled in FinalizeConvert()
   VarsToRemove := []
   EOLComments := Map_I()
   Lines := StrSplit(ScriptString, "`n", "`r")

   for i, Line in Lines {
      Line := separateComment(Line, &com:=''), EOLComments[i] := com                    ; separate comment from line
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
            nCOM    := "(.*?)((?:\w+\s*:=\s*)?ComObjMissing\(\))(.*)"
            Line    := RegExReplace(Line, nCOM, "$1$3" Chr(0x8787) "$2")
            sLine   := StrSplit(Line, Chr(0x8787))
            Line    := sLine[1]
            EOLComments[i] .= " `; V1toV2: Removed " sLine[2]
            Line    := RegExReplace(Line, "[\s,]+\)", ")")
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
      nRCOM     := "^(\s*) (; V1toV2: Removed [^;]*ComObjMissing\(\))"
      finalLine := RegExReplace(finalLine, nRCOM, "$1$2")
      final     .= finalLine "`r`n"
   }
   return RegExReplace(final, '\r\n$')
}
;################################################################################
; v2 requires an empty Catch block's braces on separate lines:
;     v1  }catch{}            (legal in v1, SYNTAX ERROR in v2)
;     v2  }catch{
;         }
; 2026-09-03 LOCAL, ADDED - RunAny product showed one-line empty catch blocks
;   surviving conversion (lines ~1026/1063/1767/4852/5540/5580/8406).
; Only rewrites EMPTY blocks ({}); a catch with a body is left untouched.
FixEmptyCatch(&code)
{
   nEC := '(?im)^(?<ind>\h*)}'
       .  '(?<csp>\h*)catch'                                                       ; }catch
       .  '(?<par>(?:\h+(?:Error\h+as\h+)?\w+)?)'                                  ; optional (Error as) e
       .  '(?<sp2>\h*)\{\h*\}'                                                     ; empty block on same line
       .  '(?<trail>[^\r\n]*)$'                                                    ; optional trailing comment
   pos := 1
   while (pos := RegExMatch(code, nEC, &m, pos)) {
      repl := m.ind . '}catch' . m.par . m.sp2 . '{'                               ; }catch...{
            . '`r`n' . m.ind . '}' . m.trail                                       ; (comment on closing brace line)
      code := SubStr(code, 1, pos - 1) . repl . SubStr(code, pos + StrLen(m[]))
      pos += StrLen(repl)
   }
}
;################################################################################
; v2 requires a Try statement to have a body. When conversion comments out the
; single statement that was the try's body (e.g. dynamic 'Menu,%expr%' switching),
; the line 'try ; V1toV2: ...' is left with no body - expand it to a block:
;     try ; comment
; becomes
;     try {
;     ; comment
;     }
; 2026-09-03 LOCAL, ADDED
FixOrphanTryComment(&code)
{
   nOrph := '(?im)^(?<ind>\h*)try(?<sp>\h+)(?<cm>;[^\r\n]*)$'                              ; try + whole-line comment, no body
   pos := 1
   while (pos := RegExMatch(code, nOrph, &m, pos)) {
      ; 'try {' then the comment on its own line, then '}' - the comment must NOT sit
      ; inline after '{' (it would swallow the closing brace on the same line).
      repl := m.ind . 'try {' . m.sp . m.cm . '`r`n' . m.ind . '}'
      code := SubStr(code, 1, pos - 1) . repl . SubStr(code, pos + StrLen(m[]))
      pos += StrLen(repl)
   }
}
;################################################################################
; v1 allows '$' as the first char of a variable name ('$Exp', '$FolderPath', ...),
; v2 does not. Rename '$name' to 'Dollar_name' everywhere EXCEPT inside strings /
; comments (where '$' is literal, e.g. Everything's '\$RECYCLE.BIN').
; 2026-09-03 LOCAL, ADDED
FixDollarVars(&code)
{
   sess := clsMask.NewSession()
   Mask_T(&code, 'C&S', , sess)                                                                ; protect strings & comments
   nDol := '(?<![\w\\])\$([A-Za-z_][A-Za-z0-9_]*)'                                             ; $name in code
   code := RegExReplace(code, nDol, 'Dollar_$1')
   Mask_R(&code, 'C&S', , sess)                                                                ; restore strings & comments
}

; 2026-09-05 LOCAL (breakage #11): v1 allowed "text"+var (numeric add with a
; literal string left operand never happened in practice - v2 FORBIDS it at
; parse time: 'Unexpected operator following literal string'). Rewrite a
; quoted-string followed by '+' into string concatenation ('.'). Must run on
; C&S-masked code so only real QS tags (not comments) are rewritten, and after
; FixIncDec so '++' cases are already resolved. "+=" and "++" are left alone.
FixStrPlusConcat(&code)
{
   nQS  := '\Q' gTagPfx 'QS_' '\E\w+' '\Q' gTagTrl '\E'                                        ; quoted-string mask tag
   code := RegExReplace(code, '(' nQS ')\h*\+(?![+=])', '$1 . ')
}

; 2026-09-05 LOCAL (breakage #7): v1 sources may contain '() ? a : b' - an empty
; ternary condition that is invalid v1 as well (author error) but must not
; survive as a v2 parse error. Mechanically default the empty condition to
; 'false' (v1 falsy) and keep the else-branch. (No inline note: the fork's
; comment rule forbids a literal ' ;' sequence inside this source's strings.)
FixEmptyTernaryCond(&code)
{
   code := RegExReplace(code, '\(\)\h*\?', '(false) ?')
}

; 2026-09-05 LOCAL (breakage #7): v1 commands with an empty mandatory first
; param (e.g. 'FileAppend, , file') emitted 'F(, x)' - for v2 functions whose
; FIRST PARAM IS REQUIRED that comma hole is a LOAD error ('Missing a required
; parameter', empirically: FileAppend(, "x") fails). Emit an explicit "".
; A comma hole for an OPTIONAL first param is valid v2 (DirSelect(, 3),
; MsgBox(, "t", "m"), FormatTime(, "time") all load) and is left untouched -
; hence the lookup table instead of a blanket rewrite.
FixEmptyFirstParam(&code)
{
   static reqFirst := ["FileAppend"]                       ; v2 builtins: required first param + v1 empty-first-arg form
   for each, fn in reqFirst
      code := RegExReplace(code, 'i)(\b' fn '\(\h*),', '$1"",')
   ; 2026-09-05 LOCAL (breakage #5): v1 Control* commands with an omitted control
   ; name ('ControlFocus,,ahk_id %hwnd%') emit 'ControlFocus(, x)' - the v2
   ; Control* builtins take the control as their FIRST parameter, where a comma
   ; hole is a runtime 'Missing a required parameter' error. Emit an explicit
   ; empty control "". ControlGetPos/ControlMove take the control as their
   ; SECOND param (after the output vars), so cover that form too.
   code := RegExReplace(code, 'i)(\bControl\w+\(\h*),', '$1"",')
   ; ControlGetPos/ControlMove: v1 places the control AFTER the four output
   ; vars - the comma hole just before the WinTitle ('..., &H, , "title"')
   ; is the same missing required parameter. Patch any empty fifth argument.
   code := RegExReplace(code, 'i)(\bControl(?:GetPos|Move)\([^,]+,\h*[^,]+,\h*[^,]+,\h*[^,]+),\h*,(?=\h*)', '$1, ""')
}

; 2026-09-05 LOCAL (breakage #3/#18): multi-line DllCalls bypass the per-line
; _DllCall converter (they are masked as multi-line paren blocks), so their
; '&var' value args and bare '*'-type output vars are emitted verbatim. Sweep
; the whole C&S-masked script for the two argument shapes:
;   "ptr"/"uptr", &var   -> V1toV2_AddrOf(var)   (v1 '&' address semantics;
;          VarSetCapacity-converted vars are already handled by FixVarSetCapacity)
;   "type*",  var        -> "type*", &var        (output param needs a VarRef;
;          empirically the fork accepts a VarRef to a not-yet-assigned variable)
FixPtrAddrArgs(&code)
{
   global gfUseV1toV2AddrOf, gmVarSetCapacityMap
   nAddrOf := V1toV2ShimName('V1toV2_AddrOf')
   pos := 1
   while (pos := RegExMatch(code, 'i)("?\b(?:u?)ptr"?\h*,\h*)&(\w+)', &m, pos)) {
      if (!gmVarSetCapacityMap.Has(m[2])) {
         repl := m[1] nAddrOf '(' m[2] ')'          ; m[1] already includes ', '
         code := SubStr(code, 1, pos-1) repl SubStr(code, pos + m.Len)
         gfUseV1toV2AddrOf := true
         pos += StrLen(repl)
      } else {
         pos += m.Len
      }
   }
   pos := 1
   while (pos := RegExMatch(code, 'i)("\w+\*")(\h*,\h*)(?=[a-z_])(\w+)(?<!&)(?!\h*(?::=|\.=|\+=))', &m, pos)) {
      repl := m[1] m[2] '&' m[3]
      code := SubStr(code, 1, pos-1) repl SubStr(code, pos + m.Len)
      pos += StrLen(repl)
   }
}

; 2026-09-05 LOCAL (breakage #25): a v1 container initialized as an EMPTY object
; literal ('x := {}') or 'x := Object()' is an associative array. The fork's
; plain objects have no __Item for dynamic/quoted keys and no .Remove(), so
; make it a Map and shim the two v1 semantics the converter cannot inline:
;   'x.Remove(k)'        -> V1toV2_MapRemove(x, k)   (returns removed value or "")
;   'x[k]' reads         -> V1toV2_MapGet(x, k)      (missing key -> "", not a throw)
; Writes 'x[k] := v' stay as-is (Map item-set). Only vars assigned an empty
; literal are shimmed - keys of Object(args)/Map(args) constructors usually
; exist, so reads there are left alone.
FixMapLiterals(&code)
{
   global gfUseV1toV2MapHelpers
   nMapGet := V1toV2ShimName('V1toV2_MapGet'), nMapRm := V1toV2ShimName('V1toV2_MapRemove')
   mapVars := Map()
   pos := 1
   while (pos := RegExMatch(code, 'i)(\b\w+)\h*:=\h*(?:\{\}|\bObject\(\))', &m, pos)) {
      mapVars[m[1]] := true
      pos += m.Len
   }
   for v, _ in mapVars {
      code := RegExReplace(code, 'i)(\b' v '\h*:=\h*)(?:\{\}|\bObject\(\))', '$1Map()')
      if (RegExMatch(code, 'i)\b' v '\.Remove\(')) {
         code := RegExReplace(code, 'i)\b' v '\.Remove\(', nMapRm '(' v ', ')
         gfUseV1toV2MapHelpers := true
      }
      nRead := 'i)\b' v '\[([^\][]+)\](?!\h*(?::=|\.=|\+=|-=|\*=|/=|=))'
      if (RegExMatch(code, nRead)) {
         code := RegExReplace(code, nRead, nMapGet '(' v ', $1)')
         gfUseV1toV2MapHelpers := true
      }
   }
}

; 2026-09-05 LOCAL: per-file unique shim name. Converted outputs #Include each
; other (plugin files include RunAny_ObjReg), so a helper defined in two files
; of one include chain is a LOAD error ('function declaration conflicts with an
; existing Func', huiZz_Text). Suffix the shim name with the source file name.
V1toV2ShimName(base)
{
   global gV1toV2ShimSuffix
   if (gV1toV2ShimSuffix = '') {
      SplitPath(gFilePath,,,, &nameNoExt)
      gV1toV2ShimSuffix := RegExReplace(nameNoExt, '\W', '_')
   }
   return base '_' gV1toV2ShimSuffix
}

; 2026-09-05 LOCAL (breakage #17): v1 allowed chained assignment where the
; MIDDLE operand is a function call on an object with __Set semantics
; ('_ := JS.(GetJScript()) := JS.("delete ...")'). v2 rejects ':=' chains
; outright ('Invalid assignment'). The middle call's assignment effect is a
; v1 __Set side channel the converter cannot reproduce, so the mechanical
; equivalent keeps the OUTER assignment with the RIGHT operand and notes the
; dropped middle call. Only fires when the middle operand is a function call;
; 'a := b := c' (both plain vars) is left untouched.
FixChainedAssign(&code)
{
	sc := Chr(59)																		; ';' - raw ' ;' is illegal in this source's strings (fork rule)
	code := RegExReplace(code, 'm)(\b\w+\h*:=\h*)([A-Za-z_]\w*\s*\([^;\r\n]*?\)\h*)(:=\h*)(.+)$'
		, '$1$4 ' sc ' V1toV2: chained assignment to a function call dropped (v1 __Set semantics)')
}

; 2026-09-05 LOCAL (breakage #16): a top-level v1 '#If <expr>' context section
; gets packaged into a converter-made 'V1toV2_GblCode_xxx()' function when the
; label-to-function pass treats it as stray global code. Directives are not
; statements - '#HotIf' inside a function body is 'Invalid usage' at load.
; Lift the directive line back out to top level (in front of the function);
; the emptied function stays behind harmlessly.
FixHotIfInFunc(&code)
{
	pos := 1
	while (pos := RegExMatch(code, 'm)(^\h*V1toV2_GblCode_\d+\(\)[^\r\n]*\r?\n)(?:global\r?\n)?\h*(#HotIf[^\r\n]*)\r?\n', &m, pos)) {
		code := SubStr(code, 1, pos-1) . m[2] . '`r`n' . m[1] . SubStr(code, pos + m.Len)
		pos += StrLen(m[1]) + StrLen(m[2]) + 2
	}
}

; 2026-09-05 LOCAL (breakage #14): v2 rejects identifiers beginning with a
; digit ('This variable name starts with a number'). v1 allowed them. Rename
; '<digits><name>' to '<name><digits>' (mirror of the golden hand-fix
; '32770Hwnd' -> 'Hwnd32770') EVERYWHERE - declaration, use, and member
; access on the renamed object ('Complete32770HwndsObj[32770Hwnd]'). Runs on
; the restored script so literals/comments are untouched.
FixLeadingDigitVars(&code)
{
	names := Map_I()
	pos := 1
	while (pos := RegExMatch(code, 'm)(^|\W)(\d+)([A-Za-z_][A-Za-z0-9_]*)(?=\W|$)', &m, pos)) {
		oldnm := m[2] . m[3]
		; 2026-09-05 LOCAL guards: (a) '0x<hex>' literals look like a digit-led
		; identifier but must stay untouched (EnvUpdate test regression),
		; (b) tokens right after a quote are inside a string literal.
		if (oldnm ~= '^0[xX][0-9A-Fa-f]*$' || m[1] = '"') {
			pos += m.Len
			continue
		}
		newnm := m[3] . m[2]
		if (!names.Has(oldnm)) {
			names[oldnm] := true
			code := RegExReplace(code, '\Q' oldnm '\E', newnm)
			pos += StrLen(newnm) + 1
		} else
			pos += m.Len
	}
}

; 2026-09-05 LOCAL (breakage #12): a v1 FUNCTION whose name collides with a
; variable ('saveFrequency(FrequencyINI,...)' vs the global 'SaveFrequency'
; ini value) is a v2 load error ('This Func cannot be used as an output
; variable'). Rename the FUNCTION (definition + call sites - the call form
; always has '(') to '<name>_Check'; bare variable references (no paren)
; keep their name. Runs on C&S-masked code so strings/comments are safe.
FixFuncVarConflict(&code)
{
	global gAllVarNames, gmList_LblsToFunc
	pos := 1
	while (pos := RegExMatch(code, 'm)^\h*([A-Za-z_]\w*)\h*\([^)\r\n]*\)\h*\{', &m, pos)) {
		fn := m[1]
		if (gAllVarNames.Has(fn) && !gmList_LblsToFunc.Has(fn)) {
			code := RegExReplace(code, 'i)\b' fn '\s*\(', fn '_Check(')
			pos := 1
			continue
		}
		pos += m.Len
	}
}

; 2026-09-05 LOCAL (breakage #13): v2 builtin CLASS names that v1 code may
; freely use as variables ('Array := StrSplit(...)' -> load error 'This Class
; cannot be used as an output variable'). Rename the variable (assignment LHS
; plus bare references) to '<name>_v'; builtin CALLS 'Array(...)' keep their
; name. Runs on C&S-masked code so strings/comments are untouched.
FixReservedVarNames(&code)
{
	static cls := '|Array|Buffer|File|Func|BoundFunc|Object|Map|OrderedMap|Menu|MenuBar|Gui|InputHook|Hotkey|Hotstring|ComValue|RegExMatchInfo|Error|TypeError|ValueError|ZeroDivisionError|MemberError|PropertyError|TargetError|OSError|TimeoutError|UnsetError|UnsetItemError|UnsetPropError|MaxParamsError|MethodError|MinParamsError|TooManyActualParamsError|TooFewActualParamsError|TypeMismatchError|InvalidThisError|UnexpectedElementError|InternalError|CustomError|Enumerator|Trace'
	for each, nm in StrSplit(cls, '|') {
		if (nm = '')
			continue
		if (!RegExMatch(code, 'mi)(^|\W)' nm '\h*:=', &m))					; only when used as an assignment LHS
			continue
		code := RegExReplace(code, 'i)(?<!\w)' nm '\b(?!\s*\()', nm '_v')		; bare references only - CALLS 'Name(...)' keep their name
	}
}

; 2026-09-05 LOCAL: prepend the runtime shims flagged during conversion. v2
; function definitions are global at load time regardless of position, so the
; helpers are appended to the end of the script.
AddV1toV2Helpers(code)
{
   global gfUseV1toV2AddrOf, gfUseV1toV2MapHelpers, gfUseV1toV2CallLabel
   ; NB: a raw 'space+;' sequence cannot appear in THIS source's strings (fork
   ; comment rule - see FixSemiInStrings), so output comments are built with
   ; Chr(59) concatenation.
   sc := Chr(59)
   nAddrOf := V1toV2ShimName('V1toV2_AddrOf'), nMapGet := V1toV2ShimName('V1toV2_MapGet'), nMapRm := V1toV2ShimName('V1toV2_MapRemove'), nCallLbl := V1toV2ShimName('V1toV2_CallLabel')
   helpers := ''
   if (gfUseV1toV2AddrOf) {
      helpers .= nAddrOf "(v) {                                                    " sc " V1toV2: v1 ampersand-address semantics (string->StrPtr, object->ObjPtr, Buffer->itself)`r`n"
      helpers .= "    If Type(v) = `"Buffer`"`r`n"
      helpers .= "        Return v`r`n"
      helpers .= "    Return IsObject(v) ? ObjPtr(v) : StrPtr(v)`r`n"
      helpers .= "}`r`n"
   }
   if (gfUseV1toV2MapHelpers) {
      helpers .= nMapGet "(m, k) {                                                  " sc " V1toV2: v1 obj[key] read - missing key yields empty, not a throw`r`n"
      helpers .= "    Return m.Has(k) ? m[k] : `"`"`r`n"
      helpers .= "}`r`n"
      helpers .= nMapRm "(m, k) {                                               " sc " V1toV2: v1 obj.Remove(key) - returns removed value or empty`r`n"
      helpers .= "    if !m.Has(k)`r`n"
      helpers .= "        Return `"`"`r`n"
      helpers .= "    v := m[k], m.Delete(k)`r`n"
      helpers .= "    Return v`r`n"
      helpers .= "}`r`n"
   }
   if (gfUseV1toV2CallLabel) {
      helpers .= nCallLbl "(name) {                                               " sc " V1toV2: v1 dynamic Gosub - labels became functions, call when found`r`n"
      helpers .= "    fn := Func(name)`r`n"
      helpers .= "    if (fn)`r`n"
      helpers .= "        fn.Call()`r`n"
      helpers .= "}`r`n"
   }
   return (helpers = '') ? code : code '`r`n' helpers
}

; 2026-09-05 LOCAL (fork rule, breakage #4 follow-up): the fork's comment
; preprocessing is NOT string-aware - a raw space or tab immediately before ';'
; starts a comment EVEN INSIDE a quoted string, truncating it
; (x := "a ; b"  ->  Missing """ at runtime/load). Escape the whitespace with
; `s / `t so the ';' is not preceded by raw whitespace; runtime content is
; unchanged because the escapes decode to the same whitespace character.
; Line-wise char scan: state machine over " and ' strings with ` escapes.
; Strings never span lines outside continuation sections, and CS content is
; literal by definition (no comment stripping there), so per-line reset is safe.
FixSemiInStrings(&code)
{
   out := ''
   for each, line in StrSplit(code, '`n', '`r')
   {
      newLine := '', inStr := '', esc := false, prev := ''
      loop parse line
      {
         ch := A_LoopField
         if (esc) {
            esc := false, newLine .= ch, prev := ch
            continue
         }
         if (inStr && ch = '``') {
            esc := true, newLine .= ch, prev := ch
            continue
         }
         if (inStr && ch = inStr) {
            inStr := '', newLine .= ch, prev := ch
            continue
         }
         if (!inStr && (ch = '"' || ch = "'")) {
            inStr := ch, newLine .= ch, prev := ch
            continue
         }
         if (inStr && ch = ';' && (prev = ' ' || prev = A_Tab)) {
            newLine := SubStr(newLine, 1, StrLen(newLine)-1) . ((prev = ' ') ? '``s' : '``t') . ch
            prev := ch
            continue
         }
         newLine .= ch, prev := ch
      }
      out .= newLine '`r`n'
   }
   code := RegExReplace(out, '\r\n$',,,1)
}
