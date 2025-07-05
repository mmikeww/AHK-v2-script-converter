
;################################################################################
															isValidV1Label(srcStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED
; returns extracted label if it resembles a valid v1 label
; 	does not verify that it is a valid v2 label (see validV2Label for that)
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_LBLDecl for details of label declaration needle (in MaskCode.ahk)

	tempStr := trim(RemovePtn(srcStr, 'LC'))		; remove line comments and trim ws

	; return just the label if...
	;	it resembles a valid v1 label
	if (RegExMatch(tempStr, gPtn_LblBLK, &m))		; single-line check
		return m[1]									; appears to be valid v1 label
	return ''										; not a valid v1 label
}
;################################################################################
											  v1_convert_Ifs(&lineStr, &lineOpen)
;################################################################################
{
; 2025-06-12 AMB, Moved steps to dedicated routine for cleaner convert loop
; Processes converts that are related to LEGACY If declarations
; 2025-07-01 AMB, SEPARATED for dual conversion support

	v1v2_If_LegToExp(&lineStr, &lineOpen)					; legacy If to expression If [surrounds in ()]
	v1v2_If_VarIn(&lineStr, &lineOpen)						; v1/v2		- if var in
	v1v2_If_VarContains(&lineStr, &lineOpen)				; v1/v2		- if var contains
	v1v2_fixTernaryBlanks(&lineStr)							; v1/v2 - fixes blank/missing ternary fields
	return		; vars by reference
}
;################################################################################
											v1v2_If_LegToExp(&lineStr, &lineOpen)
;################################################################################
{
; converts legacy If to expression If
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-07-01 AMB, UPDATED to fix #349 (indention issue)

	nIf := 'i)^(\h*)(else\h+)?if\h+(not\h+)?([a-z_]\w*\h*)(!=|==?|<>|>=?|<=?)([^{;]*)(\h*{?\h*)(.*)'
	if (!RegExMatch(lineStr, nIf, &m))
		return	false

	op			:= (m[5] = '<>') ? '!=' : m[5]	; <> to !=
	lineOpen	:= m[1] lineOpen . format('{1}if {2}({3} {4} {5}){6}'
				, m[2]				; else
				, m[3]				; not
				, RTrim(m[4])		; var
				, op				; operator
				, ToExp(m[6])		; convert val to expression
				, m[7])				; optional opening brace
	lineStr		:= m[8]				; trailing portion
	return		true
}
;################################################################################
												v1v2_If_VarIn(&lineStr, &lineOpen)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; converts If Var In

	nIf := 'i)^(\h*)(else\h+)?if\h+([a-z_]\w*)\h(\h*not\h+)?in\h([^{;]*)(\h*{?\h*)(.*)'
	if (!RegExMatch(lineStr, nIf, &m))
		return	false

	if (RegExMatch(m[5], '^%')) {
		val1 := '"^(?i:" RegExReplace(RegExReplace(' ToExp(m[5]) ',"[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\h*,\h*","|") ")$"'
	} else if (RegExMatch(m[5], '^[^\\\.\*\?\+\[\{\|\(\)\^\$]*$')) {
		val1 := '"^(?i:' RegExReplace(m[5], '\h*,\h*', '|') ')$"'
	} else {
		val1 := '"^(?i:' RegExReplace(RegExReplace(m[5], '[\\\.\*\?\+\[\{\|\(\)\^\$]', '\$0'), '\h*,\h*', '|') ')$"'
	}

	lineOpen	.= m[1] . format('{1}if {3}({2} ~= {4}){5}'
				, m[2]					; else
				, m[3]					; var
				, (m[4]) ? '!' : ''		; not
				, val1
				, m[6])					; optional opening brace
	lineStr		:= m[7]					; trailing portion
	return		true
}
;################################################################################
										 v1v2_If_VarContains(&lineStr, &lineOpen)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; converts If Var Contain

	nIf := 'i)^(\h*)(else\h+)?if\h+([a-z_]\w*)\h(\h*not\h+)?contains\h([^{;]*)(\h*{?\h*)(.*)'
	if (!RegExMatch(lineStr, nIf, &m))
		return	false

	if (RegExMatch(m[5], '^%')) {
		val1 := '"i)(" RegExReplace(RegExReplace(' ToExp(m[5]) ',"[\\\.\*\?\+\[\{\|\(\)\^\$]","\$0"),"\h*,\h*","|") ")"'
	} else if (RegExMatch(m[5], "^[^\\\.\*\?\+\[\{\|\(\)\^\$]*$")) {
		val1 := '"i)(' RegExReplace(m[5], '\h*,\h*', '|') ')"'
	} else {
		val1 := '"i)(' RegExReplace(RegExReplace(m[5], '[\\\.\*\?\+\[\{\|\(\)\^\$]', '\$0'), '\h*,\h*', '|') ')"'
	}

	lineOpen	.= m[1] . format('{1}if {3}({2} ~= {4}){5}'
				, m[2]					; else
				, m[3]					; var
				, (m[4]) ? '!' : ''		; not
				, val1
				, m[6])					; optional opening brace
	lineStr		:= m[7]					; trailing portion
	return		true
}
;################################################################################
									ToExp(text, valToStr:=false, forceDot:=false)
;################################################################################
{
; Convert traditional statements to expressions
;	Don't pass whole commands, instead pass one parameter at a time
; Used for v1 or v2 conversion
; 2025-07-01 AMB, UPDATED, MOVED from ConvertFuncs.ahk and...
;	Merged with ToStringExp() [approval from Banaanae]
; 	[Set 'valToStr' to true for old ToStringExp() calls
;	Added support for v1.1 conversion

	text := Trim(text, ' `t')									; trim horz ws

	; handle specific cases
	if (text = '')												; if text is empty...
		return '""'												; ... return two double quotes
	else if (SubStr(text, 1, 2) = '% ')	  {						; if this param was a forced expression...
		return (gV2Conv) ? SubStr(text, 3) : text				; ... v2 - just remove leading '% ', v1.1 - return as is
	}
	else if (!valToStr && isNumber(text)) {						; if a number and should NOT be treated as string
		if (IsFloat(text)) {
			return text											; return float as is
		}
		else if (IsHex(text)) {									; output for HEX is tricky...
			return text											; ... sometimes no-change is best...
			; OR... allow to fall thru?							; ... other times, surrounding in quotes is best.
		}
		else {													; return number
			return (text +0)									; note - remove +0 if it causes issues
		}
	}

	if (gV2Conv) {	; v2 conversion
		; escape literal quotes, remove escape from comma
		text := RegExReplace(text, '(?<!``)"', '``"')			; escape v2 literal quotes using `"
		text := StrReplace(text, '``,', ',')					; remove escape char from comma
	}
	else {			; v1.1 conversion
		text := RegExReplace(text, '"', '""')					; escape v1 literal quotes using ""
	}

	; if text has no variable
	if (!RegExMatch(text, '(?<!``)%'))
		return ('"' text '"')									; surround in quotes and return it

	; text has a var - parse to separate string from var
	; might be cleaner using masking/regex, but this works		; TODO - might update at some point
	sep		:= (forceDot) ? ' . ' : ' '							; separator - fat-dot for forced str, space otherwise
	outStr	:= '', prevChar := '', deRef := false
	Loop Parse, text {
		char := A_LoopField										; [working var for current char]
		if (prevChar = '``')									; if current char is escaped...
			outStr	.= char										; ... include as is
		else if (char = '%') {									; if leading or trailing % (for var)
			if ((deRef := !deRef) && (A_Index != 1))			; if on left side of var (but not first char)...
				outStr .= '"' . sep								; ... close string and add concat before var
			else if (!deRef) && (A_Index != StrLen(text))		; if on right side of var, but not last char...
				outStr .= sep . '"'								; ... add concat to right of var and begin new str
		} else													; [char for string portion]
			outStr .= (((A_Index=1) ? '"' : '') . char)			; add cur char to str, add lead quote to front as needed
		prevChar   := char										; watch for escape char
	}
	if (char != '%')											; if last char was not a closing % for var
		outStr .= '"'											; ... close string with quote

	outStr := (gV2Conv) ? outStr : '% ' outStr					; add leading % for v1.1 conversions
	return outStr												; return final string/var
}
;################################################################################
_EnvDiv() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_EnvMult() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_GetKeyState(p) {
; 2025-07-01 AMB, ADDED to fix empty params

	out		:= format('{1} := GetKeyState({2}', p[1], p[2])
	out		.= ((p[3]) ? (', ' p[3]) : '') . ') ? "D" : "U"'
	return	out
}
;################################################################################
_If_Legacy() {
	; see v1v2_If_LegToExp()
}
;################################################################################
_IfEqual() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfNotEqual() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfExist() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfNotExist() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfWinActive() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfWinNotActive() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfWinExist() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_IfWinNotExist() {
	; see gmAhkCmdsToConvertV1 map
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
_IfInString(p) {

	global gaScriptStrsUsed
	CaseSense := gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
	Out := Format("if InStr({2}, {3}, {1})", CaseSense, p*)
	return RegExReplace(Out, "[\s,]*\)", ")")
}
;################################################################################
_IfNotInString(p) {

	global gaScriptStrsUsed
	CaseSense := gaScriptStrsUsed.StringCaseSense ? "A_StringCaseSense" : ""
	Out := Format("if !InStr({2}, {3}, {1})", CaseSense, p*)
	return RegExReplace(Out, "[\s,]*\)", ")")
}
;################################################################################
_OnExit(p) {
; V1 OnExit,Func,AddRemove

	if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" p[1] ":\s")) {
		gaList_LblsToFuncO.Push({label: p[1]
				, parameters: "A_ExitReason, ExitCode"
				, aRegexReplaceList: [{NeedleRegEx: "i)^(.*)\bReturn\b([\s\t]*;.*|)$"
				, Replacement: "$1Return 1$2"}]})
	}
	; return needs to be replaced by return 1 inside the exitcode
	return Format("OnExit({1}, {2})", p*)
}
;################################################################################
_Progress(p) {
; V1 : Progress, ProgressParam1, SubTextT2E, MainTextT2E, WinTitleT2E, FontNameT2E
; V1 : Progress , Off
; V2 : Removed
; To be improved to interpreted the options

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
	Out := RegExReplace(Out, "[\s\,]*\)", ")")
	return Out
}
;################################################################################
_SetEnv() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_SplashImage(p) {
; V1 : SplashImage, ImageFile, Options, SubText, MainText, WinTitle, FontName
; V1 : SplashImage, Off
; V2 : Removed
; To be improved to interpreted the options

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
	Out := RegExReplace(Out, "[\s\,]*\)", ")")
	return Out
}
;################################################################################
_SplashTextOff() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_SplashTextOn(p) {
; V1 : SplashTextOn,Width,Height,TitleT2E,TextT2E
; V2 : Removed

	P[1] := P[1] = "" ? 200: P[1]
	P[2] := P[2] = "" ? 0: P[2]
	return "SplashTextGui := Gui(`"ToolWindow -Sysmenu Disabled`", " p[3] "), SplashTextGui.Add(`"Text`",, " p[4] "), SplashTextGui.Show(`"w" p[1] " h" p[2] "`")"
}
;################################################################################
_StringGetPos(p) {

	global gIndent, gaScriptStrsUsed

	CaseSense := gaScriptStrsUsed.StringCaseSense ? " A_StringCaseSense" : ""

	if (IsEmpty(p[4]) && IsEmpty(p[5]))
		return RegExReplace(format("{2} := InStr({3}, {4},{1}) - 1", CaseSense, p*), "[\s,]*\)", ")")

	; modelled off of:
	; https://github.com/Lexikos/AutoHotkey_L/blob/9a88309957128d1cc701ca83f1fc5cca06317325/source/script.cpp#L14732
	else
	{
		p[5] := p[5] ? p[5] : 0							; 5th param is 'Offset' aka starting position. set default value if none specified

		p4FirstChar := SubStr(p[4], 1, 1)
		p4LastChar := SubStr(p[4], -1)
		if (p4FirstChar = "`"") && (p4LastChar = "`"")	; remove start/end quotes, would be nice if a non-expr was passed in
		{
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
		}
		else if (p[4] = 1) {
			; in v1 if occurrences param = "R" or "1" conduct search right to left
			; "1" sounds weird but its in the v1 source, see link above
			return format("{2} := InStr({3}, {4},{1}, -1*(({6})+1)) - 1", CaseSense, p*)
		}
		else if (p[4] = "") {
			return format("{2} := InStr({3}, {4},{1}, ({6})+1) - 1", CaseSense, p*)
		}
		else {
			; else then a variable was passed (containing the "L#|R#" string),
			;	or literal text converted to expr, something like: "L" . A_Index
			; output something anyway even though it won't work, so that they can see something to fix
			return format("{2} := InStr({3}, {4},{1}, ({6})+1, {5}) - 1", CaseSense, p*)
		}
	}
}
;################################################################################
_StringLeft() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_StringRight() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_StringLen() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_StringMid(p) {
; 2025-07-01 AMB, UPDATED to fix (missing) indent issue

	if (IsEmpty(p[4]) && IsEmpty(p[5]))
		return format("{1} := SubStr({2}, {3})", p*)
	else if (IsEmpty(p[5]))
		return format("{1} := SubStr({2}, {3}, {4})", p*)
	else if (IsEmpty(p[4]) && SubStr(p[5], 2, 1) = "L")
		return Format("{1} := SubStr({2}, 1, {3})", p*)
	else
	{
		; any string that starts with 'L' is accepted
		if (StrUpper(SubStr(p[5], 2, 1) = "L")) {
			; Very ugly fix, but handles pseudo characters
			; (When StartChar is larger than InputVar on L mode)
			; Use below for shorter but more error prone conversion
			; return format("{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*)
			return format("{1} := SubStr(SubStr({2}, 1, {3}), StrLen({2}) >= {3} ? -{4} : StrLen({2})-{3})", p*)
		}
		else {
			out := format("if (SubStr({5}, 1, 1) = `"L`")", p*) . "`r`n"
			out .= format(gIndent "`t{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*) . "`r`n"
			out .= format(gIndent "else", p) . "`r`n"
			out .= format(gIndent "`t{1} := SubStr({2}, {3}, {4})", p*)
			return out
		}
	}
}
;################################################################################
_StringReplace(p) {
; v1
; StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
; v2
; ReplacedStr := StrReplace(Haystack, Needle [, ReplaceText, CaseSense, OutputVarCount, Limit])

	global gIndent, gSingleIndent
	if gaScriptStrsUsed.StringCaseSense
		CaseSense := " A_StringCaseSense"
	else
		CaseSense := ""
	if (IsEmpty(p[4]) && IsEmpty(p[5]))
		Out := format("{2} := StrReplace({3}, {4},,{1},, 1)", CaseSense, p*)
	else if (IsEmpty(p[5]))
		Out := format("{2} := StrReplace({3}, {4}, {5},{1},, 1)", CaseSense, p*)
	else
	{
		p5char1 := SubStr(p[5], 1, 1)
		if (p[5] = "UseErrorLevel")		; UseErrorLevel also implies ReplaceAll
			Out := format("{2} := StrReplace({3}, {4}, {5},{1}, &ErrorLevel)", CaseSense, p*)
		else if (p5char1 = "1") || (StrUpper(p5char1) = "A")
			; if the first char of the ReplaceAll param starts with '1' or 'A'
			; then all of those imply 'replace all'
			; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
			Out := format("{2} := StrReplace({3}, {4}, {5},{1})", CaseSense, p*)
		else
		{
			Out := "if (not " ToExp(p[5]) ")"
			Out .= "`r`n" . gIndent . gSingleIndent . format("{2} := StrReplace({3}, {4}, {5},{1},, 1)", CaseSense, p*)
			Out .= "`r`n" . gIndent . "else"
			Out .= "`r`n" . gIndent . gSingleIndent . format("{2} := StrReplace({3}, {4}, {5},{1}, &ErrorLevel)", CaseSense, p*)
		}
	}
	return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
_StringTrimLeft() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_StringTrimRight() {
	; see gmAhkCmdsToConvertV1 map
}
;################################################################################
_Transform(p) {

	if (p[2] ~= "i)^(Asc|Chr|Mod|Exp|sqrt|log|ln|Round|Ceil|Floor|Abs|Sin|Cos|Tan|ASin|ACos|Atan)") {
		p[2] := p[2] ~= "i)^(Asc)" ? "Ord" : p[2]
		Out := format("{1} := {2}({3}, {4})", p*)
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


