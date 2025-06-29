

;################################################################################
										updateLineMessages(&lineStr, &EOLComment)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Updates conversion communication messages to user, for current line
; currently the LAST step performed for a line

	global gEOLComment_Cont, gEOLComment_Func, gNL_Func

	; add a leading semi-colon to func comment string if it doesn't already exist
	gEOLComment_Func := (trim(gEOLComment_Func))				; if not empty string
	? RegExReplace(gEOLComment_Func, '^(\h*[^;].*)$', ' `; $1') ; ensure it has a leading semicolon
	: gEOLComment_Func											; semi-colon already exists

	; V2 ONLY !
	; Add warning for Array.MinIndex()
	nMinMaxIndexTag	:= '([^(\s]*\.)ϨMinIndex\(placeholder\)Ϩ'
	if (lineStr		~= nMinMaxIndexTag) {
		EOLComment	.= ' `; V1toV2: Not perfect fix, fails on cases like [ , "Should return 2"]'
	}

	; 2025-05-24 Banaanae, ADDED for fix #296
	gNL_Func .= (gNL_Func) ? '`r`n' : ''						; ensure this has a trailing CRLF
	NoCommentOutput	:= gNL_Func . lineStr . 'v1v2EOLCommentCont' . EOLComment . gEOLComment_Func
	OutSplit := StrSplit(NoCommentOutput, '`r`n')

	for idx, comment in gEOLComment_Cont {
		if (idx != OutSplit.Length)								; if not last element
			OutSplit[idx] := OutSplit[idx] comment				; add comment to proper line
		else
			OutSplit[idx] := StrReplace(OutSplit[idx], 'v1v2EOLCommentCont', comment)
	}
	finalLine := ''
	for , v in OutSplit {
		finalLine .= v '`r`n'
	}
	finalLine := StrReplace(finalLine, 'v1v2EOLCommentCont')
	gNL_Func  := '', gEOLComment_Func := '' ; reset global variables
	return	finalLine
}

;################################################################################
														postConversions(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
;	TODO - See if these can be combined in v2_Conversions

	v1v2_correctNEQ(&lineStr)					; Convert <> to !=
	v2_PseudoAndRegexMatchArrays(&lineStr)		; mostly v2 (separating...)
	v2_RemoveNewKeyword(&lineStr)				; V2 ONLY! Remove New keyword from classes
	v2_RenameKeywords(&lineStr)					; V2 ONLY
	v2_RenameLoopRegKeywords(&lineStr)			; V2 ONLY! Can this be combined with keywords step above?
	v2_VerCompare(&lineStr)						; V2 ONLY
	return										; lineStr by reference
}
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
									  DisableInvalidCmds(&lineStr, fCmdConverted)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; Purpose: Remove/Disable incompatible commands (that are no longer allowed)

	; V1 and V2, but with different commands for each version
	fDisableLine := false
	if (!fCmdConverted) {									; if a targetted command was found earlier...
		Loop Parse, gAhkCmdsToRemoveV1, '`n', '`r' {		; [check for v1 deprecated]
			if (InStr(gEarlyLine, A_LoopField)) {			; ... is that command invalid after v1.0?
				fDisableLine := true						; flag it as invalid
			}
		}
		if (gV2Conv) { ; v2
			Loop Parse, gAhkCmdsToRemoveV2, '`n', '`r' {	; [check for v2 deprecated]
				if (InStr(gEarlyLine, A_LoopField)) {		; ... is that command invalid in v2?
					fDisableLine := true					; flag it as invalid
				}
			}
			if (lineStr ~= '^\h*(local)\h*$')  {			; V2 Only - only force-local
				fDisableLine := true						; flag it as invalid
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
	return		; lineStr by reference
}
;################################################################################
												grabCharDirectiveAttribs(lineStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED to separate processing of character directives
;	(for cleaner conversion loop, and v1.0 => v1.1 conversion)
; only one of these directives may be found on current line
; sets data within gaScriptStrsUsed for use later

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
	return	; nothing
}
;################################################################################
											   procDirectivesAndComment(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED to separate processing of character directives and line comment
;	(for cleaner conversion loop, and v1.0 => v1.1 conversion)

	; if current line is char-directive declaration, grab the attributes
	if (RegExMatch(lineStr, 'i)^\h*#(CommentFlag|EscapeChar|DerefChar|Delimiter)\h+.')) {
		grabCharDirectiveAttribs(lineStr)
		return ''     ; might need to change this to actual line comment (EOLComment)
	}
	; not a char-directive declaration - update comment character on current line
	if (HasProp(gaScriptStrsUsed, 'CommentFlag')) {
		char := HasProp(gaScriptStrsUsed, 'EscapeChar') ? gaScriptStrsUsed.EscapeChar : '``'
		lineStr := RegExReplace(lineStr, '(?<!\Q' char '\E)\Q' gaScriptStrsUsed.CommentFlag '\E', ';')
	}

	; remove trailing comment from current line temporarily, will put it back later
	EOLComment	:= '', firstChar := SubStr(Trim(lineStr), 1, 1)
	lineStr		:= removeEOLComments(lineStr, FirstChar, &EOLComment)

	; update EscapeChar, DeRefChar, Delimiter for current line
	deref := '``'
	if (HasProp(gaScriptStrsUsed, 'EscapeChar')) {
		deref     := gaScriptStrsUsed.EscapeChar
		lineStr   := StrReplace(lineStr, '``', '``````')
		lineStr   := StrReplace(lineStr, gaScriptStrsUsed.EscapeChar, '``')
	}
	if (HasProp(gaScriptStrsUsed, 'DerefChar')) {
		lineStr   := RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.DerefChar '\E', '%')
	}
	if (HasProp(gaScriptStrsUsed, 'Delimiter')) {
		lineStr   := RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.Delimiter '\E', ',')
	}

	return EOLComment        ; return trailing comment for current line
}
;################################################################################
											fixAssignments(&lineStr, &EOLComment)
;################################################################################
{
; 2025-06-12 AMB, Moved and consolidated to dedicated routine for cleaner convert loop
; replace [ = ] with [ := ] in different situations
; TO DO - needs to be updated to cover all situations

	; Legacy v1
	; ... for assignments that take up entire line
	nLegAssign := '(?is)^(\h*+[a-z_%][\w%]*+\h*+)=(?!=)([^;]*+)'
	if (RegExMatch(lineStr, nLegAssign, &m)) {
		ExpVal	:= ToExp(m[2],valToStr:=false,forceDot:=true)		; make ToExp() options clear
		lineStr := RTrim(m[1]) . ' := ' . ExpVal
	}

	; V1 and V2 ?
	fixLSG_Assignments(&lineStr, &comment:='')						; for local, static, global assignments
	fixFuncParams(&lineStr)											; for function params (declarations and calls)

	; V1 and V2
	; var =		->	var := ""
	; var :=	->	var := ""
	if (RegExMatch(lineStr, '(?i)^(\h*+[a-z_]\w*+\h*+):?=(\h*+)$', &m)) {
		lineStr := RTrim(m[1]) . ' := ""' . m[2]
	}

	EOLComment .= comment
	return		; lineStr by reference
}
;################################################################################
										   fixLSG_Assignments(&lineStr, &comment)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; TO DO - DOES NOT WORK WITH MIXED VAR ASSIGNEMENTS - WILL FIX soon
;	(the original did not work for mixed var assignments either)

	comment := ''
	nLegAssign := '(?i)((global|local|static).+)(?<!:)=(?!=)'			; detect... legacy = on global/static/local line
	if (RegExMatch(lineStr, nLegAssign)) {
		Mask_T(&lineStr, 'STR')											; prevent detecton interference from strings
			While (RegExMatch(lineStr, nLegAssign)) {					; if line has legacy assignment...
				lineStr := RegExReplace(lineStr, nLegAssign, '$1:=')	; ... replace with expression assignment
			}
			If (InStr(lineStr, ',')) {									; add warning about mixed assignments as needed
				comment := ' `; V1toV2: Assuming this is v1.0 code'		; no mixed assignments supported (YET! but WILL soon)
			}
		Mask_R(&lineStr, 'STR')											; clean up
	}
	return		; lineStr by reference
}
;################################################################################
														  fixFuncParams(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
;	also refactored to be smaller footprint and more clear
; Replace = with := in function params (declarations and calls)
; Also flags ByRef params in advance to be fully processed within FixByRefParams()

	global gmByRefParamMap

	Mask_T(&lineStr, 'STR')												; mask strings that may contain 'ByRef, commas, ?, ='

	; does lineStr contain a function declaration/call?
	if (!RegExMatch(lineStr, gPtn_FuncCall, &mFunc)) {					; if lineStr does NOT have a function call...
		Mask_R(&lineStr, 'STR')											; ... restore strings...
		return	; no func call found									; ... and exit
	}
	; do not include IF or WHILE (which can be detected as well)
	if (mFunc.FcName ~= 'i)\b(if|while)\b') {							; if func name is actually IF or WHILE...
		Mask_R(&lineStr, 'STR')											; ... restore strings...
		return	; exclude If or While									; ... and exit
	}

	; flag byref params and replace ( = ) with ( := )
	ByRefFlags	:= []													; will be used later in FixByRefParams()
	nByRef		:= 'i)(\bByRef\h+)'										; [detection of ByRef]
	nLegAssign	:= 'i)(\h*[a-z_]\w*\h*)=([^,\)]*)'						; [detection of v1 legacy assignment equals (=)]
	fByRefChk	:= (!!((mFunc.FcParams) ~= nByRef))						; if any params have ByRef - check to see which ones are ByRef (below)
	for idx, curParam in StrSplit(mFunc.FcParams, ',') {				; for each param found...
		; check byRef status of current param
		if (fByRefChk)													; if byRefs were flagged above...
			ByRefFlags.Push(!!(curParam ~= nByRef))						; ... flag whether current param is byref (true or false)
		; check whether current param hass legacy assignment
		if (RegExMatch(curParam, nLegAssign, &mAssign)					; if current param contains a legacy assign...
			&& (!InStr(curParam, '?')))	{								; ... and is not a ternary IF...
			newParam	:= mAssign[1] ':=' mAssign[2]					; [new expression assignment]
			lineStr		:= StrReplace(lineStr, mAssign[], newParam,,,1)	; ... replace legacy assignment with expression assignment
		}
	}
	if (fByRefChk														; if function had a (any) ByRef (above)...
		&& !(gmByRefParamMap.has(mFunc.FcName))) {						; ... but func hasn't been flagged as such (yet - within global map)...
		gmByRefParamMap.Set(mFunc.FcName, ByRefFlags)					; ... flag func, to be processed fully in FixByRefParams()
	}
	Mask_R(&lineStr, 'STR')												; restore orignal strings
	return																; lineStr by reference
}
