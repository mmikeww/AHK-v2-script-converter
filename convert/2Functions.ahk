#Requires AutoHotKey v2.0-beta.1

/* a list of all renamed functions, in this format:
    , "OrigV1Function", "ReplacementV2Function"
  (first comma is not needed for the first pair)
  Similar to commands, parameters can be added
  order of Is important do not change
*/

global FunctionsToConvertM := OrderedMap(
    "ComObject(vt, value, Flags)"         	, "ComValue({1}, {2}, {3})"
  , "ComObjCreate(CLSID , IID)"           	, "ComObject({1}, {2})"
  , "DllCall(DllFunction,Type1,Arg1,val*)"	, "*_DllCall"
  , "Func(FunctionNameQ2T)"               	, "{1}"
  , "RegExMatch(Haystack, NeedleRegEx , OutputVarV2VR, StartingPos)"   , "*_RegExMatch"
  , "RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCountV2VR,Limit,StartingPos", "RegExReplace({1}, {2}, {3}, {4}, {5}, {6})"
  , "StrReplace(Haystack,Needle,ReplaceText,OutputVarCountV2VR,Limit)" , "StrReplace({1}, {2}, {3}, , {4}, {5})"
  , "RegisterCallback(FunctionNameQ2T,Options,ParamCount,EventInfo)"   , "CallbackCreate({1}, {2}, {3})"
  , "LoadPicture(Filename,Options,ImageTypeV2VR)"      	, "LoadPicture({1},{2},{3})"
  , "LV_Add(Options, Field*)"                          	, "*_LV_Add"
  , "LV_Delete(RowNumber)"                             	, "*_LV_Delete"
  , "LV_DeleteCol(ColumnNumber)"                       	, "*_LV_DeleteCol"
  , "LV_GetCount(ColumnNumber)"                        	, "*_LV_GetCount"
  , "LV_GetText(OutputVar, RowNumber, ColumnNumber)"   	, "*_LV_GetText"
  , "LV_GetNext(StartingRowNumber, RowType)"           	, "*_LV_GetNext"
  , "LV_InsertCol(ColumnNumber , Options, ColumnTitle)"	, "*_LV_InsertCol"
  , "LV_Insert(RowNumber, Options, Field*)"            	, "*_LV_Insert"
  , "LV_Modify(RowNumber, Options, Field*)"            	, "*_LV_Modify"
  , "LV_ModifyCol(ColumnNumber, Options, ColumnTitle)" 	, "*_LV_ModifyCol"
  , "LV_SetImageList(ImageListID, IconType)"           	, "*_LV_SetImageList"
  , "TV_Add(Name,ParentItemID,Options)"                	, "*_TV_Add"
  , "TV_Modify(ItemID,Options,NewName)"                	, "*_TV_Modify"
  , "TV_Delete(ItemID)"                                	, "*_TV_Delete"
  , "TV_GetSelection(ItemID)"                          	, "*_TV_GetSelection"
  , "TV_GetParent(ItemID)"                             	, "*_TV_GetParent"
  , "TV_GetPrev(ItemID)"                               	, "*_TV_GetPrev"
  , "TV_GetNext(ItemID,ItemType)"                      	, "*_TV_GetNext"
  , "TV_GetText(OutputVar,ItemID)"                     	, "*_TV_GetText"
  , "TV_GetChild(ParentItemID)"                        	, "*_TV_GetChild"
  , "TV_GetCount()"                                    	, "*_TV_GetCount"
  , "TV_SetImageList(ImageListID,IconType)"            	, "*_TV_SetImageList"
  , "SB_SetText(NewText,PartNumber,Style)"             	, "*_SB_SetText"
  , "SB_SetParts(NewText,PartNumber,Style)"            	, "*_SB_SetParts"
  , "SB_SetIcon(Filename,IconNumber,PartNumber)"       	, "*_SB_SetIcon"
  , "MenuGetHandle(MenuNameQ2T)"                       	, "{1}.Handle"
  , "MenuGetName(Handle)"                              	, "MenuFromHandle({1})"
  , "NumGet(VarOrAddress,Offset,Type)"                 	, "*_NumGet"
  , "NumPut(Number,VarOrAddress,Offset,Type)"          	, "*_NumPut"
  , "Object(Array*)"                                   	, "*_Object"
  , "OnError(FuncQ2T,AddRemove)"                       	, "OnError({1}, {2})"
  , "OnMessage(MsgNumber, FunctionQ2T, MaxThreads)"    	, "OnMessage({1}, {2}, {3})"
  , "OnClipboardChange(FuncQ2T,AddRemove)"             	, "OnClipboardChange({1}, {2})"
  , "Asc(String)"                                      	, "Ord({1})"
  , "VarSetCapacity(TargetVar,RequestedCapacity,FillByte)" , "*_VarSetCapacity"
  )


_DllCall(p) {
  ParBuffer := ""
  loop p.Length
  {
    if (p[A_Index] ~= "^&") {	; Remove the & parameter
      p[A_Index] := SubStr(p[A_Index], 2)
    }
    if (A_Index != 1 and (InStr(p[A_Index - 1], "*`"") or InStr(p[A_Index - 1], "*`'") or InStr(p[A_Index - 1], "P`"") or InStr(p[A_Index - 1], "P`'"))) {
      p[A_Index] := "&" p[A_Index]
      if (!InStr(p[A_Index], ":=")) {
        p[A_Index] .= " := 0"
      }
    }
    ParBuffer .= A_Index = 1 ? p[A_Index] : ", " p[A_Index]
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
      NextParameters := RegExReplace(VarOrAddress, "is)^\s*Numput\((.*)\)\s*$", "$1", &OutputVarCount)
      if (OutputVarCount = 0) {
        break
      }

      ParBuffer := Type ", " Number ", `r`n" Indentation "   " ParBuffer

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
  global aListPseudoArray
  ; V1: FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos := 1)
  ; V2: FoundPos := RegExMatch(Haystack, NeedleRegEx , &OutputVar, StartingPos := 1)

  if (p[3] != "") {
    OutputVar := SubStr(Trim(p[3]), 2)  ; Remove the &
    if RegexMatch(P[2], "^[^(]*O[^(]*\)") {
      ; Object Match
      aListMatchObject.Push(OutputVar)

      P[2] := RegExReplace(P[2], "(^[^(]*)O([^(]*\).*$)", "$1$2") ; Remove the "O from the options"
    } else if RegexMatch(P[2], "^\(.*\)") {
      ; aListPseudoArray.Push(OutputVar)
      aListPseudoArray.Push({name: OutputVar})
    } else {

      ; beneath the line, we sould write : Indentation OutputVar " := " OutputVar "[]"
      ; aListPseudoArray.Push(OutputVar)
      aListPseudoArray.Push({name: OutputVar})

    }
  }
  Out := Format("RegExMatch({1}, {2}, {3}, {4})", p*)
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

_VarSterCapacity(p) {
  if (p[3] = "") {
    Return Format("VarSetStrCapacity(&{1}, {2})", p*)
  }
  Return Format("{1} := Buffer({2}, {3})", p*)
}
