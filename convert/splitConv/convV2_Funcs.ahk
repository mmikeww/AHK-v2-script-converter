;################################################################################
														  v2_VerCompare(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; not sure why this is required for conversion ?

	nVer	:= 'i)\b(A_AhkVersion)(\h*[!=<>]+\h*)"?(\d[\w\-\.]*)"?'
	lineStr	:= RegExReplace(lineStr, nVer, 'VerCompare($1, "$3")${2}0')
	return		; lineStr by reference
}
;################################################################################
											   v2_RenameLoopRegKeywords(&lineStr)
;################################################################################
{
; 2024-04-08 AMB, ADDED
; separated LoopReg keywords from gmAhkKeywdsToRename map...
;	so that they can be treated differently - See 5Keywords.ahk
; 2025-06-12 AMB, UPDATED - changed func name, and some var and funcCall names
; 2025-07-03 AMB, UPDATED - minor

	for v1, v2 in gmAhkLoopRegKeywds {
		targ := Trim(v1), repl := Trim(v2)
		if (InStr(lineStr, targ)) {
			needle	:= 'i)([^\w]|^)\Q' . targ . '\E([^\w]|$)'
			lineStr	:= RegExReplace(lineStr, needle, '$1' repl '$2')
		}
	}
	return		; lineStr by reference
}
;################################################################################
													  v2_RenameKeywords(&lineStr)
;################################################################################
{
; 2024-04-08 AMB, ADDED
; moved this code from main loop to it's own function
; also separated LoopReg keywords from gmAhkKeywdsToRename map...
;	so that they can be treated differently - See 5Keywords.ahk
; Added the ability to mask the line-strings so that Keywords found within
;	strings are no longer converted along with Keyword vars
; 2025-06-12 AMB, UPDATED - changed some var and funcCall names
; 2025-07-03 AMB, UPDATED - minor

	; replace any renamed vars
	; Fixed - NO LONGER converts text found in strings
	masked := false
	for v1, v2 in gmAhkKeywdsToRename {
		targ := Trim(v1), repl := Trim(v2)
		if (InStr(lineStr, targ)) {
			if (!masked) {		; masking is slow, so only do this as necessary
				masked	:= true
				sess	:= clsMask.NewSession()
				Mask_T(&lineStr, 'STR', sess)
			}
			needle	:= 'i)([^\w]|^)\Q' . targ . '\E([^\w]|$)'
			lineStr	:= RegExReplace(lineStr, needle, '$1' repl '$2')
		}
	}
	if (masked)
		Mask_R(&lineStr, 'STR', sess)

	return		; lineStr by reference
}
;################################################################################
													v2_RemoveNewKeyword(&lineStr)
;################################################################################
{
; 2024-04-09 AMB, MODIFIED to prevent "new" within strings from being removed
; 2025-06-12 AMB, UPDATED - changed func name, and some var and funcCall names

	if (!InStr(lineStr, 'new'))
		return

	Mask_T(&lineStr, 'STR')		; protect "new" within strings
	if (RegExMatch(lineStr, 'i)^(.+?)(:=|\(|,)(\h*)new\h(\h*\w.*)$', &m)) {
		lineStr := m[1] m[2] m[3] m[4]
	}
	Mask_R(&lineStr, 'STR')
	return		; lineStr by reference
}
;################################################################################
		  v2_Conversions(&lineStr,&lineOpen,&EOLComment,&fCmdConverted,scriptStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: misc V2 ONLY conversions
; TODO - will need to separate v1 from v2 processing within most of these functions
;	currently v1.0 -> v1.1 conversion is not possible until the operations are separated

	; order matters for these two
	; convert AHKv1 (built-in) FUNCTIONS to AHKv2 format (see 2Functions.ahk)
	v2_AHKFuncs(&lineStr, scriptStr)
	; convert AHKv1 (built-in) COMMANDS  to AHKv2 format (see 1Commands.ahk)
	v2_AHKCommands(&lineStr, &lineOpen, &EOLComment, &fCmdConverted)	; SETS VALUE OF fCmdConverted

	; listed alphabetically - but order can matter, so be careful
	v2_AssocArr2Map(&lineStr, scriptStr)		; convert associative arrays to map (limited)
	v2_CleanReturns(&lineStr)					; fix return commands (misc)
	v2_DateTimeMath(&lineStr)					; var += 31, days  ->  var1 := DateAdd(var1, 31, 'days')
	v2_DQ_Literals(&lineStr)					; handles all "" (v1) to `" (v2)
	v2_FixACaret(&lineStr)						; fix v1 A_Caret references
	v2_fixObjKeyNames(&lineStr)					; {"A": "B"} -> {A: "B"}
	v2_FormatClassProperties(&lineStr)			; removes optional [] from class properties (TODO - THIS NEEDS TO BE FIXED!)
	v2_FuncDotStr(&lineStr)	; do last			; func.("string") -> func.Call("string")
	return										; lineStr by reference
}
;################################################################################
								  v2_convert_Ifs(&lineStr, &lineOpen, &lineClose)
;################################################################################
{
; 2025-06-12 AMB, Moved steps to dedicated routine for cleaner convert loop
; Processes converts that are related to If declarations
; 2025-07-01 AMB, SEPARATED for dual conversion support

	if (gV2Conv) {	; v2 only conversion
		v2_If_Between(&lineStr, &lineOpen)					; v2		- if between
		v2_If_VarIsType(&lineStr, &lineOpen)				; v2		- if var is type
		v2_fixElseError(&lineStr, &lineOpen, &lineClose)	; V2 - fixes 'Unexpected Else' error
	}
	return		; vars by reference
}
;################################################################################
											   v2_If_Between(&lineStr, &lineOpen)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; converts If Between

	nIf := 'i)^(\h*)(else\h+)?if\h+([a-z_]\w*)\h(\h*not\h+)?between\h([^{;]*)\hand\h([^{;]*)(\h*{?\h*)(.*)'
	if (!RegExMatch(lineStr, nIf, &m))
		return	false

	val1 := ToExp(m[5]), val2 := ToExp(m[6])
	if ((isNumber(val1) && isNumber(val2)) || InStr(m[5], '%') || InStr(m[6], '%'))
		formatStr := '{1}if {3}({2} >= {4} && {2} <= {5}){6}'
	else
		formatStr := '{1}if {3}((StrCompare({2}, {4}) >= 0) && (StrCompare({2}, {5}) <= 0)){6}'

	lineOpen	.= m[1] . format(formatStr
				, m[2]					; else
				, m[3]					; var
				, (m[4]) ? '!' : ''		; not
				, val1
				, val2
				, m[7])					; optional opening brace
	lineStr		:= m[8]					; trailing portion
	return		true
}
;################################################################################
											 v2_If_VarIsType(&lineStr, &lineOpen)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; converts If Var is type

	nIf := 'i)^(\h*)(else\h+)?if\h+([a-z_]\w*)\his\h+(not\h+)?([^{;]*)(\h*{?\h*)(.*)'
	if (!RegExMatch(lineStr, nIf, &m))
		return	false

	lineOpen	.= m[1] . format('{1}if {3}is{4}({2}){5}'
				, m[2]					; else
				, m[3]					; var
				, (m[4]) ? '!' : ''		; not
				, StrTitle(m[5])
				, m[6])					; optional opening brace
	lineStr		:= m[7]					; trailing portion
	return		true
}
;################################################################################
								 v2_fixElseError(&lineStr, &lineOpen, &lineClose)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Fix 'Unexpected Else' error, when else follows Try without braces (add braces)
; TODO - this is original code, have not looked it over yet

	static linesInIf := unset

	; V2 ONLY !
	If (IsSet(linesInIf) && linesInIf != '') {
		linesInIf++
		If (Trim(lineStr) ~= 'i)else\h+if' || Trim(lineOpen) ~= 'i)else\h+if') {
			; else if - reset search
			linesInIf := 0
		}
		Else If (Trim(lineStr) = '') {
			; lineStr is comment or blank - reset search
			linesInIf--
		}
		Else If ((Trim(lineStr) ~= 'i)else(?!\h+if)')
			|| (SubStr(Trim(lineStr), 1, 1) = '{') ; Fails if { is on lineStr further than next
			|| (linesInIf >= 2))
		{
			; just else - cancel search
			; { on next lineStr - "
			; search is too long - "
			linesInIf := ''
		}
		Else If (lineOpen ~= 'i)\h*try' && !InStr(lineOpen, '{')) {
			lineOpen	:= StrReplace(lineOpen, 'try', gIndent '{`ntry')
			lineClose	.= '`n' gIndent '}'
		}
	}
	If (SubStr(Trim(lineStr), 1, 2) = 'if' && !InStr(lineStr, '{')) || (SubStr(Trim(lineOpen), 1, 2) = 'if') {
		linesInIf := 0
	}
	return
}
;################################################################################
											 V2_AssocArr2Map(&lineStr, scriptStr)
;################################################################################
{
; 2025-06-12 AMB, MOVED from ConvertFuncs, modified slightly
; Converts associative arrays to maps (fails currently if more then one level ?)
; TODO - look over, see if improvements can be made

	if (!RegExMatch(lineStr, 'i)^(\h*)((global|local|static)\h+)?([a-z_0-9]+)(\h*:=\h*)(\{[^;]*)$', &m))
		return	; lineStr by reference - make no changes

	; Only convert to a map if FOR IN statement is found within script, that refers to it
	if (!RegExMatch(scriptStr, 'im)FOR\h[\h,a-z_0-9]*\hin\h' m[4] '[^.]'))
		return	; lineStr by reference - make no changes

	if (RegExMatch(lineStr, 'i)(^.*?)\{\h*([^\h:]+?)\h*:\h*([^\,}]*)\h*(.*)', &m)) {
		lineStrBegin	:= m[1]
		Key				:= m[2]
		Key				:= (InStr(Key, '"')) ? Key : ToExp(Key)
		Value			:= m[3]
		lineStr1		:= lineStrBegin 'map(' Key ', ' Value
		lineStrRest		:= m[4]
		loop {
			if (RegExMatch(lineStrRest, 'i)^\h*,\h*([^\h:]+?|"[^:"]"+?)\h*:\h*([^\},]*)\h*(.*)$', &m)) {
				Key			:= m[1]
				Key			:= (InStr(Key, '"')) ? Key : ToExp(Key)
				Value		:= m[2]
				lineStr1	.= ', ' Key ', ' Value
				lineStrRest	:= m[3]
			}
			else {
				if (RegExMatch(lineStrRest, 'i)^\h*(\})(\h*.*)$', &m)) {
					lineStrRest := ')' M[2]
				}
				break
			}
		}
		lineStr := lineStr1 lineStrRest
	}
	else {
		lineStr := RegExReplace(lineStr, '(\w+\h*:=\h*)\{\}', '$1map()')
	}
	return	; lineStr by reference
}
;################################################################################
														V2_CleanReturns(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; handles v1 to v2 conversion of 'return' commands

	; return % var -> return var
	nReturn1 := 'i)^(.*)(return)\h+%\h*\h+(.*)$'
	lineStr	 := RegExReplace(lineStr, nReturn1, '$1$2 $3')

	; return %var% -> return var
	nReturn2 := 'i)^(.*)(return)\h+%(\w+)%(.*)$'
	lineStr	 := RegExReplace(lineStr, nReturn2, '$1$2 $3$4')

	; Fix return that has multiple return values (not common)
	If (RegExMatch(lineStr, 'i)^(\h*return\h+)(.*)', &m) && InStr(m[2], ',')) {
		sess := clsMask.NewSession()		; create temp masking session
		Mask_T(&lineStr, 'FC',1,sess)		; mask func CALLS (also masks strings)
		Mask_T(&lineStr, 'KV',,sess)		; don't wrap key/val pair objects
		if InStr(lineStr, ',') {			; line appears to have multiple return values...
			lineStr := m[1] '(AHKv1v2_Temp := ' m[2] ', AHKv1v2_Temp) `; V1toV2: Wrapped Multi-statement return with parentheses'
		}
		Mask_R(&lineStr, 'KV',,sess)		; restore key/val pairs
		Mask_R(&lineStr, 'FC',,sess)		; restore function calls (also restores strings)
	}
	return
}
;################################################################################
														V2_DateTimeMath(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; converts v1 dateTime math to v2 format

	if (RegExMatch(lineStr, 'i)^(\h*)([a-z_][a-z_0-9]*)\h*(\+|-)=\h*([^,\h]*)\h*,\h*([smhd]\w*)(.*)$', &m)) {
		cmd := (m[3]='+') ? 'DateAdd' : 'DateDiff'
		lineStr := m[1] m[2] ' := ' cmd '(' m[2] ', ' FormatParam('ValueCBE2E', m[4]) ", '" m[5] "')" m[6]
	}
	return
}
;################################################################################
														   v2_FixACaret(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Adds support (compensates) for A_CaretX, A_CaretY that were remove in v2
; Adds/Uses CaretGetPos() to create variables of same name as v1 commands (A_CaretX and A_CaretY)

	if (!RegexMatch(lineStr, 'i)A_Caret(X|Y)', &m))
		return														; A_Caret not on this line - exit

	if ((lineStr ~= 'i)A_CaretX') && (lineStr ~= 'i)A_CaretY')) {
		Param	:= '&A_CaretX, &A_CaretY'							; create vars for both x and y
	} else {
		sep		:= (m[1] = 'X') ? '' : ', '							; X or Y ? (Y requires a separator comma)
		Param	:= sep . '&' m[]									; create var for just one or the other
	}
	; add CaretGetPos() to beginning of orig line code
	RegExMatch(lineStr, '^(\h*)(.*)', &m)							; grab orig line, separating leading ws from line-command
	lineStr := m[1] 'CaretGetPos(' Param '), ' m[2]					; add CaretGetPos() to beginning of orig line code

	return		; lineStr by reference
}
;################################################################################
													  v2_fixObjKeyNames(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Make sure kvPairs have valid v2 key names [{"A": "B"}] => [{A: "B"}]
; characters for V2 key names are much more restrictive, may need to update further
;  also updated to detect valid {key:val} objects (only)
; TODO - THIS CAN CHANGE KEY NAMES - NEED TO ADD SUPPORT FOR...
;	1. ENSURING KEYNAMES ARE STILL UNIQUE
;	2. UPDATING KEYNAME REFERENCES WITHIN CODE (obj.KEYNAME)

	Mask_T(&lineStr, 'STR')	; must be here to avoid errors with next regex			; don't match false positives (found within strings)
	if (!(lineStr ~= gPtn_KVO))	{													; make sure line has VALID {key:val} object
		Mask_R(&lineStr, 'STR')														; cleanup before early exit
		return	; unchanged lineStr by reference
	}

	pos := 1
	While (pos		:= RegexMatch(lineStr, gPtn_KVO, &mObj, pos)) {					; for each {key:val} object found on current line...
		kvObj		:= mObj[]														; [working var]
		kvPairsList	:= RegExReplace(kvObj, '\{([^}]+)\}', '$1')						; ... strip outer {} from object, now just key:val list sep by commas
		newObj		:= '{'															; [will be the new object string]
		for idx, kvPair in StrSplit(kvPairsList, ',') {								; for each key:val pair in list...
			if (RegExMatch(kvPair, '(?s)^(?<key>[^:]+):(?<val>.+)$', &mKV)) {		; if seems to be properly formatted key:val...
				; TODO - FOR ANY KEYNAME CHANGES in next line...
				; ... ADD SUPPORT FOR UPDATING KEYNAME REFERENCES WITHIN CODE
				val := mKV.val														; [working var]
				if((key	:= validKeyName(mKV.key)) = '') {							; make sure key name is valid
					key	:= mKV.key '_INVALID_KEYNAME'								; TODO - TEMP SOLUTION FOR NOW
				}
				kvPair := key ':' val												; reassemble key:val pair with updated key
			}
			newObj .= kvPair . ','													; add updated key:val pair to new object list
		}
		newObj	:= RTrim(newObj, ',') . '}'											; remove any trailing comma, and close the object with '}'
		lineStr	:= RegExReplace(lineStr, escRegexChars(kvObj), newObj,, 1, pos)		; update output - replacing old object string with new one
		pos		+= StrLen(newObj)													; prep for next loop iteration
	}
	Mask_R(&lineStr, 'STR')															; restore any remaining masked-strings
	return		; lineStr by reference
}
;################################################################################
																validKeyName(key)
;################################################################################
{
; 2025-06-22 AMB, ADDED - ensures keyname is valid format
; 2025-06-23 BANAANAE, UPDATED - to add support for vars as part of key
; TODO - WORK IN PROGRESS

	; support for wrapping var, using deref to access
	if HasTag(key, 'QS')															; if key contained quoted (masked) strings...
		key := RegExReplace(key, '(?<= |^)(?<!"|\w)(\w+)(?!"|\w)(?= |$)', '%$1%')	; ... wrap unquoted text in %% (variable)

	Mask_R(&key, 'STR', false)	; DO NOT REMOVE										; strings are masked when receiving from v2_fixObjKeyNames()
	key := StrReplace(RegExReplace(key,'\h+\.\h+'),'"')								; remove any concat operators and quotes from key (creates new var name)
	nKN := '^((?:\h*+\(*+)*+)([\w%]+(?:[-\h]*[\w%]+)*)+?((?:\h*+\)*+)*+)$'			; [identifies key name - supports optional parentheses/hyphens(not minus)/ws]
	if (!RegExMatch(key, nKN, &mKN)) {												; if key does not look valid...
		return ''																	; ... return empty string
	}
	; keyname looks like its valid or can be fixed...
	LWS	:= mKN[1]																	; leading ws and optional opening parenthesis (could be more than 1)
	KN	:= mKN[2]																	; [working var for keyname]
	TWS	:= mKN[3]																	; trailing ws and optional closing parenthesis (could be more than 1)

	if (KN ~= '^\d+$') {															; if keyname is a number (1 or more integer digits) ? ...
		return (LWS . KN . TWS)														; ... is valid - return it
	}

	; is alpha-numeric - ensure proper formatting
	KN := RegExReplace(KN, '[^\w%]')	; remove ws and hyphens						; valid chars are [a-z_0-9] (I think), also allow vars wrapped in %
	KN := RegExReplace(KN, '^(\h*)(\d\D.+)$', '$1_$2')								; keyname cannot begin with a number, add underscore to beginning if it does

	return (KN) ? (LWS . KN . TWS) : ''												; trim any ws if KN is now empty

}
;################################################################################
											   v2_formatClassProperties(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; removes optional [] from class properties
; TODO - NEEDS WORK... should target Class methods only...
; TODO - Use class masking to target only classes - support already exists in MaskCode
; TODO - Update for more accurate detection and targeting
; TODO - MUST ALSO ADD support to include a static property of same name...
;     so it can simulate same behavior as V1

	global gOScriptStr

	if (!lineStr)
		return

	nProperty := '(?i)^(\h*[a-z]\w*)\[\](\h*\{?.*)$'								; needle for (PROBABLE) class property - not fool-proof tho
	if (RegExMatch(lineStr, nProperty, &m)) {										; if line looks like a class property with []
		lineLastChar := SubStr(lineStr, -1)											; grab last char on current line
		nextLineChar := ''															; [avoid errors with next lines]
		if (hasNextLine	 := gOScriptStr.Length >= gO_Index +1) {					; [avoid errors with next lines]
			nextLineChar := SubStr(Trim(gOScriptStr.GetLine(gO_Index + 1)), 1, 1)	; grab first char of next line
		}
		if ((lineLastChar = '{')													; if we find opening brace on cuurent line...
			|| (hasNextLine && nextLineChar = '}')) {								; ... or opening brace on next line (at beginning)
			lineStr := m[1] m[2]													; discard [] from current line (PROBABLY is a property)
		}
	}
	return		; lineStr by reference
}
;################################################################################
														  v2_FuncDotStr(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Convert... func.("string") -> func.Call("string")
; TODO - update for more accurate targetting

	nFC := '(\w+)\.\('										; orig needle - TODO - this should be updated
	If (!(lineStr ~= nFC))									; if not a valid target...
		return	; no change to linestr						; ... exit

	Mask_T(&lineStr, 'STR')									; avoid issues caused my string chars
		lineStr := RegExReplace(lineStr, nFC, '$1.Call(')	; TODO - should update needle
	Mask_R(&lineStr, 'STR')									; remove string masks
	return		; lineStr by reference
}
;################################################################################
											  v2_AHKFuncs(&lineStr, scriptString)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Convert AHK v1 built-in functions to v2 format
;	see gmAhkFuncsToConvert() within 2Functions.ahk
; TODO - MOVE THIS AND RELATED FUNCTIONS TO 2Functions.ahk ??

	global gfNoSideEffect

	gfNoSideEffect := False		; TODO - see if this is needed OR rename var to better reflect purpose
	V1toV2_Functions(scriptString, lineStr, &lineFuncV2, &gotFunc:=False)
	if (gotFunc) {
		lineStr := lineFuncV2
	}
	return		; lineStr by reference
}
;################################################################################
				 v2_AHKCommands(&lineStr, &lineOpen, &EOLComment, &fCmdConverted)	; SETS VALUE OF fCmdConverted
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine (and redesigned) for cleaner convert loop
; 2025-06-22 AMB, UPDATED to support global masking of continuation sections,
;	and comments for all lines
; Purpose: parses line looking for v1 COMMANDS that need to be converted to v2 format
;	performs recursion as required for chained commands/params
;	also supports continuation sections
; TODO - MOVE THIS AND RELATED FUNCTIONS TO 1Commands.ahk ??

	global gO_Index, gIndent, gOScriptStr, gEOLComment_Cont

	; 2025-06-22 AMB, ADDED support for global masking of continuation sections
	; if lineStr is a continuation section masked tag...
	; extract original code, see if line1 has a targetted command... if not, exit
	fHaveCS	:= false															; flag used later
	if (tag := hasTag(lineStr, 'MLCSECTM2')) {									; is lineStr a continuation tag?
		; 2025-08-23 AMB, ADDED - to preserve proper leading indent/WS
		indentWS := ''
		if (RegExMatch(lineStr, '^(\h+)', &mLWS)) {
			indentWS := mLWS[1]													; get leading whitespace/indentation
		}
		oCode := hasTag(lineStr, tag)											; get orig line + continuation section (does not include indent)
		Mask_R(&oCode, 'C&S', false)											; extract comments/strings that are masked
		if (RegExMatch(oCode, '(?s)^([^\v]+)(.+)$', &m)) {						; will not include indentation
			tLine1 := m[1], contBlk := m[2]										; separate temp_line1, from continuation block
			if (!obj := V1LineToProcess.getCmdObject(tLine1)) {					; determine whether line1 has v1 command to be converted
				return false													; no command to process - exit
			}
			; line1 has legit command
			lineStr := indentWS . tLine1										; OK to change lineStr now - make it the first (cmd) line, and apply indent
			fHaveCS := true														; flag to use alternate routine to fill params arrays
			; deal with any comment on line 1
			lineStr	:= separateComment(lineStr, &EOLComment)					; separate comment (first occurence) from line1
			gEOLComment_Cont.Push(EOLComment)									; TODO - can lead to errors, investigate if it continues
		}
	}

	; look at current line and find/convert v1 command(s) that require conversion
	; loop will be performed recursively as needed to convert chained commands (if exist)
	loop
	{
		; get command/param object if line has legit command that must be converted
		if (!obj := V1LineToProcess.getCmdObject(lineStr)) {									; determine whether line has v1 command to be converted
			return false
		}

		; line has legit command to process, and will be converted...
		; Object members are not currently used within this function...
		;	but may be utilized in a later update of the converter
		cmd					:= obj.cmd															; v1 command found on line (and identified as target)
		cLParams			:= obj.lineOrigParams												; v1 cmd LINE parameters	[initial STRING list] (list may grow)
		cLParamsArr			:= obj.lineOrigParamsArr											; v1 cmd LINE params array	[intiial ARRAY  list] (list may grow)
		cLParamsArr.Extra	:= {}	; TODO - purpose??											; To attach helpful info (????) that can be read by custom functions
		cDParamsArr			:= obj.defProfile.v1DefParamsArr									; v1 cmd DEFINITION params array (default param list for v1 command)
		cmdV2Format			:= obj.defProfile.cmdV2Format										; v2 cmd formatting (or name of custom conversion func)

		; Some params may have continuation sections...
		; 	these 'extended' params should be last param on cur line.
		; Find this cont section (if it exists) and...
		; 	update cLParams, cLParamsArr, EOLComment

		; get continuaton section (if present)
		; 2025-06-22 AMB, UPDATED to support global masking of continuation sections
		if (fHaveCS) {																			; if we already have the continuation section (see entry above)
			if (contBlk) {																		; if we have not visited getParamContSect2() yet
				if (paramContSect := getParamContSect(contBlk, &cLParams						; use alternate routine to fill params string and array
											, &cLParamsArr, &EOLComment)) {
;					MsgBox "[" paramContSect "]", "CONT" ; debug								; debug
				}
				contBlk := ''																	; make sure we only enter getParamContSect2() once
			}
		}

		; TODO - REWORK THESE AS PART OF CLASS OBJECT INSTEAD (OR ELIMINATE ENTIRELY) ??
		; ONLY USED BY _msgbox()
		cLParamsArr.Extra.OrigArr := cLParamsArr.Clone()
		cLParamsArr.Extra.OrigStr := cLParams

		; Check/Adj line param count. We want a precise number of params that the cur cmd allows
		; each loop iteration will only process the maximum allowed params for current cmd
		; any "extra params" are probably chained-cmds that will be processed in new iteration
		;
		; if there are MORE line params than expected, this will investigate and handle it
		; 	sets recursion as needed to handle "extra params"
		fRecursionReq	:= false																; flag no recursion required... yet!
		extraParams		:= handleExtraParams(cmd, &cLParamsArr, &cDParamsArr, &fRecursionReq)	; extracts params that exceed maximum allowed params, sets fRecursionReq

		; if there are LESS line params than expected, fill with empty strings (see Issue #5)
		maxParamCount	:= cDParamsArr.Length													; maximum number of parameters allowed for current command
		if ((paramCountDiff := maxParamCount - cLParamsArr.Length) > 0) {						; if not enough params found for current command...
			Loop paramCountDiff {
				cLParamsArr.Push('')															; fills in empty/missing params so all (max) params have a value
			}
		}

		; perform actual conversion of the line (current) cammand and params
		fCmdConverted	:= executeConversion(&lineStr, &cLParamsArr, cDParamsArr, cmdV2Format)	; convert and update lineStr (for current command/params)

		; shift focus within lineStr to concentrate on chained commands/params
		; this focus shifting can occur multiple times for a single line
		if (fRecursionReq) {
			lineOpen	.= lineStr '`r`n'														; holds converted portion of line, as we step thru orig lineStr recursively
			gIndent		.= gSingleIndent														; this indent is dynamic (changes)
			lineStr		:= gIndent . extraParams												; new part of line to focus on (has not been checked/converted yet)
			; return to top of loop for another pass with new data
		}

	}	Until(!fRecursionReq)
	return																						; all func parameters by reference
}
;################################################################################
				  getParamContSect(contBlk, &cLParams, &cLParamsArr, &EOLComment)
;################################################################################
{
; 2025-06-22 AMB, UPDATED to support global masking of continuation sections
; gets continuaton section (parentheses-block) from known source (contBlk)
; updates param list string and array
; TODO - the code is currently a hybrid between the old brute force method...
;	... and already having the CS data in hand (contBlk).
;	Will redesign to remove brute-force after verifying that CS masking works well

	global gO_Index, gOScriptStr

	lastLineParam	:= cLParamsArr[cLParamsArr.length]							; most recent line param, prior to arriving here
	fullContSectStr	:= lastLineParam '`r`n'										; starts with command from previous line (line1 usually)

	lines := StrSplit(contBlk, '`n', '`r')										; grab lines from cont blk
	curContLine := '', looped := false											; ini
	for idx, line in lines
	{
		; TODO - might need to adjust this jump/continue in future?
		if (idx=1)
			continue															; skip first element
		looped		:= true														; flag for gEOLComment_Cont[] below loop
		curContLine	:= line														; [working var]
		curContLine	:= separateComment(curContLine, &EOLComment)				; separate comment (first occurence) from line
		gEOLComment_Cont.Push(EOLComment)										; save comment for CURRENT LINE to be restored later

		FirstChar	:= SubStr(Trim(curContLine),1,1)							; capture "(" or ")" if on current line
		if (FirstChar == ')')													; if current line appears to be end of cont section
		{
			cLParams .= '`r`n' curContLine										; append current continuation line to LINE params
;			fullContSectStr .= curContLine '`r`n'

			; when a cont section is not the last param...
			;	look for trailing params that follow the
			;	closing parenthesis of cont section...
			; 	This can also continue the search for...
			;	addtional params and cont sections
			trailingParams := V1ParamSplit(curContLine)							; get any additional params that follow closing parenthesis

			lastIdx := cLParamsArr.Length										; [last array element idx]
			cLParamsArr[lastIdx] := fullContSectStr . trailingParams[1]			; REPLACE the last element with accumulaed contSect lines and first param from current line
			Loop trailingParams.Length - 1 {									; then, add the rest of trailing params from current line
				cLParamsArr.Push(trailingParams[A_index + 1])
			}
			break																; continuation section has concluded - EXIT
		}
		cLParams .= '`r`n' curContLine											; add the final continuation line to LINE params
		fullContSectStr .= curContLine '`r`n'									; add the final continuation to output string
	}
	fullContSectStr .= curContLine												; this final concat is just for output purposes (for debugging)

	; gEOLComment_Cont is provided by Banaanae
	if (looped)	; don't do this unless we entered loop above
	{
		if (gEOLComment_Cont.Length != 1) {
			EOLComment := ''
		}
		else {
			gEOLComment_Cont.Pop()
		}
	}
	return fullContSectStr														; output full continuation block
}
;################################################################################
			  executeConversion(&lineStr, &cLParamsArr, cDParamsArr, cmdV2Format)
;################################################################################
{
; 2025-06-12 AMB, Moved from v2_AHKCommands() to dedicated routine
; Purpose: performs conversion of line v1 commands/params to v2 format

	; 2025-08-23 AMB, ADDED - separate leading indent/WS from command
	indentWS := ''
	if (RegExMatch(lineStr, '(?s)^(\h+)(.+)$', &mLWS)) {
		indentWS := mLWS[1], lineStr := mLWS[2]
	}

	; perform special formatting of line params as outlined by command definition
	maxParamCount := cDParamsArr.Length
	Loop maxParamCount {																		; for each line param...
		cLParamsArr[A_Index] := FormatParam(cDParamsArr[A_Index], cLParamsArr[A_Index])			; ... handle any special formatting of line param
	}

	; if using a special custom function for conversion
	cmdV2Format := trim(cmdV2Format)
	if (SubStr(cmdV2Format, 1, 1) = '*')
	{
		/*
		1. get custom function name from gmAhkCmdsToConvertV2 (thru cmdV2Format var)
		2. create an on-the-fly function call (funcObj) from that name
		3. call that custom function (passing array to func)...
			to get a string value for 'lineStr :=' below
		FuncObj(cLParamsArr) is a custom func call that returns a string value
		The FuncObj(FuncName) varies depending on...
			which line-cmd is being processed/converted
		FuncObj name usually begins with underscore and...
			can usually be found in ConvertFuncs.ahk
		The cLParamsArr is passed to the function, which will return...
			a string value to be used below for lineStr assignment
		*/
		FuncName := SubStr(cmdV2Format, 2)				; #1
		if ((FuncObj := %FuncName%) is Func) {			; #2
			; To see the name of the function that will be called...
			;	use the following to display it
			;	msgbox("FuncName=" FuncName)
			lineStr := FuncObj(cLParamsArr)				; #3 returns string val					; convert using custom function defined in cmdV2Format
		}
	}
	else	; or convert using the formatting of cmdV2Format directly
	{
		lineStr := format(cmdV2Format, cLParamsArr*)											; convert using cmdV2Format directly
		lineStr := RegExReplace(lineStr, '[\h,]*(\))?$', '$1')									; remove any left-over trailing commas
	}
	lineStr := indentWS . lineStr																; 2025-08-23 - reapply leading indent/WS

	return true		; sets fCmdConverted which is needed by other functions						; also returns all func params by reference
}
;################################################################################
			   handleExtraParams(cmd, &cLParamsArr, &cDParamsArr, &fRecursionReq)
;################################################################################
{
; 2025-06-12 AMB, Moved from v2_AHKCommands() to dedicated routine
; detects whether EXTRA line params are found for current command
; These 'extras' are usually chained commands
; will set recursion to true as needed to handle "extra" params (chained-commands)

	extraParams		:= ''																		; will be altered and returned to caller
	maxParamCount	:= cDParamsArr.Length														; max params required (by default) for cmd

	; Are there MORE line params than expected? If not... exit
	if ((paramCountDiff	:= cLParamsArr.Length - maxParamCount) <= 0) {							; if line param count does not exceed max param count...
		return extraParams	; empty string														; ... exit
	}

	; There are MORE line params than expected for the current cmd								(when compared to the max param count for the v1 command)

	; First, grab the extra params, FROM cLParamsArr
	; these extra params 'may/will' be handled during next loop pass (recursion)
	Loop paramCountDiff {																		; for each 'extra param'...
		extraParams .= ',' . cLParamsArr[maxParamCount + A_Index]								; ... add to a comma separated param string
	}
	extraParams := LTrim(extraParams, ',')														; remove leading comma

	; WHY are there more params than expected? See reasons below...

	/*
		1. First possible reason for extra params...
		The line command/params list include chained commands/kywrds, OR
		Same-Line-Action type commands such as v1.0 legacy IF...
			ex: 'IfEqual, x, 1, Sleep, 1' ('Sleep, 1' becomes two 'extra params')
	*/
	; Check to see if recursion is required to handle these extra 'params'...
	; Handling (recursion) is only required when...
	; 	these 'extra params' turn out to be one of the reasons stated above
	fRecursionReq := false																		; ini recursion flag to 'not required'
	nV1LegacySameLineCmds	:= 'If((?:Not)?(?:Equal|InString)'
							. '|(?:Greater|Less)(?:OrEqual)?|MsgBox)'
	if (RegExMatch(cmd, 'i)^(?:' nV1LegacySameLineCmds ')$')) {									; if cmd is a 'same-Line-Action' type...
		if (RegExMatch(extraParams, '^\h*(\w+)([\h,]|$)', &mExP1)) {							; get first 'extra param'...
			exParam1 := mExP1[1]
			if (exParam1 ~= 'i)^(break|continue|return|throw)$') {								; is first extra param an AHK keyword...?
				fRecursionReq := true															; ... recursion will be required
			}
			else {																				; look to see whether 'extra param' is a chained cmd...
				fRecursionReq := FindCmdDefs(exParam1)											; recursion will be required IF it is a chained command
			}
			if (fRecursionReq) {
				extraParams := LTrim(extraParams)	; RE-ADDED 2025-06-22						; trim next param if it's actually a keyword or command
			}
		}
	}

	/*
		2. https://www.autohotkey.com/docs/v1/misc/EscapeChar.htm
			"Commas that appear within the last parameter of a cmd do not need
			to be escaped because the program knows to treat them literally."
		When the extra comma is...
		- escaped comma, intended to be treated as sting char (legacy)
			IfEqual, var, `,					(IfEqual_ex2)
		- not escaped, but intended as part of an unquoted string (legacy)
			IfEqual, var, hello,world			(if_traditional_ex2)
			Send Sincerely,{enter}John Smith	(Send_ex1)
			SetEnv, var, h,e, l,l,o				(Y_Test_101)
			Sort, MyVar, N D,					(Y_Test_108)
	*/
	; turn entire extraParams string into a 'single value' within cLParamsArr
	; add that 'single value' to the 'max default' element position
	; any additional elements after that (even if filled) will be ignored...
	;	... during current loop iteration
	if ((maxParamCount != 0) && (!fRecursionReq)) {												; if recursion is disabled... (not set to true above)
		cLParamsArr[maxParamCount] .= ',' extraParams											; add 'full string value' of 'extraParms' to cLParamsArr (to 'max' element)
	}

	return extraParams
}
;################################################################################
Class V1LineToProcess
{
; 2025-06-12 AMB, ADDED
; for detection v1 line commands/params that require conversion
; called from v2_AHKCommands()

	lineStr				:= ''
	cmd					:= ''
	lineOrigParams		:= ''
	lineOrigParamsArr	:= []
	defProfile			:= object

	__new(lineStr, cmd, params, defProfile)
	{
		this.lineStr			:= lineStr
		this.cmd				:= cmd
		this.lineOrigParams		:= params
		this.lineOrigParamsArr	:= V1ParamSplit(this.lineOrigParams)
		this.defProfile			:= defProfile
	}

	; TODO - ADD MEMBERS AS NEEDED

	; Public
	static getCmdObject(lineStr)
	{
		; 2025-06-12 AMB, Moved from v2_AHKCommands to dedicated routine
		; Determines whether LineStr has cmd that needs to be converted to v2
		; if yes... returns an object of this class for line command, false otherwise

		if (!obj := V1LineToProcess._evaluateLine(lineStr))									; if not a legit command...
			return false																	; ... return negatory!
		return V1LineToProcess(lineStr, obj.cmd, obj.lineParams, obj.defProfile)			; is legit command... return object
	}

	static _evaluateLine(lineStr)
	{
		; 2025-06-12 AMB, Moved from v2_AHKCommands to dedicated routine
		; Determines whether LineStr has cmd that needs to be converted to v2
		; if yes... returns an object... with cmd, initial params, and definition profile for line cmd
		; if not... return false

		cmd := lineParams := ''
		lineCmdDelimPos1 := RegExMatch(lineStr, '\w(\h*[,\h])', &mlineCmd)					; locate first comma/ws on current line

		if (lineCmdDelimPos1 > 0) {															; if comma/ws found...
			cmd := Trim(SubStr(lineStr, 1, lineCmdDelimPos1))								; ... grab POSSIBLE command (chars up to first comma/ws)
			cLParams := SubStr(lineStr, lineCmdDelimPos1 + StrLen(mlineCmd[1])+1)			; ... and POSSIBLE params list (rest of line)
		}
		else {
			cmd := Trim(lineStr)															; no comma/ws found, cmd becomes full line
			cLParams := ''																	; no params
		}
		; check to see whether data collected above is...
		;	a legit/target command/params that need to be processed? If not... exit
		if  (	!(cmd~='i)^#?[a-z]+$')														; if cmd string found is not a potential command... OR
			||	(cLParams ~= '^[^"]=')														; if line param is actually an assignment...		OR
			||	(!defProfile := CommandDefProfile.GetProfile(cmd)))							; if line cmd is NOT found in definition list...
			return false																	; ... exit
		return {cmd:cmd,lineParams:cLParams,defProfile:defProfile}							; legit! - return extracted details and def profile
	}
}
;################################################################################
Class CommandDefProfile
{
; 2025-06-12 AMB, ADDED
; creates a command definition profile that includes...
;	v1 command param definitions and v2 conversion details for that command
; used with V1LineToProcess class and v2_AHKCommands()

	cmd				:= ''
	cmdV1Format		:= ''
	cmdV2Format		:= ''
	v1DefParams		:= ''
	v1DefParamsArr	:= []

	__new(cmd, cmdV1Format, cmdV2Format, v1DefParams)
	{
		this.cmd		 	:= cmd
		this.cmdV1Format	:= cmdV1Format
		this.cmdV2Format	:= cmdV2Format
		this.v1DefParams 	:= v1DefParams
		; convert definition param string to array
		Loop Parse, v1DefParams, ','
			this.v1DefParamsArr.Push(A_LoopField)
	}

	; TODO - ADD MEMBERS AS NEEDED

	; Public - max number of parameters allowed for command
	MaxParamCount => this.v1DefParamArr.Length

	; Public
	static GetProfile(cmd)
	{
		if (!profile := CommandDefProfile._matchLineCmdToDefList(cmd))
			return false
		return profile
	}

	; Private
	static _matchLineCmdToDefList(cmd)
	{
		; 2025-06-12 AMB, Moved from v2_AHKCommands to dedicated routine
		; Determines whether cmd is a target for v2 conversion
		; if yes, returns a CommandDefProfile object for cmd, false otherwise

		if (!FindCmdDefs(cmd, &cmdV1Format, &cmdV2Format))									; is cmd a targetted command for v2 conversion?
			return false																	; ... not a targeted command

		; is a targetted command - get definition details
		v1DefParams		:= ''
		v1DefDelimPos	:= RegExMatch(cmdV1Format, '[,\h]|$')								; get pos of first comma in DEFINITION list, for line command
		v1DefCmd		:= Trim(SubStr(cmdV1Format, 1, v1DefDelimPos - 1))					; get DEFINITION cmd from gmAhkCmdsToConvertV2 DEFINITION map
		if (v1DefCmd != cmd)																; if line cmd doesn't match def cmd from gmAhkCmdsToConvertV2 map...
			return false																	; ... exit

		v1DefParams := RTrim(SubStr(cmdV1Format, v1DefDelimPos + 1))						; get V1 DEFINITION params from gmAhkCmdsToConvertV2 map, for DEFINITION cmd
		return CommandDefProfile(cmd, cmdV1Format, cmdV2Format, v1DefParams)				; return a command profile object to caller
	}
}
