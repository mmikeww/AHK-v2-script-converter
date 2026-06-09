;################################################################################
; 2025-12-24 - MOVED Dynamic Conversion Funcs to AhkLangConv.ahk
;################################################################################
; Returns a Map of options like x100 y200 ...
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
GetMapOptions(Options)
{
	mOptions := Map_I()
	Loop parse, Options, " "
	{
		if (StrLen(A_LoopField) > 0) {
			mOptions[SubStr(StrUpper(A_LoopField), 1, 1)] := SubStr(A_LoopField, 2)
		}
		if (StrLen(A_LoopField) > 2) {
			mOptions[SubStr(StrUpper(A_LoopField), 1, 2)] := SubStr(A_LoopField, 3)
		}
	}
	return mOptions
}
;################################################################################
; Processes converts that are related to LEGACY If declarations
; 2025-06-12 AMB, Moved steps to dedicated routine for cleaner convert loop
; 2025-07-01 AMB, SEPARATED for dual conversion support
v1_convert_Ifs(&lineStr, &lineOpen)
{
	v1v2_If_LegToExp(&lineStr, &lineOpen)													; legacy If to expression If [surrounds in ()]
	v1v2_If_VarIn(&lineStr, &lineOpen)														; v1/v2	- if var in
	v1v2_If_VarContains(&lineStr, &lineOpen)												; v1/v2	- if var contains
	v1v2_fixTernaryBlanks(&lineStr)						; see sharedCode.ahk				; v1/v2 - fixes blank/missing ternary fields
	return		; vars by reference
}
;################################################################################
; Converts legacy If to expression If
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-07-01 AMB, UPDATED to fix #349 (indention issue)
v1v2_If_LegToExp(&lineStr, &lineOpen)
{
	nLWS	:= '(\h*)'
	nIf		:= '(else\h+)?if\h+'
	nNot	:= '(NOT\h+)?'
	nVar	:= '([a-z_]\w*\h*)'
	nOp 	:= '(!=|==?|<>|>=?|<=?)'
	nOth	:= '([^{;]*)'
	nBrc	:= '(\h*{?\h*)'
	pattern	:= '(?i)^' nLWS nIf nNot nVar nOp nOth nBrc '(.*)'

	if (!RegExMatch(lineStr, pattern, &m))
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
; Converts If Var In
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
v1v2_If_VarIn(&lineStr, &lineOpen)
{
	nLWS	:= '(\h*)'
	nIf		:= '(else\h+)?if\h+'
	nVar	:= '([a-z_]\w*)\h'
	nNot	:= '(\h*NOT\h+)?'
	nIn		:= 'IN\h'
	nOth	:= '([^{;]*)'
	nBrc	:= '(\h*{?\h*)'
	pattern	:= '(?i)^' nLWS nIf nVar nNot nIn nOth nBrc '(.*)'

	if (!RegExMatch(lineStr, pattern, &m))
		return	false

	nChars	:= '\\\.\*\?\+\[\{\|\(\)\^\$', nComma := '\h*,\h*'
	if (RegExMatch(m[5], '^%')) {
		val1 := '"^(?i:" RegExReplace(RegExReplace('
			 . ToExp(m[5]) ',"[' nChars ']","\$0"),"' nComma '","|") ")$"'
	} else if (RegExMatch(m[5], '^[^' nChars ']*$')) {
		val1 := '"^(?i:' RegExReplace(m[5], nComma, '|') ')$"'
	} else {
		val1 := '"^(?i:' RegExReplace(RegExReplace(m[5],'[' nChars ']','\$0'),nComma,'|') ')$"'
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
; Converts If Var Contain
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
v1v2_If_VarContains(&lineStr, &lineOpen)
{
	nLWS	:= '(\h*)'
	nIf		:= '(else\h+)?if\h+'
	nVar	:= '([a-z_]\w*)\h'
	nNot	:= '(\h*NOT\h+)?'
	nCtns	:= 'CONTAINS\h'
	nOth	:= '([^{;]*)'
	nBrc	:= '(\h*{?\h*)'
	pattern	:= '(?i)^' nLWS nIf nVar nNot nCtns nOth nBrc '(.*)'

	if (!RegExMatch(lineStr, pattern, &m))
		return	false

	nChars	:= '\\\.\*\?\+\[\{\|\(\)\^\$', nComma := '\h*,\h*'
	if (RegExMatch(m[5], '^%')) {
		val1 := '"i)(" RegExReplace(RegExReplace('
			 . ToExp(m[5]) ',"[' nChars ']","\$0"),"' nComma '","|") ")"'
	} else if (RegExMatch(m[5], '^[^' nChars ']*$')) {
		val1 := '"i)(' RegExReplace(m[5], nComma, '|') ')"'
	} else {
		val1 := '"i)(' RegExReplace(RegExReplace(m[5],'[' nChars ']','\$0'),nComma,'|') ')"'
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
; Convert traditional statements to expressions
;	Don't pass whole commands, instead pass one parameter at a time
; Used for v1 or v2 conversion
; 2025-07-01 AMB, UPDATED, MOVED from ConvertFuncs.ahk and...
;	Merged with ToStringExp() [approval from Banaanae]
; 	[Set 'valToStr' to true for old ToStringExp() calls
;	Added support for v1.1 conversion
ToExp(text, valToStr:=false, forceDot:=false)
{
	text := Trim(text, ' `t')																; trim horz ws

	; handle specific cases
	if (text = '')																			; if text is empty...
		return '""'																			; ... return two double quotes
	else if (SubStr(text, 1, 2) = '% ')	  {													; if this param was a forced expression...
		return (gV2Conv) ? SubStr(text, 3) : text											; ... v2 - just remove leading '% ', v1.1 - return as is
	}
	else if (!valToStr && isNumber(text)) {													; if a number and should NOT be treated as string
		if (IsFloat(text)) {
			return text																		; return float as is
		}
		else if (IsHex(text)) {																; output for HEX is tricky...
			return text																		; ... sometimes no-change is best...
			; OR... allow to fall thru?														; ... other times, surrounding in quotes is best.
		}
		else {																				; return number
			return (text +0)																; note - remove +0 if it causes issues
		}
	}

	if (gV2Conv) {	; v2 conversion
		; escape literal quotes, remove escape from comma
		text := RegExReplace(text, '(?<!``)"', '``"')										; escape v2 literal quotes using `"
		text := StrReplace(text, '``,', ',')												; remove escape char from comma
	}
	else {			; v1.1 conversion
		text := RegExReplace(text, '"', '""')												; escape v1 literal quotes using ""
	}

	; if text has no variable
	if (!RegExMatch(text, '(?<!``)%'))
		return ('"' text '"')																; surround in quotes and return it

	; text has a var - parse to separate string from var
	; might be cleaner using masking/regex, but this works									; TODO - might update at some point
	sep		:= (forceDot) ? ' . ' : ' '														; separator - fat-dot for forced str, space otherwise
	outStr	:= '', prevChar := '', deRef := false
	Loop Parse, text {
		char := A_LoopField																	; [working var for current char]
		if (prevChar = '``')																; if current char is escaped...
			outStr	.= char																	; ... include as is
		else if (char = '%') {																; if leading or trailing % (for var)
			if ((deRef := !deRef) && (A_Index != 1))										; if on left side of var (but not first char)...
				outStr .= '"' . sep															; ... close string and add concat before var
			else if (!deRef) && (A_Index != StrLen(text))									; if on right side of var, but not last char...
				outStr .= sep . '"'															; ... add concat to right of var and begin new str
		} else																				; [char for string portion]
			outStr .= (((A_Index=1) ? '"' : '') . char)										; add cur char to str, add lead quote to front as needed
		prevChar   := char																	; watch for escape char
	}
	if (char != '%')																		; if last char was not a closing % for var
		outStr .= '"'																		; ... close string with quote

	outStr := (gV2Conv) ? outStr : '% ' outStr												; add leading % for v1.1 conversions
	return outStr																			; return final string/var
}