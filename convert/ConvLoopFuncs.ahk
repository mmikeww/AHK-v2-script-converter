
;################################################################################
												lp_DirectivesAndComment(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED to separate processing of character directives and line comment
;	(for cleaner conversion loop, and v1.0 => v1.1 conversion)

	; if current line is char-directive declaration, grab the attributes
	if (RegExMatch(lineStr, 'i)^\h*#(CommentFlag|EscapeChar|DerefChar|Delimiter)\h+.')) {
		grabCharDirectiveAttribs(lineStr)
		return ''		; might need to change this to actual line comment (EOLComment)
	}
	; not a char-directive declaration - update comment character on current line
	if (HasProp(gaScriptStrsUsed, 'CommentFlag')) {
		char	:= HasProp(gaScriptStrsUsed, 'EscapeChar') ? gaScriptStrsUsed.EscapeChar : '``'
		lineStr := RegExReplace(lineStr, '(?<!\Q' char '\E)\Q' gaScriptStrsUsed.CommentFlag '\E', ';')
	}

	; separate trailing comment from current line temporarily, will put it back later
	lineStr		:= separateComment(lineStr, &EOLComment:='')

	; update EscapeChar, DeRefChar, Delimiter for current line
	deref := '``'
	if (HasProp(gaScriptStrsUsed, 'EscapeChar')) {
		deref	:= gaScriptStrsUsed.EscapeChar
		lineStr	:= StrReplace(lineStr, '``', '``````')
		lineStr	:= StrReplace(lineStr, gaScriptStrsUsed.EscapeChar, '``')
	}
	if (HasProp(gaScriptStrsUsed, 'DerefChar')) {
		lineStr	:= RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.DerefChar '\E', '%')
	}
	if (HasProp(gaScriptStrsUsed, 'Delimiter')) {
		lineStr	:= RegExReplace(lineStr, '(?<!\Q' deref '\E)\Q' gaScriptStrsUsed.Delimiter '\E', ',')
	}

	return EOLComment		; return trailing comment for current line
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
														   lp_SplitLine(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; separates non-convert portion of line from portion to be converted
; returns non-convert portion in 'lineOpen' (hotkey declaration, opening brace, Try\Else, etc)
; returns rest of line (that requires conversion) in 'lineStr'

	v1v2_noKywdCommas(&lineStr)			; first remove trailing commas from keywords (including Switch)
	lineOpen := ''						; will become non-convert portion of line
	firstTwo := subStr(lineStr, 1, 2)

	; if line is not a hotstring, but is single-line hotkey with cmd, separate hotkey from cmd temporarily...
	;	so the cmd can be processed alone. The hotkey will be re-combined with cmd after it is converted.
	;	nHotKey	:= gPtn_HOTKEY . '(.*)' ;((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
	; TODO - need to update needle for more accurate targetting
	nHotKey	:= '((?:(?:^\h*+|\h*+&\h*+)(?:[^,\h]*|[$~!^#+]*,))+::)(.*+)$'
	if ((firstTwo	!= '::') && RegExMatch(LineStr, nHotKey, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with switch, separate any value following it temporarily....
	;	so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
	; any trailing comma for switch statement should have already been removed via noKywdCommas()
	nSwitch := 'i)^(\h*\bswitch\h*+)(.*+)'
	if (RegExMatch(LineStr, nSwitch, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with case or default, separate any command following it temporarily...
	;	so the cmd can be processed alone. The opening part will be re-combined with cmd after it is converted.
	nCaseDefault := 'i)^(\h*(?:case .*?|default):(?!=)\h*+)(.*+)$'
	if (RegExMatch(LineStr, nCaseDefault, &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with Try or Else, separate any command that may follow them temporarily...
	;	so the cmd can be processed alone. The try/else will be re-combined with cmd after it is converted.
	nTryElse := 'i)^(\h*+}?\h*+(?:Try|Else)\h*[\h{]\h*+)(.*+)$'
	if (RegExMatch(LineStr, nTryElse, &m) && m[2]) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with {, separate any command following it temporarily...
	;	so the cmd can be processed alone. The { will be re-combined with cmd after it is converted.
	if (RegExMatch(LineStr, '^(\h*+{\h*+)(.*+)$', &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	; if line begins with } (but not else), separate any command following it temporarily...
	;	so the cmd can be processed alone. The } will be re-combined with cmd after it is converted.
	if (RegExMatch(LineStr, 'i)^(\h*}(?!\h*else|\h*\n)\h*)(.*+)$', &m)) {
		lineOpen	:= m[1]				; non-convert portion
		LineStr		:= m[2]				; portion to convert
		return lineOpen
	}

	return lineOpen
}
;################################################################################
								   lp_DisableInvalidCmds(&lineStr, fCmdConverted)
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
			if (lineStr ~= '^\h*(local)\h*$')	{			; V2 Only - only force-local
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
													 lp_PostConversions(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
;	TODO - See if these can be combined in v2_Conversions

	v1v2_FixNEQ(&lineStr)						; Convert <> to !=
	v2_PseudoAndRegexMatchArrays(&lineStr)		; mostly v2 (separating...)
	v2_RemoveNewKeyword(&lineStr)				; V2 ONLY! Remove New keyword from classes
	v2_RenameKeywords(&lineStr)					; V2 ONLY
	v2_RenameLoopRegKeywords(&lineStr)			; V2 ONLY! Can this be combined with keywords step above?
	v2_VerCompare(&lineStr)						; V2 ONLY
	return										; lineStr by reference
}
;################################################################################
										   lp_PostLineMsgs(&lineStr, &EOLComment)
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

	; TEMP - DEBUGGING - THESE TWO LENGTHS DO NOT MATCH SOMETIMES - CAUSES SCRIPT RUN ERRORS
	; ... ESPECIALLY IN OLD VERSION OF CONVERTER
	if (OutSplit.Length < gEOLComment_Cont.Length)
	{
;		MsgBox "[" NoCommentOutput "]`n`n" OutSplit.Length "`n`n" gEOLComment_Cont.Length
	}
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
