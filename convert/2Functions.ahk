#Requires AutoHotKey v2.0

/* a list of all renamed functions, in this format:
    , "OrigV1Function" ,
      "ReplacementV2Function"
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
  order of Is important do not change
*/

global FunctionsToConvertM := OrderedMap(
    "ComObject(vt, value, Flags)" ,
    "ComValue({1}, {2}, {3})"
  , "ComObjCreate(CLSID , IID)" ,
     "ComObject({1}, {2})"
  , "DllCall(DllFunction,Type1,Arg1,val*)" ,
     "*_DllCall"
  , "Func(FunctionNameQ2T)" ,
     "{1}"
  , "InStr(Haystack,Needle,CaseSensitive,StartingPos,Occurrence)" ,
    "InStr({1}, {2}, {3}, {4}, {5})"
  , "RegExMatch(Haystack, NeedleRegEx, OutputVar, StartingPos)" ,
    "*_RegExMatch"
  , "RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCountV2VR,Limit,StartingPos)" ,
    "RegExReplace({1}, {2}, {3}, {4}, {5}, {6})"
  , "StrReplace(Haystack,Needle,ReplaceText,OutputVarCountV2VR,Limit)" ,
    "StrReplace({1}, {2}, {3}, , {4}, {5})"
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
  , "SB_SetParts(NewText,PartNumber,Style)" ,
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
     "OnMessage({1}, {2}, {3})"
  , "OnClipboardChange(FuncQ2T,AddRemove)" ,
     "OnClipboardChange({1}, {2})"
  , "Asc(String)" ,
     "Ord({1})"
  , "VarSetCapacity(TargetVar,RequestedCapacity,FillByte)^(\s*[*+\-\/][\/]?)(\s*[.\d]{1,})(\s*[*+\-\/])?" ,
    "*_VarSetCapacity"
  )


_DllCall(p) {
  ParBuffer := ""
  global noSideEffect
  loop p.Length
  {
    if (p[A_Index] ~= "i)^U?(Str|AStr|WStr|Int64|Int|Short|Char|Float|Double|Ptr)P?\*?$"){
      ; Correction of old v1 DllCalls who forget to quote the types
      p[A_Index] := '"' p[A_Index] '"'
    }
    NeedleRegEx := "(\*\s*0\s*\+\s*)(&)(\w*)" ; *0+&var split into 3 groups (*0+), (&), and (var)
    if (p[A_Index] ~= "^&") {                       ; Remove the & parameter
      p[A_Index] := SubStr(p[A_Index], 2)
    } else if RegExMatch(p[A_Index], NeedleRegEx) { ; even if it's behind a *0 var assignment preceding it
      noSideEffect := 1
      subLoopFunctions(ScriptString:=p[A_Index], Line:=p[A_Index], &v2:="", &gotFunc:=False)
      noSideEffect := 0
      if (commentPos:=InStr(v2,"`;")) {
        v2 := SubStr(v2, 1, commentPos-1)
      }
      if RegExMatch(v2, "VarSetStrCapacity\(&") {   ; guard var in StrPtr if UTF-16 passed as "Ptr"
        if p.Has(A_Index-1) and (p[A_Index-1] = '"Ptr"') {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1StrPtr($3)")
          dbgTT(3, "@DllCall: 1StrPtr", Time:=3,id:=9)
        } else {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1$3")
          dbgTT(3, "@DllCall: 2NotPtr", Time:=3,id:=9)
        }
      } else if RegExMatch(v2, "Buffer\("){         ; leave only the variable,  _VarSetCapacity(p) should place the rest on a new line before this
          p[A_Index] := RegExReplace(p[A_Index], ".*" NeedleRegEx,"$3")
          dbgTT(3, "@DllCall: 3Buff", Time:=3,id:=9)
      } else {
          p[A_Index] := RegExReplace(p[A_Index],      NeedleRegEx,"$1$3")
          dbgTT(3, "@DllCall: 4Else", Time:=3,id:=9)
      }
    }
    if (((A_Index !=1) and (mod(A_Index, 2) = 1)) and (InStr(p[A_Index - 1], "*`"") or InStr(p[A_Index - 1], "*`'") or InStr(p[A_Index - 1], "P`"") or InStr(p[A_Index - 1], "P`'"))) {
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

_LV_Add(p) {
  global ListviewNameDefault
  Out := ListviewNameDefault ".Add("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  ; Out := format("{1}.Add({2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17})", ListviewNameDefault, p*)
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_LV_Delete(p) {
  global ListviewNameDefault
  Return format("{1}.Delete({2})", ListviewNameDefault, p*)
}
_LV_DeleteCol(p) {
  global ListviewNameDefault
  Return format("{1}.DeleteCol({2})", ListviewNameDefault, p*)
}
_LV_GetCount(p) {
  global ListviewNameDefault
  Return format("{1}.GetCount({2})", ListviewNameDefault, p*)
}
_LV_GetText(p) {
  global ListviewNameDefault
  Return format("{2} := {1}.GetText({3})", ListviewNameDefault, p*)
}
_LV_GetNext(p) {
  global ListviewNameDefault
  Return format("{1}.GetNext({2},{3})", ListviewNameDefault, p*)
}
_LV_InsertCol(p) {
  global ListviewNameDefault
  Return format("{1}.InsertCol({2}, {3}, {4})", ListviewNameDefault, p*)
}
_LV_Insert(p) {
  global ListviewNameDefault
  Out := ListviewNameDefault ".Insert("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_LV_Modify(p) {
  global ListviewNameDefault
  Out := ListviewNameDefault ".Modify("
  loop p.Length {
    Out .= p[A_Index] ", "
  }
  Out .= ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_LV_ModifyCol(p) {
  global ListviewNameDefault
  Return format("{1}.ModifyCol({2}, {3}, {4})", ListviewNameDefault, p*)
}
_LV_SetImageList(p) {
  global ListviewNameDefault
  Return format("{1}.SetImageList({2}, {3})", ListviewNameDefault, p*)
}

_NumGet(p) {
  ;V1: NumGet(VarOrAddress , Offset := 0, Type := "UPtr")
  ;V2: NumGet(Source, Offset, Type)
  if (p[2] = "" and p[3] = "") {
    p[2] := '"UPtr"'
  }
  if (p[3] = "" and InStr(p[2],"A_PtrSize")) {
    p[3] := '"UPtr"'
  }  
  Out := "NumGet(" P[1] ", " p[2] ", " p[3] ")"
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
_NumPut(p) {
  ;V1 NumPut(Number,VarOrAddress,Offset,Type)
  ;V2 NumPut Type, Number, Type2, Number2, ... Target , Offset
  ; This should work to unwind the NumPut labyrinth
  p[1] := StrReplace(StrReplace(p[1], "`r"), "`n")
  p[2] := StrReplace(StrReplace(p[2], "`r"), "`n")
  p[3] := StrReplace(StrReplace(p[3], "`r"), "`n")
  p[4] := StrReplace(StrReplace(p[4], "`r"), "`n")
  if InStr(p[2], "Numput(") {
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
      
      ParBuffer := Type ", " Number ", `r`n" Indentation "   " ParBuffer
      
      NextParameters := RegExReplace(VarOrAddress, "is)^\s*Numput\((.*)\)\s*$", "$1", &OutputVarCount)
      if (OutputVarCount = 0) {
        break
      }

      p := V1ParSplit(NextParameters)
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

_Object(p) {
  Parameters := ""
  Function := p.Has(2) ? "Map" : "Object" ; If parameters are used, a map object is intended
  Loop p.Length
  {
    Parameters .= Parameters = "" ? p[A_Index] : ", " p[A_Index]
  }
  ; Should we convert used statements as mapname.test to mapname["test"]?
  Return Function "(" Parameters ")"
}

_RegExMatch(p) {
  global aListMatchObject, aListPseudoArray
  ; V1: FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos := 1)
  ; V2: FoundPos := RegExMatch(Haystack, NeedleRegEx , &OutputVar, StartingPos := 1)

  if (p[3] != "") {
    OrigPattern := P[2]
    OutputVar := p[3]

    CaptNames := [], pos := 1
    while pos := RegExMatch(OrigPattern, "(?<!\\)(?:\\\\)*\(\?<(\w+)>", &Match, pos)
      pos += Match.Len, CaptNames.Push(Match[1])

    Out := ""
    if RegExMatch(OrigPattern, '^"([^"(])*O([^"(])*\)(.*)$', &Match) {
      ; Mode 3 (match object)
      ; v1OutputVar.Value(1) -> v2OutputVar[1]
      ; The v1 methods Count and Mark are properties in v2.
      P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "O" from the options
      aListMatchObject.Push(OutputVar)
    } else if RegExMatch(OrigPattern, '^"([^"(])*P([^"(])*\)(.*)$', &Match) {
      ; Mode 2 (position-and-length)
      ; v1OutputVar -> v2OutputVar.Len
      ; v1OutputVarPos1 -> v2OutputVar.Pos[1]
      ; v1OutputVarLen1 -> v2OutputVar.Len[1]
      P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "P" from the options
      aListPseudoArray.Push({name: OutputVar "Len", newname: OutputVar '.Len'})
      aListPseudoArray.Push({name: OutputVar "Pos", newname: OutputVar '.Pos'})
      aListPseudoArray.Push({strict: true, name: OutputVar, newname: OutputVar ".Len"})
      for CaptName in CaptNames {
        aListPseudoArray.Push({strict: true, name: OutputVar "Len" CaptName, newname: OutputVar '.Len["' CaptName '"]'})
        aListPseudoArray.Push({strict: true, name: OutputVar "Pos" CaptName, newname: OutputVar '.Pos["' CaptName '"]'})
      }
    } else if RegExMatch(OrigPattern, 'i)^"[a-z``]*\)') ; Explicit options.
      || RegExMatch(OrigPattern, 'i)^"[^"]*[^a-z``]') { ; Explicit no options.
      ; Mode 1 (Default)
      ; v1OutputVar -> v2OutputVar[0]
      ; v1OutputVar1 -> v2OutputVar[1]
      aListPseudoArray.Push({name: OutputVar})
      aListPseudoArray.Push({strict: true, name: OutputVar, newname: OutputVar "[0]"})
      for CaptName in CaptNames
        aListPseudoArray.Push({strict: true, name: OutputVar CaptName, newname: OutputVar '["' CaptName '"]'})
    } else { 
      ; Unknown mode. Unclear options, possibly variables obscuring the parameter.
      ; Treat as default mode?... The unhandled options O and P will make v2 throw anyway.
      aListPseudoArray.Push({name: OutputVar})
      aListPseudoArray.Push({strict: true, name: OutputVar, newname: OutputVar "[0]"})
    }
    Out .= Format("RegExMatch({1}, {2}, &{3}, {4})", p*)
  } else {
    Out := Format("RegExMatch({1}, {2}, , {4})", p*)
  }
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SB_SetText(p) {
  global StatusBarNameDefault
  Return format("{1}.SetText({2}, {3}, {4})", StatusBarNameDefault, p*)
}
_SB_SetParts(p) {
  global StatusBarNameDefault, gFunctPar
  Return format("{1}.SetParts({2})", StatusBarNameDefault, gFunctPar)
}
_SB_SetIcon(p) {
  global StatusBarNameDefault, gFunctPar
  Return format("{1}.SetIcon({2})", StatusBarNameDefault, gFunctPar)
}

_TV_Add(p) {
  global TreeViewNameDefault
  Return format("{1}.Add({2}, {3}, {4})", TreeViewNameDefault, p*)
}
_TV_Modify(p) {
  global TreeViewNameDefault
  Return format("{1}.Modify({2}, {3}, {4})", TreeViewNameDefault, p*)
}
_TV_Delete(p) {
  global TreeViewNameDefault
  Return format("{1}.Delete({2})", TreeViewNameDefault, p*)
}
_TV_GetSelection(p) {
  global TreeViewNameDefault
  Return format("{1}.GetSelection({2})", TreeViewNameDefault, p*)
}
_TV_GetParent(p) {
  global TreeViewNameDefault
  Return format("{1}.GetParent({2})", TreeViewNameDefault, p*)
}
_TV_GetChild(p) {
  global TreeViewNameDefault
  Return format("{1}.GetChild({2})", TreeViewNameDefault, p*)
}
_TV_GetPrev(p) {
  global TreeViewNameDefault
  Return format("{1}.GetPrev({2})", TreeViewNameDefault, p*)
}
_TV_GetNext(p) {
  global TreeViewNameDefault
  Return format("{1}.GetNext({2}, {3})", TreeViewNameDefault, p*)
}
_TV_GetText(p) {
  global TreeViewNameDefault
  Return format("{2} := {1}.GetText({3})", TreeViewNameDefault, p*)
}
_TV_GetCount(p) {
  global TreeViewNameDefault
  Return format("{1}.GetCount()", TreeViewNameDefault)
}
_TV_SetImageList(p) {
  global TreeViewNameDefault
  Return format("{2} := {1}.SetImageList({3})", TreeViewNameDefault)
}

_VarSetCapacity(p) {
  global grePostFuncMatch, NL_Func, EOLComment_Func, noSideEffect
  if noSideEffect {
    tmp1:="", tmp2:=""
    lNL_Func        	:= &tmp1
    lEOLComment_Func	:= &tmp2
  } else {
    lNL_Func        	:= &NL_Func
    lEOLComment_Func	:= &EOLComment_Func
  }
  %lEOLComment_Func%:=""
  reM := grePostFuncMatch
  if        (p[3] != "") {
    ; since even multiline continuation allows semicolon comments adding lEOLComment_Func shouldn't break anything, but if it does, add this hacky comment
      ;`{3} + 0*StrLen("V1toV2: comment")`, or when you can't add a 0 (to a buffer)
      ; p.Push("V1toV2: comment")
      ; retStr := Format('RegExReplace("{1} := Buffer({2}, {3}) ``; {4}", " ``;.*$")', p*)
    varA  	:= Format("{1}"                           , p*)
    retStr	:= Format("VarSetStrCapacity(&{1}, {2})"  , p*)
    %lEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}'", varA, retStr)
    if not reM {
      retBuf	:= Format("{1} := Buffer({2}, {3})"     , p*)
      dbgTT(3, "@_VarSetCapacity: 3 args, plain", Time:=3,id:=5,x:=-1,y:=-1)
    } else {
      if        reM.Count = 1 { ; just in case, min should be 2
        p.Push(reM[])
        retBuf	:= Format("({1} := Buffer({2}, {3})).Size{4}", p*)
        dbgTT(3, "@_VarSetCapacity: 3 args, Regex 1 group", Time:=3,id:=5,x:=-1,y:=-1)
      } else if reM.Count = 2 { ; one operator and a number, e.g. *0
        ; op  := reM[1]
        ; num := reM[2]
        ; if Trim(op) = "//"
        p.Push(reM[])
        retBuf	:= Format("({1} := Buffer({2}, {3})).Size{4}", p*)
        dbgTT(3, "@_VarSetCapacity: 3 args, Regex 2 groups", Time:=3,id:=5,x:=-1,y:=-1)
      } else if reM.Count = 3 { ; op1, number, op2, e.g. *0+
        op1 := reM[1]
        num := reM[2]
        op2 := reM[3]
        if Trim(op1)="*" and Trim(num)="0" { ; move to the previous new line, remove regex matches
          if %lNL_Func% {                       ; add a newline for multiple calls in a line
            %lNL_Func%	.= "`r`n" ;;;;; but breaks other calls
          }
          %lEOLComment_Func% .= " NB! if this is part of a control flow block without {}, please enclose this and the next line in {}!"
          p.Push(%lEOLComment_Func%)
          %lNL_Func%	.= Format("{1} := Buffer({2}, {3}) `; {4}"   , p*)
          ; DllCall("oleacc", "Ptr", VarSetCapacity(vC,8,0)*0 + &vC)
          %lEOLComment_Func% := ""
          retBuf	:= ""
          dbgTT(3, "@_VarSetCapacity: 3 args, Regex 3 groups, NEWLINE", Time:=3,id:=5,x:=-1,y:=-1)
        } else {
          p.Push(reM[])
          retBuf	:= Format("({1} := Buffer({2}, {3})).Size{4}", p*)
          dbgTT(3, "@_VarSetCapacity: 3 args, Regex 3 groups", Time:=3,id:=5,x:=-1,y:=-1)
        }
      }
    }
    Return retBuf
  } else if (p[3]  = "") {
    dbgTT(3, "@_VarSetCapacity: 2 args", Time:=3,id:=5,x:=-1,y:=-1)
    varA  	:= Format("{1}"                           , p*)
    retBuf	:= Format("{1} := Buffer({2})"            , p*)
    %lEOLComment_Func% .= format("V1toV2: if '{1}' is NOT a UTF-16 string, use '{2}'", varA, retBuf)
    if not reM {
      retStr	:= Format("VarSetStrCapacity(&{1}, {2})"  , p*)
    } else {
      p.Push(reM[])
      retStr	:= Format("VarSetStrCapacity(&{1}, {2}){4}"  , p*)
    }
    Return retStr
  } else {
    dbgTT(3, "@_VarSetCapacity: fallback", Time:=3,id:=5,x:=-1,y:=-1)
    varA  	:= Format("{1}", p*)
    retStr	:= Format("VarSetStrCapacity(&{1}, {2})"        , p*)
    %lEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}'", varA, retStr)
    if not reM {
      retBuf	:= Format("{1} := Buffer({2}, {3})"           , p*)
    } else {
      p.Push(reM[])
      retBuf	:= Format("({1} := Buffer({2}, {3}).Size){4}" , p*)
    }
    Return retBuf
  }
}
