;################################################################################
/*
	WORK IN PROGRESS...
	Each continuation section has attributes that identify its "type", and each
	"type" will be converted in a specific way. This file is dedicated to detection,
	interpretation (which type), and conversion of continuation sections.

	A continuation section has multiple parts
	1. The line that precedes the continuation section block '(...)'.
		This line may be a combo of... vars, cmds, funcCalls, params, etc
	2. The extra lines (optional) that come after line1 but before opening '('
		These lines may be empty, or have line/block comments (but nothing else).
		These comments should already be masked/tagged.
	3. The CS block itself '(...)'
		Starts with open ( on its own line, followed by unlimited number of lines...
		... and ending with ) that starts a new line.
		The opening ( can be followed by comments (which should already be masked).
	4. The optional trailing portion of the CS... that follows ')'
		This is usually a trailing comment or extra params of the first line above.
		... It is on the same line as the closing )

	The process for handling CS is as follows
	1. (easy) Mask all cont sects found in script (globally), using a general needle
	2. (easy) For each mask-tag (created in #1), extract the orig code (one at a time)
	3. (easy) For each tag found in #2... Extract Line1 from the section
	4. (tricky) Use specific needles with line1 (extracted in #3) to determine the type of CS
	5. (easy) Based on result of #4, pass sect orig-code to appropriate convert routine
	6. (easy) Replace orig-code of script with converted code from #5.

	This file has a CSect class which has static members dedicated to Cont sections
*/
;################################################################################
; 2025-06-12 AMB. ADDED
; 2026-02-07 AMB, UPDATED to fix var needle
class CSect
{
	Static MLLineCont		:= '(?i)(?<head>.++)' . buildPtn_MLBlock().FullT				; head (cmd line) + body (block) + optional trailer
	Static cmdVar			:= '(?i)^(?<cv>[\h\w]+?)'										; command/var portion of head
	Static var				:= '(?i)(?<var>(?<!``)[_a-z]\w*+\h*+)'							; variable, includes trailing ws (for now)
	Static tag				:= '(?<tag1>(?:\h*+#TAG★(?:LC|BC|QS)\w++★#)*+)'					; optional tag on head line (comments or quoted-string ONLY!)

	; head configurations
	Static nLegacyAssign	:= CSect.var	. '``?='								. CSect.tag ; . '$'		; [var/cmd =] (DO NOT ADD OPTIONAL TRAILING WS)
	Static nLegAssignVar	:= CSect.var	. '``?=(\h*+)%(\w++)%'					. CSect.tag ; . '$'		; [var = %var%] (MAY BE CONVERTED TO [var .= ])
	Static nExpAssignQS1	:= CSect.cmdVar . '([.:]=)(\h*%)?(\h*")?'				. CSect.tag ; . '$'		; [var/cmd :=] or [var/cmd .= "]
	Static nExpAssignQS2	:= CSect.cmdVar . '[:]=\h*+\w+\h*"?'					. CSect.tag ; . '$'		; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
	Static nCmdPlus			:= CSect.cmdVar . '(\h*[,%]?)?(\h*")?' 					. CSect.tag ; . '$'		; [cmd] or [cmd,]
	Static nFCall			:= '(?i)^'		. '(?:\h*%)?(\h*[a-z]\w*\()(\h*"?)?'	. CSect.tag ; . '$'		; [cmd] or [cmd,]
	Static nLegExp			:= '(?i)^'		. '(\h*[,%]?)?(\h*")?'					. CSect.tag ; . '$'		; [cmd] or [cmd,]
	;############################################################################
	; will determine whether srcStr has a continuation section
	; will return converted code if convert param is true
	; will return simple T or F flag, otherwise
	; 2025-06-12 AMB, ADDED
	Static HasContSect(srcStr, convert := true)
	{
		; ADD SUPPORT FOR MORE SECTION DESIGNS, AS NEEDED

		if (!(srcStr ~= '(?im)' . buildPtn_MLBlock().ParBlk)) {								; if does not have a parentheses block...
			return false																	; ... return no
		}
		if (!convert) {																		; if no conversion requested
			return true																		; ... simply flag as continuation block
		}
		; conversion requested

		; if srcStr is a full section, including the...
		;	... head (cmd line), neck, body (block), and optional trailer...
		if (RegExMatch(srcStr, CSect.MLLineCont, &mML)) {									; if is [head + body + optional trailer]...
			return CSect.FilterAndConvert(srcStr)											; ... return converted code
		}

		; default behavior (for now)
		; looks like srcStr is just the block
		return conv_ContParBlk(srcStr)														; otherwise... return converted block
	}
	;############################################################################
	; Determines whether code is a continuation section...
	;	if so... routes code to appropriate conversion routine
	;		then returns converted code
	;	if not... returns false
	; 2025-06-22 AMB, UPDATED
	Static FilterAndConvert(code)
	{
		Mask_T(&code, 'C&S', false)															; mask comments/strings, don't mask multi-line strings!

		if (!RegExMatch(code, CSect.MLLineCont, &mCS)) {									; if does not match profile (head + body + optional trailer)
			return false																	; ... return no
		}
		; code is a properly formatted continuation section
		; route code to proper function for conversion

		if	(mCS.head ~= CSect.nLegAssignVar		. '\h*$')	{
			return CSect._conv_LegAssignVar(code)											; [var = %var%]
		}
		else if (mCS.head ~= CSect.nLegacyAssign	. '\h*$')	{
			return CSect._conv_LegacyAssign(code)											; [var =]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS1	. '\h*$')	{
			return CSect._conv_ExpAssignQS1(code)											; [var/cmd := %? "?]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS2	. '\h*$')	{
;			return CSect._conv_ExpAssignQS2(code)											; [var := var] or [var := "]
		}
		else if	(mCS.head ~= CSect.nCmdPlus			. '\h*$')	{
;			return 	CSect._conv_CmdComma(code)												; [cmd] or [cmd,]
		}
		else if	(mCS.head ~= CSect.nFCall			. '\h*$')	{
			return 	CSect._conv_FCall(code)													; [ %? funcCall("? ]
		}
		else if	(mCS.head ~= CSect.nLegExp			. '\h*$')	{							; CAN CATCH FALSE POSITIVES
			return 	CSect._conv_LegExp(code)												; [,? %? "?]
		}
		else {
			if (IsSet(gFilePath)) {
				msg := '`n`nPATTERN NOT FOUND`n' gFilePath '`n' mCS.head
				head .= msg
			}
			return code
		}
	}
	;############################################################################
	; head	->	var/cmd :=  %? "?
	; body	->	(...)"?
	; 2025-06-22 AMB, UPDATED
	Static _conv_ExpAssignQS1(code)
	{																						; 2026-01-17 - UPDATED to fix DQ and IF block bug
		; verify code matches pattern
		nML := CSect.nExpAssignQS1 . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		varCmd		:= mML[1]																; var or command on cmd line
		equals		:= mML[2]																; equals on cmd line [ := or .= ]
		tag1		:= mML.tag1																; trailing comment (masked) on command line
		perc		:= trim(mML[3])															; % on cmd line (will be removed)
		dq			:= trim(mML[4])															; " on cmd line (will be removed)
		head		:= varCmd . equals . tag1												; newly formatted cmd line
		neck		:= mML.neck																; portion between head and opening body '('
		body		:= mML.parBlk															; parentheses block '(...)' - before conversion

		if (dq)	{																			; if cmd line had "...
			body	:= conv_ContParBlk(body)												; ... convert the block code
		} else {
			Mask_R(&body, 'C&S')															; restore comments/strings
			body	:= RegExReplace(body, '(?<!``)""', '``"')								; change "" to `", nothing else
		}
		trail		:= RegExReplace(mML.trail, '^"')										; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail											; assemble output string
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return 		outStr																	; return converted output
	}
	;############################################################################
	; head	->	,? %? "?
	; body	->	(...)"?
	; 2025-06-22 AMB, UPDATED
	; 2025-07-03 AMB, UPDATED to simulate v1 indention behavior
	Static _conv_LegExp(code)
	{
		; verify code matches pattern
		nML := CSect.nLegExp . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		CorP		:= mML[1]			; optional											; comma and/or % (will be omitted)
		expQuote	:= trim(mML[2])		; optional											; expression double-quote - will be used to force indention
		tag1		:= mML.tag1			; optional											; comment (masked) on cmd line
		head		:= tag1																	; remove all of these -> , % " (from cmd line)
		neck		:= mML.neck																; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)											; convert contents of parentheses block '(...)'
		; force indention behavior for expression, if necessary
		nBlk		:= buildPtn_MLBlock().parBlk											; [block/body needle]
		if (expQuote && RegExMatch(body, nBlk, &mBlk)) {									; if exp quote was found above, force indention if present
			guts	:= mBlk.guts															; get current guts from block
			wsGuts	:= RegExReplace(guts, '^(\s+)"', ' "$1')								; incl lead ws (move lead "), [lead space req for v1.1])
			body	:= RegExReplace(body, guts, wsGuts,,1)									; update body to include leading ws (force indention)
		}
		trail		:= RegExReplace(mML.trail, '^"')										; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail											; assemble output string
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return 		outStr																	; return converted output
	}
	;############################################################################
	; head	->	var =
	; body	->	(...)
	; 2025-06-22 AMB, UPDATED
	Static _conv_LegacyAssign(code)
	{
		; verify code matches pattern
		nML := CSect.nLegacyAssign . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		var1		:= mML[1]																; var on left side of = (includes trailing ws, for now)
		tag1		:= mML.tag1																; optional comment (masked) on cmd line
		head		:= var1 . ':=' . tag1													; newly formatted cmd line [ = to := ]
		neck		:= mML.neck																; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)											; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')										; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail											; assemble output string
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return 		outStr																	; return converted output
	}
	;############################################################################
	; head	->	var = %var%
	; body	->	(...)"?
	; 2025-06-22 AMB, UPDATED
	Static _conv_LegAssignVar(code)
	{
		; verify code matches pattern
		nML := CSect.nLegAssignVar . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		var1		:= mML[1]																; var on left side of = (includes trailing ws, for now)
		ws			:= mML[2]																; optional horz whitespace
		var2		:= mML[3]																; var on right side of =
		tag1		:= mML.tag1																; optional comment (masked) on cmd line
		head		:= var1 . ':=' . ws . var2 . tag1										; newly formatted cmd line [ = to := ]
		neck		:= mML.neck																; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)											; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')										; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail											; assemble output string
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return 		outStr																	; return converted output
	}
	;############################################################################
	; head	->	%? funcCall("?
	; body	->	(...)"?
	; 2025-06-22 AMB, UPDATED
	Static _conv_FCall(code)
	{
		; verify code matches pattern
		nML := CSect.nFCall . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		fCall		:= trim(mML[1])															; function call on cmd line (preserve)
		ws			:= StrReplace(mML[2], '"')												; whitespace - remove DQ if present
		tag1		:= mML.tag1																; optional comment (masked) on cmd line
		head		:= fCall . ws . tag1													; newly formatted cmd line
		neck		:= mML.neck																; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)											; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')										; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail											; assemble output string
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return 		outStr																	; return converted output
	}
}
;################################################################################
;################################################################################
; Purpose: adds continuation lines to current line
; TODO -	EVENTUALLY - USE CONTINUATION SECTION MASKING INSTEAD
;			Ternary DOES NOT require ws - might need to adjust these needles
; WORK IN PROGRESS - MAY BE MERGING INTO CSect class soon
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
addContsToLine(&curLine, &EOLComment)
{
	global gOScriptStr, gO_Index, gEOLComment_Cont
	outStr := ''	; will hold all added lines, then be added to curLine
	loop {
		; watch for last line in script
		if (gOScriptStr.Length < gO_Index + 1) {
		;if (!gOScriptStr.HasNext) {
			break	; reached last line in script - exit
		}

		; grab next line for inspection
		;nextLine	:= LTrim(gOScriptStr[gO_Index + 1])
		nextLine	:= LTrim(gOScriptStr.GetLine(gO_Index + 1))

		; prevent these from interfering with detection of continuation lines
		Mask_T(&nextLine, 'HK')																; mask hotkey declarations
		Mask_T(&nextLine, 'HS')																; mask hotstring declarations
		Mask_T(&nextLine, 'labels')															; mask label declarations

		; inspect each line after cur line to see whether a cont sect exists...
		;	if so, add each cont line to the working var, which will then...
		;	... be added to curLine (and returned)
		; cont can start with any of [ comma, dot, ?, :, &&, ||, AND, OR ]
		if (nextLine ~= '(?i)^(?:[,.?]|:(?!:)|\|\||&&|AND|OR)')								; valid continuation chars
		{
			; 2025-05-24 Banaanae, ADDED for fix #296
			;separateComment(gOScriptStr[gO_Index + 1], nlChar1, &EOLComment)
			separateComment(gOScriptStr.GetLine(gO_Index + 1), &EOLComment)
			gEOLComment_Cont.Push(EOLComment)												; TODO - can lead to errors, need to investigate

			gO_Index++																		; adjust main-loop line-index
			gOScriptStr.SetIndex(gO_Index)
			;outStr .= '`r`n' RegExReplace(gOScriptStr[gO_Index], '(\h+`;.*)$', '')			; update output string as we go
			outStr .= '`r`n' RegExReplace(gOScriptStr.GetLine(gO_Index),'(\h+`;.*)$','')	; update output string as we go

			; these are not really needed... they serve no purpose here...
			;	only included to cleanup reference within PreMask.masklist
			Mask_R(&nextLine, 'labels')														; restore label declarations
			Mask_R(&nextLine, 'HS')															; restore hotstring declarations
			Mask_R(&nextLine, 'HK')															; restore hotkey declarations
		}
		else {
			break	; reached end of continuation section
		}
	}
	curLine .= outStr																		; update curLine to be returned

	; 2025-05-24 Banaanae, ADDED for fix #296
	if (gEOLComment_Cont.Length != 1) {
		EOLComment := ''
	}
	else {
		gEOLComment_Cont.Pop()
	}
	return false
}
