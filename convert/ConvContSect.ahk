;#Include maskCode.ahk

;		WORK IN PROGRESS

/*
	Each continuation section has attributes that identify it's "type", and each "type" will be converted in a specific way
	This file is dedicated to detection, iterpretation (which type), and conversion of continuation sections

	A continuation section has multiple parts
	1. The line that preceedes the continuation section block '(...)'.
		This line may be a combination of... vars, commands, function calls, parameters, etc
	2. The extra lines (optional) that come after line 1 but before the opening '('
		These lines can be empty, or have line/block comments (which will be masked), but nothing else
	3. The CS block itself '(...)'
		Starts with opening ( on its own line, followed by unlimited number of lines, and ending with ) that starts a new line
		The opening ( can be followed by comments (which will be masked).
	4. The optional trailing portion of the CS... that follows ')'
		This is usually a trailing comment or extra params of the first line above
		It is on the same line as the closing )



	The process for handling CS is as follows
	1. (easy) Mask all continuation sections found in script (globally), using a general detection needle
	2. (easy) For each mask-tag (created in #1), extract the original code (one at a time)
	3. (easy) For each tag found in #2... Extract Line 1 from the section

	4. (tricky) Use specific needles with line 1 (extracted in #3) to determine what type of CS we are dealing with

	5. (easy) Based on result of #4, pass section orig-code to appropriate converter routine (for it's type)
	6. (easy) Replace orig-code of script with with converted code from #5.

	This file has a CSect class which has static members dedicated to Cont sections

*/

;;################################################################################
;														 Conv_LegacyAssign(&code)
;;################################################################################
;{
;	/*
;	ATTRIBUTES:
;		has LEGACY equals assignment
;		DOES NOT have quotes yet (any quotes found should be treated as literal characters)
;		could have variables inside parentheses block -> %var%
;	TREATMENT
;		will be converted to v2 string...
;		change LEGACY equals = to expression equals := (outside of block)
;		text with block will be quoted
;		convert %var% to var
;		add concat dots between newly quoted strings and vars
;		all other characters should be treated literally...
;			make sure they have proper escape chars for strings as needed
;		DO NOT add quotes outside parentheses block
;	*/

;	/*
;		verify proper profile

;	*/

;	if (!RegExMatch(code, CSect.MLLineCont, &mCS))
;		return false

;	if (!(mCS[] ~= CSect.LegacyAssign))
;		return false


;	return
;}


;;################################################################################
;													 verifyProfile(code, profile)
;;################################################################################
;{
;; Desc:


;	return
;}


;################################################################################
; 2025-06-12 AMB. ADDED

;	THIS IS A WORK IN PROGRESS

class CSect
{
	static MLLineCont		:= '(?im)(?<line1>.++)' . buildPtn_MLBlock().Full
	static cmdVar			:= '(?im)^([\h\w]+?)'											; command/var portion of line1
	static tag				:= '(?<tag>\h*+#TAG★(?:LC|BC|QS)\w++★#)*+'						; optional tag on line 1 (comments or quoted-string ONLY!)
	; Line1 configurations
	static nLegacyAssign	:= CSect.cmdVar . '='					. CSect.tag . '$'		; [var/cmd =]
	static nLegAssignVar	:= CSect.cmdVar . '=\h*+%\w++%'			. CSect.tag . '$'		; [var = %var%] (CAN BE CONVERTED TO [var .= ])
	static nExpAssignQS1	:= CSect.cmdVar . '[.:]=\h*+"?'			. CSect.tag . '$'		; [var/cmd :=] or [var/cmd .= "]
	static nExpAssignQS2	:= CSect.cmdVar . '[:]=\h*+\w+\h*"?'	. CSect.tag . '$'		; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
	static nCmdComma		:= CSect.cmdVar . ',?' 					. CSect.tag . '$'		; [cmd] or [cmd,]

	needle := ''


	__new(needle)
	{
	}


	; PUBLIC - 2025-06-12 AMB, ADDED
	; will determine whether srcStr has a continuation section
	; if convert param is true, will return converted code
	; otherwise will return simple T or F flag
	static HasContSect(srcStr, convert := true)
	{
		; TODO - ADD SUPPORT FOR MORE SECTION TYPES, AS NEEDED

		; if srcStr is a full section, including the...
		;	... line leading into the cont block (and possibly the trailer)...
		if (RegExMatch(srcStr, CSect.MLLineCont, &mML)) {							; if is [line + contSect + trailer]...
			return (convert) ? CSect._conv_MLLineCont(srcStr) : true				; ... return converted block if requested, true otherwise
		}
;		; OR... if is full cont section without leading line
;		else if (RegExMatch(srcStr, buildPtn_MLBlock().Full, &mML)) {
;			return (convert) ? conv_ContFullBlk(srcStr) : true						; return converted block if requested, true otherwise
;		}
		; OR... if is just cont blk (...)
		else if (RegExMatch(srcStr, '(?im)' . buildPtn_MLBlock().ParBlk, &mML)) {
			return (convert) ? conv_ContParBlk(srcStr) : true						; return converted block if requested, true otherwise
		}
		else {
;			if (srcStr ~= '\R') {
;				MsgBox "[" "no contSect match" "]`n`n" srcStr						; DEBUGGING
;			}
			return false     														; srcStr does NOT have continuation section
		}
	}


;	static FilterAndConvert(&code)
;	{
;		if (!RegExMatch(code, CSect.MLLineCont, &mCS))
;			return false

;		; code is a CS
;		; return the appropriate func to handle the specific CS block
;		if		(mCS.line1 ~= CSect.nLegacyAssign)	{
;				; [var/cmd =]
;				CSect._conv_LegacyAssign(&code)
;				return true
;;				return "_conv_LegacyAssign"
;		}
;		else if	(mCS.line1 ~= CSect.nLegAssignVar)	{
;				; [var = %var%] (CAN BE COVERTED TO [var .= ])
;				CSect._conv_LegAssignVar(&code)
;				return true
;;				return "_conv_LegAssignVar"
;		}
;		else if	(mCS.line1 ~= CSect.nExpAssignQS1)	{
;				; [var/cmd :=] or [var/cmd .= "]
;				CSect._conv_ExpAssignQS1(&code)
;				return true
;;				return "_conv_ExpAssignQS1"
;		}
;		else if	(mCS.line1 ~= CSect.nExpAssignQS2)	{
;				; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
;				CSect._conv_ExpAssignQS2(&code)
;				return true
;;				return "_conv_ExpAssignQS2"
;		}
;		else if	(mCS.line1 ~= CSect.nCmdComma)		{
;				; [cmd] or [cmd,]
;				CSect._conv_CmdComma(&code)
;				return true
;;				return "_conv_CmdComma"
;		}
;		else {
;				line1 .= '`n`nPATTERN NOT FOUND`n' gFilePath "`n" mCS.Line1
;				return false
;		}

;;		; identify CS block type
;;		if (convFunc := CSect.IdentifyCS(&code))
;;		{
;;			CSect.%convFunc%(&code)
;;		}
;;		; pass code to appropriate conversion func
;;		; return code via reference
;	}

	static _conv_MLLineCont(code)
	{
		; TODO - ADD SUPPORT FOR 'Command,' (as needed)

		; verify code matches pattern
		if (!RegExMatch(code, CSect.MLLineCont, &mML)) {					; if code does not match CS pattern...
			return false													; ... return negatory!
		}

		line1		:= mML.line1											; line leading into cont section
;		oLine1		:= line1												; save original line1
		line1		:= RegExReplace(line1, '^\h*%\h')						; remove ' % ' from line1
		line1		:= RegExReplace(line1, '^([^"]*?)"(\h*)$', '$1$2')		; remove (optional) " at end of line1
		entry		:= mML.entry											; [part between line1 and opening '(']
		trail		:= mML.trail											; [part following closing ')' (additional params?)]
;		oTrail		:= trail												; save original trailing-code
		trail		:= RegExReplace(trail, '^"')							; remove any (optional) trailing DQ following ')"'
		pBlk		:= mML.parBlk											; parentheses block '(...)'
;		oBlk		:= pBlk													; save original pBlk
		pBlk		:= conv_ContParBlk(pBlk)								; convert parentheses block '(...)'
		outStr		:= line1 . entry . pBlk . trail							; build full (converted) output string...
		return		outStr													; ... and return it
	}

;	static _conv_LegacyAssign(&code)
;	{
;		code := "LegacyAssign`n" . code
;		/*
;			verify proper profile
;		*/

;	}
;	static _conv_LegAssignVar(&code)
;	{
;		code := "LegAssignVar`n" . code
;	}
;	static _conv_ExpAssignQS1(&code)
;	{
;		code := "ExpAssignQS1`n" . code
;	}
;	static _conv_ExpAssignQS2(&code)
;	{
;		code := "ExpAssignQS2`n" . code
;	}
;	static _conv_CmdComma(&code)
;	{
;		code := "CmdComma`n" . code
;	}

;	static IdentifyCS(&code)
;	{
;		if (!RegExMatch(code, CSect.MLLineCont, &mCS))
;			return false

;		; code is a CS
;		; return the appropriate func to handle the specific CS block
;		if		(mCS.line1 ~= CSect.LegacyAssign)	{
;				; [var/cmd =]
;				CSect._conv_LegacyAssign(&code)
;;				return "_conv_LegacyAssign"
;		}
;		else if	(mCS.line1 ~= CSect.LegAssignVar)	{
;				; [var = %var%] (CAN BE COVERTED TO [var .= ])
;				CSect._conv_LegAssignVar(&code)
;;				return "_conv_LegAssignVar"
;		}
;		else if	(mCS.line1 ~= CSect.ExpAssignQS1)	{
;				; [var/cmd :=] or [var/cmd .= "]
;				CSect._conv_ExpAssignQS1(&code)
;;				return "_conv_ExpAssignQS1"
;		}
;		else if	(mCS.line1 ~= CSect.ExpAssignQS2)	{
;				; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
;				CSect._conv_ExpAssignQS2(&code)
;;				return "_conv_ExpAssignQS2"
;		}
;		else if	(mCS.line1 ~= CSect.CmdComma)		{
;				; [cmd] or [cmd,]
;				CSect._conv_CmdComma(&code)
;;				return "_conv_CmdComma"
;		}
;		else {
;				line1 .= '`n`nPATTERN NOT FOUND`n' gFilePath "`n" mCS.Line1
;				return false
;		}
;	}

;	Convert(&code)
;	{
;	}
}


;;################################################################################
;														   conv_ContFullBlk(code)
;;################################################################################
;{
;; 2025-06-12 AMB, ADDED - WORK IN PROGRESS
;; converts code within full continuation block
;; TODO - WORK IN PROGRESS

;	; verify code matches pattern
;	if (!RegExMatch(code, buildPtn_MLBlock().Full, &mML)) {				; if code does not match CS pattern...
;		return false													; ... return negatory!
;	}

;	; TODO - MORE TO DO HERE

;	entry	:= mML.entry
;	pBlk	:= mML.ParBlk
;	guts	:= mML.guts
;	trail	:= mML.trail

;	pBlk := conv_ContParBlk(pBlk)
;	return entry . pBlk . trail

;}
;################################################################################
															conv_ContParBlk(code)
;################################################################################
{
; 2025-06-12 AMB, ADDED - WORK IN PROGRESS
; converts code within continuation parentheses block
; TODO - WORK IN PROGRESS

	; verify code matches pattern
	if (!RegExMatch(code, '(?im)' . buildPtn_MLBlock().ParBlk, &mML)) {		; if code does not match CS pattern...
		return false														; ... return negatory!
	}

	pBlk	:= code															; [parentheses block - working var]
	oBlk	:= pBlk															; orig block code - will need this later

	; separate/tag leading and trailing ws
	nSep := '(?is)\((?<LWS>[^\v]*\R\s*)(?<guts>.*?)(?<TWS>\h*\R\h*)\)'		; separate leading/trailing ws from block contents
	RegExMatch(pBlk, nSep, &mSep)											; fill vars - TODO - CHANGE TO VERIFICATION IF
	oLWS	:= mSep.LWS														; save orig leading  WS for restore later
	oTWS	:= mSep.TWS														; save orig trailing WS for restore later
	oGuts	:= mSep.guts													; save orig guts contents (excluding lead/trail ws)
	tLWS	:= gTagPfx 'LWS' gTagTrl										; create temp tag for leading  WS
	tTWS	:= gTagPfx 'TWS' gTagTrl										; create temp tag for trailing WS
	pBlk	:= RegExReplace(pBlk, '^\(' oLWS, '(' tLWS)						; replace orig lead  ws with a temp tag
	pBlk	:= RegExReplace(pBlk, oTWS '\)$', tTWS ')')						; replace orig trail ws with a temp tag

	; work on guts of block
	uGuts	:= oGuts														; updated/new guts - will be changed below
	Restore_Strings(&uGuts)													; remove masking from strings within guts only
	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (to prep for next step)
	v2_DQ_Literals(&uGuts)													; change "" to `" within guts only
	uGuts	:= RegExReplace(uGuts, '(?s)^"(.+)"$', '$1')					; remove surrounding DQs (to prep for next step)
	uGuts	:= RegExReplace(uGuts, '(?<!``)"', '``"')						; replace " (single) with `"
	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (again)

	; mask all %var% within guts
	nV1Var := '(?<!``)%([^%]+)(?<!``)%'										; [identifies %var%]
	clsPreMask.MaskAll(&uGuts, 'V1VAR', nV1Var)								; mask/hide all %var%s for now

	; add quotes before and after v1 vars
	nV1VarTag := gTagPfx 'V1VAR_\w+' gTagTrl								; [identifies V1Var tags]
	pos := 1
	While(pos := RegexMatch(uGuts, nV1VarTag, &mVarTag, pos)) {				; for each V1Var tag found...
		repl	:= '" ' mVarTag[] ' "'										; ... add concat quotes (SHOULD WE INCLUDE CONCAT DOTS?)
		uGuts	:= RegExReplace(uGuts, mVarTag[], repl,,1,pos)				; replace tags with concat-quote tags
		pos		+= StrLen(repl)												; prep for next loop iteration
	}
	uGuts		:= RegExReplace(uGuts, '^""\h*')							; remove any leading  "" (un-needed)
	uGuts		:= RegExReplace(uGuts, '\h*""$')							; remove any trailing "" (un-needed)
	pBlk		:= StrReplace(pBlk, oGuts, uGuts)							; replace orig guts with new guts

	; restore original %VAR%s, then replace each with VAR (remove %)
	clsPreMask.RestoreAll(&pBlk, 'V1VAR')									; restore orig %VAR%s
;	nV1Var := '(?<!``)%([^%]+)(?<!``)%'										; [identifies %VAR%] (redundant)
	pos := 1
	While(pos := RegexMatch(pBlk, nV1Var, &mVar, pos)) {					; for each %VAR% found...
		repl	:= mVar[1]													; [grabs just VAR from %VAR%]
		pBlk	:= RegExReplace(pBlk, mVar[], repl,,1,pos)					; replace %VAR% with VAR
		pos		+= StrLen(repl)												; prep for next loop iteration
	}

	; restore original lead/trail ws
	pBlk := RegExReplace(pBlk, tLWS, oLWS)									; replace leadWS  tag with orig ws code
	pBlk := RegExReplace(pBlk, tTWS, oTWS)									; replace trailWS tag with orig ws code

	; add leading empty lines to quoted text								; (simulate same output as v1)
	RegExReplace(oLWS, '\R',, &cCRLF)										; count CRLFs - will tells us how many (leading) empty lines
	if (cCRLF > 1) {	; first CRLF doesn't count							; if one or more empty lines...
		nBlk := '(?s)(\([^\v]*)(\R)(\s+)"(.+?)(\))'							; [separates block anatomy]
		pBlk := RegExReplace(pBlk, nBlk, '$1$2"$3$4$5')						; include those empty lines in quoted text (move leading DQ)
	}

	Restore_Premask(&pBlk)													; make sure premask tags are removed
	return pBlk
}