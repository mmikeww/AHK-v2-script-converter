;################################################################################

; 2025-12-24 AMB - Combined cmds/func functions into single file for easier manangement
; This file contains functions used to convert v1 cmd/funcs to v2 format
;	They accept an array of v1 parameters (p) and return v2 command/func in text form
;	These funcs are called (dynamically) from:
;		executeConversion()	in convV2_Funcs.ahk	(for ahkv1 command	conversion)
;		V1toV2_Functions()	in 2Functions.ahk	(for ahkv1 function	conversion)
;		The funcs below should be listed alphabetically (with few exceptions)
;	Some conversions are handled directly using the following maps:
;		(SEE BOTTOM OF THIS FILE FOR REFERENCES TO THESE)
;		gmAhkCmdsToConvertV1 (see 1Commands.ahk)	for ahkv1.0 (legacy) commands
;		gmAhkCmdsToConvertV2 (see 1Commands.ahk)	for ahkv1.1		  	 commands
;		gmAhkFuncsToConvert  (see 2Functions.ahk)	for ahkv1			 functions

;################################################################################
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
; V1: Control, SubCommand, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText
_Control(p) {
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
; V1: ControlGet, OutputVar, SubCommand, Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText
; unfinished
; 2026-01-03 AMB, UPDATED - fixed indent issue
_ControlGet(p) {
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
			Out .= gIndent gSingleIndent p[1] " .= A_index=1 ? `"`" : `"``n`"`r`n"	; Attention do not add ``r!!!
			Out .= gIndent gSingleIndent p[1] " .= o" p[1] "[A_Index] `r`n"
			Out .= gIndent "}"
		}
	}
	out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	out		:= Zip(out, 'CTRLGET')		; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	out
}
;################################################################################
_ControlGetFocus(p) {
	Out		:= format("{1} := ControlGetClassNN(ControlGetFocus({2}, {3}, {4}, {5}))", p*)
	Return	RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_CoordMode(p) {
	p[2]	:= StrReplace(P[2], "Relative", "Window")
	Out		:= Format("CoordMode({1}, {2})", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
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
		p[2]	:= p[2] = "" ? "" : ToExp(p[2])
		p[3]	:= p[3] = "" ? "" : ToExp(p[3])
		Out		:= Format("Drive{1}({2}, {3})", p*)
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; 2025-10-05 AMB, UPDATED - changed var name gfNoSideEffect to gfLockGlbVars
; 2025-11-28 AMB, UPDATED - prevent ampersand from being added to numbers
_DllCall(p) {
	ParBuffer := ""
	global gfLockGlbVars
	loop p.Length {
		if (p[A_Index] ~= "i)^U?(Str|AStr|WStr|Int64|Int|Short|Char|Float|Double|Ptr)P?\*?$") {
			; Correction of old v1 DllCalls who forget to quote the types
			p[A_Index] := '"' p[A_Index] '"'
		}
		NeedleRegEx := "(\*\s*0\s*\+\s*)(&)(\w*)"							; *0+&var split into 3 groups (*0+), (&), and (var)
		;if (p[A_Index] ~= "^&") {											; Remove the & parameter
		;p[A_Index] := SubStr(p[A_Index], 2)
		;} else
		if (RegExMatch(p[A_Index], NeedleRegEx)) {							; even if it's behind a *0 var assignment preceding it
			gfLockGlbVars := 1												; lock global vars (no changes allowed)
				V1toV2_Functions(ScriptString:=p[A_Index], Line:=p[A_Index], &v2:="", &gotFunc:=False)
			gfLockGlbVars := 0												; unlock global vars (changes allowed)
			if (commentPos:=InStr(v2,"`;")) {
				v2 := SubStr(v2, 1, commentPos-1)
			}
			if (RegExMatch(v2, "VarSetStrCapacity\(&")) {					; guard var in StrPtr if UTF-16 passed as "Ptr"
				if (p.Has(A_Index-1) && (p[A_Index-1] = '"Ptr"')) {
					p[A_Index] := RegExReplace(p[A_Index], NeedleRegEx,"$1StrPtr($3)")
					dbgTT(3, "@DllCall: 1StrPtr", Time:=3,id:=9)
				} else {
					p[A_Index] := RegExReplace(p[A_Index], NeedleRegEx,"$1$3")
					dbgTT(3, "@DllCall: 2NotPtr", Time:=3,id:=9)
				}
			} else if (RegExMatch(v2, "Buffer\(")) {						; leave only the variable,	_VarSetCapacity(p) should place the rest on a new line before this
				p[A_Index] := RegExReplace(p[A_Index], ".*" NeedleRegEx,"$3")
				dbgTT(3, "@DllCall: 3Buff", Time:=3,id:=9)
			} else {
				p[A_Index] := RegExReplace(p[A_Index], NeedleRegEx,"$1$3")
				dbgTT(3, "@DllCall: 4Else", Time:=3,id:=9)
			}
		}
		if (((A_Index !=1) && (mod(A_Index, 2) = 1)) && (InStr(p[A_Index - 1], "*`"")
		|| InStr(p[A_Index - 1], "*`'") || InStr(p[A_Index - 1], "P`"") || InStr(p[A_Index - 1], "P`'"))) {
			; 2025-11-28 AMB, UPDATED - prevent ampersand from being added to numbers
			if (!IsNumber(p[A_index])) {
				p[A_Index] := "&" p[A_Index]
			}
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
_EnvAdd(p) {
	if (!IsEmpty(p[3]))
		return format("{1} := DateAdd(({1} != `"`" ? {1} : A_Now), {2}, {3})", p*)
	else
		return format("{1} += {2}", p*)
}
;################################################################################
_EnvSub(p) {
	if (!IsEmpty(p[3]))
		return format("{1} := DateDiff(({1} != `"`" ? {1} : A_Now), ({2} != `"`" ? {2} : A_Now), {3})", p*)
	else
		return format("{1} -= {2}", p*)
}
;################################################################################
_FileCopy(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		Out := format("Try {`r`n"
		. gIndent "   FileCopy({1}, {2}, {3})`r`n"
		. gIndent "   ErrorLevel := 0`r`n"
		. gIndent "} Catch as Err {`r`n"
		. gIndent "   ErrorLevel := Err.Extra`r`n"
		. gIndent "}", p*)
	} Else {
		out := format("FileCopy({1}, {2}, {3})", p*)
	}
	out		:= RegExReplace(Out, "[\s\,]*\)", ")")
	out		:= Zip(out, 'FILECOPY')		; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	out
}
;################################################################################
_FileCopyDir(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		Out := format("Try {`r`n"
		. gIndent "   DirCopy({1}, {2}, {3})`r`n"
		. gIndent "   ErrorLevel := 0`r`n"
		. gIndent "} Catch {`r`n"
		. gIndent "   ErrorLevel := 1`r`n"
		. gIndent "}", p*)
	} Else {
		out := format("DirCopy({1}, {2}, {3})", p*)
	}
	out		:= RegExReplace(Out, "[\s\,]*\)", ")")
	out		:= Zip(out, 'FILECOPYDIR')	; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	out
}
;################################################################################
_FileMove(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		Out := format("Try {`r`n"
		. gIndent "   FileMove({1}, {2}, {3})`r`n"
		. gIndent "   ErrorLevel := 0`r`n"
		. gIndent "} Catch as Err {`r`n"
		. gIndent "   ErrorLevel := Err.Extra`r`n"
		. gIndent "}", p*)
	} Else {
		out := format("FileMove({1}, {2}, {3})", p*)
	}
	out		:= RegExReplace(Out, "[\s\,]*\)", ")")
	out		:= Zip(out, 'FILEMOVE')		; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	out
}
;################################################################################
; FileRead, OutputVar, Filename
; OutputVar := FileRead(Filename, Options)
_FileRead(p) {
	if (InStr(p[2], "*")) {
		Options		:= RegExReplace(p[2], "^\s*(\*.*?)\s[^\*]*$", "$1")
		Filename	:= RegExReplace(p[2], "^\s*\*.*?\s([^\*]*)$", "$1")
		Options		:= StrReplace(Options, "*t", "``n")
		Options		:= StrReplace(Options, "*")
		if (InStr(options, "*P")) {
			OutputDebug("Conversion FileRead has not correct.`n")
		}
		; To do: add encoding
		Return format("{1} := FileRead({2}, {3})", p[1], ToExp(Filename), ToExp(Options))
	}
	Return format("{1} := FileRead({2})", p[1], ToExp(p[2]))
}
;################################################################################
; FileReadLine, OutputVar, Filename, LineNum
; Not really a good alternative, inefficient but the result is the same
_FileReadLine(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		; 2025-11-30 AMB - fix indent issue
		cmd :=							; Very bulky solution, only way for errorlevel
		(
		'Try {`r`n'
		gIndent gSingleIndent 'Global ErrorLevel := 0, ' p[1] ' := StrSplit(FileRead(' p[2] '),`"``n`",`"``r`")[' p[3] ']`r`n'
		gIndent '} Catch {`r`n'
		gIndent gSingleIndent p[1] ' := "", ErrorLevel := 1`r`n'
		gIndent '}'
		)
		Return Zip(cmd, 'FILEREADLN')	; 2025-11-30 AMB - compress to single-line tag, as needed
	} else {
		out := p[1] " := StrSplit(FileRead(" p[2] "),`"``n`",`"``r`")[" P[3] "]"
		Return Zip(out, 'FILEREADLN')	; 2025-11-30 AMB - compress to single-line tag, as needed
	}
}
;################################################################################
; V1: FileSelectFile, OutputVar [, Options, RootDir\Filename, Title, Filter]
; V2: SelectedFile := FileSelect([Options, RootDir\Filename, Title, Filter])
; 2026-01-01 AMB, UPDATED - changed global gEarlyLine to gV1Line
_FileSelect(p) {
	oPar			:= V1ParamSplit(RegExReplace(gV1Line, "i)^\s*FileSelectFile\s*[\s,]\s*(.*)$", "$1"))
	OutputVar		:= oPar[1]
	Options			:= oPar.Has(2) ? oPar[2] : ""
	RootDirFilename	:= oPar.Has(3) ? oPar[3] : ""
	Title			:= oPar.Has(4) ? trim(oPar[4]) : ""
	Filter			:= oPar.Has(5) ? trim(oPar[5]) : ""

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
	return Zip(Line, 'FILESELECT')		; 2025-11-30 AMB - compress to single-line tag, as needed
}
;################################################################################
; old V1 : FileSetAttrib, Attributes, FilePattern, OperateOnFolders?, Recurse?
; New V2 : FileSetAttrib Attributes, FilePattern, Mode (DFR)
_FileSetAttrib(p) {
	OperateOnFolders	:= P[3]
	Recurse				:= P[4]
	P[3]	:= OperateOnFolders = 1 ? "DF" : OperateOnFolders = 2 ? "D" : ""
	P[3]	.= Recurse = 1 ? "R" : ""
	P[3]	:= P[3] = "" ? "" : ToExp(P[3])
	Out		:= format("FileSetAttrib({1}, {2}, {3})", p*)
	Return	out := RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
; old V1 : FileSetTime, YYYYMMDDHH24MISS, FilePattern, WhichTime, OperateOnFolders?, Recurse?
; New V2 : YYYYMMDDHH24MISS, FilePattern, WhichTime, Mode (DFR)
_FileSetTime(p) {
	OperateOnFolders	:= P[4]
	Recurse				:= P[5]
	P[4]	:= OperateOnFolders = 1 ? "DF" : OperateOnFolders = 2 ? "D" : ""
	P[4]	.= Recurse = 1 ? "R" : ""
	P[4]	:= P[4] = "" ? "" : ToExp(P[4])
	Out		:= format("FileSetTime({1}, {2}, {3}, {4})", p*)
	Return	out := RegExReplace(Out, "[\s\,]*\)", ")")
}
;################################################################################
_GetKeyState(p) {
	out		:= format('{1} := GetKeyState({2}', p[1], p[2])
	out		.= ((p[3]) ? (', ' p[3]) : '') . ') ? "D" : "U"'
	return	out
}
;;################################################################################
;_Goto() {
;	; SEE PreProcessLines()	in ConvertFuncs.ahk
;	; 	and convertGoto()	in LabelAndFunc.ahk
;}
;################################################################################
_Gui(p) {
	return GuiConv(p)			; see GuiAndMenu.ahk
}
;################################################################################
_GuiControl(p) {
	return GuiControlConv(p)	; see GuiAndMenu.ahk
}
;################################################################################
_GuiControlGet(p) {
	return GuiControlGetConv(p)	; see GuiAndMenu.ahk
}
;################################################################################
_HashtagIfWinActivate(p) {
	if (p[1] = "" && p[2] = "") {
		Return "#HotIf"
	}
	Return format("#HotIf WinActive({1}, {2})", p*)
}
;################################################################################
; #Warn {1}, {2}
_HashtagWarn(p) {
	if (p[1] = "" && p[2] = "") {
		Return "#Warn"
	}
	Out := "#Warn "
	if (p[1] != "") {
		if (p[1] ~= "^((Use(Env|Unset(Local|Global)))|ClassOverwrite)$") {	; UseUnsetLocal, UseUnsetGlobal, UseEnv, ClassOverwrite
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
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-10-12 AMB, UPDATED - to fix issue #328
; 2025-11-01 AMB, UPDATED - as part of Scope support, and gmList_LblsToFunc key case-sensitivity
_Hotkey(p) {
	LineSuffix := ""
	global gmList_LblsToFunc

	;Convert label to function

	if (scriptHasLabel(p[2])) {												; 2025-11-01 UPDATED as part of Scope support
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
		if (SubStr(Trim(P[2]),1,1) = '%') {									; 2025-10-12 AMB - fix for #328
			p[2]		:= ToExp(p[2])										; remove %, (but we needed to know this was a var and not a str)
			funcName	:= addHKCmdFunc(p[2])								; link var name and func it points to
		}
		if InStr(p[3], "UseErrorLevel") {
			p[3] := Trim(StrReplace(p[3], "UseErrorLevel"))
			LineSuffix := " `; V1toV2: Removed UseErrorLevel"
		}
		p[3] := p[3] = "" ? "" : ToExp(p[3])
		Out := Format("Hotkey({1}, {2}, {3})", p*)
	}
	Out		:= RegExReplace(Out, "\s*`"`"\s*\)$", ")")
	Return	RegExReplace(Out, "[\s\,]*\)$", ")") LineSuffix
}
;################################################################################
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-11-01 AMB, UPDATED - gmList_LblsToFunc key case-sensitivity
_Hotstring(p) {
	global gmList_LblsToFunc
	if (RegExMatch(p[1], '":') && p.Has(2)) {
		p[2] := Trim(p[2], '"')
		gmList_LblsToFunc[p[2]] := ConvLabel('HS', p[2], '*', getV2Name(p[2]))
	}
	Out := "Hotstring("
	loop p.Length {
		Out .= p[A_Index] ", "
	}
	Out		.= ")"
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_IfGreater(p) {
	if (isNumber(p[2]) || InStr(p[2], "%"))
		return format("if ({1} > {2})", p*)
	else
		return format("if (StrCompare({1}, {2}) > 0)", p*)
}
;################################################################################
_IfGreaterOrEqual(p) {
	if (isNumber(p[2]) || InStr(p[2], "%"))
		return format("if ({1} > {2})", p*)
	else
		return format("if (StrCompare({1}, {2}) >= 0)", p*)
}
;################################################################################
_IfInString(p) {
	CaseSense	:= gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
	Out			:= Format("if InStr({2}, {3}, {1})", CaseSense, p*)
	return		RegExReplace(Out, "[\s,]*\)", ")")
}
;################################################################################
_IfNotInString(p) {
	CaseSense	:= gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
	Out			:= Format("if !InStr({2}, {3}, {1})", CaseSense, p*)
	return		RegExReplace(Out, "[\s,]*\)", ")")
}
;################################################################################
_IfLess(p) {
	if (isNumber(p[2]) || InStr(p[2], "%"))
		return format("if ({1} < {2})", p*)
	else
		return format("if (StrCompare({1}, {2}) < 0)", p*)
}
;################################################################################
_IfLessOrEqual(p) {
	if (isNumber(p[2]) || InStr(p[2], "%"))
		return format("if ({1} < {2})", p*)
	else
		return format("if (StrCompare({1}, {2}) <= 0)", p*)
}
;################################################################################
_Input(p) {
	Out		:= format("ih{1} := InputHook({2},{3},{4}), ih{1}.Start(), "
			. ((gaScriptStrsUsed.ErrorLevel) ? "ErrorLevel := " : "")
			. "ih{1}.Wait(), {1} := ih{1}.Input"
			, p*)
	Out		:= RegExReplace(Out, "[\h\,]*\)", ")")
	Return	Out
}
;################################################################################
; V1: InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default]
; V2: Obj := InputBox(Prompt, Title, Options, Default)
_InputBox(oPar) {
	options		:= ""
	OutputVar	:= oPar[1]
	Title		:= oPar.Has(2) ? oPar[2] : ""
	Prompt		:= oPar.Has(3) ? oPar[3] : ""
	Hide		:= oPar.Has(4) ? trim(oPar[4]) : ""
	Width		:= oPar.Has(5) ? trim(oPar[5]) : ""
	Height		:= oPar.Has(6) ? trim(oPar[6]) : ""
	X			:= oPar.Has(7) ? trim(oPar[7]) : ""
	Y			:= oPar.Has(8) ? trim(oPar[8]) : ""
	Locale		:= oPar.Has(9) ? trim(oPar[9]) : ""
	Timeout		:= oPar.Has(10) ? trim(oPar[10]) : ""
	Default		:= (oPar.Has(11) && oPar[11] != "") ? ToExp(trim(oPar[11])) : ""

	Parameters	:= ToExp(Prompt)
	Title		:= ToExp(Title)
	if (Hide	= "hide") {
		Options .= "Password"
	}
	if (Width	!= "") {
		Options .= Options != "" ? " " : ""
		Options .= "w"
		Options .= IsNumber(Width) ? Width : "`" " Width " `""
	}
	if (Height	!= "") {
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
	Options		:= Options = "" ? "" : "`"" Options "`""

	Out := format("IB := InputBox({1}, {3}, {4}, {5})", parameters, OutputVar, Title, Options, Default)
	Out := RegExReplace(Out, "[\s\,]*\)$", ")")
	Out .= ", " OutputVar " := IB.Value"
	if (gaScriptStrsUsed.ErrorLevel) {
		Out .= ', ErrorLevel := IB.Result="OK" ? 0 : IB.Result="CANCEL" ? 1 : IB.Result="Timeout" ? 2 : "ERROR"'
	}
	Return Out
}
;################################################################################
_InsertAt(p) {
	if (p.Length = 1) {
		Return "Push(" p[1] ")"
	} else if (p.Length > 1 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"'))) {
		for i, v in p {
			val .= ", " v
		}
		Return "InsertAt(" LTrim(val, ", ") ")"
	}
}
;################################################################################
_InStr(p) {
	p[3]	:= p[3] = "" && gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : p[3]
	Out		:= Format("InStr({1}, {2}, {3}, {4}, {5})", p*)
	return	RegExReplace(Out, "[\s,]*\)", ")")
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
	if (InStr(p[1], "*") && InStr(p[1], "\")) {								; Automatically switching to Files loop
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
		Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")				; remove trailing ,\s and ,\s""
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
		Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")				; remove trailing ,\s and ,\s""
		return Line BracketEnd
	} else if (p[1] = "Files") {
		Line := format("Loop {1}, {2}, {3}", "Files", ToExp(p[2]), ToExp(p[3]))
		Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")				; remove trailing ,\s and ,\s""
		return Line
	} else if (p[1] = "Read") {
		Line := p.Has(3) ? Trim(ToExp(p[3])) : ""
		Line := Line != "" ? ", " Line : ""
		Line := p.Has(2) ? Trim(ToExp(p[2])) Line : "" Line
		Line := Line != "" ? ", " Line : ""
		Line := p.Has(1) ? Trim(p[1]) Line : "" Line
		Line := "Loop " Line
		Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "")				; remove trailing ,\s and ,\s""
		return Line BracketEnd
	} else {
		Line := p[1] != "" ? "Loop " Trim(ToExp(p[1])) : "Loop"
		return Line BracketEnd
	}
	; Else no changes need to be made
}
;################################################################################
_LV_Add(p) {
	Out := gLVNameDefault ".Add("
	loop p.Length {
		Out .= p[A_Index] ", "
	}
	Out		.= ")"
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_Delete(p) {
	Return format("{1}.Delete({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_DeleteCol(p) {
	Return format("{1}.DeleteCol({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetCount(p) {
	Return format("{1}.GetCount({2})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetText(p) {
	Return format("{2} := {1}.GetText({3})", gLVNameDefault, p*)
}
;################################################################################
_LV_GetNext(p) {
	Return format("{1}.GetNext({2},{3})", gLVNameDefault, p*)
}
;################################################################################
_LV_InsertCol(p) {
	Return format("{1}.InsertCol({2}, {3}, {4})", gLVNameDefault, p*)
}
;################################################################################
_LV_Insert(p) {
	Out := gLVNameDefault ".Insert("
	loop p.Length {
		Out .= p[A_Index] ", "
	}
	Out		.= ")"
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_Modify(p) {
	Out := gLVNameDefault ".Modify("
	loop p.Length {
		Out .= p[A_Index] ", "
	}
	Out		.= ")"
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_LV_ModifyCol(p) {
	Return format("{1}.ModifyCol({2}, {3}, {4})", gLVNameDefault, p*)
}
;################################################################################
_LV_SetImageList(p) {
	Return format("{1}.SetImageList({2}, {3})", gLVNameDefault, p*)
}
;################################################################################
_Menu(p) {
	return MenuConv(p)		; see GuiAndMenu.ahk
}
;################################################################################
; 2025-07-03 AMB, CHANGED for dual conversion support
_MsgBox(p) {
	return (gV2Conv) ? _MsgBox_V2(p) : _MsgBox_V1(p)
}
;################################################################################
; 2025-07-03 AMB, ADDED for v1.1 conversion (WORK IN PROGRESS)
;	TODO - may merge with _MsgBox_V2() when done
; V1:
;	 MsgBox, Text (1-parameter method)
;	 MsgBox [, Options, Title, Text, Timeout]
_MsgBox_V1(p) {
	if (RegExMatch(p[1], 'i)^((0x)?\d*\h*|\h*%\h*\w+%?\h*)$')
	&& (p.Extra.OrigArr.Length > 1)) {
		options	:= p[1]
		title	:= ToExp(p[2])
		; if param 4 is empty, OR is a number, OR has a var (%)
		if (p.Length = 4 && (IsEmpty(p[4])
		||	IsNumber(p[4])
		||	RegExMatch(p[4], '\h*%', &mVar))) {
			text	:= (csStr := CSect.HasContSect(p[3])) ? csStr : ToExp(p[3])
			TmOut	:= (IsEmpty(p[4])) ? '' : ToExp(p[4])					; add timeout as needed
		} else {
			text	:= ''
			loop p.Extra.OrigArr.Length - 2
				text.= ',' p.Extra.OrigArr[A_Index + 2]
			text	:= ToExp(SubStr(text, 2))
		}
		; format output
		Out := format('MsgBox {1}, {2}, {3}', ToExp(options), (title = '""' ? '' : title), text)
		Out .= (TmOut) ? ', ' TmOut : ''
		return Out
	} else {																; only has 1 param - could be text, var, func call, or combo of these
		; 2024-08-03 AMB, ADDED support for multiline text that may include variables
		if (csStr := CSect.HasContSect(p[1])) {								; if has continuation section, converts it
			return 'MsgBox %' csStr
		}
		; does not have continuation section
		param	:= p.Extra.OrigStr
		param	:= (param='') ? '""' : RegExReplace(ToExp(param), '^%\h+')
		Out		:= format('MsgBox % {1}', param)
		return	Out
	}
}
;################################################################################
; 2025-07-03 AMB, ADDED/UPDATED for dual conversion support (WORK IN PROGRESS)
;	TODO - may merge with _MsgBox_V1() when done
; V1:
; 	MsgBox, Text (1-parameter method)
; 	MsgBox [, Options, Title, Text, Timeout]
; V2:
; 	Result := MsgBox(Text, Title, Options)
_MsgBox_V2(p) {
	if (RegExMatch(p[1], 'i)^((0x)?\d*\h*|\h*%\h*\w+%?\h*)$')
	&& (p.Extra.OrigArr.Length > 1)) {
		options	:= p[1]
		title	:= ToExp(p[2])
		; if param 4 is empty, OR is a number, OR has a var (%)
		if (p.Length = 4 && (IsEmpty(p[4])
		||	IsNumber(p[4])
		||	RegExMatch(p[4], '\h*%', &mVar))) {
			text	:= (csStr := CSect.HasContSect(p[3])) ? csStr : ToExp(p[3])
			options	.= (IsEmpty(p[4])) ? '' : ' " T" ' ToExp(p[4])			; add timeout as needed
		} else {
			text	:= ''
			loop p.Extra.OrigArr.Length - 2
				text.= ',' p.Extra.OrigArr[A_Index + 2]
			text	:= ToExp(SubStr(text, 2))
		}
		; format output
		Out := format('MsgBox({1}, {2}, {3})', text, (title = '""' ? '' : title), ToExp(options))
		if (gaScriptStrsUsed.IfMsgBox) {
			Out := 'msgResult := ' Out
		}
		; clean up options param
		if IsSet(mVar) {													; If timeout is variable
			Out := RegExReplace(Out, '``" T``" (\w+)"\)', '" T" $1)')
		}
		Out := RegExReplace(Out, '``" T``" ', 'T')
		Out := RegExReplace(Out, '" " T', '" T')
		Out := RegExReplace(Out, '(,\h*"[^,]*?)\h*"([^,]*"[^,]*?\))$', '$1$2')
		return Out
	} else {																; only has 1 param - could be text, var, func call, or combo of these
		; 2024-08-03 AMB, ADDED support for multiline text that may include variables
		if (csStr := CSect.HasContSect(p[1])) {								; if has continuation section, converts it
			return 'MsgBox(' csStr ')'
		}
		; does not have continuation section
		param	:= p.Extra.OrigStr
		Out		:= format('MsgBox({1})', ((param='') ? '' : ToExp(param)))
		if (gaScriptStrsUsed.IfMsgBox) {
			Out	:= 'msgResult := ' Out
		}
		return	Out
	}
}
;################################################################################
; V1: NumGet(VarOrAddress, Offset := 0, Type := "UPtr")
; V2: NumGet(Source, Offset, Type)
_NumGet(p) {
	if (p[2] = "" && p[3] = "") {
		p[2] := '"UPtr"'
	}
	if (p[3] = "" && InStr(p[2],"A_PtrSize")) {
		p[3] := '"UPtr"'
	}
	Out		:= "NumGet(" P[1] ", " p[2] ", " p[3] ")"
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; V1: NumPut(Number,VarOrAddress,Offset,Type)
; V2: NumPut Type, Number, Type2, Number2, ... Target, Offset
_NumPut(p) {
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
		} else {
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
		} else {
		OffSet := p[3]
		Type := p[4]
		}
		Out := "NumPut(" Type ", " Number ", " VarOrAddress ", " OffSet ")"
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	Return	Out
}
;################################################################################
_Object(p) {
	Parameters := ""
	Function := (p.Has(2)) ? "Map" : "Object"								; If parameters are used, a map object is intended
	Loop p.Length {
		Parameters .= Parameters = "" ? p[A_Index] : ", " p[A_Index]
	}
	; Should we convert used statements as mapname.test to mapname["test"]?
	Return Function "(" Parameters ")"
}
;################################################################################
; V1: OnExit,Func,AddRemove
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; TODO - FIX MISSING 2ND PARAM AND "RETURN 1" BEING PLACE AFTER EXITAPP
;	SEE DRAWLINE 123548C5 FOR EXAMPLE
; 2025-11-01 AMB, UPDATED as part of Scope support, and gmList_LblsToFunc key case-sensitivity
_OnExit(p) {
	if (scriptHasLabel(p[1])) {
		gmList_LblsToFunc[p[1]] := ConvLabel('OX', p[1], 'A_ExitReason, ExitCode', ''
		, regex := {NeedleRegEx: "(?i)^(.*)(\bRETURN\b)([\s\t]*;.*|)$", Replacement: "$1$2 1$3"})
	}
	; return needs to be replaced by return 1 inside the exitcode
	return Format("OnExit({1}, {2})", p*)
}
;################################################################################
; 2025-10-12 AMB - ADDED for better support of OnMessage params and binding
; used with gmOnMessageMap
class clsOnMsg {
	msg		:= ''															; OnMessage message ID
	cbFunc	:= ''															; callback func - from OnMessage-call perspective
	bindStr	:= ''															; bind string (can be used for sensing or appending)
	__new(msg,cbf:='',bs:='') {												; must be instantiated using msg id
		this.msg		:= msg
		this.cbFunc		:= cbf
		this.bindStr	:= bs
	}
	funcName => Trim(this.cbFunc, '% ')										; callback func NAME ONLY (in case it's needed)
}
;################################################################################
; 2025-10-05 AMB, UPDATED - changed masking src to gCBPH - see MaskCode.ahk
; 2025-10-12 AMB, UPDATED - to provide better support for params and binding
;	gmOnMessageMap now holds custom clsOnMsg objects
; OnMessage(MsgNumber, FunctionQ2T, MaxThreads)
; OnMessage({1}, {2}, {3})
_OnMessage(p) {
	global gmOnMessageMap
	if (p.Has(1) && p.Has(2) && p[1] != '' && p[2] != '') {
		msg := string(p[1]), cbFunc := p[2], bindStr := ''					; use vars for better clarity
		if (InStr(cbFunc, 'Func(')) {										; when cbFunc param is using v1 Func()...
			if (RegExMatch(cbFunc, '\.Bind\(.*\)', &bindContent)) {			; if OnMsg call includes .Bind()...
				bindStr := bindContent[]									; ... save .Bind() string
			}
			if (RegExMatch(cbFunc, '%Func\("(\w+)"\)', &m)) {				; when cbFunc param is using Func("name")...
				cbFunc := m[1]												; ... record just the CB func name
			}
			else if RegExMatch(cbFunc, '%Func\((\w+)\)', &m) {				; when cbFunc param is using Func(var)...
				cbFunc := '%' m[1] '%'										; ... add deref to cb func name
			}
		}
		; 2025-10-12 AMB - changed to using clsOnMsg object for issue #384-2
		; see addOnMessageCBArgs() in GuiAndMenu.ahk
		gmOnMessageMap[msg] := clsOnMsg(msg,cbFunc,bindStr)					; create a new clsOnMsg object
		maxThds := (p.Has(3) && p[3] != '') ? ', ' p[3] : ''				; include maxThreads param if present
		return	'OnMessage(' msg ', ' cbFunc bindStr maxThds ')'			; create/return OnMessage Call str
	}
	if (p.Has(2) && p[2] = '') {											; if cbFunc is empty...
		Try {
			callback := gmOnMessageMap[string(p[1])].cbFunc					; try to get cb func...
		} Catch {															; ... (no object has been created for this msg)
			Return 'OnMessage(' p[1] ', ' gCBPH ', 0)'						; Didnt find lister to turn off
		}
		Return 'OnMessage(' p[1] ', ' callback ', 0)'						; Found the listener to turn off
	}
}
;################################################################################
; V1: Pause, OnOffToggle, OperateOnUnderlyingThread
; TODO handle OperateOnUnderlyingThread
_Pause(p) {
	if (p[1]="")
		p[1]=-1
	Return Format("Pause({1})", p*)
}
;################################################################################
_PixelGetColor(p) {
	Out := p[1] " := PixelGetColor(" p[2] ", " p[3]
	if (p[4] != "") {
		mode := StrReplace(p[4], "RGB")										; We remove RGB because it is no longer used, while it doesn't error now it might error in the future
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
	} else
		msg := "", FixedColour := p[7]
	param8	:= ""
	Out		:= Format("ErrorLevel := !PixelSearch({2}, {3}, {4}, {5}, {6}, {7}, {1}", FixedColour, p*)
	if (p[8] != "")
		param8 := ", " p[8]
	Return Out param8 ")" msg
}
;################################################################################
; V1: Process,SubCommand,PIDOrName,Value
_Process(p) {
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
; V1: Progress, ProgressParam1, SubTextT2E, MainTextT2E, WinTitleT2E, FontNameT2E
; V1: Progress, Off
; V2: Removed
; To be improved to interpreted the options
_Progress(p) {
	if (p[1] = "Off") {
		Out := "ProgressGui.Destroy"
	} else if (p[1] = "Show") {
		Out := "ProgressGui.Show()"
	} else if (p[2] = "" && p[3] = "" && p[4] = "" && p[5] = "") {
		Out := "gocProgress.Value := " p[1]
	} else {
		width				:= 200
		mOptions			:= GetMapOptions(p[1])
		width				:= mOptions.Has("W") ? mOptions["W"] : 200
		GuiOptions			:= ""
		GuiShowOptions		:= ""
		SubTextFontOptions	:= ""
		MainTextFontOptions	:= ""
		ProgressOptions		:= ""
		ProgressStart		:= ""
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
	GuiShowOptions		.= mOptions.Has("X")	? " X" mOptions["X"]		: ""
	GuiShowOptions		.= mOptions.Has("Y")	? " Y" mOptions["Y"]		: ""
	GuiShowOptions		.= mOptions.Has("W")	? " W" mOptions["W"]		: ""
	GuiShowOptions		.= mOptions.Has("H")	? " H" mOptions["H"]		: ""
	MainTextFontOptions	:= mOptions.Has("WM")	? "W" mOptions["WM"]		: "Bold"
	MainTextFontOptions	.= mOptions.Has("FM")	? " S" mOptions["FM"]		: ""
	SubTextFontOptions	:= mOptions.Has("WS")	? "W" mOptions["WS"]		: mOptions.Has("WM") ? " W400" : ""
	SubTextFontOptions	.= mOptions.Has("FS")	? " S" mOptions["FS"]		: mOptions.Has("FM") ? " S8" : ""
	ProgressOptions		.= mOptions.Has("R")	? " Range" mOptions["R"]	: ""
	ProgressStart		.= mOptions.Has("P")	? mOptions["P"]				: ""

	Out	:= "ProgressGui := Gui(`"" GuiOptions "`")"
	Out	.= (p[4] != "")
		? ", ProgressGui.Title := " p[4] " "
		: ""
	Out	.= (p[3] = "" && p[2] = "") || mOptions.Has("FM") || mOptions.Has("FS")
		? ", ProgressGui.MarginY := 5, ProgressGui.MarginX := 5"
		: ""
	Out	.= (p[3] != "")
		? ", ProgressGui.SetFont(" ToExp(MainTextFontOptions) "," p[5] "), ProgressGui.AddText(`"x0 w" width " Center`", " p[3] ")"
		: ""
	Out	.= ", gocProgress := ProgressGui.AddProgress(`"x10 w" width - 20 " h20" ProgressOptions "`", " ProgressStart ")"
	Out	.= (p[3] != "" && p[2] != "")
		? ", ProgressGui.SetFont(" ToExp(SubTextFontOptions) "," p[5] ")"
		: (p[2] != "" && p[5] != "")
			? ", ProgressGui.SetFont(," p[5] ")"
			: ""
	Out	.= (p[2] != "")
		? ", ProgressGui.AddText(`"x0 w" width " Center`", " p[2] ")"
		: ""
	Out	.= ", ProgressGui.Show(" ToExp(GuiShowOptions) ")"
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)", ")")
	return	Out
}
;################################################################################
; 2025-12-10 AMB, UPDATED - added line fill to prevent lockups in certain cases
; V1: Random, OutputVar, Min, Max
_Random(p) {
	if (p[1] = "") {
		Return "`; V1toV2: Removed Random reseed" . NL.CRLF gLineFillMsg
	}
	Out		:= format("{1} := Random({2}, {3})", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
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
	p[1]	:= p[1] = "`"`"" ? "" : p[1]
	p[2]	:= p[2] = "`"`"" ? "" : p[2]
	p[3]	:= p[3] = "`"`"" ? "" : p[3]
	Out		:= format("RegDelete({1}, {2})", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; V1: FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos := 1)
; V2: FoundPos := RegExMatch(Haystack, NeedleRegEx , &OutputVar, StartingPos := 1)
_RegExMatch(p) {
	global gaList_MatchObj, gaList_PseudoArr
	if (p[3] != "") {
		OrigPattern := P[2]
		OutputVar := p[3]
		CaptNames := [], pos := 1
		while pos := RegExMatch(OrigPattern, "(?<!\\)(?:\\\\)*\(\?<(\w+)>", &Match, pos)
			pos += Match.Len, CaptNames.Push(Match[1])
		Out := ""
		if (RegExMatch(OrigPattern, '^"([^"(])*O([^"(])*\)(.*)$', &Match)) {
			; Mode 3 (match object)
			; v1OutputVar.Value(1) -> v2OutputVar[1]
			; The v1 methods Count and Mark are properties in v2.
			P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "O" from the options
			gaList_MatchObj.Push(OutputVar)
		} else if (RegExMatch(OrigPattern, '^"([^"(])*P([^"(])*\)(.*)$', &Match)) {
			; Mode 2 (position-and-length)
			; v1OutputVar		-> v2OutputVar.Len
			; v1OutputVarPos1	-> v2OutputVar.Pos[1]
			; v1OutputVarLen1	-> v2OutputVar.Len[1]
			P[2] := ( Match[1] || Match[2] ? '"' Match[1] Match[2] ")" : '"' ) . Match[3] ; Remove the "P" from the options
			gaList_PseudoArr.Push({name: OutputVar "Len", newname: OutputVar '.Len'})
			gaList_PseudoArr.Push({name: OutputVar "Pos", newname: OutputVar '.Pos'})
			gaList_PseudoArr.Push({strict: true, name: OutputVar, newname: OutputVar ".Len"})
			for CaptName in CaptNames {
				gaList_PseudoArr.Push({strict: true, name: OutputVar "Len" CaptName, newname: OutputVar '.Len["' CaptName '"]'})
				gaList_PseudoArr.Push({strict: true, name: OutputVar "Pos" CaptName, newname: OutputVar '.Pos["' CaptName '"]'})
			}
		} else if (RegExMatch(OrigPattern, 'i)^"[a-z``]*\)'))		; Explicit options.
			|| 	   RegExMatch(OrigPattern, 'i)^"[^"]*[^a-z``]') {	; Explicit no options.
			; Mode 1 (Default)
			; v1OutputVar	-> v2OutputVar[0]
			; v1OutputVar1	-> v2OutputVar[1]
			; 2024-06-22 AMB - Added regex property to be used in ConvertPseudoArray()
			gaList_PseudoArr.Push({regex: true, name: OutputVar})
			gaList_PseudoArr.Push({regex: true, strict: true, name: OutputVar, newname: OutputVar "[0]"})
			for CaptName in CaptNames
				gaList_PseudoArr.Push({strict: true, name: OutputVar CaptName, newname: OutputVar '["' CaptName '"]'})
		} else {
			; Unknown mode. Unclear options, possibly variables obscuring the parameter.
			; Treat as default mode?... The unhandled options O and P will make v2 throw anyway.
			; 2024-06-22 AMB - Added regex property to be used in ConvertPseudoArray()
			gaList_PseudoArr.Push({regex: true, name: OutputVar})
			gaList_PseudoArr.Push({regex: true, strict: true, name: OutputVar, newname: OutputVar "[0]"})
		}
		Out .= Format("RegExMatch({1}, {2}, &{3}, {4})", p*)
	} else {
		Out := Format("RegExMatch({1}, {2}, , {4})", p*)
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_RegRead(p) {
	; Possible an error if old syntax is used without 5th parameter
	if (p[4] != "" || (InStr(p[3], "\") && !InStr(p[2], "\"))) {
		; Old V1 syntax RegRead, ValueType, RootKey, SubKey, ValueName, Value
		p[2] := ToExp(p[2] "\" p[3])
		p[3] := ToExp(p[4])
	} else {
		; New V1 syntax RegRead, ValueType, KeyName, ValueName, Value
		p[2] := ToExp(p[2])
		p[3] := ToExp(p[3])
	}
	p[3]	:= p[3] = "`"`"" ? "" : p[3]
	p[2]	:= p[2] = "`"`"" ? "" : p[2]
	Out		:= format("{1} := RegRead({2}, {3})", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_RegWrite(p) {
	; Possible an error if old syntax is used without 5th parameter
	if (p[5] != "" || (!InStr(p[2], "\") && InStr(p[3], "\"))) {
		; Old V1 syntax RegWrite, ValueType, RootKey, SubKey, ValueName, Value
		Out := format("RegWrite({5}, {1}, {2} `"\`" {3}, {4})", p*)
		; Cleaning up the code
		Out := StrReplace(Out, "`" `"\`" `"", "\")
		Out := StrReplace(Out, "`"\`" `"", "`"\")
		Out := StrReplace(Out, "`" `"\`"", "\`"")
	} else {
		; New V1 syntax RegWrite, ValueType, KeyName, ValueName, Value
		Out := format("RegWrite({4}, {1}, {2}, {3})", p*)
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_RemoveAt(p) {
	if (p.Length = 1 && p[1] = "") {																						; Arr.Remove()
		Return "Pop()"
	} else if (p.Length = 1 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"'))) {													; Arr.Remove(n)
		Return "RemoveAt(" p[1] ")"
	} else if (p.Length = 2 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"')) && (IsDigit(p[2]) || p[2] = Trim(p[2], '"'))) {	; Arr.Remove(n, n)
		Return "RemoveAt(" p[1] ", " p[2] " - " p[1] " + 1)"
	} else if (p.Length = 2 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"')) && p[2] = "`"`"") {								; Arr.Remove(n, "")
		Return "Delete(" p[1] ")"
	} else {
		params := ""
		for , param in p
			params .= param ", "
		Return "Delete(" RTrim(params, ", ") ") `; V1toV2: Check Object.Remove in v1 docs to see which one matches"
	}
}
;################################################################################
_Run(p) {
	if (InStr(p[3], "UseErrorLevel")) {
		p[3] := RegExReplace(p[3], "i)(.*?)\s*\bUseErrorLevel\b(.*)", "$1$2")
		Out := format("{   ErrorLevel := `"ERROR`"`r`n" gIndent "   Try ErrorLevel := Run({1}, {2}, {3}, {4})`r`n" gIndent "}", p*)
	} else {
		Out := format("Run({1}, {2}, {3}, {4})", p*)
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	Out		:= Zip(out, 'RUN')			; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	Out
}
;################################################################################
_SB_SetText(p) {
	Return format("{1}.SetText({2}, {3}, {4})", gSBNameDefault, p*)
}
;################################################################################
_SB_SetParts(p) {
	Out := gSBNameDefault ".SetParts("
	for , v in p {
		Out .= v ", "
	}
	Return RTrim(Out, ", ") ")"
}
;################################################################################
_SB_SetIcon(p) {
	Return format("{1}.SetIcon({2})", gSBNameDefault, gFuncParams)
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
	Out		:= format("ErrorLevel := SendMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_SendRaw(p) {
	p[1]	:= FormatParam("keysT2E","{Raw}" p[1])
	Return	"Send(" p[1] ")"
}
;################################################################################
; 2025-10-05 AMB, UPDATED - changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-11-01 AMB, UPDATED - gmList_LblsToFunc key case-sensitivity
_SetTimer(p) {
	if (p[2] = "Off") {
		Out := format("SetTimer({1},0)", p*)
	} else if (p[2] = 0) {
		Out := format("SetTimer({1},1)", p*)								; Change to 1, because 0 deletes timer instead of no delay
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
	p[2]	:= p[2]="`"`""? "" : p[2]
	Out		:= format("{1} := Sort({1}, {2}, " SortFunction ")", p*)
	Return	RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E
_SoundGet(p) {
	OutputVar		:= p[1]
	ComponentType	:= p[2]
	ControlType		:= p[3]
	DeviceNumber	:= p[4]
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
; SoundSet,NewSetting,ComponentTypeT2E,ControlType,DeviceNumberT2E
; Not 100% verified, more examples would be helpfull.
_SoundSet(p) {
	NewSetting		:= p[1]
	ComponentType	:= p[2]
	ControlType		:= p[3]
	DeviceNumber	:= p[4]
	if (ControlType = "mute") {
		if (p[2]	= "`"Microphone`"") {
			p[4]	:= "`"Microphone`""
			p[2]	:= ""
		}
		out		:= Format("SoundSetMute({1}, {2}, {4})", p*)
	} else if (ComponentType = "Volume" || ComponentType = "Vol" || ComponentType = "") {
		p[1]	:= InStr(p[1], "+") ? "`"" p[1] "`"" : p[1]
		out		:= Format("SoundSetVolume({1}, {2}, {4})", p*)
	} else {
		out		:= Format("; V1toV2: Not currently supported -> CV2 Soundset{3}({1}, {2}, {4})", p*)
	}
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; V1: SplashImage, ImageFile, Options, SubText, MainText, WinTitle, FontName
; V1: SplashImage, Off
; V2: Removed
; To be improved to interpreted the options
_SplashImage(p) {
	if (p[1] = "Off") {
		Out := "SplashImageGui.Destroy"
	} else if (p[1] = "Show") {
		Out := "SplashImageGui.Show()"
	} else {
		mOptions := GetMapOptions(p[1])
		width := mOptions.Has("W") ? mOptions["W"] : 200
		Out := "SplashImageGui := Gui(`"ToolWindow -Sysmenu Disabled`")"
		Out .= (p[5] != "")
			? ", SplashImageGui.Title := " p[5] " "
			: ""
		Out .= (p[4] = "" && p[3] = "")
			? ", SplashImageGui.MarginY := 0, SplashImageGui.MarginX := 0"
			: ""
		Out .= (p[4] != "")
			? ", SplashImageGui.SetFont(`"bold`"," p[6] "), SplashImageGui.AddText(`"w" width " Center`", " p[4] ")"
			: ""
		Out .= ", SplashImageGui.AddPicture(`"w" width " h-1`", " p[1] ")"
		Out .= (p[4] != "" && p[3] != "")
			? ", SplashImageGui.SetFont(`"norm`"," p[6] ")"
			: (p[3] != "" && p[6] != "")
				? ", SplashImageGui.SetFont(," p[6] ")"
				: ""
		Out .= (p[3] != "")
			? ", SplashImageGui.AddText(`"w" width " Center`", " p[3] ")"
			: ""
		Out .= ", SplashImageGui.Show()"
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)", ")")
	return	Out
}
;################################################################################
; V1: SplashTextOn,Width,Height,TitleT2E,TextT2E
; V2: Removed
_SplashTextOn(p) {
	P[1] := P[1] = "" ? 200	: P[1]
	P[2] := P[2] = "" ? 0	: P[2]
	return "SplashTextGui := Gui(`"ToolWindow -Sysmenu Disabled`", " p[3] "), SplashTextGui.Add(`"Text`",, " p[4] "), SplashTextGui.Show(`"w" p[1] " h" p[2] "`")"
}
;################################################################################
_StringCaseSense(p) {
	if	p[1] =	"Locale"													; In conversions locale is treated as off
		p[1] :=	'"Locale"'													; this is just for is script checks in expressions, (and no unset var warnings)
	return "A_StringCaseSense := " p[1]
}
;################################################################################
_StringGetPos(p) {
	CaseSense := gaScriptStrsUsed.StringCaseSense ? " A_StringCaseSense" : ""
	if (IsEmpty(p[4]) && IsEmpty(p[5])) {
		return RegExReplace(format("{2} := InStr({3}, {4},{1}) - 1", CaseSense, p*), "[\s,]*\)", ")")
	}
	; modelled off of:
	; https://github.com/Lexikos/AutoHotkey_L/blob/9a88309957128d1cc701ca83f1fc5cca06317325/source/script.cpp#L14732
	else {
		p[5] := p[5] ? p[5] : 0												; 5th param is 'Offset' aka starting position. set default value if none specified
		p4FirstChar	:= SubStr(p[4], 1, 1)
		p4LastChar	:= SubStr(p[4], -1)
		if (p4FirstChar = "`"") && (p4LastChar = "`"") {					; remove start/end quotes, would be nice if a non-expr was passed in
			; the text param was already conveted to expr based on the SideT2E param definition
			; so this block handles cases such as "L2" or "R1" etc
			p4noquotes	:= SubStr(p[4], 2, -1)
			p4char1		:= SubStr(p4noquotes, 1, 1)
			occurrences	:= SubStr(p4noquotes, 2)
			if (StrUpper(p4char1) = "R") {
				; only add occurrences param to InStr func if occurrences > 1
				if (isInteger(occurrences) && (occurrences > 1))
					return format("{2} := InStr({3}, {4},{1}, -1*(({6})+1), -" . occurrences . ") - 1", CaseSense, p*)
				else
					return format("{2} := InStr({3}, {4},{1}, -1*(({6})+1)) - 1", CaseSense, p*)
			} else {
				if (isInteger(occurrences) && (occurrences > 1))
					return format("{2} := InStr({3}, {4},{1}, ({6})+1, " . occurrences . ") - 1", CaseSense, p*)
				else
					return format("{2} := InStr({3}, {4},{1}, ({6})+1) - 1", CaseSense, p*)
			}
		} else if (p[4] = 1) {
			; in v1 if occurrences param = "R" or "1" conduct search right to left
			; "1" sounds weird but its in the v1 source, see link above
			return format("{2} := InStr({3}, {4},{1}, -1*(({6})+1)) - 1", CaseSense, p*)
		} else if (p[4] = "") {
			return format("{2} := InStr({3}, {4},{1}, ({6})+1) - 1", CaseSense, p*)
		} else {
			; else then a variable was passed (containing the "L#|R#" string),
			;	or literal text converted to expr, something like: "L" . A_Index
			; very ugly fix, but works, maybe should prompt user to update how this is handled?
			return format("{2} := InStr({3}, {4},{1}, (SubStr({5}, 1, 1) = `"L`" ? 1 : -1)*(({6})+1), (SubStr({5}, 1, 1) = `"L`" ? Trim({5}, `"L`") : -Trim({5}, `"R`"))) - 1", CaseSense, p*)
		}
	}
}
;################################################################################
_StringLower(p) {
	if (p[3] = '"T"')
		return format("{1} := StrTitle({2})", p*)
	else
		return format("{1} := StrLower({2})", p*)
}
;################################################################################
; 2025-07-01 AMB, UPDATED to fix (missing) indent issue
; 2025-11-30 AMB, UPDATED output to compress multi-line output into single-line tag
_StringMid(p) {
	if (IsEmpty(p[4]) && IsEmpty(p[5]))
		return format("{1} := SubStr({2}, {3})", p*)
	else if (IsEmpty(p[5]))
		return format("{1} := SubStr({2}, {3}, {4})", p*)
	else if (IsEmpty(p[4]) && SubStr(p[5], 2, 1) = "L")
		return Format("{1} := SubStr({2}, 1, {3})", p*)
	else {
		; any string that starts with 'L' is accepted
		if (StrUpper(SubStr(p[5], 2, 1) = "L")) {
			; Very ugly fix, but handles pseudo characters
			; (When StartChar is larger than InputVar on L mode)
			; Use below for shorter but more error prone conversion
			; return format("{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*)
			return format("{1} := SubStr(SubStr({2}, 1, {3}), StrLen({2}) >= {3} ? -{4} : StrLen({2})-{3})", p*)
		} else {
			out := format("if (SubStr({5}, 1, 1) = `"L`")", p*) . "`r`n"
			out .= format(gIndent "`t{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*) . "`r`n"
			out .= format(gIndent "else", p) . "`r`n"
			out .= format(gIndent "`t{1} := SubStr({2}, {3}, {4})", p*)
			Out := Zip(Out, 'STRMID')	; 2025-11-30 AMB - compress to single-line tag, as needed
			return out
		}
	}
}
;################################################################################
; V1: StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
; V2: ReplacedStr := StrReplace(Haystack, Needle [, ReplaceText, CaseSense, OutputVarCount, Limit])
; 2025-11-30 AMB, UPDATED output to compress multi-line output into single-line tag
_StringReplace(p) {
	if gaScriptStrsUsed.StringCaseSense {
		CaseSense := " A_StringCaseSense"
	} else {
		CaseSense := ""
	}
	if (IsEmpty(p[4]) && IsEmpty(p[5])) {
		Out := format("{2} := StrReplace({3}, {4},,{1},, 1)", CaseSense, p*)
	} else if (IsEmpty(p[5])) {
		Out := format("{2} := StrReplace({3}, {4}, {5},{1},, 1)", CaseSense, p*)
	} else {
		p5char1 := SubStr(p[5], 1, 1)
		if (p[5] = "UseErrorLevel") {											; UseErrorLevel also implies ReplaceAll
			Out := format("{2} := StrReplace({3}, {4}, {5},{1}, &ErrorLevel)", CaseSense, p*)
		} else if (p5char1 = "1") || (StrUpper(p5char1) = "A") {
			; if the first char of the ReplaceAll param starts with '1' or 'A'
			; then all of those imply 'replace all'
			; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
			Out := format("{2} := StrReplace({3}, {4}, {5},{1})", CaseSense, p*)
		} else {
			Out := "if (not " ToExp(p[5]) ")"
			Out .= "`r`n" . gIndent . gSingleIndent . format("{2} := StrReplace({3}, {4}, {5},{1},, 1)", CaseSense, p*)
			Out .= "`r`n" . gIndent . "else"
			Out .= "`r`n" . gIndent . gSingleIndent . format("{2} := StrReplace({3}, {4}, {5},{1}, &ErrorLevel)", CaseSense, p*)
		}
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	Out		:= Zip(Out, 'STRREPL')		; 2025-11-30 AMB - compress to single-line tag, as needed
	return	Out
}
;################################################################################
; V1: StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E
; Output should be checked to replace OutputArray\d to OutputArray[\d]
_StringSplit(p) {
	global gaList_PseudoArr
	VarName := Trim(p[1])
	gaList_PseudoArr.Push({name: VarName})
	gaList_PseudoArr.Push({strict: true, name: VarName "0", newname: VarName ".Length"})
	Out := Format("{1} := StrSplit({2},{3},{4})", p*)
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_StringUpper(p) {
	if (p[3] = '"T"')
		return format("{1} := StrTitle({2})", p*)
	else
		return format("{1} := StrUpper({2})", p*)
}
;################################################################################
_StrReplace(p) {
	CaseSense	:= gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
	Out			:= Format("StrReplace({2}, {3}, {4}, {1}, {5}, {6})", CaseSense, p*)
	return		RegExReplace(Out, "[\s,]*\)", ")")
}
;################################################################################
; V1: Suspend, Mode
_SuspendV2(p) {
	p[1] := p[1]="toggle" ? -1 : p[1]
	if (p[1]="Permit") {
		Return "#SuspendExempt"
	}
	Out := "Suspend(" Trim(p[1]) ")"
	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
; V1: SysGet,OutputVar,SubCommand,Value
_SysGet(p) {
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
_Transform(p) {
	if (p[2] ~= "i)^(Asc|Chr|Mod|Exp|sqrt|log|ln|Round|Ceil|Floor|Abs|Sin|Cos|Tan|ASin|ACos|Atan)") {
		p[2] := p[2] ~= "i)^(Asc)" ? "Ord" : p[2]
		Out	:= format("{1} := {2}({3}, {4})", p*)
		return RegExReplace(Out, "[\s\,]*\)$", ")")
	}
	p[3] := p[3] ~= "^-.*" ? "(" p[3] ")" : P[3]
	p[4] := p[4] ~= "^-.*" ? "(" p[4] ")" : P[4]
	if (p[2] ~= "i)^(Pow)") {
		return format("{1} := {3}**{4}", p*)
	}
	if (p[2] ~= "i)^(BitNot)") {
		return format("{1} := ~{3} `; V1toV2: Now always uses 64-bit signed integers", p*)
	}
	if (p[2] ~= "i)^(BitAnd)") {
		return format("{1} := {3}&{4}", p*)
	}
	if (p[2] ~= "i)^(BitOr)") {
		return format("{1} := {3}|{4}", p*)
	}
	if (p[2] ~= "i)^(BitXOr)") {
		return format("{1} := {3}^{4}", p*)
	}
	if (p[2] ~= "i)^(BitShiftLeft)") {
		return format("{1} := {3}<<{4}", p*)
	}
	if (p[2] ~= "i)^(BitShiftRight)") {
		return format("{1} := {3}>>{4}", p*)
	}
	return format("; V1toV2: Removed : Transform({1}, {2}, {3}, {4})", p*)
}
;################################################################################
_TV_Add(p) {
	Return format("{1}.Add({2}, {3}, {4})", gTVNameDefault, p*)
}
;################################################################################
_TV_Delete(p) {
	Return format("{1}.Delete({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetChild(p) {
	Return format("{1}.GetChild({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetCount(p) {
	Return format("{1}.GetCount()", gTVNameDefault)
}
;################################################################################
_TV_GetNext(p) {
	Return format("{1}.GetNext({2}, {3})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetParent(p) {
	Return format("{1}.GetParent({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetPrev(p) {
	Return format("{1}.GetPrev({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetSelection(p) {
	Return format("{1}.GetSelection({2})", gTVNameDefault, p*)
}
;################################################################################
_TV_GetText(p) {
	Return format("{2} := {1}.GetText({3})", gTVNameDefault, p*)
}
;################################################################################
_TV_Modify(p) {
	Return format("{1}.Modify({2}, {3}, {4})", gTVNameDefault, p*)
}
;################################################################################
_TV_SetImageList(p) {
	Return format("{2} := {1}.SetImageList({3})", gTVNameDefault)
}
;################################################################################
; 2025-10-05 AMB, UPDATED - changed some var names
_VarSetCapacity(p) {
	global gNL_Func, gEOLComment_Func, gfrePostFuncMatch, gfLockGlbVars
	; if global vars are locked, update local temp vars instead (using ref vars)
	if (gfLockGlbVars) {
		vrNL_Func			:= &tmp1 := ''
		vrEOLComment_Func	:= &tmp2 := ''
	} else {
		vrNL_Func			:= &gNL_Func
		vrEOLComment_Func	:= &gEOLComment_Func := ''
	}
	reM := gfrePostFuncMatch
	if (p[3] != "") {
		; since even multiline continuation allows line comments adding vrEOLComment_Func shouldn't break anything, but if it does, add this hacky comment
		;`{3} + 0*StrLen("V1toV2: comment")`, or when you can't add a 0 (to a buffer)
		; p.Push("V1toV2: comment")
		; retStr := Format('RegExReplace("{1} := Buffer({2}, {3}) ``; {4}", " ``;.*$")', p*)
		varA	:= Format("{1}", p*)
		retStr	:= Format("VarSetStrCapacity(&{1}, {2})", p*)
		%vrEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}' and replace all instances of '{1}.Ptr' with 'StrPtr({1})'", varA, retStr)
		gmVarSetCapacityMap.Set(p[1], "B")
		if (!reM) {
		retBuf := Format("{1} := Buffer({2}, {3})", p*)
		dbgTT(3, "@_VarSetCapacity: 3 args, plain", Time:=3,id:=5,x:=-1,y:=-1)
		} else {
		if (reM.Count = 1) {												; just in case, min should be 2
			p.Push(reM[])
			retBuf	:= Format("({1} := Buffer({2}, {3})).Size{4}", p*)
			dbgTT(3, "@_VarSetCapacity: 3 args, Regex 1 group", Time:=3,id:=5,x:=-1,y:=-1)
		} else if (reM.Count = 2) {											; one operator and a number, e.g. *0
			; op	:= reM[1]
			; num	:= reM[2]
			; if Trim(op) = "//"
			p.Push(reM[])
			retBuf	:= Format("({1} := Buffer({2}, {3})).Size{4}", p*)
			dbgTT(3, "@_VarSetCapacity: 3 args, Regex 2 groups", Time:=3,id:=5,x:=-1,y:=-1)
		} else if (reM.Count = 3) {											; op1, number, op2, e.g. *0+
			op1 := reM[1]
			num := reM[2]
			op2 := reM[3]
			if (Trim(op1)="*" && Trim(num)="0") {							; move to the previous new line, remove regex matches
				if (%vrNL_Func%) {											; add a newline for multiple calls in a line
				%vrNL_Func% .= "`r`n"										;;;;; but breaks other calls
				}
				%vrEOLComment_Func% .= " NB! if this is part of a control flow block without {}, please enclose this and the next line in {}!"
				p.Push(%vrEOLComment_Func%)
				%vrNL_Func% .= Format("{1} := Buffer({2}, {3}) `; {4}", p*)
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
	} else if (p[3] = "") {
		dbgTT(3, "@_VarSetCapacity: 2 args", Time:=3,id:=5,x:=-1,y:=-1)
		varA	:= Format("{1}", p*)
		retBuf	:= Format("{1} := Buffer({2})", p*)
		%vrEOLComment_Func% .= format("V1toV2: if '{1}' is NOT a UTF-16 string, use '{2}' and replace all instances of 'StrPtr({1})' with '{1}.Ptr'", varA, retBuf)
		gmVarSetCapacityMap.Set(p[1], "V")
		if (!reM) {
		retStr := Format("VarSetStrCapacity(&{1}, {2})", p*)
		} else {
		p.Push(reM[])
		retStr := Format("VarSetStrCapacity(&{1}, {2}){4}", p*)
		}
		Return retStr
	} else {
		dbgTT(3, "@_VarSetCapacity: fallback", Time:=3,id:=5,x:=-1,y:=-1)
		varA	:= Format("{1}", p*)
		retStr	:= Format("VarSetStrCapacity(&{1}, {2})", p*)
		%vrEOLComment_Func% .= format("V1toV2: if '{1}' is a UTF-16 string, use '{2}' and replace all instances of '{1}.Ptr' with 'StrPtr({1})'", varA, retStr)
		gmVarSetCapacityMap.Set(p[1], "B")
		if (!reM) {
		retBuf := Format("{1} := Buffer({2}, {3})", p*)
		} else {
		p.Push(reM[])
		retBuf := Format("({1} := Buffer({2}, {3}).Size){4}", p*)
		}
		Return retBuf
	}
}
;################################################################################
; 2025-11-30 AMB, UPDATED output to compress multi-line output into single-line tag
_WinGet(p) {
	p[2] := p[2] = "ControlList" ? "Controls" : p[2]
	Out := format("{1} := WinGet{2}({3},{4},{5},{6})", p*)
	if (P[2] = "Class" || P[2] = "Controls" || P[2] = "ControlsHwnd" || P[2] = "ControlsHwnd") {
		Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
		Out .= gIndent "For v in o" P[1] "`r`n"
		Out .= gIndent "{`r`n"
		Out .= gIndent "   " P[1] " .= A_index=1 ? v : `"``r``n`" v`r`n"
		Out .= gIndent "}"
	}
	if (P[2] = "List") {
		Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
		Out .= gIndent "a" P[1] " := Array()`r`n"
		Out .= gIndent P[1] " := o" P[1] ".Length`r`n"
		Out .= gIndent "For v in o" P[1] "`r`n"
		Out .= gIndent "{   a" P[1] ".Push(v)`r`n"
		Out .= gIndent "}"
		gaList_PseudoArr.Push({name: P[1], newname: "a" P[1]})
		gaList_PseudoArr.Push({strict: true, name: P[1], newname: "a" P[1] ".Length"})
	}
	Out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	Out		:= Zip(Out, 'WINGET')		; 2025-11-30 AMB - compress to single-line tag, as needed
	Return	Out
}
;################################################################################
_WinGetActiveStats(p) {
	Out := format("{1} := WinGetTitle(`"A`")", p*) . "`r`n"
	Out .= format("WinGetPos(&{4}, &{5}, &{2}, &{3}, `"A`")", p*)
	Out := Zip(Out, 'WINGAS')			; 2025-11-30 AMB - compress to single-line tag, as needed
	return Out
}
;################################################################################
; V1: WinMove, WinTitle, WinText, X, Y, Width, Height, ExcludeTitle, ExcludeText
; V1: WinMove, X, Y
; V2: WinMove X, Y, Width, Height, WinTitle, WinText, ExcludeTitle, ExcludeText
_WinMove(p) {
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
	if (p[1] = "AlwaysOnTop" || p[1] = "TopMost") {
		p[1] := "AlwaysOnTop"												; Convert TopMost
		Switch p[2], False {
			Case '"on"':		p[2] := 1
			Case '"off"':	p[2] := 0
			Case '"toggle"': p[2] := -1
			Case '':			p[2] := -1
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
	Out		:= RegExReplace(Out, "[\s\,]*\)$", ")")
	return	Out
}
;################################################################################
; V1:		WinSetTitle, NewTitle
; V1: (alt) WinSetTitle, WinTitle, WinText, NewTitle, ExcludeTitle, ExcludeText
; V2:		WinSetTitle NewTitle, WinTitle, WinText, ExcludeTitle, ExcludeText
_WinSetTitle(p) {
	if (P[3] = "") {
		Out := format("WinSetTitle({1})", p*)
	} else {
		Out := format("WinSetTitle({3}, {1}, {2}, {4}, {5})", p*)
	}
	Out := RegExReplace(Out, "[\s\,]*\)$", ")")
	return Out
}
;################################################################################
; Created because else there where empty parameters.
_WinWait(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		out := Format("ErrorLevel := !WinWait({1}, {2}, {3}, {4}, {5})", p*)
	} else {
		out := Format("WinWait({1}, {2}, {3}, {4}, {5})", p*)
	}
	Return RegExReplace(out, "[\s\,]*\)$", ")")								; remove trailing empty params
}
;################################################################################
; Created because else there where empty parameters.
_WinWaitActive(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		out := Format("ErrorLevel := !WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
	} else {
		out := Format("WinWaitActive({1}, {2}, {3}, {4}, {5})", p*)
	}
	Return RegExReplace(out, "[\s\,]*\)$", ")")								; remove trailing empty params
}
;################################################################################
; Created because else there where empty parameters.
_WinWaitClose(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		out := Format("ErrorLevel := !WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
	} else {
		out := Format("WinWaitClose({1}, {2}, {3}, {4}, {5})", p*)
	}
	Return RegExReplace(out, "[\s\,]*\)$", ")")								; remove trailing empty params
}
;################################################################################
; Created because else there where empty parameters.
_WinWaitNotActive(p) {
	if (gaScriptStrsUsed.ErrorLevel) {
		out := Format("ErrorLevel := !WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
	} else {
		out := Format("WinWaitNotActive({1}, {2}, {3}, {4}, {5})", p*)
	}
	Return RegExReplace(out, "[\s\,]*\)$", ")")								; remove trailing empty params
}

/*
;######################  THESE DONT HAVE DEDICATED FUNCS  #######################
;###############  CONVERTION IS HANDLED USING THE FOLLOWING MAPS  ###############

SEE gAhkCmdsToRemoveV1		in 1Commands.ahk for the following
	#CommentFlag, #Delimiter, #DerefChar, #EscapeChar, SetFormat, SplashImage

SEE gAhkCmdsToRemoveV2		in 1Commands.ahk for the following
	#AllowSameLineComments, #LTrim, #MaxMem, #NoEnv, A_FormatFloat, A_FormatInteger
	AutoTrim, SetBatchLines, SoundGetWaveVolume, SoundSetWaveVolume

SEE gmAhkCmdsToConvertV1	in 1Commands.ahk for the following
	EnvDiv, EnvMult, IfEqual, IfNotEqual, IfExist, IfNotExist, IfWinActive,
	IfWinNotActive, IfWinExist, IfWinNotExist, SetEnv, SplashTextOff, StringLeft,
	StringLen, StringRight, StringTrimLeft, StringTrimRight

SEE gmAhkCmdsToConvertV2	in 1Commands.ahk for the following
	#ClipboardTimeout, #ErrorStdOut, #HotString, #HotkeyInterval, #HotkeyModifierTimeout,
	#If, #IfTimeout, #IfWinExist, #IfWinNotActive, #IfWinNotExist, #Include, #IncludeAgain,
	#InputLevel, #InstallKeybdHook, #InstallMouseHook, #KeyHistory, #MaxHotkeysPerInterval,
	#MaxThreads, #MaxThreadsBuffer, #MaxThreadsPerHotkey, #MenuMaskKey, #Persistent,
	#Requires, #SingleInstance, #UseHook, BlockInput, Click, ClipWait, ControlClick,
	ControlFocus, ControlGetPos, ControlGetText, ControlMove, ControlSend, ControlSendRaw,
	ControlSetText, Critical, DetectHiddenText, DetectHiddenWindows, DriveGet, DriveSpaceFree,
	Edit, EnvGet, EnvSet, EnvUpdate, Exit, ExitApp, FileAppend, FileCreateDir, FileCreateShortcut,
	FileDelete, FileEncoding, FileGetAttrib, FileGetShortcut, FileGetSize, FileGetTime,
	FileGetVersion, FileInstall, FileMoveDir, FileRecycle, FileRecycleEmpty, FileRemoveDir,
	FileSelectFolder, FormatTime, GroupActivate, GroupAdd, GroupClose, GroupDeactivate, IfMsgBox,
	ImageSearch, IniDelete, IniRead, IniWrite, ListHotkeys, ListLines, ListVars, MouseClick,
	MouseClickDrag, MouseGetPos, MouseMove, OutputDebug, PostMessage, Reload, RunAs, RunWait,
	Send, SendEvent, SendInput, SendLevel, SendMode, SendPlay, SendText, SetCapsLockState,
	SetControlDelay, SetDefaultMouseSpeed, SetKeyDelay, SetMouseDelay, SetNumLockState,
	SetRegView, SetScrollLockState, SetStoreCapsLockMode, SetTitleMatchMode, SetWinDelay,
	SetWorkingDir, Shutdown, Sleep, SoundBeep, SoundPlay, SplitPath, StatusBarGetText,
	StatusBarWait, Thread, ToolTip, TrayTip, UrlDownloadToFile, WinActivate, WinActivateBottom,
	WinClose, WinGetActiveTitle, WinGetClass, WinGetPos, WinGetText, WinGetTitle, WinHide,
	WinKill, WinMaximize, WinMenuSelectItem, WinMinimize, WinRestore, WinShow

SEE gmAhkFuncsToConvert		in 1Functions.ahk for the following
	Asc, ComObject, ComObjCreate, ComObjError, ComObjParameter, Exception, Func, LoadPicture,
	MenuGetHandle, MenuGetName, ObjRawGet, ObjRawSet, OnClipboardChange, OnError, RegExReplace,
	RegisterCallback, SubStr
*/