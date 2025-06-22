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
;################################################################################
; 2025-06-12 AMB. ADDED

;	THIS IS A WORK IN PROGRESS

class CSect
{
	static MLLineCont		:= '(?i)(?<head>.++)' . buildPtn_MLBlock().FullT		; head (cmd line) + body (block) + optional trailer
	static cmdVar			:= '(?i)^(?<cv>[\h\w]+?)'								; command/var portion of head
	static var				:= '(?i)(?<var>[_a-z]\w*+\h*+)'							; variable, includes trailing ws (for now)
	static tag				:= '(?<tag1>(?:\h*+#TAG★(?:LC|BC|QS)\w++★#)*+)'		; optional tag on head line (comments or quoted-string ONLY!)

	; head configurations
	static nLegacyAssign	:= CSect.var	. '``?='								. CSect.tag ; . '$'		; [var/cmd =]
	static nLegAssignVar	:= CSect.var	. '``?=(\h*+)%(\w++)%'					. CSect.tag ; . '$'		; [var = %var%] (MAY BE CONVERTED TO [var .= ])
	static nExpAssignQS1	:= CSect.cmdVar . '([.:]=)(\h*%)?(\h*")?'				. CSect.tag ; . '$'		; [var/cmd :=] or [var/cmd .= "]
	static nExpAssignQS2	:= CSect.cmdVar . '[:]=\h*+\w+\h*"?'					. CSect.tag ; . '$'		; [var := var] or [var := "] (CAN BE COVERTED TO [var .= "])
	static nCmdPlus			:= CSect.cmdVar . '(\h*[,%]?)?(\h*")?' 					. CSect.tag ; . '$'		; [cmd] or [cmd,]
	static nFCall			:= '(?i)^'		. '(?:\h*%)?(\h*[a-z]\w*\()(\h*"?)?'	. CSect.tag ; . '$'		; [cmd] or [cmd,]
	static nLegExp			:= '(?i)^'		. '(\h*[,%]?)?(\h*")?'					. CSect.tag ; . '$'		; [cmd] or [cmd,]


	; PUBLIC - 2025-06-12 AMB, ADDED
	; will determine whether srcStr has a continuation section
	; will return converted code if convert param is true
	; will return simple T or F flag, otherwise
	static HasContSect(srcStr, convert := true)
	{
		; ADD SUPPORT FOR MORE SECTION DESIGNS, AS NEEDED

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
			return CSect.FilterAndConvert(srcStr)									; ... return converted code
		}

		; default behavior (for now)
		; looks like srcStr is just the block
		return conv_ContParBlk(srcStr)												; otherwise... return converted block
	}


	; Public - 2025-06-22 AMB, UPDATED
	; Determines whether code is a continuation section...
	;	if so... routes code to appropriate conversion routine
	;		then returns converted code
	;	if not... returns false
	static FilterAndConvert(code)
	{
		MaskT(&code, 'C&S', false)													; mask comments/strings, don't mask multi-line strings!

		if (!RegExMatch(code, CSect.MLLineCont, &mCS)) {							; if does not match profile (head + body + optional trailer)
			return false															; ... return negatory!
		}
		; code is a properly formatted continuation section
		; route code to proper function for conversion

		if	(mCS.head ~= CSect.nLegAssignVar		. '$')	{
			return CSect._conv_LegAssignVar(code)									; [var = %var%]
		}
		else if (mCS.head ~= CSect.nLegacyAssign	. '$')	{
			return CSect._conv_LegacyAssign(code)									; [var =]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS1	. '$')	{
			return CSect._conv_ExpAssignQS1(code)									; [var/cmd := %? "?]
		}
		else if	(mCS.head ~= CSect.nExpAssignQS2	. '$')	{
;			return CSect._conv_ExpAssignQS2(code)									; [var := var] or [var := "]
		}
		else if	(mCS.head ~= CSect.nCmdPlus			. '$')	{
;			return 	CSect._conv_CmdComma(code)										; [cmd] or [cmd,]
		}
		else if	(mCS.head ~= CSect.nFCall			. '$')	{
			return 	CSect._conv_FCall(code)											; [ %? funcCall("? ]
		}
		else if	(mCS.head ~= CSect.nLegExp			. '$')	{						; CAN CATCH FALSE POSITIVES
			return 	CSect._conv_LegExp(code)										; [,? %? "?]
		}
		else {
			msg := '`n`nPATTERN NOT FOUND`n' gFilePath "`n" mCS.head
			head .= msg
			return code
		}
	}


	; Public - 2025-06-22 AMB, UPDATED
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
			body	:= conv_ContParBlk(body)								; ... convert the block code
		else
			MaskR(&body, 'C&S')												; restore comments/strings
			body	:= RegExReplace(body, '""', '``"')						; change "" to `", nothing else
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		MaskR(&outStr, 'C&S')												; restore comments/strings
		return 		outStr													; return converted output
	}


	; Public - 2025-06-22 AMB, UPDATED
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
		body		:= conv_ContParBlk(mML.parBlk)							; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		MaskR(&outStr, 'C&S')												; restore comments/strings
		return 		outStr													; return converted output
	}


	; Public - 2025-06-22 AMB, UPDATED
	; head	->	var =
	; body	->	(...)
	static _conv_LegacyAssign(code)
	{
		; verify code matches pattern
		nML := CSect.nLegacyAssign . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		var1		:= mML[1]												; var on left side of = (includes trailing ws, for now)
		tag1		:= mML.tag1												; optional comment (masked) on cmd line
		head		:= var1 . ':=' . tag1									; newly formatted cmd line [ = to := ]
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)							; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		MaskR(&outStr, 'C&S')												; restore comments/strings
		return 		outStr													; return converted output
	}


	; Public - 2025-06-22 AMB, UPDATED
	; head	->	var = %var%
	; body	->	(...)"?
	static _conv_LegAssignVar(code)
	{
		; verify code matches pattern
		nML := CSect.nLegAssignVar . buildPtn_MLBlock().FullT
		if (!RegExMatch(code, nML, &mML)) {
			return false
		}
		var1		:= mML[1]												; var on left side of = (includes trailing ws, for now)
		ws			:= mML[2]												; optional horz whitespace
		var2		:= mML[3]												; var on right side of =
		tag1		:= mML.tag1												; optional comment (masked) on cmd line
		head		:= var1 . ':=' . ws . var2 . tag1						; newly formatted cmd line [ = to := ]
		neck		:= mML.neck												; portion between head and opening body '('
		body		:= conv_ContParBlk(mML.parBlk)							; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		MaskR(&outStr, 'C&S')												; restore comments/strings
		return 		outStr													; return converted output
	}


	; Public - 2025-06-22 AMB, UPDATED
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
		body		:= conv_ContParBlk(mML.parBlk)							; convert contents of parentheses block '(...)'
		trail		:= RegExReplace(mML.trail, '^"')						; remove any [optional] trailing DQ following ')"'
		outStr		:= head . neck . body . trail							; assemble output string
		MaskR(&outStr, 'C&S')												; restore comments/strings
		return 		outStr													; return converted output
	}
}
