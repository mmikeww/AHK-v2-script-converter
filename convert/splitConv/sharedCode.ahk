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
; 2025-10-05 AMB, UPDATED - nSep1LC - move needle to MaskCode.ahk

	nSep1LC		:= buildPtn_Sep1LC()							; separation needle (see MaskCode.ahk)
	comment		:= ''											; ini, in case of no comment
	if (RegExMatch(line, nSep1LC, &m)) {						; see MaskCode.ahk for needle
		line	:= m.ln											; 'command' side (if present), supports `;
		comment	:= m.lc											;  comment - captures FIRST occurence
	}
	return	line
}
;################################################################################
								   separateTrailCWS(srcStr, &trail, incHIF:=true)
;################################################################################
{
; 2025-10-05 AMB, ADDED
;	separates trailing comments and whitespace from srcStr

	tags	:= 'LC|BC|QS'
	tags	.= (incHIF) ? '|HIF' : ''
	nTag	:= '(?<=^)\h*' uniqueTag('(?:' tags ')\w++') '.*'		; [tag for comments or quoted string]
	nLC		:= '(?:(?<=^)|(?<=^)\h+)(?<!``);[^\v]*+'				; [line comment]
	nSep	:= '(?m)((?:\v+|' nTag '|' nLC ')++)$'					; will separate relevant portion from trailing comments/tags/ws
	trail	:= ''													; ini, in case nothing to separate
	if (RegExMatch(srcStr, nSep, &m)) {								; separate trailing comments/tags/ws from srcStr
		trail	:= m[1]												; returns trailing comments/tags/ws (via reference)
		srcStr	:= RegExReplace(srcStr, escRegexChars(trail) '$')	; removes trailing comments/tags/ws from srcStr
	}
	return srcStr													; return resulting srcStr, trimmed or not
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
 */
FixOnMessage(ScriptString) {

	if (!InStr(ScriptString, gCBPH))
		Return ScriptString

	tCRLF := ''
	if (RegExMatch(ScriptString, '.*(\R+)$', &m)) {
		tCRLF := m[1]	; preserve any trailing CRLFs that code came with
	}
	retScript := ""
	loop parse ScriptString, "`n", "`r" {
		Line := A_LoopField
		for i, v in gmOnMessageMap {
			if (RegExMatch(Line, 'OnMessage\(\s*((?:0x)?\d+)\s*,\s*' gCBPH '\s*(?:,\s*\d+\s*)?\)', &match)) {
				Line := StrReplace(Line, gCBPH, v,, &OutputVarCount)
			}
		}
		retScript .= Line "`r`n"
	}
	retScript := RegExReplace(retScript, gCBPH '(.*)', '$1 `; V1toV2: Put callback to turn off in param 2')
	return RTrim(retScript, "`r`n") . tCRLF	; preserve any trailing CRLFs that code came with
}
;################################################################################
/**
 * Updates VarSetCapacity target var
 * &BufferObj -> BufferObj.Ptr
 * &VarSetStrCapacityObj -> StrPtr(VarSetStrCapacityObj)
 */
; 2025-10-05 AMB, MOVED from ConvertFuncs.ahk, ADDED masking for comments/strings
FixVarSetCapacity(ScriptString) {
	tCRLF := ''
	if (RegExMatch(ScriptString, '.*(\R+)$', &m)) {
		tCRLF := m[1]	; preserve any trailing CRLFs that code came with
	}
	Mask_T(&ScriptString, 'C&S')	; 2025-10-05 - fix issue with incorrectly adding .Ptr to V1ToV2 VarSetCapacity comments
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
	Mask_R(&retScript, 'C&S')
	retScript := RTrim(retScript, "`r`n") . tCRLF		; preserve any trailing CRLFs that code came with
	return retScript
}
;################################################################################
/**
 * Finds function calls with ByRef params
 * and appends an &
 */
/*
2025-10-05 AMB - MOVED/UPDATED to fix errors and missing line comments
	* param-detection issues/errors when params contain funcCalls (due to extra commas)
		ADDED funcCall masking - TODO - test to verify full resolution...
 Known issues that still remain
	* can conflict with converter-manufactured function/methods (or AHK funcCalls)
		... such as _Input/InputHook added methods [ .Start(), .Wait() ]
	* conflicts can arise between same-name funcs/methods (different scope)
	* adds & to &this.func(param)
 TODO
	* mask strings? (test to see if this is necessary)
	* mask all functions/classes and func calls first...
	* 	to assist with detection of declaration/blocks
	* 	to include continuation sections
	* 	to assist with controlling scope
*/
FixByRefParams(ScriptString) {

	tCRLF := ''
	if (RegExMatch(ScriptString, '.*(\R+)$', &m)) {
		tCRLF := m[1]																	; preserve any trailing CRLFs that code came with
	}
	retScript	:= ''																	; ini return string
	maskSessID	:= clsMask.NewSession()													; 2025-10-05 - establish an isolated mask session
	loop parse ScriptString, '`n', '`r' {												; for each line...
		fReplaced	:= false
		Line		:= separateComment(A_LoopField, &EOLComment:='')					; 2025-10-05 AMB, fix missing line comments
		for fName, v in gmByRefParamMap {												; for each byRef entry in map...
			needle := '(?m)^(.*?)\b\Q' fName '\E\b' gPtn_PrnthBlk '(.*)$'				; 2025-10-05 [detect function calls and declarations?]
			if (RegExMatch(Line, needle, &mFD)
				&& !InStr(Line, '&')) {													; if line not already converted? (might req string masking)
				newLine	:= mFD[1] fName '('												; beginning of line, including func name and open parenthesis
				params	:= mFD.FcParams													; params inside parentheses
				trail	:= mFD[4]														; trailing portion of line
				pTWS	:= ''															; will preserve trailing whitspace for next param
				Mask_T(&params, 'FC',,maskSessID)										; 2025-10-05 AMB - mask any func calls within params
				fParamCountError := false												; ini error flag
				while (pos := RegExMatch(params, '(\h*)([^,]+)', &mParams)) {			; grab each param (between commas)
					pLWS		:= mParams[1]											; preserve leading whitespace for current param
					curParam	:= mParams[2]											; current parameter
					if (RegExMatch(curParam, '^(.+?)(\h*)$', &mWS2)) {					; if param has trailing WS...
						curParam := mWS2[1], pTWS := mWS2[2]							; ... separate any trailing WS from param
					}
					if (A_Index > v.Length) {											; detect false-positives (not fool-proof) and avoid errors
						fParamCountError := true										; will prevent any replacement in current line
						break
					}
					if (v[A_Index]) {													; if current param is BYREF...
						curParam := '&' . RegExReplace(LTrim(curParam),'i)^ByRef ')		; update current param by adding &, remove ByRef
					}
					newLine .= pLWS . curParam . pTWS . ','								; add updated param to updated line
					params	:= StrReplace(params, mParams[],,,,1)						; remove current param from param list (prep for next search)
				}
				newLine		:= RTrim(newLine, ', ') . pTWS . ')' . trail				; finalize newly-created line
				fReplaced	:= !fParamCountError										; flag for retScript update below
			}
		}
		retScript .= ((fReplaced) ? newLine : Line) . EOLComment . '`r`n'				; update return string with updated line
	}
	Mask_R(&retScript, 'FC',,maskSessID)												; 2025-10-05 restore any func calls found in param lists
	return RTrim(retScript, '`r`n') . tCRLF												; preserve any trailing CRLFs that code came with
}
;################################################################################
FixIncDec(ScriptString) {
; 2025-10-10 AMB, ADDED to cover issue #350 - invalid spaces with ++, --
; https://github.com/mmikeww/AHK-v2-script-converter/issues/350

	Mask_T(&ScriptString, 'C&S')														; mask comments/strings to avoid interference
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