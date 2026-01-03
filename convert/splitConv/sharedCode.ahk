;################################################################################
												 Zip(srcStr, TagID, Force:=false)
;################################################################################
{
; 2025-11-30 AMB, ADDED - compression of entire string into single tag
; adds support for multi-line compression...
; ... this is necessary to add braces to non-brace (single-line) IF/ELSEIF/ELSE blocks

	global gaZipTagIDs																; multi-lines added by converter
	if (!srcStr || !TagID) {														; if params are invalid...
		return 'ERROR in ' A_ThisFunc '() - missing required params'				; ... output an error statement
	}
	if (!Force && !InStr(srcStr, '`n')) {											; if not multi-line, and force not requested...
		return srcStr																; ... return orig str
	}
	gaZipTagIDs.Push(TagID)															; flag the TagID so the lines can be unzipped later
	Mask_T(&srcStr, TagID, '(?s).+')												; mask the entire srcStr, replace with a tag
	return srcStr			; is now a custom masked-tag							; return the tag
}
;################################################################################
														 UnZip(srcStr, TagID:='')
;################################################################################
{
; 2025-11-30 AMB, ADDED - restores custom tags created with Zip()
; But with added feature...
;	if expanded code is multi-line and is placed within a single-line IF/ELSEIF/ELSE block...
;	... surrounding braces will be added so the blocks support the multi-line code
; addBlkBraces() - see labelAndFunc.ahk

	if (!TagID && !gaZipTagIDs.Length) {											; if there are no tags to unzip/restore...
		return srcStr																; ... return orig str
	}
	if (TagID) {																	; if a single tagID has been specified by caller...
		addBlkBraces(&srcStr, TagID)												; ... add braces to (non-brace) if/elseif/else, as needed
		Mask_R(&srcStr, TagID '\w+')												; ... restore all target tags (unzip/expand the lines)
		return srcStr																; ... return the unzipped/expanded code
	}
	addBlkBraces(&srcStr, gaZipTagIDs)		; array list of all tag IDs				; No tag was specified, add braces for all tags as needed
	for idx, id in gaZipTagIDs {													; for each tag in list...
		Mask_R(&srcStr, id '\w+')													; ... unzip/expand their associated lines
	}
	return srcStr																	; return code with braces added and lines expanded
}
;################################################################################
													   addBlkBraces(&code, tagID)
;################################################################################
{
; 2025-11-23 AMB, ADDED as part of fix for #413
; 2025-11-30 AMB, UPDATED to support mutiple tagIDs in single operation (tagID can be an array)
; 2025-12-10 AMB, UPDATED to support LOOP blocks
; used in conjuction with Zip(), UnZip()
; adds braces to (non-brace) IF, IfMsgBox, LOOP sections, when those sections have target tags
; TODO - can be adapted to also support WHILE/TRY/FOR/SWITCH, as needed

	; IF needles
	nIfFull	:= buildPtn_IF().fullIF															; needle for full if/elseif/else blocks
	nIF		:= buildPtn_IF().IFSect															; needle for full IF	 section only
	nEF		:= buildPtn_IF().EFSect															; needle for full ELSEIF section only
	nEL		:= buildPtn_IF().ELSect															; needle for full ELSE	 section only

	; LOOP needle - customized (2025-12-10)
	Kloc	:= InStr(gPtn_Blk_LP, '\K')														; find \K within loop needle (not needed here)
	nLoop	:= SubStr(gPtn_Blk_LP, Kloc+2)													; capture everything after \K
	nloop	:= '(?im)^([\h{}]*+(?:TRY\b\h*+)?)' . nLoop										; customize prefix to Loop needle

	; build needle for tags
	if (Type(tagID) = 'Array') {															; if multiple tags will be targetted...
		tagList := '|'																		; ini for detection of duplicate tag id's
		for idx, id in gaZipTagIDs {														; for each tag in zip list...
			if (!id || InStr(tagList, '|' id '|'))											; ... if empty or a dup tag name...
				continue																	; ... skip it
			tagList	.= id . '|'																; ... otherwise add tag to needle list
		}
		nTarg	:= '(?i)' uniqueTag('(?:' Trim(tagList, ' |') . ')\w+')						; finalize needle for target tags
	}
	else {	; only single tag will be targetted
		nTarg	:= '(?i)' uniqueTag(tagID '\w+')											; finalize needle for target tags
	}

	revPos	:= IWTLFS.GetRevPositions(&code)												; get pos for IF/WHILE/TRY/LOOP/FOR/SWITCH nodes, in reverse order
	Loop parse, revPos, '`n', '`r'															; for each node in list...
	{
		ss	:= StrSplit(A_LoopField, ':'), nPos := ss[1], nType := ss[2]					; separate/extract node-position and node-type

		;########################################################################
		; LOOP (2025-12-10)
		if (nType = 'LOOP') {																; if node is a Loop block...
			if (RegExMatch(code, nLoop, &mLoop, nPos) = nPos) {								; verify that loop block is actually at node position
				if (mLoop[] ~= nTarg) {														; if loop block has a target tag...
					lpBlk	:= mLoop.TCT . mLoop.LPBlk										; [loop block, including leading comments, tags, ws]
					if (isBraceBlock(lpBlk))												; if loop block already has braces...
						continue															; ... ignore this node
					mFull	:= origFull :=  mLoop[]											; [FULL Loop block]
					LWS		:= RegExReplace(mLoop[1], '(?i)[}{TRY]', ' ')					; extract leading whitespace (indent), replace any braces or TRY with spaces
					newBlk	:= '`r`n' LWS '{' lpBlk '`r`n' LWS '}'							; build new loop block (with braces)
					mFull	:= RegExReplace(mFull, escRegexChars(lpBlk), newBlk,,1)			; replace orig loop block with brace-block
					if (mFull != origFull) {												; if replacements were made...
						code := RegExReplace(code, escRegexChars(origFull), mFull,,1,nPos)	; ... replace original node string with updated version
					}
					continue																; loop block now has braces - search for next node
				}
			}
		}
		;########################################################################
		; IF
		if (!(nType ~= '(IF|IFMSGBOX)'))													; if node is NOT IF/IfMsgBox...
			continue																		; ... skip it (not currently targetting other node types)
		if (RegExMatch(code, nIfFull, &ifFull, nPos) != nPos)								; if current position does not have an IF block...
			continue																		; ... skip it
		if (!(ifFull[] ~= nTarg))															; if IF-node does not have a target tag...
			continue																		; ... skip it

		; node is a legit IF target
		mFull	:= origFull :=  ifFull[]													; [FULL if/elseif/else (or IfMsgBox) block]
		LWS		:= RegExReplace(ifFull[2], '[}{]', ' ')										; extract leading whitespace (indent), replace any braces with space

		;########################################################################
		; add braces to single-line IF section, if target present
		ifBlk	:= '', ifGuts := '', ifPos := 1												; ini IF vars
		newGuts	:= orig := tag := ''														; ini working vars
		if (ifPos	:= RegExMatch(mFull, nIf, &mIf, ifPos)) {								; if IF-section found at position 1... (should always be true)
			ifBlk	:= mIf[]																; ... [IFblock str]
			ifGuts	:= LTrim(mIf.TCT) . mIf.ifBlk											; ... [IF-section block/guts string (including leading comments/WS)]
			if (mIf.noBB && ifGuts ~= nTarg) {												; ... if IF-section has no braces, but has targ tag
				newGuts	:= '`r`n' LWS . '{' ifGuts '`r`n' LWS '}'							; ...	add braces to block/guts string
				mFull	:= RegExReplace(mFull, escRegexChars(ifGuts), newGuts,,1,ifPos)		; ...	replace block/guts string with brace version
			}
		}
		;########################################################################
		; add braces to single-line ELSEIF sections, if target present
		efGuts := ''																		; ini ELSEIF vars
		efPos := (StrLen(ifBlk) + ((tag) ? StrLen(newGuts)-StrLen(tag) : 0))				; set approx position for initial elseIf search
		newGuts	:= orig := tag := ''														; ini working vars
		While(efPos := RegexMatch(mFull, nEF, &mEF, efPos)) {								; while there are elseIf sections...
			efGuts := LTrim(mEF.TCT) . mEF.efBlk											; ... ELSEIF-section block/guts string (including leading comments/WS)
			if (mEF.noBB && efGuts ~= nTarg) {												; ... if ELSEIF-section has no braces, but has targ tag
				newGuts	:= '`r`n' LWS . '{' efGuts '`r`n' LWS '}'							; ...	add braces to block/guts string
				mFull	:= RegExReplace(mFull, escRegexChars(efGuts), newGuts,,1,efPos)		; ...	replace block/guts string with brace version
			}
			efPos += (StrLen(efGuts) + ((tag) ? StrLen(newGuts)-StrLen(tag) : 0))			; set new starting pos for next elseif search
		}
		;########################################################################
		; add braces to single-line ELSE section, if target present
		elGuts := ''																		; ini ELSE vars
		newGuts	:= orig := tag := ''														; ini working vars
		if (elPos := RegExMatch(mFull, nEL, &mEL)) {										; if ELSE-section found...
			elGuts := LTrim(mEL.TCT) . mEL.elBlk											; ... ELSE-section block/guts string (including leading comments/WS)
			if (mEL.noBB && elGuts ~= nTarg) {												; ... if ELSE-section has no braces, but has targ tag
				newGuts	:= '`r`n' LWS . '{' elGuts '`r`n' LWS '}'							; ...	add braces to block/guts string
				mFull	:= RegExReplace(mFull, escRegexChars(elGuts), newGuts,,1,elPos)		; ...	replace block/guts string with brace version
			}
		}
		;########################################################################
		if (mFull != origFull) {															; if replacements were made...
			code := RegExReplace(code, escRegexChars(origFull), mFull,,1,ifPos)				; ... replace original node string with updated version
		}
	}
}
;################################################################################
																	   isHex(val)
;################################################################################
{
; 2025-07-03 AMB, ADDED - determines whether val is a hex val

	val := trim(val)
	return ((IsNumber(val)) && (val ~= '(?i)^0x[0-9a-f]+$'))
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
	sess	:= clsMask.NewSession()										; create new masking session
	Mask_T(&lineStr, 'FC' ,,sess)										; hide commas within func calls		 (premasks STR, but does not auto-restore STR)
	Mask_T(&lineStr, 'KV' ,,sess)										; hide commas within key/val objects (0 = do not restore C&S)

	; mask expression assignments for easier detection
	nExpAssign	:= gPtnVarAssign . '([:.*/]=)(\h*)([^=,\v]*)'			; [detection for expression assignments]
	Mask_T(&lineStr, 'EA', nExpAssign)									; tag expression assignments (custom mask/tag)
	ntNeedle	:= uniqueTag('EA\w+')									; [needle for exp assignment tags]

	While(pos	:= RegexMatch(lineStr, ntNeedle, &m, pos??1)) {			; for each expression assignment...
		mTag	:= m[]													; found tag
		oStr	:= HasTag(,mTag)										; extract original string from tag
		if (RegExMatch(oStr, nExpAssign, &mA)) {						; separate parts of expression assignment
			var		:= mA[1]											; variable and leading ws
			op		:= mA[2]											; operator .= or :=
			ws		:= mA[3]											; ws following operator
			val		:= mA[4]											; value
			val		:= (val!='') ? val : '""'							; make sure value is not missing
			val		:= RegExReplace(val, '^%\h+')						; 2025-10-06, fix #377, remove lead % when followed by ws (but allow %var%)
			newStr	:= var . op . ws . val								; reassemble output string
			lineStr := RegExReplace(lineStr, mTag, newStr,,1,pos)		; update output str
			pos		+= StrLen(newStr)									; prep for next search
		}
	}
	Mask_R(&lineStr, 'KV' ,,sess)										; restore key/val objects
	Mask_R(&lineStr, 'FC' ,,sess)										; restore func calls (converts as part of restore)
	Mask_R(&lineStr, 'STR',,sess)										; restore strings

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

	nLegVar		:= '(?is)(\h*+,?\h*+[a-z_%](?|[\w%]++|\.(?=\w))*+\h*+)'		; new support for obj.property
	nLegAssign	:= nLegVar . '``?=(?!=)(\h*)(.*)'
	if (!(lineStr ~= nLegAssign)) {
		return false
	}

	origStr	:= lineStr														; save orig to flag whether change was made

	; pre-mask to avoid char detection interferrence
	sess	:= clsMask.NewSession()											; create new masking session
	Mask_T(&lineStr, 'FC' ,,sess)											; hide commas within func calls		 (premasks STR, but does not auto-restore STR)
	Mask_T(&lineStr, 'KV' ,,sess)											; hide commas within key/val objects (0 = do not restore C&S)

	; mask expression assignments for easier detection
	nLegAssign	  := '^' . nLegAssign										; [detection for legacy assignments]
	Mask_T(&lineStr, 'LA', nLegAssign)										; tag legacy assignments
	ntNeedle	:= uniqueTag('LA\w+')										; [needle for leg assignment tags]

	While(pos	:= RegexMatch(lineStr, ntNeedle, &m, pos??1)) {				; for each legacy assignment...
		mTag	:= m[]														; found tag
		oStr	:= HasTag(,mTag)											; extract original string from tag
		if (RegExMatch(oStr, nLegAssign, &mA)) {							; separate parts of legacy assignment
			var		:= mA[1]												; variable and leading ws
			op		:= ':='													; operator .= or :=
			ws		:= mA[2]												; ws following operator
			val		:= mA[3]												; value
			Mask_R(&val, 'KV' ,,sess)										; restore key/val objects
			Mask_R(&val, 'FC' ,,sess)										; restore func calls (converts as part of restore)
			Mask_R(&val, 'STR',,sess)										; restore strings
			val		:= ToExp(val, valToStr:=false, forceDot:=true)			; make ToExp() options clear
			newStr	:= var . op . ws . val									; reassemble output string
			lineStr := RegExReplace(lineStr, mTag, newStr,,1,pos)			; update output str
			pos		+= StrLen(newStr)										; prep for next search
		}
	}
	Mask_R(&lineStr, 'KV' ,,sess)											; restore key/val objects
	Mask_R(&lineStr, 'FC' ,,sess)											; restore func calls (converts as part of restore)
	Mask_R(&lineStr, 'STR',,sess)											; restore strings

	return	(lineStr != origStr)											; and return lineStr by reference
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
; 2025-10-16 AMB, UPDATED to add msg for trailing comma if present

	; use (?s) since these assignments can span multi-line
	nLSG		:= '(?is)^(\h*+(?:global|local|static)\h)(.+)'			; declaration for global,local,static
	nLegAssign	:= gPtnVarAssign . '``?=(?!=)(\h*)([^=,\v]*)'			; individal legacy assignments

	if (!(lineStr ~= nLSG && lineStr ~= nLegAssign)) {					; avoid unnecessary (slow) masking if possible
		return false
	}

	origStr := lineStr, tempStr	:= lineStr								; save orig, and use working var (due to masking)
	sess	:= clsMask.NewSession()										; limit restore to single masking session
	Mask_T(&lineStr, 'FC' ,,sess)										; hide commas within func calls		 (masks STR, but does not auto-restore STR)
	Mask_T(&lineStr, 'KV' ,,sess)										; hide commas within key/val objects (0 = do not restore C&S)

	msg := (Trim(tempStr) ~= ',$')										; if line has trailing comma...
		? ' `; V1toV2: Assuming this is v1.0 code'						; ... plan to add msg to line
		: ''															; ... otherwise no msg required
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
		Mask_R(&outStr, 'KV' ,,sess)									; restore key/val objects
		Mask_R(&outStr, 'FC' ,,sess)									; restore func calls (converts as part of restore)
		Mask_R(&outStr, 'STR',,sess)									; restore strings
		lineStr := outStr . msg											; update final output, 2025-10-16 - add msg as needed
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
;################################################################################
Class NULL {
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
;   static ToString() => "[NULL]"
}
;################################################################################
; 2025-06-12 AMB, ADDED to support dual/multiple "layers" of scriptCode...
; ... each with its own properties. Will be used more in future version of converter
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
;################################################################################
Class ScriptCode
{
	_origStr	:= ''
	_lineArr	:= []
	_curIdx		:= 0

	; acts as constuctor
	__new(str) {
		this._origStr := str
		this.__fillArray()
	}
	;############################################################################
	; Public
	AddAt(lines, position := -1) {
	pos		:= (position > 0 && position <= this.Length +1)
			? position
			: this._lineArr.Length + 1

	if (Type(lines)="Array")
		this._lineArr.InsertAt(pos, lines*)
	else
		this._lineArr.InsertAt(pos, lines)
	}
	;############################################################################
	; Public
	Has(index) {
		return this._lineArr.has(index)
	}
	;############################################################################
	; Public
	SetLine(index, val) {
		if (this.Has(index))
		this._lineArr[index] := val
	}
	;############################################################################
	; Public
	GetLine(index) {
		if (this.Has(index))
			return this._lineArr[index]
		return Null
	}
	;############################################################################
	; Public
	GetLines(startIdx:=1, lineCount:='') {
	; 2025-11-18 AMB, ADDED as part of fix for #409
	; returns all lines from start index

		lineCount	:= (lineCount = '')										; if lineCount not set...
					? (this._lineArr.Length - startIdx) +1					; ... return all after/including start idx
					: lineCount
		curIdx := startIdx, offset := 0, outStr := ''						; ini
		while (this._lineArr.Length >= curIdx && offset < lineCount) {		; while lines still available, and lineCount not satisfied yet...
			curLine	:= this._lineArr[curIdx]								; ... get current/next line
			outStr	.= curLine '`r`n'										; ... add line to output str
			offset++, curIdx++
		}
		return RegExReplace(outStr, '\r\n$',,,1)							; remove last/extra CRLF
	}
	;############################################################################
	; Public
	GetNext {
		get {
			this._curIdx++
			return this.GetLine(this._curIdx)
		}
	}
	;############################################################################
	; Public
	; Param 1 - set current index to passed val
	; Param 2 - adj current index by passed val (+ or -)
	; Param 3 - set NEXT	index to passed val (curIdx will be set to val-1)
	;############################################################################
	SetIndex(setCur := -1, adjVal := 0, setNext := 0) {
		if (IsNumber(setCur) && setCur >= 0) {
			this._curIdx := setCur
		}
		if (adjVal != 0 && (adjVal ~= '[+-]' || IsNumber(adjVal))) {
			this._curIdx += adjVal
		}
		if (IsNumber(setNext) && setNext >= 1){
			this._curIdx := setNext-1
		}
		; ensure valid index
		this._curIdx := max(this._curIdx, 0)
		this._curIdx := min(this._curIdx, this.Length)
	}
	;############################################################################
	; Public
	CurIndex => this._curIdx
	Length		=> this._lineArr.Length
	HasNext	=> this._curIdx < this.Length
	;############################################################################
	; Private
	__fillArray() {
		this._lineArr := StrSplit(this._origStr, '`n', '`r')
	}
}
;################################################################################
/**
 * Fix turning off OnMessage when OnMessage is turned off
 * before it is assigned a callback (by eg using functions)
 * 2025-10-05 AMB, MOVED/UPDATED - gCBPH - see MaskCode.ahk
 * 2025-10-10 AMB, UPDATED handling of trailing CRLFs
 * 2025-11-01 AMB, UPDATED to fix bug (after change made to gmOnMessageMap)
 */
FixOnMessage(ScriptString) {

	if (!InStr(ScriptString, gCBPH))
		Return ScriptString

	retScript := ""
	loop parse ScriptString, "`n", "`r" {
		Line := A_LoopField
		for i, v in gmOnMessageMap {
			cbFunc := v.cbFunc			; 2025-11-01 - gmOnMessageMap now holds object
			if (RegExMatch(Line, 'OnMessage\(\s*((?:0x)?\d+)\s*,\s*' gCBPH '\s*(?:,\s*\d+\s*)?\)', &match)) {
				Line := StrReplace(Line, gCBPH, cbFunc,, &OutputVarCount)
			}
		}
		retScript .= Line "`r`n"
	}
	retScript := RegExReplace(retScript,'\r\n$',,,1)
	retScript := RegExReplace(retScript, gCBPH '(.*)', '$1 `; V1toV2: Put callback to turn off in param 2')
	return retScript
}
;################################################################################
/**
 * Updates VarSetCapacity target var
 * &BufferObj -> BufferObj.Ptr
 * &VarSetStrCapacityObj -> StrPtr(VarSetStrCapacityObj)
 */
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk, ADDED masking for comments/strings
; 2025-10-10 AMB, UPDATED handling of trailing CRLFs, moved masking to FinalizeConvert()
FixVarSetCapacity(ScriptString) {
	; 2025-10-10 - masking now handled in FinalizeConvert()
	;Mask_T(&ScriptString, 'C&S')	; 2025-10-05 - fix issue with incorrectly adding .Ptr to V1ToV2 VarSetCapacity comments
	retScript := ""
	loop parse ScriptString, "`n", "`r" {
		Line := A_LoopField
		StrReplace(Line, "&",,, &ReplacementCount)
		Loop (ReplacementCount) {
			if (RegExMatch(Line, "(?<!VarSetStrCapacity\()(?<=\W)&(\w+)", &match))
				&& !RegExMatch(Line, "^\s*;") {
				for vName, vType in gmVarSetCapacityMap {
					if (vName = match[1]) {
						if (vType = "B")
							Line := StrReplace(Line, "&" match[1], match[1] ".Ptr")
						else if (vType = "V")
							Line := StrReplace(Line, "&" match[1], "StrPtr(" match[1] ")")
					}
				}
			}
		}
		retScript .= Line "`r`n"
	}
	retScript := RegExReplace(retScript,'\r\n$',,,1)
	return retScript
}
;################################################################################
/**
 * Updates ByRef params for all func declarations or calls
 * (Byref param) -->> (&param)
 */
/*
2025-10-05 AMB, MOVED/UPDATED to fix errors and missing line comments
2025-10-10 AMB, UPDATED handling of trailing CRLFs
2025-11-28 AMB, UPDATED to prevent ampersand from being added to numbers and THIS.X
2026-01-03 AMB, now supports obj.prop, multi-line, multiple calls on same line (nested or separated by comma)
NOTES:
 * watch for param-detection issues/errors when params have nested funcCalls (due to extra commas)...
	... ADDED funcCall masking - TODO - NEED TO ALSO CHECK THESE FOR BYREF PARAMS...
Known issues that may still remain
 * can conflict with converter-manufactured function/methods (or AHK funcCalls)
	... such as _Input/InputHook added methods [ .Start(), .Wait() ]
 * conflicts can arise between same-name funcs/methods (different scope)
 TODO
	* check nested func calls for nested Byref params
	* mask strings? (test to see if this is necessary)
	* mask all functions/classes and func calls first...
	* 	to assist with detection of declaration/blocks
	* 	to assist with controlling scope
*/
FixByRefParams(code) {
	sessID		:= clsMask.NewSession()													; start new masking session
	nObj		:= '(?i)^(.+\.)([_a-z]\w*)'												; needle to separate obj from method, if present
	While(pos	:= RegexMatch(code, gPtn_FuncCall, &mFD, pos??1)) {						; for each func declaration or call...
		oFunc	:= mFD[], params := mFD.FcParams, fName := mFD.fcName					; extract details
		objName := _extractfuncName(fName)												; separate obj from property, if fName is 'obj.prop'
		oName	:= objName.oName, fName := objName.fName								; obj and prop name, or just func name
		if (!gmByRefParamMap.Has(fName)) {												; if func is NOT a BYREF func...
			pos += StrLen(oName . fName)												; ... skip it (slide just past func name, not full func declare/call)
			continue
		}
		Mask_T(&params, 'FC',,sessID)													; 2025-10-05 AMB - mask any nested func calls within params
		brMapObj	:= gmByRefParamMap[fName]											; grab byref map obj for current func name
		rParam		:= ''																; ini, but not currently used - see optional usage below
		pos2		:= 1																; ini for each new func/call
		while (pos2 := RegExMatch(params, '(\h*)([^,]+)', &mParam, pos2)) {				; grab each param (between commas)
			if (A_Index > brMapObj.Length)												; if current param count exceeeds array length
				break																	; ... avoid errors (temp fix)
			oParam	:= mParam[]															; current (orig) param, WITH leading WS
			pLWS	:= mParam[1]														; preserve leading WS for current param
			cParam	:= mParam[2]														; current (clean) param - WITHOUT leading WS
			pTWS	:= ''																; preserve trailing WS for current param
			if (RegExMatch(cParam, '^(.+?)(\s*)$', &mWS2))								; if param has trailing WS (\s - support multiline CRLF!)...
				cParam := mWS2[1], pTWS := mWS2[2]										; ... separate any trailing WS from param
			tag		:= '', saveParam := cParam											; ini
			if (tag := hasTag(cParam, 'FC'))											; if current param has/is a nested func call...
				Mask_R(&cParam, 'FC',,sessID)											; ... restore the nested call
			if (saveParam = tag && isByRefFunc(cParam)) {								; if current param IS a nested BYREF func call...
				p := FixByRefParams(cParam)												; ... handle its BYREF params (use recursion)
				cParam := '&v2Param' A_index ':=' p										; ... use temp-VarRef to allow param to become ref param
			}
			else if (brMapObj[A_Index] && cParam ~= nObj) {								; if param is BYREF and is 'obj.prop'...
				tempParam	:= 'v2Param' A_Index										; ... create temp-VarRef param
				;rParam		:= " = (" cParam ':=' tempParam ')'							; ... optional reverse assignment (this will allow 'obj.prop' to be updated!!)
				cParam		:= '&' tempParam ':=' cParam								; ... apply temp-VarRef assignment to orig param
			}
			else if (brMapObj[A_Index]													; if current param is BYREF...
			 && !IsNumber(cParam)														; ... 2025-11-28 ADDED - and not a number...
			 && !InStr(cParam, 'THIS.')) {												; ... 2025-11-28 ADDED - and not this.X...  (just in case)
				cParam := '&' . RegExReplace(cParam,'i)^ByRef ')						; ...	update current param by adding &, remove ByRef
			}
			cParam		:= pLWS . cParam . pTWS											; update  current param with lead/trail WS
			;params		:= RegExReplace(params,escRegexChars(oParam),cParam,,1,pos2)	; replace current param with updated one
			params		:= StrReplaceAt(params,oParam,cParam,,pos2,1)					; replace current param with updated one
			pos2		+= StrLen(cParam)												; prep for next param search
		}
		outLine	:= oName . fName . '(' . params . ')' . rParam							; assemble final output for current func/Call
		;code	:= RegExReplace(code,escRegexChars(oFunc),outLine,,1,pos)				; replace orig func/call declaration/params with updated ones
		code	:= StrReplaceAt(code,oFunc,outLine,,pos,1)								; replace orig func/call declaration/params with updated ones
		pos		+= StrLen(outLine)														; prep for next func/call search
	}
	Mask_R(&code, 'FC',,sessID)															; restore any nested func calls
	return code																			; return updated code
	;############################################################################
	_extractfuncName(str) {																; if str is 'obj.prop', separate obj name from prop name
		local m := obn := '', fcn := str												; ini
		if (RegExMatch(str, nObj '$', &m))												; if str is actually obj.prop...
			obn := m[1], fcn := m[2]													; ... separate obj from prop
		return {oName:obn,fName:fcn}													; return result as object
	}
	;############################################################################
	isByRefFunc(str) {																	; determines whether str is a BYREF func
		local m,fcn := ''																; ini
		if (RegExMatch(str, gPtn_FuncCall, &m)) {										; if str is a func declaration or call...
			fcn := m.fcName, fcn := _extractfuncName(fcn).fName							; ... grab the func name
			return gmByRefParamMap.Has(fcn)												; ... return true if is BYREF func, false otherwise
		}
		return false																	; not a BYREF func
	}
}
;################################################################################
FixIncDec(ScriptString) {
; 2025-10-10 AMB, ADDED to cover issue #350 - invalid spaces with ++, --
; https://github.com/mmikeww/AHK-v2-script-converter/issues/350

	;Mask_T(&ScriptString, 'C&S')	; 2025-10-10 - now handled in FinalizeConvert()		; mask comments/strings to avoid interference
	nVar	:= '(?<!\+|-)(\b[a-z](?:[\w.]+\w)?\b)'										; variables
	nIncDec	:= '(\+\+|--)'																; ++ or --
	;nDet	:= '(?<=^|\W)(?<![+-])(?:\+\+|--)(?![+-])(?=\W|$)'							; detect only (can be used for msgs)
	nInc1	:= '(?i)' nVar '\h+'	nIncDec '(?!\w)',	repl1 := '$1$2'					; example 1 - remove ws between var and ++/--
	;nInc2	:= '(?i)(.*?)' nVar '(\h+)' nInc '((?2))(.*)', repl2 := '$1$5$4$3. $2$6'	; example 2 - reorder, not same output as v1
	nInc2	:= '(?i)' nVar '(\h+)'	nIncDec '([a-z])',	repl2 := '$1$3$2. $4'			; example 2 - remove space, add concat, same output as v1
	retStr	:= ''																		; will be output
	for idx, line in StrSplit(ScriptString, '`n', '`r') {								; for each line in script...
		pos		  := 1
		While(pos := RegexMatch(line,nInc2, &m, pos)) {									; look for each occurence of example 2 on cur line
			line  := RegExReplace(line, nInc2, repl2,,1,pos)							; handle example 2 of issue #350
			pos   += StrLen(repl2)														; prep for next search on same line
		}
		pos		  := 1
		While(pos := RegexMatch(line,nInc1, &m, pos)) {									; look for each occurence of example 1 on cur line
			line  := RegExReplace(line, nInc1, repl1,,1,pos)							; handle example 1 of issue #350
			pos   += StrLen(repl1)														; prep for next search on same line
		}
		retStr	  .= line . '`r`n'														; update output str with current line
	}
	retStr		  := RegExReplace(retStr,'\r\n$',,,1)									; remove last CRLF from output
	return retStr																		; return output
}
;################################################################################
updateFileOpenProps(&code) {
; 2025-10-12 AMB, ADDED - to address issue #358
; https://github.com/mmikeww/AHK-v2-script-converter/issues/358
; see V1toV2_Functions() for filling gaFileOpenVars[] with obj/var names
; currently does not consider scope, and is more of a temp band-aid for now
; a better solution can be designed later, to support other obj types/props as well

	for idx, obj in gaFileOpenVars {
		code := RegExReplace(code, '(?i)' obj '\.__handle',					obj '.Handle')
		code := RegExReplace(code, '(?i)' obj '\.tell\(\)',					obj '.Pos')
		code := RegExReplace(code, '(?i)' obj '\.pos(?:ition)?\((\d+)\)',	obj '.Pos := $1')
		code := RegExReplace(code, '(?i)' obj '\.position(?!\()',			obj '.Pos')
	}
}
;################################################################################
; check if a param is empty
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
IsEmpty(param) {
	; if its an empty string, or a string containing two double quotes
	if (param = '') || (param = '""')
		return true
	return false
}
;################################################################################
; change		"text" -> text
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
RemoveSurroundingQuotes(text) {
	if (SubStr(text, 1, 1) = "`"") && (SubStr(text, -1) = "`"")
		return SubStr(text, 2, -1)
	return text
}
;################################################################################
; change		%text% -> text
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk
RemoveSurroundingPercents(text)
{
	if (SubStr(text, 1, 1) = "%") && (SubStr(text, -1) = "%")
		return SubStr(text, 2, -1)
	return text
}