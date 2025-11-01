﻿#Requires AutoHotKey v2.0

/* a list of all renamed functions, in this format:
    , "OrigV1Function" ,
      "ReplacementV2Function"
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
  order of Is important do not change
*/

;################################################################################
global gmAhkFuncsToConvert := OrderedMap(
    "Catch(OutputVar)" ,
    "*_Catch"
  , "ComObject(vt, value, Flags)" ,
    "ComValue({1}, {2}, {3})"
  , "ComObjCreate(CLSID , IID)" ,
     "ComObject({1}, {2})"
  , "ComObjError(Enable)" ,
     "({1} ? true : false) `; V1toV2: Wrap Com functions in try"
  , "ComObjParameter(vt, value, Flags)" ,
     "ComValue({1}, {2}, {3})"
  , "DllCall(DllFunction,Type1,Arg1,val*)" ,
     "*_DllCall"
  , "Exception(Message, What, Extra)",
     "Error({1}, {2}, {3})"
  , "Func(FunctionNameQ2T)" ,
     "{1}"
  , "Hotstring(String,Replacement,OnOffToggle)" ,
    "*_Hotstring"
  , "InStr(Haystack,Needle,CaseSensitive,StartingPos,Occurrence)" ,
    "*_InStr"
  , "RegExMatch(Haystack, NeedleRegEx, OutputVar, StartingPos)" ,
    "*_RegExMatch"
  , "RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCountV2VR,Limit,StartingPos)" ,
    "RegExReplace({1}, {2}, {3}, {4}, {5}, {6})"
  , "StrReplace(Haystack,Needle,ReplaceText,OutputVarCountV2VR,Limit)" ,
    "*_StrReplace"
  , "SubStr(String, StartingPos, Length)" ,
    "SubStr({1}, {2}, {3})"
  , "RegisterCallback(FunctionNameQ2T,Options,ParamCount,EventInfo)" ,
    "CallbackCreate({1}, {2}, {3})"
  , "LoadPicture(Filename,Options,ImageTypeV2VR)" ,
     "LoadPicture({1},{2},{3})"
  , "LV_Add(Options, Field*)" ,
     "*_LV_Add"
  , "LV_Delete(RowNumber)" ,
     "*_LV_Delete"
  , "LV_DeleteCol(ColumnNumber)" ,
     "*_LV_DeleteCol"
  , "LV_GetCount(ColumnNumber)" ,
     "*_LV_GetCount"
  , "LV_GetText(OutputVar, RowNumber, ColumnNumber)" ,
     "*_LV_GetText"
  , "LV_GetNext(StartingRowNumber, RowType)" ,
     "*_LV_GetNext"
  , "LV_InsertCol(ColumnNumber , Options, ColumnTitle)" ,
     "*_LV_InsertCol"
  , "LV_Insert(RowNumber, Options, Field*)" ,
     "*_LV_Insert"
  , "LV_Modify(RowNumber, Options, Field*)" ,
     "*_LV_Modify"
  , "LV_ModifyCol(ColumnNumber, Options, ColumnTitle)" ,
     "*_LV_ModifyCol"
  , "LV_SetImageList(ImageListID, IconType)" ,
     "*_LV_SetImageList"
  , "TV_Add(Name,ParentItemID,Options)" ,
     "*_TV_Add"
  , "TV_Modify(ItemID,Options,NewName)" ,
     "*_TV_Modify"
  , "TV_Delete(ItemID)" ,
     "*_TV_Delete"
  , "TV_GetSelection(ItemID)" ,
     "*_TV_GetSelection"
  , "TV_GetParent(ItemID)" ,
     "*_TV_GetParent"
  , "TV_GetPrev(ItemID)" ,
     "*_TV_GetPrev"
  , "TV_GetNext(ItemID,ItemType)" ,
     "*_TV_GetNext"
  , "TV_GetText(OutputVar,ItemID)" ,
     "*_TV_GetText"
  , "TV_GetChild(ParentItemID)" ,
     "*_TV_GetChild"
  , "TV_GetCount()" ,
     "*_TV_GetCount"
  , "TV_SetImageList(ImageListID,IconType)" ,
     "*_TV_SetImageList"
  , "SB_SetText(NewText,PartNumber,Style)" ,
     "*_SB_SetText"
  , "SB_SetParts(Width*)" ,
     "*_SB_SetParts"
  , "SB_SetIcon(Filename,IconNumber,PartNumber)" ,
     "*_SB_SetIcon"
  , "MenuGetHandle(MenuNameQ2T)" ,
     "{1}.Handle"
  , "MenuGetName(Handle)" ,
     "MenuFromHandle({1})"
  , "NumGet(VarOrAddress,Offset,Type)" ,
     "*_NumGet"
  , "NumPut(Number,VarOrAddress,Offset,Type)" ,
     "*_NumPut"
  , "Object(Array*)" ,
     "*_Object"
  , "ObjRawGet(Object, KeyQ2T)" ,
     "{1}.{2}"
  , "ObjRawSet(Object, KeyQ2T, Value)" ,
     "{1}.{2} := {3}"
  , "OnError(FuncQ2T,AddRemove)" ,
     "OnError({1}, {2})"
  , "OnMessage(MsgNumber, FunctionQ2T, MaxThreads)" ,
     "*_OnMessage"
  , "OnClipboardChange(FuncQ2T,AddRemove)" ,
     "OnClipboardChange({1}, {2})"
  , "Asc(String)" ,
     "Ord({1})"
  , "VarSetCapacity(TargetVar,RequestedCapacity,FillByte)^(\s*[*+\-\/][\/]?)(\s*[.\d]{1,})(\s*[*+\-\/])?" ,
    "*_VarSetCapacity"
  )


;################################################################################
; See ConvertFuncs.ahk for _Catch() (also used for command conversion)
; 2025-10-05 AMB, UPDATED - changed var name gfNoSideEffect to gfLockGlbVars

_DllCall(p) {
  ParBuffer := ""
  global gfLockGlbVars
  loop p.Length
  {
    if (p[A_Index] ~= "i)^U?(Str|AStr|WStr|Int64|Int|Short|Char|Float|Double|Ptr)P?\*?$") {
      ; Correction of old v1 DllCalls who forget to quote the types
      p[A_Index] := '"' p[A_Index] '"'
    }
    NeedleRegEx := "(\*\s*0\s*\+\s*)(&)(\w*)" ; *0+&var split into 3 groups (*0+), (&), and (var)
    ;if (p[A_Index] ~= "^&") {                       ; Remove the & parameter
    ;  p[A_Index] := SubStr(p[A_Index], 2)
    ;} else
    if (RegExMatch(p[A_Index], NeedleRegEx)) { ; even if it's behind a *0 var assignment preceding it
      gfLockGlbVars := 1    ; lock global vars (no changes allowed)
        V1toV2_Functions(ScriptString:=p[A_Index], Line:=p[A_Index], &v2:="", &gotFunc:=False)
      gfLockGlbVars := 0    ; unlock global vars (changes allowed)
      if (commentPos:=InStr(v2,"`;")) {
        v2 := SubStr(v2, 1, commentPos-1)
      }
      if (RegExMatch(v2, "VarSetStrCapacity\(&")) {   ; guard var in StrPtr if UTF-16 passed as "Ptr"
        if (p.Has(A_Index-1) && (p[A_Index-1] = '"Ptr"')) {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1StrPtr($3)")
          dbgTT(3, "@DllCall: 1StrPtr", Time:=3,id:=9)
        } else {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1$3")
          dbgTT(3, "@DllCall: 2NotPtr", Time:=3,id:=9)
        }
      } else if (RegExMatch(v2, "Buffer\(")) {         ; leave only the variable,  _VarSetCapacity(p) should place the rest on a new line before this
          p[A_Index] := RegExReplace(p[A_Index], ".*" NeedleRegEx,"$3")
          dbgTT(3, "@DllCall: 3Buff", Time:=3,id:=9)
      } else {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1$3")
          dbgTT(3, "@DllCall: 4Else", Time:=3,id:=9)
      }
    }
    if (((A_Index !=1) && (mod(A_Index, 2) = 1)) && (InStr(p[A_Index - 1], "*`"")
       || InStr(p[A_Index - 1], "*`'") || InStr(p[A_Index - 1], "P`"") || InStr(p[A_Index - 1], "P`'"))) {
      p[A_Index] := "&" p[A_Index]
      if (!InStr(p[A_Index], ":=")) {
        ; Disabled for now because of issue #54, but this can result in undefined variables...
        ; p[A_Index] .= " := 0"
      }
    }
    ParBuffer .= A_Index=1 ? p[A_Index] : ", " p[A_Index]
  }
  Return "DllCall(" ParBuffer ")"
}

;################################################################################
_Hotstring(p) {
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-11-01 AMB, UPDATED - gmList_LblsToFunc key case-sensitivity
  global gmList_LblsToFunc
  if (RegExMatch(p[1], '":') and p.Has(2)) {
    p[2] := Trim(p[2], '"')
    gmList_LblsToFunc[StrLower(p[2])] := ConvLabel('HS', p[2], '*', getV2Name(p[2]))
  }

  Out := "Hotstring("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

;################################################################################
_InStr(p) {
  global gaScriptStrsUsed
  p[3] := p[3] = "" and gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : p[3]
  Out := Format("InStr({1}, {2}, {3}, {4}, {5})", p*)
  return RegExReplace(Out, "[\s,]*\)", ")")
}

;################################################################################
_LV_Add(p) {
  global gLVNameDefault
  Out := gLVNameDefault ".Add("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  ; Out := format("{1}.Add({2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17})", gLVNameDefault, p*)
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_Delete(p) {
  global gLVNameDefault
  Return format("{1}.Delete({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_DeleteCol(p) {
  global gLVNameDefault
  Return format("{1}.DeleteCol({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetCount(p) {
  global gLVNameDefault
  Return format("{1}.GetCount({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetText(p) {
  global gLVNameDefault
  Return format("{2} := {1}.GetText({3})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetNext(p) {
  global gLVNameDefault
  Return format("{1}.GetNext({2},{3})", gLVNameDefault, p*)
}
;################################################################################
_LV_InsertCol(p) {
  global gLVNameDefault
  Return format("{1}.InsertCol({2}, {3}, {4})", gLVNameDefault, p*)
}
;################################################################################
_LV_Insert(p) {
  global gLVNameDefault
  Out := gLVNameDefault ".Insert("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_Modify(p) {
  global gLVNameDefault
  Out := gLVNameDefault ".Modify("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_ModifyCol(p) {
  global gLVNameDefault
  Return format("{1}.ModifyCol({2}, {3}, {4})", gLVNameDefault, p*)
}
;################################################################################
_LV_SetImageList(p) {
  global gLVNameDefault
  Return format("{1}.SetImageList({2}, {3})", gLVNameDefault, p*)
}

;################################################################################
_NumGet(p) {
  ;V1: NumGet(VarOrAddress , Offset := 0, Type := "UPtr")
  ;V2: NumGet(Source, Offset, Type)
  if (p[2] = "" && p[3] = "") {
    p[2] := '"UPtr"'
  }
  if (p[3] = "" && InStr(p[2],"A_PtrSize")) {
    p[3] := '"UPtr"'
  }
  Out := "NumGet(" P[1] ", " p[2] ", " p[3] ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_NumPut(p) {
  ;V1 NumPut(Number,VarOrAddress,Offset,Type)
  ;V2 NumPut Type, Number, Type2, Number2, ... Target , Offset
  ; This should work to unwind the NumPut labyrinth
  p[1] := StrReplace(StrReplace(p[1], "`r"), "`n")
  p[2] := StrReplace(StrReplace(p[2], "`r"), "`n")
  p[3] := StrReplace(StrReplace(p[3], "`r"), "`n")
  p[4] := StrReplace(StrReplace(p[4], "`r"), "`n")
  ; Get size from VarSetCapacity
  ; Only for NumPut, if this is common for enough other functions a global solution may be required
  for i, param in p {
    p[i] := RegExReplace(param, "i)VarSetCapacity\(.+?\)", "($0).Size")
  }
  if (InStr(p[2], "Numput(")) {
    ParBuffer := ""
    loop {
      p[1] := Trim(p[1])
      p[2] := Trim(p[2])
      p[3] := Trim(p[3])
      p[4] := Trim(p[4])
      Number := p[1]
      VarOrAddress := p[2]
      if (p[4] = "") {
        if (P[3] = "") {
          OffSet := ""
          Type := "`"UPtr`""
        } else if (IsInteger(p[3])) {
          OffSet := p[3]
          Type := "`"UPtr`""
        } else {
          OffSet := ""
          Type := p[3]
        }
      } else {  ;
        OffSet := p[3]
        Type := p[4]
      }

      ParBuffer := Type ", " Number ", `r`n" gIndent "   " ParBuffer

      NextParameters := RegExReplace(VarOrAddress, "is)^\s*Numput\((.*)\)\s*$", "$1", &OutputVarCount)
      if (OutputVarCount = 0) {
        break
      }

      p := V1ParamSplit(NextParameters)
      loop 4 - p.Length {
        p.Push("")
      }
    }
    Out := "NumPut(" ParBuffer VarOrAddress ", " OffSet ")"
  } else {
    p[1] := Trim(p[1])
    p[2] := Trim(p[2])
    p[3] := Trim(p[3])
    p[4] := Trim(p[4])
    Number := p[1]
    VarOrAddress := p[2]
    if (p[4] = "") {
      if (P[3] = "") {
        OffSet := ""
        Type := "`"UPtr`""
      } else if (IsInteger(p[3])) {
        OffSet := p[3]
        Type := "`"UPtr`""
      } else {
        OffSet := ""
        Type := p[3]
      }
    } else {  ;
      OffSet := p[3]
      Type := p[4]
    }
    Out := "NumPut(" Type ", " Number ", " VarOrAddress ", " OffSet ")"
  }
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

;################################################################################
_Object(p) {
  Parameters := ""
  Function := (p.Has(2)) ? "Map" : "Object" ; If parameters are used, a map object is intended
  Loop p.Length
  {
    Parameters .= Parameters = "" ? p[A_Index] : ", " p[A_Index]
  }
  ; Should we convert used statements as mapname.test to mapname["test"]?
  Return Function "(" Parameters ")"
}

;################################################################################
class clsOnMsg
{
; 2025-10-12 AMB - ADDED for better support of OnMessage params and binding
; used with gmOnMessageMap
  msg       := ''                       ; OnMessage message ID
  cbFunc    := ''                       ; callback func - from OnMessage-call perspective
  bindStr   := ''                       ; bind string (can be used for sensing or appending)

  __new(msg,cbf:='',bs:='') {                 ; must be instantiated using msg id
    this.msg        := msg
    this.cbFunc     := cbf
    this.bindStr    := bs
  }
  funcName => Trim(this.cbFunc, '% ')   ; callback func NAME ONLY (in case it's needed)
}
;################################################################################
_OnMessage(p) {
; 2025-10-05 AMB, UPDATED - changed masking src to gCBPH - see MaskCode.ahk
; 2025-10-12 AMB, UPDATED - to provide better support for params and binding
;   gmOnMessageMap now holds custom clsOnMsg objects
  ; OnMessage(MsgNumber, FunctionQ2T, MaxThreads)
  ; OnMessage({1}, {2}, {3})
  global gmOnMessageMap

  if (p.Has(1) && p.Has(2) && p[1] != '' && p[2] != '') {
    msg := string(p[1]), cbFunc := p[2], bindStr := ''                          ; use vars for better clarity
    if (InStr(cbFunc, 'Func(')) {                                                 ; when cbFunc param is using v1 Func()...
      if (RegExMatch(cbFunc, '\.Bind\(.*\)', &bindContent)) {                   ; if OnMsg call includes .Bind()...
        bindStr := bindContent[]                                                ; ... save .Bind() string
      }
      if (RegExMatch(cbFunc, '%Func\("(\w+)"\)', &m)) {                           ; when cbFunc param is using Func("name")...
        cbFunc := m[1]                                                          ; ... record just the CB func name
      }
      else if RegExMatch(cbFunc, '%Func\((\w+)\)', &m) {                        ; when cbFunc param is using Func(var)...
        cbFunc := '%' m[1] '%'                                                  ; ... add deref to cb func name
      }
    }
    ; 2025-10-12 AMB - changed to using clsOnMsg object for issue #384-2
    ; see addOnMessageCBArgs() in GuiAndMenu.ahk
    gmOnMessageMap[msg] := clsOnMsg(msg,cbFunc,bindStr)                         ; create a new clsOnMsg object
    maxThds := (p.Has(3) && p[3] != '') ? ', ' p[3] : ''                        ; include maxThreads param if present
    return  'OnMessage(' msg ', ' cbFunc bindStr maxThds ')'                    ; create/return OnMessage Call str
  }
  if (p.Has(2) && p[2] = '') {                                                  ; if cbFunc is empty...
    Try {
      callback := gmOnMessageMap[string(p[1])].cbFunc                           ; try to get cb func...
    } Catch {                                                                   ; ... (no object has been created for this msg)
      Return 'OnMessage(' p[1] ', ' gCBPH ', 0)'                                ; Didnt find lister to turn off
    }
    Return 'OnMessage(' p[1] ', ' callback ', 0)'                               ; Found the listener to turn off
  }
}

;################################################################################
_StrReplace(p) {
  global gaScriptStrsUsed
  CaseSense := gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
  Out := Format("StrReplace({2}, {3}, {4}, {1}, {5}, {6})", CaseSense, p*)
  return RegExReplace(Out, "[\s,]*\)", ")")
}

;################################################################################
_SB_SetText(p) {
  global gSBNameDefault
  Return format("{1}.SetText({2}, {3}, {4})", gSBNameDefault, p*)
}
;################################################################################
_SB_SetParts(p) {
  global gSBNameDefault
  Out := gSBNameDefault ".SetParts("
  for , v in p {
    Out .= v ", "
  }
  Return RTrim(Out, ", ") ")"
}
;################################################################################
_SB_SetIcon(p) {
  global gSBNameDefault, gFuncParams
  Return format("{1}.SetIcon({2})", gSBNameDefault, gFuncParams)
}

;################################################################################
_TV_Add(p) {
  global gTVNameDefault
  Return format("{1}.Add({2}, {3}, {4})", gTVNameDefault, p*)
}
;################################################################################
_TV_Modify(p) {
  global gTVNameDefault
  Return format("{1}.Modify({2}, {3}, {4})", gTVNameDefault, p*)
}
;################################################################################
_TV_Delete(p) {
  global gTVNameDefault
  Return format("{1}.Delete({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetSelection(p) {
  global gTVNameDefault
  Return format("{1}.GetSelection({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetParent(p) {
  global gTVNameDefault
  Return format("{1}.GetParent({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetChild(p) {
  global gTVNameDefault
  Return format("{1}.GetChild({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetPrev(p) {
  global gTVNameDefault
  Return format("{1}.GetPrev({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetNext(p) {
  global gTVNameDefault
  Return format("{1}.GetNext({2}, {3})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetText(p) {
  global gTVNameDefault
  Return format("{2} := {1}.GetText({3})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetCount(p) {
  global gTVNameDefault
  Return format("{1}.GetCount()", gTVNameDefault)
}
;################################################################################
_TV_SetImageList(p) {
  global gTVNameDefault
  Return format("{2} := {1}.SetImageList({3})", gTVNameDefault)
}

;################################################################################
_VarSetCapacity(p) {
; 2025-10-05 AMB, UPDATED - changed some var names
  global gfrePostFuncMatch, gNL_Func, gEOLComment_Func, gfLockGlbVars

  ; if global vars are locked, update local temp vars instead (using ref vars)
  if (gfLockGlbVars) {
    vrNL_Func           := &tmp1 := ''
    vrEOLComment_Func   := &tmp2 := ''
  } else {
    vrNL_Func           := &gNL_Func
    vrEOLComment_Func   := &gEOLComment_Func := ''
  }
  reM := gfrePostFuncMatch
  if (p[3] != "") {
    ; since even multiline continuation allows line comments adding vrEOLComment_Func shouldn't break anything, but if it does, add this hacky comment
      ;`{3} + 0*StrLen("V1toV2: comment")`, or when you can't add a 0 (to a buffer)
      ; p.Push("V1toV2: comment")
      ; retStr := Format('RegExReplace("{1} := Buffer({2}, {3}) ``; {4}", " ``;.*$")', p*)
    varA   := Format("{1}"                           , p*)
    retStr := Format("VarSetStrCapacity(&{1}, {2})"  , p*)
    %vrEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}' and replace all instances of '{1}.Ptr' with 'StrPtr({1})'", varA, retStr)
    gmVarSetCapacityMap.Set(p[1], "B")
    if (!reM) {
      retBuf := Format("{1} := Buffer({2}, {3})"     , p*)
      dbgTT(3, "@_VarSetCapacity: 3 args, plain", Time:=3,id:=5,x:=-1,y:=-1)
    } else {
      if (reM.Count = 1) { ; just in case, min should be 2
        p.Push(reM[])
        retBuf   := Format("({1} := Buffer({2}, {3})).Size{4}", p*)
        dbgTT(3, "@_VarSetCapacity: 3 args, Regex 1 group", Time:=3,id:=5,x:=-1,y:=-1)
      } else if (reM.Count = 2) { ; one operator and a number, e.g. *0
        ; op  := reM[1]
        ; num := reM[2]
        ; if Trim(op) = "//"
        p.Push(reM[])
        retBuf   := Format("({1} := Buffer({2}, {3})).Size{4}", p*)
        dbgTT(3, "@_VarSetCapacity: 3 args, Regex 2 groups", Time:=3,id:=5,x:=-1,y:=-1)
      } else if (reM.Count = 3) { ; op1, number, op2, e.g. *0+
        op1 := reM[1]
        num := reM[2]
        op2 := reM[3]
        if (Trim(op1)="*" && Trim(num)="0") { ; move to the previous new line, remove regex matches
          if (%vrNL_Func%) {                       ; add a newline for multiple calls in a line
            %vrNL_Func% .= "`r`n" ;;;;; but breaks other calls
          }
          %vrEOLComment_Func% .= " NB! if this is part of a control flow block without {}, please enclose this and the next line in {}!"
          p.Push(%vrEOLComment_Func%)
          %vrNL_Func% .= Format("{1} := Buffer({2}, {3}) `; {4}"   , p*)
          ; DllCall("oleacc", "Ptr", VarSetCapacity(vC,8,0)*0 + &vC)
          %vrEOLComment_Func% := ""
          retBuf := ""
          dbgTT(3, "@_VarSetCapacity: 3 args, Regex 3 groups, NEWLINE", Time:=3,id:=5,x:=-1,y:=-1)
        } else {
          p.Push(reM[])
          retBuf := Format("({1} := Buffer({2}, {3})).Size{4}", p*)
          dbgTT(3, "@_VarSetCapacity: 3 args, Regex 3 groups", Time:=3,id:=5,x:=-1,y:=-1)
        }
      }
    }
    Return retBuf
  } else if (p[3]  = "") {
    dbgTT(3, "@_VarSetCapacity: 2 args", Time:=3,id:=5,x:=-1,y:=-1)
    varA   := Format("{1}"                           , p*)
    retBuf := Format("{1} := Buffer({2})"            , p*)
    %vrEOLComment_Func% .= format("V1toV2: if '{1}' is NOT a UTF-16 string, use '{2}' and replace all instances of 'StrPtr({1})' with '{1}.Ptr'", varA, retBuf)
    gmVarSetCapacityMap.Set(p[1], "V")
    if (!reM) {
      retStr := Format("VarSetStrCapacity(&{1}, {2})"  , p*)
    } else {
      p.Push(reM[])
      retStr := Format("VarSetStrCapacity(&{1}, {2}){4}"  , p*)
    }
    Return retStr
  } else {
    dbgTT(3, "@_VarSetCapacity: fallback", Time:=3,id:=5,x:=-1,y:=-1)
    varA   := Format("{1}", p*)
    retStr := Format("VarSetStrCapacity(&{1}, {2})"        , p*)
    %vrEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}' and replace all instances of '{1}.Ptr' with 'StrPtr({1})'", varA, retStr)
    gmVarSetCapacityMap.Set(p[1], "B")
    if (!reM) {
      retBuf := Format("{1} := Buffer({2}, {3})"           , p*)
    } else {
      p.Push(reM[])
      retBuf := Format("({1} := Buffer({2}, {3}).Size){4}" , p*)
    }
    Return retBuf
  }
}
;################################################################################
; V1toV2_Functions() - Convert a v1 function in a single script line to v2
;   Can be used from inside _Funcs for nested checks (e.g., function in a DllCall)
;   Set gfLockGlbVars to 1 to lock global vars from being changed by funcs
; 2025-06-12 AMB, UPDATED - changed func name and some var and funcCall names
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
;################################################################################
V1toV2_Functions(ScriptString, Line, &retV2, &gotFunc) {
; 2025-11-01 AMB, UPDATED as part of Scope support
;   TODO - REMOVE ScriptString param

    global gFuncParams, gfrePostFuncMatch, gFileOpenVars
    FuncsRemoved := 0   ; Number of funcs that have been removed during conversion (e.g Arr.Length() -> Arr.Length)
    ScriptString := gOrigScript ; 2025-11-01 AMB, ADDED as part of Scope support
    loop {
        if (!InStr(Line, "("))
            break


        oResult := V1ParSplitfunctions(Line, A_Index - FuncsRemoved)

        if (oResult.Found = 0) {
            break
        }
        if (oResult.Hook_Status > 0) {
            ; This means that the function did not close, probably a continuation section
            break
        }
        if (oResult.Func = "") {
            continue  ; Not a function, only parenthesis
        }
        ; 2025-10-12 AMB - VERY BASIC (temp) support for #358
        ;MsgBox line "`n`n[" oResult.pre "]`n[" oResult.func "]`n[" oResult.parameters "]`n[" oResult.post "]`n[" oResult.separator "]"
        if (oResult.func = 'FileOpen' && RegExMatch(oResult.pre, '\h*(\w+)\h*:=', &mFOv)) { ; look for obj assignments for FileOpen
          gaFileOpenVars.Push(mFOv[1])                                                      ; add var/obj name to list of FileOpen objects
        }

        oPar := V1ParamSplit(oResult.Parameters)
        gFuncParams := oResult.Parameters

        ConvertList := gmAhkFuncsToConvert
        if (RegExMatch(oResult.Pre, "((?:\w+)|(?:\[.*\])|(?:{.*}))\.$", &Match)) {
            ObjectName := Match[1]
            if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\[|(Array|StrSplit)\()")) {   ; Type Array().
                ConvertList := gmAhkArrMethsToConvert
            } else if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(\{|(Object)\()")) {    ; Type Object().
                ConvertList := gmAhkMethsToConvert
            } else if (RegExMatch(ScriptString, "i)(?<!\w)(\Q" ObjectName "\E)\s*:=\s*(new\s+|(FileOpen|Func|ObjBindMethod|\w*\.Bind)\()")) { ; Type instance of class.
                ConvertList := []   ; Unspecified conversion patterns.
            } else if (RegExMatch(ScriptString, "i)(?<!\w)class\s(\Q" ObjectName "\E)(?!\w)")) {    ; Type Class.
                ConvertList := []   ; Unspecified conversion patterns.
            } else {
                ConvertList := gmAhkMethsToConvert
                Loop gaList_MatchObj.Length {
                    if (ObjectName = gaList_MatchObj[A_Index]) {
                        ConvertList := []   ; Conversions handled elsewhere.
                        Break
                    }
                }
                Loop gaList_PseudoArr.Length {
                    if (ObjectName = gaList_PseudoArr[A_Index].name) {
                        ConvertList := []   ; Conversions handled elsewhere.
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
                    try
                    {
                        a := oListParam[A_Index]
                    }
                    catch
                    {
                        A_Clipboard := line
                        MsgBox "[" "error" "]"
                    }

                    b := oPar[A_Index]
                    oPar[A_Index] := FormatParam(a,b)
                }
                loop oListParam.Length
                {
                    if (!oPar.Has(A_Index)) {
                        oPar.Push("")
                    }
                }

                if (SubStr(v2, 1, 1) == "*")    ; if using a special function
                {
                    if (rePostFunc != "")
                    {
                        ; move post-function's regex match to _Func (it should return back if needed)
                        RegExMatch(oResult.Post, rePostFunc, &gfrePostFuncMatch)
                        oResult.Post := RegExReplace(oResult.Post, rePostFunc)
                    }

                    FuncName := SubStr(v2, 2)

                    FuncObj := %FuncName%   ; // https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
                    if (FuncObj is Func) {
                        NewFunction := FuncObj(oPar)
                    }
                } Else {
                    FormatString := Trim(v2)
                    NewFunction := Format(FormatString, oPar*)
                }

                ; Remove the empty variables
                NewFunction := RegExReplace(NewFunction, "[\s\,]*\)$", ")")

                Line := oResult.Pre NewFunction oResult.Post

                retV2 := Line
                gotFunc:=True

                ; TODO: make this count "(" instead, fixes removed funcs with params
                ;       only breaks if script did Arr.Length(MeaninglessVar)
                StrReplace(Line, "()",,, &v2FuncCount)
                FuncsRemoved := Max(0, v1FuncCount - v2FuncCount)

                break   ; Function/Method just found and processed.
            }
        }
    }
}