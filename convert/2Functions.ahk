#Requires AutoHotKey v2.0

; 2025-12-24 AMB, MOVED Dynamic Conversion Funcs to AhkLangConv.ahk
/* a list of all renamed functions, in this format:
    , "OrigV1Function" ,
      "ReplacementV2Function"   (see AhkLangConv.ahk)
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
  order of Is important do not change
*/
;################################################################################
; 2025-11-28 AMB, UPDATED - changed to Case-Insensitive Map
; 2025-12-24 AMB, UPDATED - re-ordered Map Keys to alphabetic
global gmAhkFuncsToConvert := Map_I()
gmAhkFuncsToConvert := OrderedMap(
    "Asc(String)" ,
      "Ord({1})"
  , "Catch(OutputVar)" ,
      "*_Catch"
  , "ComObjCreate(CLSID , IID)" ,
      "ComObject({1}, {2})"
  , "ComObjError(Enable)" ,
      "({1} ? true : false) `; V1toV2: Wrap Com functions in try"
  , "ComObjParameter(vt, value, Flags)" ,
      "ComValue({1}, {2}, {3})"
  , "ComObject(vt, value, Flags)" ,
      "ComValue({1}, {2}, {3})"
  , "DllCall(DllFunction,Type1,Arg1,val*)" ,
      "*_DllCall"
  , "Exception(Message, What, Extra)" ,
      "Error({1}, {2}, {3})"
  , "Func(FunctionNameQ2T)" ,
      "{1}"
  , "Hotstring(String,Replacement,OnOffToggle)" ,
      "*_Hotstring"
  , "InStr(Haystack,Needle,CaseSensitive,StartingPos,Occurrence)" ,
      "*_InStr"
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
  , "LV_GetNext(StartingRowNumber, RowType)" ,
      "*_LV_GetNext"
  , "LV_GetText(OutputVar, RowNumber, ColumnNumber)" ,
      "*_LV_GetText"
  , "LV_Insert(RowNumber, Options, Field*)" ,
      "*_LV_Insert"
  , "LV_InsertCol(ColumnNumber , Options, ColumnTitle)" ,
      "*_LV_InsertCol"
  , "LV_Modify(RowNumber, Options, Field*)" ,
      "*_LV_Modify"
  , "LV_ModifyCol(ColumnNumber, Options, ColumnTitle)" ,
      "*_LV_ModifyCol"
  , "LV_SetImageList(ImageListID, IconType)" ,
      "*_LV_SetImageList"
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
  , "OnClipboardChange(FuncQ2T,AddRemove)" ,
      "OnClipboardChange({1}, {2})"
  , "OnError(FuncQ2T,AddRemove)" ,
      "OnError({1}, {2})"
  , "OnMessage(MsgNumber, FunctionQ2T, MaxThreads)" ,
      "*_OnMessage"
  , "RegExMatch(Haystack, NeedleRegEx, OutputVar, StartingPos)" ,
      "*_RegExMatch"
  , "RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCountV2VR,Limit,StartingPos)" ,
      "RegExReplace({1}, {2}, {3}, {4}, {5}, {6})"
  , "RegisterCallback(FunctionNameQ2T,Options,ParamCount,EventInfo)" ,
      "CallbackCreate({1}, {2}, {3})"
  , "SB_SetIcon(Filename,IconNumber,PartNumber)" ,
      "*_SB_SetIcon"
  , "SB_SetParts(Width*)" ,
      "*_SB_SetParts"
  , "SB_SetText(NewText,PartNumber,Style)" ,
      "*_SB_SetText"
  , "StrReplace(Haystack,Needle,ReplaceText,OutputVarCountV2VR,Limit)" ,
      "*_StrReplace"
  , "SubStr(String, StartingPos, Length)" ,
      "SubStr({1}, {2}, {3})"
  , "TV_Add(Name,ParentItemID,Options)" ,
      "*_TV_Add"
  , "TV_Delete(ItemID)" ,
      "*_TV_Delete"
  , "TV_GetChild(ParentItemID)" ,
      "*_TV_GetChild"
  , "TV_GetCount()" ,
      "*_TV_GetCount"
  , "TV_GetNext(ItemID,ItemType)" ,
      "*_TV_GetNext"
  , "TV_GetParent(ItemID)" ,
      "*_TV_GetParent"
  , "TV_GetPrev(ItemID)" ,
      "*_TV_GetPrev"
  , "TV_GetSelection(ItemID)" ,
      "*_TV_GetSelection"
  , "TV_GetText(OutputVar,ItemID)" ,
      "*_TV_GetText"
  , "TV_Modify(ItemID,Options,NewName)" ,
      "*_TV_Modify"
  , "TV_SetImageList(ImageListID,IconType)" ,
      "*_TV_SetImageList"
  , "VarSetCapacity(TargetVar,RequestedCapacity,FillByte)^(\s*[*+\-\/][\/]?)(\s*[.\d]{1,})(\s*[*+\-\/])?" ,
      "*_VarSetCapacity"
)
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
; 2025-12-24 AMB, MOVED to 2Functions.ahk
FormatParam(ParName, ParValue) {
;   ParName := StrReplace(Trim(ParName), "*")  ; Remove the *, that indicate an array (2025-06-12 NOT USED)
    ParValue := Trim(ParValue)
    if (ParName ~= "V2VRM?$") {
        if (ParValue != "" && !InStr(ParValue, "&"))
            ParValue := "&" . ParValue
        else if (ParName ~= "M$" && ParValue = "" && !InStr(ParValue, "&"))
            ParValue := "&AHKv1v2_vPlaceholder", goWarnings.AddedV2VRPlaceholder := 1
    } else if (ParName ~= "CBE2E$") {                                                       ; 'Can Be an Expression TO an Expression'
        if (SubStr(ParValue, 1, 2) = "% ")                                                  ; if this param expression was forced
            ParValue := SubStr(ParValue, 3)                                                 ; remove the forcing
        else
            ParValue := RemoveSurroundingPercents(ParValue)
    } else if (ParName ~= "CBE2T$") {                                                       ; 'Can Be an Expression TO literal Text'
        if (isInteger(ParValue))                                                            ; if this param is int
        || (SubStr(ParValue, 1, 2) = "% ")                                                  ; or the expression was forced
        || ((SubStr(ParValue, 1, 1) = "%") && (SubStr(ParValue, -1) = "%"))                 ; or var already wrapped in %%s
            ParValue := ParValue                                                            ; dont do any conversion
        else
            ParValue := "%" . ParValue . "%"                                                ; wrap in percent signs to evaluate the expr
    } else if (ParName ~= "Q2T$") {                                                         ; 'Can Be an quote TO literal Text'
        if ((SubStr(ParValue, 1, 1) = "`"") && (SubStr(ParValue, -1) = "`""))               ;  var already wrapped in Quotes
        || ((SubStr(ParValue, 1, 1) = "`'") && (SubStr(ParValue, -1) = "`'"))               ;  var already wrapped in Quotes
            ParValue := SubStr(ParValue, 2, StrLen(ParValue) - 2)
        else
            ParValue := "%" ParValue "%"
    } else if (ParName ~= "T2E$") {                                                         ; 'Text TO Expression'
        if (SubStr(ParValue, 1, 2) = "% ") {
            ParValue := SubStr(ParValue, 3)                                                 ; remove '% '
        } else {
            ; 2025-06-12 AMB, ADDED support for continuation sections
            csStr := ''
            ParValue := (ParValue != "") ? ((csStr := CSect.HasContSect(ParValue)) ? csStr : ToExp(parValue)) : ""
        }
    } else if (ParName ~= "T2QE$") {                                                        ; 'Text TO Quote Expression'
        ParValue := ToExp(ParValue)
    } else if (ParName ~= "i)On2True$") {                                                   ; 'Text TO Quote Expression'
        ParValue := RegexReplace(ParValue, "^%\s*(.*?)%?$", "$1")
        ParValue := RegexReplace(RegexReplace(RegexReplace(ParValue, "i)\btoggle\b", "-1"), "i)\bon\b", "true"), "i)\boff\b", "false")
    } else if (ParName ~= "i)^StartingPos$") {                                              ; Only parameters with this name. Found at InStr, SubStr, RegExMatch and RegExReplace.
        if (ParValue != "") {
            if (IsNumber(ParValue)) {
                ParValue := ParValue<1 ? ParValue-1 : ParValue
            } else {
                ParValue := "(" ParValue ")<1 ? (" ParValue ")-1 : (" ParValue ")"
            }
        }
    } else {
        v2_DQ_Literals(&ParValue)
    }
   Return ParValue
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
; Created by Ahk_user
; Tries to split the parameters better because sometimes the , is part of a quote, function or object
; spinn-off from DeathByNukes from https://autohotkey.com/board/topic/35663-functions-to-get-the-original-command-line-and-parse-it/
; I choose not to trim the values as spaces can be valuable too
; 2025-12-24 AMB, MOVED to 2Functions.ahk
V1ParamSplit(String, IsFromFunc := 0) {
   oResult := Array()   ; Array to store result
   oIndex := 1   ; index of array
   InArray := 0
   InApostrophe := false
   InFunction := 0
   InObject := 0
   InQuote := false
   CanBeExpr := true
   IsExpr := IsFromFunc

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

      if (oString.has(A_Index + 1) && Char = "%" && oString[A_Index + 1] = " " && CanBeExpr) {
         IsExpr := true
      } else if (CanBeExpr && Char != " ") {
         CanBeExpr := false
      }

      if (!InQuote && !InObject && !InArray && !InApostrophe && !InFunction) {
         if (Char = "," && (A_Index = 1 || oString[A_Index - 1] != "``")) {
            oIndex++
            oResult.Push("")
            Continue
         }
      }

      if (Char = "`"" && !InApostrophe && CheckQuotes) {
         if (IsExpr && !InQuote) {
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
   ;   MsgBox "[" v "]"
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
; Will try to extract the function of the given line
; Created by Ahk_user
; TODO - add support for "(steps[steps.maxindex()"
;    use gPtn_FuncCall needle instead ?
; 2025-12-24 AMB, MOVED to 2Functions.ahk
V1ParSplitFunctions(String, FunctionTarget := 1) {


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
; V1toV2_Functions() - Convert a v1 function in a single script line to v2
;   Can be used from inside _Funcs for nested checks (e.g., function in a DllCall)
;   Set gfLockGlbVars to 1 to lock global vars from being changed by funcs
; 2025-06-12 AMB, UPDATED - changed func name and some var and funcCall names
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
; 2025-11-01 AMB, UPDATED as part of Scope support
; 2026-01-24 AMB, UPDATED Catch
;   TODO - REMOVE ScriptString param
V1toV2_Functions(ScriptString, Line, &retV2, &gotFunc) {
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

        oPar := V1ParamSplit(oResult.Parameters, true)
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
                    try {
                        a := oListParam[A_Index]
                    }
                    catch as e { ; 2026-01-24 UPDATED for better handling
                        msg := "CONVERSION ERROR IN`n" A_ThisFunc "()"
                            . "`n`nFilePath:`n" gFilePath
                            . "`n`nScript Line:`n" line
                            . "`n`n" e.Message "`n`n" e.Extra
                        A_Clipboard := msg
                        MsgBox msg
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
                        NewFunction := FuncObj(oPar)    ; 2025-12-24 - see AhkLangConv.ahk for dynamic functions
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