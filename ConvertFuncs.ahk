#Requires AutoHotKey v2.0
#SingleInstance Force
CoordMode("tooltip", "screen")          ; for debugging msgs

; 2025-12-24 AMB    MOVED Dynamic Conversion Funcs to AhkLangConv.ahk
#Include Global_Declare.ahk             ; global definitions, classes, etc

; 2025-07-06 AMB, ERROR related to combination of recursion AND global scope
; will cause error when called using a global var, AND performing recursion
; must call from inside a function that has a "copy" of the var (local scope)
; See Mask_T() and Mask_R() within MaskCode.ahk for more info
;   globalVar := "This is a test"
;   Mask_T(&globalVar, 'C&S') ; mask comments and strings (uses recursion)

;################################################################################
Convert(code)                    ; MAIN ENTRY POINT for conversion process
;################################################################################
{
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-21 AMB, UPDATED to support new UI

   ;####  PLEASE DO NOT PLACE ANY OF YOUR CODE IN THIS FUNCTION  #####

   ; Please place any code that must be performed BEFORE _convertLines()...
   ;  ... into the following function
   Before_LineConverts(&code)
   Prog.ULog(10)                ; update UI - 10% complete

   ; DO NOT PLACE YOUR CODE HERE
   ; perform line conversions
   ; [to test WITHOUT using Macro Scope, change fUseScope flag to 0 (below)]
   code := (fUseScope:=1) ? convertLines_UseScope(code) : convertLines_NoScope(code)
   Prog.ULog(60)                ; update UI - 60% complete

   ; Please place any code that must be performed AFTER _convertLines()...
   ;  ... into the following function
   After_LineConverts(&code)
   Prog.ULog(100)               ; update UI - 100% complete

   return code                  ; . 'fail for debugging'
}
;################################################################################
convertLines_NoScope(code)
{
; 2025-11-01 AMB, ADDED to provide option to NOT USE Macro Scope (for testing previous method)
   Mask_T(&code,'CSECT2'), Mask_T(&code,'FUNC&CLS') ; mask M2 continuation sections, funcs/classes
   return _convertLines(code)
}
;################################################################################
convertLines_UseScope(code)
{
; 2025-11-01 AMB, ADDED to support Scope
; 2026-01-21 AMB, UPDATED to support new UI
;   supports processing global-code first (by default)
;    change fGblOrder flag to 0 to test orig-order processing

   curProg          := Prog.curProg                                                     ; get current progress percentage
   Prog.ULog(,'Getting Script Sections...')                                             ; update UI
   sects            := GetScopeSections(code)                                           ; get Macro-Scope sections
   Prog.ULog(,'Processing Script Sections...')                                          ; update UI
   if (fGblOrder    :=1) {                                                              ; if global code should be processed first...
      origOrder     := Map_I()                                                          ; [will keep track of orig section order]
      gblOrder      := StrSplit(clsScopeSect.OrderGbl, ',')                             ; get global-first index ordering
      sectCount     := gblOrder.Length, progInc := (50/sectCount)                       ; calc average progress percent for each section
      for idx, index in gblOrder {                                                      ; for each order index...
         Prog.ULog(,'Processing Section ' idx ' of ' sectCount)                         ; ... update UI
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
      sectCount := sects.Length, progInc := (65/sectCount)                              ; calc average progress percent for each section
      for idx, curSect in sects {                                                       ; for each section (original order)...
         Prog.ULog(,'Processing Section ' idx ' of ' sectCount)                         ; ... update UI
         Mask_T(&curSect,'CSECT2'), Mask_T(&curSect,'FUNC&CLS')                         ; ... mask M2 continuation sections, funcs/classes
         convSect   := _convertLines(curSect)                                           ; ... convert lines within section
         outStr     .= convSect                                                         ; ... add converted sect to output, reassemble script string
         curProg    += progInc, Prog.ULog(curProg)                                      ; ... update UI with progress percent
      }
   }
   Prog.ULog(,'Processing Sections - COMPLETE')                                         ; update UI - sections complete
   return outStr                                                                        ; return converted/output str
}
;################################################################################
Before_LineConverts(&code)
{
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-21 AMB, UPDATED to support new UI

   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   Prog.UPath(gFilePath), Prog.ULog(,,A_ThisFunc ' [IN]')                               ; update UI - file path and debug
   Prog.ULog(1, 'Pre Process - Set Globals...')                                         ; update UI - 1% complete
      setGlobals()                                                                      ; initialize all global vars here so ALL code has access to them
   Prog.ULog(,  'Pre Process - Isolated labels...')                                     ; update UI
      code := isolateLabels(code)                                                       ; 2025-06-22 AMB, move labels to their own line as needed
   Prog.ULog(,  'Pre Process - Get Func names...')                                      ; update UI
      global gAllFuncNames     := getFuncNames(code)                                    ; comma-delim stringList of all function names
   Prog.ULog(2, 'Pre Process - Get Class names...')                                     ; update UI - 2% complete
      global gAllClassNames    := getClassNames(code)                                   ; comma-delim stringList of all class names (2025-10-08)
   Prog.ULog(4, 'Pre Process - Get V1 Label names..')                                   ; update UI - 4% complete
      global gAllV1LabelNames  := getV1LabelNames(code)                                 ; comma-delim stringList of all orig v1 label names
   Prog.ULog(6, 'Pre Process - Get V2 Label names...')                                  ; update UI - 6% complete
      global gmAllV2LablNames  := getV2LabelNames(gAllV1LabelNames)                     ; map of v1 label names converted to V2 label/funcNames
   Prog.ULog(7, 'Pre Process - Get MenuBar name...')                                    ; update UI - 7% complete
      global gMenuBarName      := getMenuBarName(code)                                  ; name of GUI main menubar
      ;global gmAltLabel        := GetAltLabelsMap(code)                                ; 2025-11-28 AMB - no longer needed, causes gLabel routing issues
   Prog.ULog(8, 'Pre Process - Goto/Gui/HK/Ternary...')                                 ; update UI - 8% complete
      PreProcessLines(&code)   ; changes orig code                                      ; 2025-11-23 AMB, ADDED as part of fix for #413
      global gOrigScript       := code                                                  ; 2025-11-01 AMB, ADDED as part of Scope support
   Prog.ULog(9, 'Pre Process - Get V1 Flags...')                                        ; update UI - 9% complete
      getScriptStringsUsed(code)                                                        ; 2025-11-01 AMB, ADDED as part of Scope support
   Prog.ULog(,  '',A_ThisFunc ' [OUT]')                                                 ; update UI - debug
   return                                                                               ; code by reference
}
;################################################################################
After_LineConverts(&code)
{
; 2025-11-01 AMB, UPDATED as part of Scope support

   ;####  Please place CALLS TO YOUR FUNCTIONS here - not boilerplate code  #####

   ; operations that must be performed last
   ; inspect to see whether your code is best placed here or in the following
   FinalizeConvert(&code)                   ; perform all final operations

   return    ; code by reference
}
;################################################################################
PreProcessLines(&code)
{
; 2025-11-23 AMB, ADDED - part of fix for #413
; pre-processing of certain commands via single-iteration of script lines

    Mask_T(&code, 'C&S')
    nGoto       := '(?im)^(\h*)(GOTO)(.+)'                                              ; needle for 'Goto, Label'
    nHK         := '(?im)^(\h*)' gPtn_HOTKEY . '(?<cmd>.*)'                             ; needle for full HK line
    lines       := StrSplit(code, '`n', '`r')                                           ; separate all lines within Code
    outStr      := ''                                                                   ; ini output
    for idx, line in lines {                                                            ; for each line in script...
        ; GOTO
        if (line ~= nGoto) {                                                            ; if line has a Goto command...
            line := convertGoto(line, idx, &lines)                                      ; ... convert Goto
        }
        ; HOTKEY
        else if (RegExMatch(line, nHK, &m) && m.cmd) {                                  ; if line is HK with possible cmd on same line...
            line := HK1LToML(line, idx, &lines)                                         ; ... see if cmd needs multi-line instead
        }
        outStr  .= line '`r`n'                                                          ; add line to output str
    }
    code := RegExReplace(outStr, '\r\n$',,,1)                                           ; update code (also remove very last CRLF)
    code := UnZip(code, 'GOTORET')                                                      ; handle GotoReturn - add braces to IF/ELSEIF/ELSE as needed
    return                                                                              ; return Code by reference
}
;################################################################################
getScriptStringsUsed(scopeCode, term:='')
{
; 2025-11-01 AMB, ADDED as part of Scope support
; scopeCode - can be entire script string, or a limited portion of code (to control scope)
; when term is NOT specified, sets global flags as needed (scopeCode param should be entire script)
; when term is specified... scopeCode param should be set to code of limited scope
;   sets flag for term (output-option one), also returns whether term was found in scopeCode

   global gaScriptStrsUsed

   ; First, remove false positives hiding in commments and strings
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
_convertLines(ScriptString)
;################################################################################
{
; 2025-06-12 AMB, UPDATED
;   moved most operations to external funcs for modular design (SEE ConvLoopFuncs.ahk)
;   removed finalize parameter and optional step at bottom of function
;   changed gOSriptStr from array to class object - prep for more functionaity later
;   added block-comment masking as a global condition for full ScriptString
;   changed many variable and function names
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-01 AMB, UPDATED - changed global gEarlyLine to gV1Line
; 2026-01-21 AMB, UPDATED to support new UI

   ;Prog.ULog(,,A_ThisFunc)          ; update UI - debug

   Mask_T(&ScriptString, 'BC')      ; 2025-06-12 AMB, mask all block-comments globally

   global gOrig_ScriptStr           := ScriptString
   global gaList_PseudoArr          := []                                  ; 2025-11-01 AMB, ADDED here as part of Scope support
   global gV1Line                   := ''                                  ; 2026-01-01 changed name from gEarlyLine
;   global gOScriptStr               := StrSplit(ScriptString, '`n', '`r') ; array for all the lines
   global gOScriptStr               := ScriptCode(ScriptString)            ; now a class object, for future use
   global gO_Index                  := 0                                   ; current index of the lines
   global gIndent                   := ''
   global gSingleIndent             := (RegExMatch(ScriptString, '(^|[\r\n])( +|\t)', &ws)) ? ws[2] : '    ' ; First spaces or single tab found
          gSingleIndent             := StrLen(gSingleIndent) > 4 ? '    ' : gSingleIndent                    ; in case of unusual LWS
   global gNL_Func                  := ''                                  ; _Funcs can use this to add New Previous Line
   global gEOLComment_Func          := ''                                  ; _Funcs can use this to add comments at EOL
   global gEOLComment_Cont          := []                                  ; 2025-05-24 Banaanae, ADDED for fix #296
   global gaScriptStrsUsed

   ScriptOutput                     := ''
   getScriptStringsUsed(ScriptString, 'IfMsgBox')                          ; 2025-10-28 Banaanae (limit scope boundary to current section only)

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
      ;Prog.ULog(,,,gO_Index,Trim(curLine))                          ; update UI - debug

      gIndent           := RegExReplace(curLine,'^(\h*).*','$1')    ; original line indentation (if present)
      EOLComment        := lp_DirectivesAndComment(&curLine)        ; process character directives and extract initial trailing comment from line
      lineOpen          := lp_SplitLine(&curLine)                   ; see lp_splitLine() for details
      gV1Line           := curLine                                  ; portion of line to process [prior to processing], has no trailing comment
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
{
; 2024-06-27 ADDED, 2025-06-12, 2025-10-05, 2026-01-01 UPDATED
; 2026-01-21 AMB, UPDATED to support new UI
; Performs tasks that finalize overall conversion

   Prog.ULog(,  'Post Process - Restore Classes/Funcs...', A_ThisFunc       )           ; update UI - current operation, debug
      Mask_R(&code, 'FUNC&CLS')                                                         ; remove masking from classes/funcs (returned as v2 converted)
   Prog.ULog(65,'Post Process - Expand zipped lines...'                     )           ; update UI - current operation - 65% complete
      code := UnZip(code)                                                               ; 2025-11-30 AMB, expand ML code added by converter, add braces to blocks as needed
   Prog.ULog(,  'Post Process - VarRefs and OnClipboardChange...'           )           ; update UI - current operation
      code := addToCode(code)                                                           ; 2026-01-01 AMB, add messages and directives to code
   Prog.ULog(70,'Post Process - Labels/Hotkeys/Hotstrings...'               )           ; update UI - current operation - 70% complete
      code := Update_LBL_HK_HS(code)                                                    ; 2025-10-05 AMB, UPDATED conversion for labels,HKs,HSs to v2 format
   Prog.ULog(80,'Post Process - Premask Comments/Strings...'                )           ; update UI - current operation - 85% complete
      Mask_T(&code, 'C&S')                                                              ; 2025-10-10 AMB, first attempt to improve efficiency of conversion (WORK IN PROGRESS)
   Prog.ULog(,  'Post Process - Fix Min/MaxIndex...'                        )           ; update UI - current operation
      code := FixMinMaxIndex(code)                                                      ; 2025-12-21 AMB, MOVED to dedicated func
   Prog.ULog(,  'Post Process - Fix OnMessage...'                           )           ; update UI - current operation
      code := FixOnMessage(code)                                                        ; Fix turning off OnMessage when defined after turn off
   Prog.ULog(,  'Post Process - Fix VarSetCapacity...'                      )           ; update UI - current operation
      code := FixVarSetCapacity(code)                                                   ; &buf -> buf.Ptr   &vssc -> StrPtr(vssc)
   Prog.ULog(,  'Post Process - Fix ByRef Params...'                        )           ; update UI - current operation
      code := FixByRefParams(code)                                                      ; Replace ByRef with & in func declarations and calls - see related fixFuncParams()
   Prog.ULog(,  'Post Process - Fix Increment/Decrement...'                 )           ; update UI - current operation
      code := FixIncDec(code)                                                           ; 2025-10-10 AMB, ADDED to cover issue #350
   Prog.ULog(,  'Post Process - Remove ComObjMissing...'                    )           ; update UI - current operation
      code := RemoveComObjMissing(code)                                                 ; Removes ComObjMissing() and variables
   Prog.ULog(,  'Post Process - Add CB Args for Gui...'                     )           ; update UI - current operation
      addGuiCBArgs(&code)                                                               ; Add args to Gui callback funcs
   Prog.ULog(,  'Post Process - Add CB Args for Menu...'                    )           ; update UI - current operation
      addMenuCBArgs(&code)                                                              ; 2024-06-26, AMB - Fix #131
   Prog.ULog(,  'Post Process - Add CB Args for OnMessage...'               )           ; update UI - current operation
      addOnMessageCBArgs(&code)                                                         ; 2024-06-28, AMB - Fix #136
   Prog.ULog(,  'Post Process - Add CB Args for Hotkey Command...'          )           ; update UI - current operation
      addHKCmdCBArgs(&code)                                                             ; 2025-10-12, AMB - Fix #328
   Prog.ULog(,  'Post Process - Update FileOpen Properties...'              )           ; update UI - current operation
      updateFileOpenProps(&code)                                                        ; 2025-10-12, AMB - support for #358
   Prog.ULog(,  'Post Process - Restore Continuation Sections...'           )           ; update UI - current operation
      Mask_R(&code, 'CSect')                                                            ; restore remaining cont sects (returned as v2 converted)
   Prog.ULog(,  'Post Process - Restore Multi-line Parentheses Blocks...'   )           ; update UI - current operation
      Mask_R(&code, 'MLPB')                                                             ; restore remaining ML parentheses blocks
   Prog.ULog(,  'Post Process - Restore V1 Multi-line String Blocks...'     )           ; update UI - current operation
      Mask_R(&code, 'V1MLS')                                                            ; restore remaining V1 ML strings
   Prog.ULog(90,'Post Process - Restore Comments/Strings...'                )           ; update UI - current operation - 90% complete
      Mask_R(&code, 'C&S')                                                              ; ensure all comments/strings are restored (just in case)

   return                                                                               ; code by reference
}
;################################################################################
; 2026-01-01 AMB, ADDED - Add global warnings, etc
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
      gmList_LblsToFunc['OnClipboardChange_v2'] := ConvLabel('OCC', 'OnClipboardChange_v2', 'dataType:=""', 'OnClipboardChange_v2'
                                                , {NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$", Replacement: "$1dataType$2"})
   }
   return code
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
; 2025-12-21 AMB, ADDED to update MnxIndex handling
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
; 2025-06-12 AMB, ADDED to separate processing of character directives and line comment
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
;  (for cleaner conversion loop, and v1.0 => v1.1 conversion)
lp_DirectivesAndComment(&lineStr) {
   ; if current line is char-directive declaration, grab the attributes
   if (RegExMatch(lineStr, 'i)^\h*#(CommentFlag|EscapeChar|DerefChar|Delimiter)\h+.')) {
      _grabCharDirectiveAttribs(lineStr)
      return ''      ; might need to change this to actual line comment (EOLComment)
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

   return EOLComment    ; return trailing comment for current line

   ;############################################################################
   _grabCharDirectiveAttribs(lineStr) {
   ; 2025-06-12 AMB, ADDED to separate processing of character directives
   ;  (for cleaner conversion loop, and v1.0 => v1.1 conversion)
   ; only one of these directives may be found on current line
   ; sets data within gaScriptStrsUsed for use later
   ; 2025-12-24 AMB, UPDATED - converted to internal func

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
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
; 2026-01-01 AMB, UPDATED - changed global gEarlyLine to gV1Line
; Purpose: Remove/Disable incompatible commands (that are no longer allowed)
lp_DisableInvalidCmds(&lineStr, fCmdConverted) {
   ; V1 and V2, but with different commands for each version
   ; 2025-10-08 AMB, Updated to fix #375
   fDisableLine := false
   if (!fCmdConverted) {                                    ; if a targetted command was found earlier...
      Loop Parse, gAhkCmdsToRemoveV1, '`n', '`r' {          ; [check for v1 deprecated]
         targStr:= escRegexChars(A_LoopField)               ; prep for regex check
         lead   := (A_LoopField ~= '^#') ? '' : '\b'        ; add word boundary to beginning of needle, but only when hask char not present
         nTarg  := '(?i)' lead targStr '\b'                 ; needle to cover all scenerios in gAhkCmdsToRemoveV1
         if (gV1Line ~= nTarg)                              ; ... is that command invalid after v1.0?
            fDisableLine := true                            ; flag it as invalid
      }
      if (gV2Conv) {                                        ; v2
         Loop Parse, gAhkCmdsToRemoveV2, '`n', '`r' {       ; [check for v2 deprecated]
            targStr := escRegexChars(A_LoopField)           ; prep for regex check
            lead    := (A_LoopField ~= '^#') ? '' : '\b'    ; add word boundary to beginning of needle, but only when hask char not present
            nTarg   := '(?i)' lead targStr '\b'             ; needle to cover all scenerios in gAhkCmdsToRemoveV2
            if (gV1Line ~= nTarg)                           ; ... is that command invalid after v2?
               fDisableLine := true                         ; flag it as invalid
         }
         if (lineStr ~= '^\h*(\blocal\b)\h*$')  {           ; V2 Only - only force-local
            fDisableLine := true                            ; flag it as invalid
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
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
;   TODO - See if these can be combined in v2_Conversions
lp_PostConversions(&lineStr) {
   v1v2_FixNEQ(&lineStr)                    ; Convert <> to !=
   v2_PseudoAndRegexMatchArrays(&lineStr)   ; mostly v2 (separating...)
   v2_RemoveNewKeyword(&lineStr)            ; V2 ONLY! Remove New keyword from classes
   v2_RenameKeywords(&lineStr)              ; V2 ONLY
   v2_RenameLoopRegKeywords(&lineStr)       ; V2 ONLY! Can this be combined with keywords step above?
   v2_VerCompare(&lineStr)                  ; V2 ONLY
   return                                   ; lineStr by reference
}
;################################################################################
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Updates conversion communication messages to user, for current line
; currently the LAST step performed for a line
; 2025-10-05 AMB, UPDATED - changed source of mask chars
; 2025-11-30 AMB, UPDATED - added Try to prevent index errors in certain situations
; 2025-12-21 AMB, UPDATED - MinIndex, MaxIndex messages
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
lp_PostLineMsgs(&lineStr, &EOLComment) {
   global gEOLComment_Cont, gEOLComment_Func, gNL_Func

   ; add a leading semi-colon to func comment string if it doesn't already exist
   gEOLComment_Func := (trim(gEOLComment_Func))                 ; if not empty string
   ? RegExReplace(gEOLComment_Func, '^(\h*[^;].*)$', ' `; $1')  ; ensure it has a leading semicolon
   : gEOLComment_Func                                           ; semi-colon already exists

   ; V2 ONLY !
   ; Add warning for Array.MinIndex(), Array.MaxIndex()
   ; 2025-12-21 AMB, Updated
   nMinIdxTag  := '\.' gMNPH, nMaxIdxTag := '\.' gMXPH          ; see MaskCode.ahk
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
   gNL_Func .= (gNL_Func) ? '`r`n' : ''                         ; ensure this has a trailing CRLF
   NoCommentOutput   := gNL_Func . lineStr . 'v1v2EOLCommentCont' . EOLComment . gEOLComment_Func
   OutSplit := StrSplit(NoCommentOutput, '`r`n')

   ; TEMP - DEBUGGING - THESE TWO LENGTHS DO NOT MATCH SOMETIMES - CAUSES SCRIPT RUN ERRORS
   ; ... ESPECIALLY IN OLD VERSION OF CONVERTER
   if (OutSplit.Length < gEOLComment_Cont.Length)
   {
;       MsgBox "[" NoCommentOutput "]`n`n" OutSplit.Length "`n`n" gEOLComment_Cont.Length
   }
   for idx, comment in gEOLComment_Cont {
      if (idx != OutSplit.Length) {                             ; if not last element
         ; 2025-11-30 AMB, ADDED Try to prevent index errors...
         ; ... when script lines are added by converter (or hidden with Zip())
         try {
            OutSplit[idx] := OutSplit[idx] comment              ; add comment to proper line
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
   gNL_Func  := '', gEOLComment_Func := '' ; reset global variables
   return    finalLine
}
;################################################################################
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-12-24 AMB, MOVED to ConvertFuncs.ahk
; separates non-convert portion of line from portion to be converted
; returns non-convert portion in 'lineOpen' (hotkey declaration, opening brace, Try\Else, etc)
; returns rest of line (that requires conversion) in 'lineStr'
lp_SplitLine(&lineStr) {
   v1v2_noKywdCommas(&lineStr)     ; first remove trailing commas from keywords (including Switch)
   lineOpen := ''                  ; will become non-convert portion of line
   firstTwo := subStr(lineStr, 1, 2)

   ; if line is not a hotstring, but is single-line hotkey with cmd, separate hotkey from cmd temporarily...
   ;   so the cmd can be processed alone. The hotkey will be re-combined with cmd after it is converted.
   ;   nHotKey   := gPtn_HOTKEY . '(.*)' ;((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
   ; TODO - need to update needle for more accurate targetting
   nHotKey   := '((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
   if ((firstTwo   != '::') && RegExMatch(LineStr, nHotKey, &m)) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }

   ; if line begins with switch, separate any value following it temporarily....
   ;   so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
   ; any trailing comma for switch statement should have already been removed via noKywdCommas()
   nSwitch := 'i)^(\h*\bswitch\h*+)(.*+)'
   if (RegExMatch(LineStr, nSwitch, &m)) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }

   ; if line begins with case or default, separate any command following it temporarily...
   ;   so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
   nCaseDefault := 'i)^(\h*(?:case .*?|default):(?!=)\h*+)(.*+)$'
   if (RegExMatch(LineStr, nCaseDefault, &m)) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }

   ; if line begins with Try or Else, separate any command that may follow them temporarily...
   ;   so the cmd can be processed alone. The try/else will be re-combined with cmd after it is converted.
   nTryElse := 'i)^(\h*+}?\h*+(?:Try|Else)\h*[\h{]\h*+)(.*+)$'
   if (RegExMatch(LineStr, nTryElse, &m) && m[2]) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }

   ; if line begins with {, separate any command following it temporarily...
   ;   so the cmd can be processed alone. The { will be re-combined with cmd after it is converted.
   if (RegExMatch(LineStr, '^(\h*+{\h*+)(.*+)$', &m)) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }

   ; if line begins with } (but not else), separate any command following it temporarily...
   ;   so the cmd can be processed alone. The } will be re-combined with cmd after it is converted.
   if (RegExMatch(LineStr, 'i)^(\h*}(?!\h*else|\h*\n)\h*)(.*+)$', &m)) {
      lineOpen   := m[1]           ; non-convert portion
      LineStr      := m[2]         ; portion to convert
      return lineOpen
   }
   return lineOpen
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
   EOLComments := Map_I()
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