;################################################################################
																	   isHex(val)
;################################################################################
{
; 2025-07-03 AMB, ADDED - determines whether val is a hex val

	val := trim(val)
	return ((IsNumber(val)) && (val ~= '(?i)^0x[0-9a-f]+$'))
}
;################################################################################
												  separateComment(line, &comment)
;################################################################################
{
; 2025-05-24 Banaanae, ADDED to fix #296
;   returns comment and 'command' portion of line in separate vars
; 2025-06-12 AMB, UPDATED - to capture far-left line comment, rather than trailing (far right) occurence
; 2025-07-03 AMB, UPDATED - moved and changed func name, added support for `; to fix issue #347
;   needle now handles full separation so removed unnecessary FirstChar param

	comment		:= ''								; ini, in case of no comment
	if (RegExMatch(line, gnCmd_Comment, &mSep)) {	; see MaskCode.ahk for needle
		line	:= mSep[1]							; 'command' side (if present), supports `;
		comment	:= mSep[2]							;  comment - captures FIRST occurence
	}
	return	line
}
;################################################################################
														 fixAssignments(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved and consolidated to dedicated routine for cleaner convert loop
; 2025-07-03 AMB, UPDATED to support multi-line and orig whitespace
; Purpose: conversions related to assignments, in different situatons
; TODO - needs to be updated to cover all situations

	; Does order matter here? ... I dont think so
	; only one needs to be performed for current lne...
	;	(as far as I can tell in testing, anyway)
	;	... future tests may reveal otherwise
	if (fixFuncParams(&lineStr))				{		; for function params (declarations and calls)
	;	return
	}
	else if (v1v2_fixLSG_Assignments(&lineStr))	{		; for local, static, global assignments
	;	return
	}
	else if (v1v2_FixExpAssignments(&lineStr))	{		; for expression assignments
	;	return
	}
	else if (v1v2_FixLegAssignments(&lineStr))	{		; for legacy assignments
	;	return
	}
	return												; lineStr by reference
}
;################################################################################
														  fixFuncParams(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
;	also refactored to be smaller footprint and more clear
; Replace = with := in function params (declarations and calls)
; Also flags ByRef params in advance to be fully processed within FixByRefParams()
; The only thing exclusive to v2 is the ByRef conversion...
;	... otherwise can also be used for v1.1 conversion (I think)
; TODO - (MAYBE) SEPARATE BYREF DETECTION FROM THIS ROUTINE?

	global gmByRefParamMap

	origStr := lineStr													; save orig for change detection
	Mask_T(&lineStr, 'STR')												; mask strings that may contain 'ByRef, commas, ?, ='

	; does lineStr contain a function declaration/call?
	if (!RegExMatch(lineStr, gPtn_FuncCall, &mFunc)) {					; if lineStr does NOT have a function call...
		Mask_R(&lineStr, 'STR')											; ... restore strings...
		return false	; no func call found							; ... and exit
	}
	; do not include IF or WHILE (which can be detected as well)
	if (mFunc.FcName ~= 'i)\b(if|while)\b') {							; if func name is actually IF or WHILE...
		Mask_R(&lineStr, 'STR')											; ... restore strings...
		return false	; exclude If or While							; ... and exit
	}

	; flag byref params and replace ( = ) with ( := )
	ByRefFlags	:= []													; will be used later in FixByRefParams()
	nByRef		:= 'i)(\bByRef\h+)'										; [detection of ByRef]
	nLegAssign	:= gPtnVarAssign . '``?=([^,\)]*)'						; [detection of v1 legacy assignment equals (=)]
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

	return	(lineStr != origStr)										; and return lineStr by reference
}
;################################################################################
												 v1v2_FixExpAssignments(&lineStr)
;################################################################################
{
; 2025-07-03 AMB, ADDED to provide...
;	... better detection/conversion of empty expression assignments
; Primary purpose:
;	var := (nothing) -> var := ""
;	also supports chained assignments and multi-line
; NOTE:
;	v1 does not seem to support chained assignments past the first var := (nothing)...
;		(this statement is based on testing, not any documentation)
;	BUT... this does add the "", and support chained assignments past that point
;		this may cause v2 converted code to act differently in some rare cases...
;	BUT... v2 requires initial value, so this func provides that

	origStr	:= lineStr													; save orig to flag whether change was made

	; pre-mask to avoid char detection interferrence
	sess	:= clsMask.NewSession()
	Mask_T(&lineStr, 'STR', sess)										; hide commas and equals within strings
	Mask_T(&lineStr, 'FC',  sess)										; hide commas within func calls
	Mask_T(&lineStr, 'KVO', sess)										; hide commas within key/val objects

	; mask expression assignments for easier detection
	nExpAssign	:= gPtnVarAssign . '([:.*/]=)(\h*)([^=,\v]*)'			; detect expression assignments
	Mask_T(&lineStr, 'EA', nExpAssign)									; tag    expression assignments
	ntNeedle	:= uniqueTag('EA\w+')									; needle for exp assignment tags

	While(pos	:= RegexMatch(lineStr, ntNeedle, &m, pos??1)) {			; for each expression assignment...
		mTag	:= m[]													; found tag
		oStr	:= HasTag(,mTag)										; extract original string from tag
		if (RegExMatch(oStr, nExpAssign, &mA)) {
			var		:= mA[1]											; variable and leading ws
			op		:= mA[2]											; operator .= or :=
			ws		:= mA[3]											; ws following operator
			val		:= mA[4]											; value
			val		:= (val!='') ? val : '""'							; make sure value is not missing
			newStr	:= var . op . ws . val								; reassemble output string
			lineStr := RegExReplace(lineStr, mTag, newStr,,1,pos)		; update output str
			pos		+= StrLen(newStr)									; prep for next search
		}
	}
	Mask_R(&lineStr, 'KVO', sess)										; restore key/val objects
	Mask_R(&lineStr, 'FC',  sess)										; restore func calls (converts as part of restore)
	Mask_R(&lineStr, 'STR', sess)										; restore strings

	return	(lineStr != origStr)										; and return lineStr by reference
}
;################################################################################
												 v1v2_FixLegAssignments(&lineStr)
;################################################################################
{
; 2025-07-03 AMB, ADDED to provide...
;	... better detection/conversion of legacy assignments
;	v1 does not support chained legacy assignments - this does not attempt to either
;	BUT... it will allow a string assignment to span multiple lines

	nLegVar		:= '(?is)(\h*+,?\h*+[a-z_%](?|[\w%]++|\.(?=\w))*+\h*+)'			; new support for obj.property
	nLegAssign	:= nLegVar . '``?=(?!=)(\h*)(.*)'
	if (!(lineStr ~= nLegAssign)) {
		return false
	}

	origStr	:= lineStr															; save orig to flag whether change was made

	; pre-mask to avoid char detection interferrence
	sess	:= clsMask.NewSession()
	Mask_T(&lineStr, 'STR', sess)												; hide commas and equals within strings
	Mask_T(&lineStr, 'FC',  sess)												; hide commas within func calls
	Mask_T(&lineStr, 'KVO', sess)												; hide commas within key/val objects

	; mask expression assignments for easier detection
	nLegAssign	  := '^' . nLegAssign											; detect legacy assignments
	Mask_T(&lineStr, 'LA', nLegAssign)											; tag    legacy assignments
	ntNeedle	:= uniqueTag('LA\w+')											; needle for leg assignment tags

	While(pos	:= RegexMatch(lineStr, ntNeedle, &m, pos??1)) {					; for each legacy assignment...
		mTag	:= m[]															; found tag
		oStr	:= HasTag(,mTag)												; extract original string from tag
		if (RegExMatch(oStr, nLegAssign, &mA)) {
			var		:= mA[1]													; variable and leading ws
			op		:= ':='														; operator .= or :=
			ws		:= mA[2]													; ws following operator
			val		:= mA[3]													; value
			Mask_R(&val, 'KVO', sess)											; restore key/val objects
			Mask_R(&val, 'FC',  sess)											; restore func calls (converts as part of restore)
			Mask_R(&val, 'STR', sess)											; restore strings
			val		:= ToExp(val, valToStr:=false, forceDot:=true)				; make ToExp() options clear
			newStr	:= var . op . ws . val										; reassemble output string
			lineStr := RegExReplace(lineStr, mTag, newStr,,1,pos)				; update output str
			pos		+= StrLen(newStr)											; prep for next search
		}
	}
	Mask_R(&lineStr, 'KVO', sess)												; restore key/val objects
	Mask_R(&lineStr, 'FC',  sess)												; restore func calls (converts as part of restore)
	Mask_R(&lineStr, 'STR', sess)												; restore strings

	return	(lineStr != origStr)												; and return lineStr by reference
}
;################################################################################
												v1v2_FixLSG_Assignments(&lineStr)
;################################################################################
{
; Replaces = with := for global/local/static declaration assignments
; NOTE: for v1 global/local/static declaration assignments, = is treated as := and...
;	... commas are treated as separators (even when escaped)
; 	see here: https://www.autohotkey.com/docs/v1/Functions.htm#More_about_locals_and_globals
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-07-03 AMB, UPDATED -
;	* made needle adjs to fix false positives
;	* added pre-masking to mimimize potential char conflicts
;	* trim fix for #351

	; use (?s) since these assignments can span multi-line
	nLSG		:= '(?is)^(\h*+(?:global|local|static)\h)(.+)'			; declaration for global,local,static
	nLegAssign	:= gPtnVarAssign . '``?=(?!=)(\h*)([^=,\v]*)'			; individal legacy assignments

	if (!(lineStr ~= nLSG && lineStr ~= nLegAssign)) {					; avoid unnecessary (slow) masking if possible
		return false
	}

	origStr := lineStr, tempStr	:= lineStr								; save orig, and use working var (due to masking)
	sess	:= clsMask.NewSession()										; limit restore to single masking session
	Mask_T(&tempStr, 'STR', sess)										; hide commas and equals within strings
	Mask_T(&tempStr, 'FC',  sess)										; hide commas within func calls
	Mask_T(&tempStr, 'KVO', sess)										; hide commas within key/val objects
	if (RegExMatch(tempStr, nLSG, &mLSG)) {								; separate declaration from assignemnts
		declare		:= mLSG[1], outStr := declare						; declaration portion, [outStr will become output]
		assignList	:= mLSG[2]											; var assignment list (can be multi-line)
		for idx, assign in StrSplit(assignList, ',') {					; for each assignment in list...
			if (RegExMatch(assign, '^' nLegAssign '$', &mLA)) {			; included in case of var = (with no value)
				var := mLA[1], ws := mLA[2], val := mLA[3]				; separate assignment parts
				val := trim(val) ? val : '""'							; make sure var has a value when encountering var =
				assign := var . ':=' . ws . val							; assemble new assignment str
			}
			outStr .= assign ','										; update output str
		}
		outStr := RTrim(outStr, ',')									; trim final/stray trailing commas (also fixes #351)
		Mask_R(&outStr, 'KVO', sess)									; restore key/val objects
		Mask_R(&outStr, 'FC',  sess)									; restore func calls (converts as part of restore)
		Mask_R(&outStr, 'STR', sess)									; restore strings
		lineStr := outStr												; update final output
	}
	return	(lineStr != origStr)										; and return lineStr by reference
}
;################################################################################
															v1v2_FixNEQ(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, UPDATED - some var and funcCall names
; Converts <> to !=

	if (!InStr(lineStr, '<>'))
		return

	Mask_T(&lineStr, 'STR')		; protect "<>" within strings
		lineStr := StrReplace(lineStr, '<>', '!=')
	Mask_R(&lineStr, 'STR')
	return						; lineStr by reference
}
;################################################################################
												  v1v2_FixTernaryBlanks(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; fixes ternary IF - when value for 'true' or 'false' is blank/missing
; added support for multi-line
; [var ?  : "1"] => [var ? "" : "1"]
; [var ? "1" : ] => [var ? "1" : ""]

	Mask_T(&lineStr, 'STR')
		; for blank/missing 'true' value, single or multi-line
		nTSML	:= '(?im)^(.*?\s*+)\?(\h*+)(\s*+):(\h*+)(.+)$'
		lineStr := RegExReplace(lineStr, nTSML, '$1?$2""$3:$4$5')
		; for blank/missing 'false' value, SINGLE-line
		nFSng	:= '(?im)^(.*?\h\?.*?:\h*)(\)|$)'
		lineStr := RegExReplace(lineStr, nFSng, '$1 ""$2')
		; for blank/missing 'false' value, MULTI-line
		nFML	:= '(?im)^(.*?\h*+)(\v+\h*+\?[^\v]+\v++)(\h*+:)(\h*+)(\){1,}|$)'
		lineStr := RegExReplace(lineStr, nFML, '$1$2$3$4""$5')
	Mask_R(&lineStr, 'STR')

	return		; lineStr by reference
}
;################################################################################
													  v1v2_NoKywdCommas(&lineStr)
;################################################################################
{
; 2025-06-12 AMB, Moved to dedicated routine for cleaner convert loop
; 2025-07-03 AMB, Changed func name
; removes trailing commas from some AHK keywords/commands

	nFlow	:= 'i)^(\h*)(else|for|if|loop|return|switch|while)(?:\h*,\h*|\h+)(.*)$'
	lineStr	:= RegExReplace(lineStr, nFlow, '$1$2 $3')
	return		; lineStr by reference
}
