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
	static MLLineCont		:= '(?i)(?<head>.++)' . buildPtn_MLBlock().FullT		; head (cmd line) + body (block) + optional trailer
	static cmdVar			:= '(?i)^([\h\w]+?)'									; command/var portion of head
	static tag				:= '(?<tag1>(?:\h*+#TAG★(?:LC|BC|QS)\w++★#)*+)'		; optional tag on head line (comments or quoted-string ONLY!)

	; head configurations
	static nLegacyAssign	:= CSect.cmdVar . '='									. CSect.tag ; . '$'		; [var/cmd =]
	static nLegAssignVar	:= CSect.cmdVar . '=(\h*+)%(\w++)%'						. CSect.tag ; . '$'		; [var = %var%] (MAY BE CONVERTED TO [var .= ])
	static nExpAssignQS1	:= CSect.cmdVar . '([.:]=)(\h*%)?(\h*")?'				. CSect.tag ; . '$'		; [var/cmd :=] or [var/cmd .= "]
	static nExpAssignQS2	:= CSect.cmdVar . '[:]=\h*+\w+\h*"?'					. CSect.tag ; . '$'		; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
	static nCmdPlus			:= CSect.cmdVar . '(\h*[,%]?)?(\h*")?' 					. CSect.tag ; . '$'		; [cmd] or [cmd,]
	static nFCall			:= '(?i)^'		. '(?:\h*%)?(\h*[a-z]\w*\()(\h*"?)?'	. CSect.tag ; . '$'		; [cmd] or [cmd,]
	static nLegExp			:= '(?i)^'		. '(\h*[,%]?)?(\h*")?'					. CSect.tag ; . '$'		; [cmd] or [cmd,]

	; TODO - ADD SUPPORT FOR 'Command,' (as needed)


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

		if (!(srcStr ~= '(?im)' . buildPtn_MLBlock().ParBlk)) {						; if does not have a parentheses block...
			return false															; ... return negatory!
		}
		if (!convert) {																; if no conversion requested
			return true																; ... simply flag as continuation block
		}
		; conversion requested

		; if srcStr is a full section, including the...
		;	... head (cmd line), neck, body (block), and optional trailer...
		if (RegExMatch(srcStr, CSect.MLLineCont, &mML)) {							; if is [head + body + optional trailer]...
			return CSect.FilterAndConvert(srcStr)									; ... return converted block
		}

		; default behavior (for now)
		; looks like srcStr is just the block ?
		return conv_ContParBlk(srcStr)												; otherwise... return converted block
	}


	; Public - 2025-06-16 AMB, UPDATED
	; Determines whether code is a continuation section...
	;	if so... routes code to appropriate conversion routine
	;		then returns converted code
	;	if not... returns false
	static FilterAndConvert(code)
	{
		Mask_PreMask(&code, false)													; false - do not mask multi-line strings!

		if (!RegExMatch(code, CSect.MLLineCont, &mCS)) {							; if does not match profile (head + body + optional trailer)
			return false															; ... return negatory!
		}
		; code is a properly formatted continuation section
		; route code to proper function for conversion

		if (mCS.head ~= CSect.nLegacyAssign			. '$')	{
;			return CSect._conv_LegacyAssign(&code)				; [var/cmd =]
		}
		else if	(mCS.head ~= CSect.nLegAssignVar	. '$')	{
			return CSect._conv_LegAssignVar(code)				; [var = %var%]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS1	. '$')	{
			return CSect._conv_ExpAssignQS1(code)				; [var/cmd := %? "?]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS2	. '$')	{
;			return CSect._conv_ExpAssignQS2(code)				; [var := var] or [var := "]
		}
		else if	(mCS.head ~= CSect.nCmdPlus			. '$')	{
;			return 	CSect._conv_CmdComma(code)					; [cmd] or [cmd,]
		}
		else if	(mCS.head ~= CSect.nFCall			. '$')	{
			return 	CSect._conv_FCall(code)						; [ %? funcCall("? ]
		}
		else if	(mCS.head ~= CSect.nLegExp			. '$')	{	; CAN CATCH FALSE POSITIVES
			return 	CSect._conv_LegExp(code)					; [,? %? "?]
		}
		else {
			msg := '`n`nPATTERN NOT FOUND`n' gFilePath "`n" mCS.head
;			MsgBox msg
			head .= msg
			return code
		}
	}


;	; Public - 2025-06-16 AMB, UPDATED - NOT USED FOR NOW
;	static _conv_MLLineCont(code)
;	{
;		; verify code matches pattern
;		nML := CSect.MLLineCont
;		if (!RegExMatch(code, nML, &mML)) {
;			return false
;		}
;		head		:= mML.head												; cmd line
;		head		:= RegExReplace(head, '^\h*%\h')						; remove ' % ' from head line
;		head		:= RegExReplace(head, '^([^"]*?)"(\h*)$', '$1$2')		; remove [optional] " at end of head line
;		neck		:= mML.neck												; portion between head and opening body '('
;		body		:= conv_ContParBlk(mML.parBlk)							; parentheses block '(...)' - converted
;		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
;		outStr		:= head . neck . body . trail							; assemble output string
;		Restore_Premask(&outStr)											; make sure strings and comments have been restored
;		return 		outStr													; return converted output
;	}


	; Public - 2025-06-16 AMB, UPDATED
	; head	->	var/cmd :=  %? "?
	; body	->	(...)"?
	static _conv_ExpAssignQS1(code)
	{
		; verify code matches pattern
		nML := CSect.nExpAssignQS1 . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		varCmd		:= mML[1]												; var or command on cmd line
		equals		:= mML[2]												; equals on cmd line [ := or .= ]
		tag1		:= mML.tag1												; trailing comment (masked) on command line
		perc		:= trim(mML[3])											; % on cmd line (will be removed)
		dq			:= trim(mML[4])											; " on cmd line (will be removed)
		head		:= varCmd . equals . tag1								; newly formatted cmd line
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= mML.parBlk											; parentheses block '(...)' - before conversion
		if (dq)																; if cmd line had "...
			body	:= conv_ContParBlk(body)								; ... convert the block code, (otherwise don't convert ??)
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		Restore_Premask(&outStr)											; make sure strings and comments have been restored
		return 		outStr													; return converted output
	}

	; Public - 2025-06-16 AMB, UPDATED
	; head	->	,? %? "?
	; body	->	(...)"?
	static _conv_LegExp(code)
	{
		; verify code matches pattern
		nML := CSect.nLegExp . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		tag1		:= mML.tag1												; optional comment (masked) on cmd line
		head		:= tag1													; remove all of these -> , % " (from cmd line)
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)							; full parentheses block (...) - converted
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		Restore_Premask(&outStr)											; make sure strings and comments have been restored
		return 		outStr													; return converted output
	}

	; Public - 2025-06-16 AMB, UPDATED
	; head	->	var = %var%
	; body	->	(...)"?
	static _conv_LegAssignVar(code)
	{
		; verify code matches pattern
		nML := CSect.nLegAssignVar . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		var1		:= mML[1]												; var on left side of =
		ws			:= mML[2]												; optional horz whitespace
		var2		:= mML[3]												; var on right side of =
		tag1		:= mML.tag1												; optional comment (masked) on cmd line
		head		:= var1 . ':=' . ws . var2 . tag1						; newly formatted cmd line [ = to := ]
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)							; full parentheses block (...) - converted
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		Restore_Premask(&outStr)											; make sure strings and comments have been restored
		return 		outStr													; return converted output
	}

	; Public - 2025-06-16 AMB, UPDATED
	; head	->	%? funcCall("?
	; body	->	(...)"?
	static _conv_FCall(code)
	{
		; verify code matches pattern
		nML := CSect.nFCall . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		fCall		:= trim(mML[1])											; function call on cmd line (preserve)
		ws			:= StrReplace(mML[2], '"')								; whitespace - remove DQ if present
		tag1		:= mML.tag1												; optional comment (masked) on cmd line
		head		:= fCall . ws . tag1									; newly formatted cmd line
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)							; full parentheses block (...) - converted
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		Restore_Premask(&outStr)											; make sure strings and comments have been restored
		return 		outStr													; return converted output
	}
}


; 2025-06-16 - MOVED TO MaskCode.ahk... at least for now
;;################################################################################
;															conv_ContParBlk(code)
;;################################################################################
;{
;; 2025-06-12 AMB, ADDED - WORK IN PROGRESS
;; 2025-06-16 AMB, UPDATED
;; converts code within string continuation (parentheses) block
;; TODO - WORK IN PROGRESS

;	; verify code matches pattern
;	if (!RegExMatch(code, '(?im)' . buildPtn_MLBlock().ParBlk, &mML)) {		; if code does not match CS pattern...
;		return false														; ... return negatory!
;	}

;	body	:= code															; [parentheses block - working var]
;	oBdy	:= body															; orig block code - will need this later

;	; separate/tag leading and trailing ws
;	nSep := '(?is)\((?<LWS>[^\v]*\R\s*)(?<guts>.*?)(?<TWS>\h*\R\h*)\)'		; [separation needle]
;	RegExMatch(body, nSep, &mSep)											; fill vars - TODO - CHANGE TO VERIFICATION IF
;	oLWS	:= mSep.LWS														; save orig leading  WS for restore later
;	oTWS	:= mSep.TWS														; save orig trailing WS for restore later
;	oGuts	:= mSep.guts													; save orig guts contents (excluding lead/trail ws)
;	tLWS	:= gTagPfx 'LWS' gTagTrl										; create temp tag for leading  WS
;	tTWS	:= gTagPfx 'TWS' gTagTrl										; create temp tag for trailing WS
;	body	:= RegExReplace(body, '^\(' oLWS, '(' tLWS)						; replace orig lead  ws with a temp tag
;	body	:= RegExReplace(body, oTWS '\)$', tTWS ')')						; replace orig trail ws with a temp tag

;	; work on guts of body
;	uGuts	:= oGuts														; updated/new guts - will be changed below
;	Restore_Strings(&uGuts)													; remove masking from strings within guts only
;	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (to prep for next step)
;	v2_DQ_Literals(&uGuts)													; change "" to `" within guts only
;	uGuts	:= RegExReplace(uGuts, '(?s)^"(.+)"$', '$1')					; remove surrounding DQs (to prep for next step)
;	uGuts	:= RegExReplace(uGuts, '(?<!``)"', '``"')						; replace " (single) with `"
;	uGuts	:= '"' uGuts '"'												; add surounding double-quotes to guts (again)

;	; mask all %var% within guts
;	nV1Var := '(?<!``)%([^%]+)(?<!``)%'										; [identifies %var%]
;	clsPreMask.MaskAll(&uGuts, 'V1VAR', nV1Var)								; mask/hide all %var%s for now

;	; add quotes before and after v1 vars
;	nV1VarTag := gTagPfx 'V1VAR_\w+' gTagTrl								; [identifies V1Var tags]
;	pos := 1
;	While(pos := RegexMatch(uGuts, nV1VarTag, &mVarTag, pos)) {				; for each V1Var tag found...
;		oTag	:= mVarTag[]												; tag found (orig)
;		qTag	:= '" ' oTag ' "'											; ... add concat quotes around tag (INCLUDE CONCAT DOTS ALSO?)
;		uGuts	:= RegExReplace(uGuts, oTag, qTag,,1,pos)					; replace orig tag with quoted tag
;		pos		+= StrLen(qTag)												; prep for next loop iteration
;	}
;	uGuts		:= RegExReplace(uGuts, '^""\h*')							; cleanup any leading  "" (un-needed)
;	uGuts		:= RegExReplace(uGuts, '\h*""$')							; cleanup any trailing "" (un-needed)
;	body		:= StrReplace(body, oGuts, uGuts)							; replace orig guts with new guts

;	; restore original %VAR%s, then replace each with VAR (remove %)
;	clsPreMask.RestoreAll(&body, 'V1VAR')									; restore orig %VAR%s
;	pos := 1
;	While(pos := RegexMatch(body, nV1Var, &mVar, pos)) {					; for each %VAR% found...
;		pVar	:= mVar[]													; %VAR%
;		eVar	:= mVar[1]													; extracted var [gets VAR from %VAR%]
;		body	:= RegExReplace(body, pVar, eVar,,1,pos)					; replace %VAR% with VAR
;		pos		+= StrLen(eVar)												; prep for next loop iteration
;	}

;	; restore original lead/trail ws
;	body := RegExReplace(body, tLWS, oLWS)									; replace leadWS  tag with orig ws code
;	body := RegExReplace(body, tTWS, oTWS)									; replace trailWS tag with orig ws code

;	; add leading empty lines to quoted text								; (simulate same output as v1)
;	RegExReplace(oLWS, '\R',, &cCRLF)										; count CRLFs - will tells us how many (leading) empty lines
;	if (cCRLF > 1) {	; first CRLF doesn't count							; if one or more empty lines...
;		nBlk := '(?s)(\([^\v]*)(\R)(\s+)"(.+?)(\))'							; [separates block anatomy]
;		body := RegExReplace(body, nBlk, '$1$2"$3$4$5')						; include those empty lines in quoted text (move leading DQ)
;	}

;	; if block is empty (it happens), add empty quotes
;	if (RegExReplace(body, '\s') = '()') {									; if body is empty...
;		body := RegExReplace(body, '(?s)(\(\R)', '$1""',,1)					; add empty string quotes below opening parenthesis
;	}

;	Restore_Premask(&body)													; make sure premask tags are removed
;	return body
;}
