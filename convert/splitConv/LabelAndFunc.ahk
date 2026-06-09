;################################################################################
; 2025-10-05 Added LabelAndFunc.ahk to organize support/conversion/interaction of...
;	LBL,HK,HS,Func/Class
; 2026-05-04 AMB, UPDATED to merge common code with Scope.ahk
;################################################################################
; class clsLabelSect
; To support new structure for labels, hotkeys, hotstrings, and...
;	the interaction between them, global-scope-code, and funcs
; The goal of this class is to organize individual LBLs/HKs/HSs,
;	their code-blocks, and the logic flow between them
; Original Funcs/Classes are not a main focus for this class (only as necessary)
; This class separates the original code into sections/chunks. The borders of...
;	... these sections occur where LBL/HK/HS/FUNC/CLS/GLOBAl-CODE meet.
;	Each section holds the code associated with one of those section types.
; 2025-10-05 AMB, ADDED
; 2026-05-04 AMB, UPDATED - changed class name, merged some code with Scope.ahk
class clsLabelSect
{
	Static Sects			:= []															; array to hold section objects
	Static ToFunc			:= Map_I()														; map to hold all newly created funcs (strings)
	Static codeTop			:= ''															; code that occurs before any LBL/HK/HS/FUNC/CLS
	Static codeBot			:= ''															; code that occurs after  all LBL/HK/HS/FUNC/CLS sections
	Static LogicFlowStr		:= ''															; string that holds logic-links between sections
	Static HKFuncCnt		:= 0															; counter for creating unique func names, from HKs
	Static NextHKCnt		=> ++this.HKFuncCnt												; returns next value for HKFuncCnt
	Static HasSects			=> (this.Sects.Length > 0)										; does code have any sections at all? (convenience)
	Static SectsStr			=> this._buildSectStr											; final output (convenience)

	;############################################################################
	Static Reset()																			; resets static props (needed for UNIT TESTING)
	{
		this.Sects			:= []
		this.ToFunc			:= Map_I()
		this.codeTop		:= ''
		this.codeBot		:= ''
		this.LogicFlowStr	:= ''
		this.HKFuncCnt		:= 0
	}
	;############################################################################
	; 2026-06-07 AMB, UPDATED to guarantee sections have CRLF between them
	Static _buildSectStr																	; assembles all (final) section strings into single string
	{
		get {
			outStr := L_CRLF := T_CRLF := PT_CRLF := ''										; ini (CRLF - lead, trail, prev trail)
			for idx, sect in this.Sects {													; for each section in list
				curStr := sect.GetSectStr													; get current sect string
				; is CRLF at either end of current section str?
				RegExReplace(curStr, '^\R',, &L_CRLF)										; determine whether lead  CRLF is present for current str
				RegExReplace(curStr, '\R$',, &T_CRLF)										; determine whether trail CRLF is present for current str
				; decide whether lead CRLF will be needed or not
				CRLF := ''																	; ini current CRLF as empty
				if (idx > 1																	; if this is NOT first section...
				&& (!(PT_CRLF||L_CRLF))) {													; ... AND BOTH, prev trail CRLF, and cur lead CRLF are empty...
					CRLF	:= '`r`n'														; ...	add a lead CRLF   for current str
					curStr	:= LTrim(curStr, ' \t')											; ... 	trim lead horz WS for current str
				}
				; update output str
				outStr	.= CRLF . curStr													; add cur string to output, including lead CRLF as needed
				PT_CRLF	:= T_CRLF															; save cur trail CRLF for check during next pass
			}
			return outStr																	; return final output
		}
	}
	;############################################################################
	Static SectionObj[lblName]																; returns sect obj associated with lblName param
	{
		get {
			for idx, sect in this.Sects {													; look thru array list...
				if (sect.LabelName = lblName) {												; if current sect obj is for lblName...
					return {idx:idx,sect:sect}												; return the idx and sect obj
				}
			}
			return false																	; no entry was found for lblName
		}
	}
	;############################################################################
	Static uHKFcName[hkStr]																	; creates unique func name from HK trigger
	{
		get {
			if (!Trim(hkStr))																; if hkStr is empty...
				return ''																	; ... return empty
			hkName := ''																	; ini
			if (RegExMatch(hkStr, '(?i)[^a-z]*(\w+.*)', &m))								; extract just the alphaNumeric portion of trigger
				hkName := RegExReplace(m[1], '\h+', '_')									; replace ws with underscore
			unique := 'HK' . this.NextHKCnt . '_'											; HK prefix and unique counter
			return unique RTrim(validV2LabelName(hkName ':'), ':')							; return unique func name
		}
	}
	;############################################################################
	; 2026-01-01 AMB, UPDATED - added 'Unreachable' directive
	; 2026-05-04 AMB, UPDATED - now fills sects array using external scope class
	; 2026-05-26 AMB, UPDATED - as part of fix for #488

		/*
		1. separate code into sections
			each section will be one of the following [GLOBAL,LBL,HK,HS,CLS,FUNC]
			there will also be a top section, and trailing code section
		2. if ANY lbls will be converted to func...
			plan to convert ALL labels to func, but also keep orig labels intact
			a. convert multi-line HKs to func, and move these funcs below global code
				call HK funcs using same-line func calls
				leave orig same-line HKs as is
				leave orig pass-thru HKs as is
			b. convert multi-line HSs to func, but don't move code
				leave orig same-line HSs as is
				leave orig pass-thru HSs as is
			c. stray global code between LBL,HK,HS,CLS,FUNC...
				will be converted to new lbls/funcs
			d. logic flow between sections...
				will be extracted and stored in a single string
				logic flow (and gosubs) between lbl/HK funcs...
					will be controlled using chained func calls, added to new funcs
				global goto calls will be controlled as normal
			e. label/func naming conflicts will be addressed, as needed
		3. if NO lbls will be converted to func...
			code will not be rearranged
			multi-line HKs/HSs will have braces added, but not be moved
			logic flow will behave normally ?
			no change to stray global code
		4. Orig funcs/classes will not be changed, except...
			update func params for v2 compatibility, as needed
		*/
	Static Main_ProcessSects(code)															; Main operation for this class
	{
		Mask_T(&code, 'MLPBT')																; 2026-05-26, AMB - part of fix for #488
		this._getSects(&code)																; divide code into sections, get section list
		this._organizeSects(&code)															; determine logic flow, create funcs, rearrange code as necessary
		this._finalizeCode(&code)															; update goto/gosub/funcs, remove masking, finalize code
		Mask_R(&code, 'MLPBT')																; 2026-05-26, AMB - part of fix for #488
		return code																			; return updated script code
	}
	;############################################################################
	Static _getSects(&code)																	; divides code into sects, fills sects array
	{																						;	each sect is one of [GLOBAL,LBL,HK,HS,CLS,FUNC]
		this.Reset()																		; resets static vars - required when performing bulk/unit testing
		oSectList	 := clsLFSectList(&code,1)												; create section list obj
		this.Sects	 := oSectList.Sects														; extract sect list
		this.codeTop := oSectList.codeTop													; transfer code top section
		this.codeBot := oSectList.codeBot													; transfer code bottom section
	}
	;############################################################################
	Static _organizeSects(&code)
	{
		newFuncList	:= ''																	; ini
		if (this.HasSects) {																; if sections were established...
			flowStr		:= this._logicFlow													; determine logic flow between sections
			dummy		:= this._hkhsToFunc()												; convert HK/HS to funcs (will be added in next step)
			newFuncList	:= this._buildFuncsList()											; string with all new funcs, to be added to lower portion of script
			lowerSect	:= separateTrailCWS(this.codeBot, &TCWS:='', false)					; extracts trailing comments/CRLFs so they remain at bottom of script
			code := this.codeTop . this.SectsStr . lowerSect . newFuncList . TCWS			; assemble new script-code format
		}
	}
	;############################################################################
	Static _finalizeCode(&code)
	{
		code := this._updateLblToFuncs(code)												; adds v2 formatting to new label funcs
		code := this._gotoToFC_orig(code)													; converts goto to funcCalls as needed (for orig script funcs only)
;		if (gMicroScopeTest) {
;			return
;		}

		code := clsCodeChop.RestoreMasksAll(code)											; removes temp-masking, performs cleanup of script code
		code := this._gosubUpdate(code)														; update Gosub calls (to reflect changes made here, and fix issue #322)
		(gHasV2Funcs) && code := '#Warn Unreachable, Off`r`n' . code						; add warning if labels were converted to funcs
	}
	;############################################################################
	Static _addWildcardParam(sect)															; adds wildcard param to func declaration
	{
		funcCode := sect.Line1																; grab func tag from line 1
		Mask_R(&funcCode, 'CLS&FUNC',,, false)												; extract orig func code from tag
		if (RegExMatch(funcCode, gPtn_Blk_FUNC, &m)											; [use func needle to extract declaration details]
			&& !m.Args) {																	; if func params are empty...
			funcCode := RegExReplace(funcCode												; ... add wildcard param (*)
						, m.FName . '\(\h*\)'												; TODO - MIGHT NEED TO HANDLE APPEND WILDCARD ALSO
						, m.FName . '(*)'  )												; replace empty params with wildcard
			return funcCode																	; return updated func string (that has wildcard param)
		}
		return ''																			; flag unsuccessful (should not happen)
	}
	;############################################################################
	; 2026-03-29 AMB, UPDATED to add global gHasV2Funcs
	Static _buildFuncsList()																; gathers all new funcs into single string
	{
		if (!funcListStr := this._makeFuncsStr())											; if funcListStr creation is NOT successful...
			return ''																		; ... return empty str
		div			:= StrReplace(Format('{:15}',''),' ','#')								; generic divider
		divLine		:= '`r`n`r`n`;' div '  V1toV2 FUNCS  ' div								; mark very top of func list
		global		gHasV2Funcs := true														; 2026-03-29 ADDED
		return		divLine . funcListStr													; return func list string
	}
	;############################################################################
	; Goto Label -> label()... for labels converted to funcs
	;	targets gotos within orig func/cls ONLY, not global Goto's or those in new funcs
	Static _gotoToFC_orig(code)																; replaces Goto calls with func calls (within ORIG funcs only)
	{
		nTag	:= '(?im)' uniqueTag('(?:BLKFUNC|BLKCLS)\w+')								; target masked (orig) funcs/classes only
		nGoto	:= '(?im)^(?<lws>\h*)(?<gt>GOTO' gPtn_PrnthBlk ')(?<trl>.*)'				; targets V2 Goto call (entire line)
		While (cfPos := RegexMatch(code, nTag, &mTag, cfPos??1)) {							; find each masked cls/func within source code...
			tag	:= mTag[], oCode := tag, Mask_R(&oCode, 'CLS&FUNC')							; get mask tag, and orig code from that tag
			gPos:= 1, fUpdated := false														; ini before searching each cls/func
			while (gPos := RegExMatch(oCode, nGoto, &m, gPos)) {							; find each  Goto line within current cls/func...
				line		:= m[], LWS := m.lws, trail := m.trl ;, mgoto := m.gt 			; sub-divide Goto line
				lblStr		:= m.FcParams, Mask_R(&lblStr, 'STR')							; extract label being called, unmask it
				labelName	:= Trim(lblStr, '"')											; remove double-quotes surrounding label name
				curLine		:= line															; ini, in case no update is performed
				if (this.ToFunc.Has(labelName)) {											; was current label converted to func?
					curLine	:= LWS . labelName '() `; V1toV2: Goto->FuncCall' . trail		; reformat line as a funcCall, instead of Goto
					oCode	:= RegExReplace(oCode, escregexchars(line), curLine,,1,gPos)	; replace cur Goto line with new FuncCall line
					fUpdated:= true															; flag to signal that change was made
				}
				gPos += StrLen(curLine)														; prep for next Goto search
			}
			if (fUpdated) {																	; if Goto was replaced with FuncCall...
				code := RegExReplace(code, tag, oCode), cfPos += StrLen(oCode)				; ... update orig source code with change
			} else {																		; no change was made in last cls/func...
				cfPos += StrLen(tag)														; ... prep for next cls/func tag search
			}
		}
		return code																			; return updated code
	}
	;############################################################################
	; Goto Label -> label()... for labels converted to funcs
	;	targets gotos within newly created funcs ONLY
	Static _gotoToFC_new(code)																; replaces Goto calls with func calls (within NEW funcs only)
	{
		needle := '(?im)^(?<lws>\h*)(?<gt>GOTO' gPtn_PrnthBlk ')(?<trl>.*)'					; targets V2 Goto call (entire line)
		While(pos := RegExMatch(code, needle, &m, pos??1)) {								; for each Goto call...
			line		:= m[], LWS := m.lws, trail := m.trl ;, mgoto := m.gt 				; sub-divide Goto line
			lblStr		:= m.FcParams, Mask_R(&lblStr, 'STR')								; extract label being called, unmask it
			labelName	:= Trim(lblStr, '"')												; remove surrounding quotes from label name
			curLine		:= line																; ini, in case no update is performed
			if (sectObj	:= this.SectionObj[labelName]) {									; get label obj for label being called
				funcName	:= sectObj.sect.FuncName										; get funcname for label (if name has changed)
				curLine		:= LWS . funcName . '() `; V1toV2: Goto->FuncCall' . trail		; reformat line as a funcCall, instead of Goto
				code		:= RegExReplace(code, escRegexChars(line), curLine,,1,pos)		; replace cur Goto line with new FuncCall line
			}
			pos += StrLen(curLine)															; prep for next search, if there are more than 1
		}
		return code																			; return code with changes, if applied
	}
	;############################################################################
	; 2025-11-01 AMB, UPDATED key case-sensitivity for gmList_GosubToFunc
	Static _gosubUpdate(code)																; handles v1 Gosub to v2 funcCall conversion
	{

		Mask_T(&code, 'C&S')																; mask comments/strings (since src code has already been restored)
		outStr := ''																		; ini output
		nGosub := '(?i)(GOSUB\h+)([^\s]+)(.*)'												; gosub needle [only supports changes made in _Gosub()]
		for idx, line in StrSplit(code, '`n', '`r') {										; for each line in script...
			if (pos := InStr(line, 'gosub')) {												; get position of Gosub call, if present
				leftStr := SubStr(line, 1, pos-1)											; capture characters before Gosub
				if (RegExMatch(line, nGosub, &m, pos)) {									; capture	Gosub call details
					GS := m[1], Lbl := m[2], trail := m[3]									; save		Gosub call details
					if (gmList_GosubToFunc.Has(Lbl)) {										; if label was recorded in _Gosub()...
						if (obj := this.SectionObj[Lbl]) {									; ... if object is avail for label
							funcName:= obj.sect.FuncName									; ...	get func name (may be different than labelname)
							msg		:= ' `; V1toV2: Gosub'									; ...	[conv msg to user]
							line	:= leftStr . funcName . '()' . msg . trail				; ...	replace Gosub call with func call
						}
						else {																; ... UNKNOWN label - probably not global (located in a func maybe?)
							msg		:= ' `; V1toV2: Gosub (Manual edit required)'			; ... 	flag Gosub call as a manual edit
							line	:= leftStr . GS . Lbl . msg . trail						; ...	add msg to Gosub call
						}
					}
				}
			}
			outStr .= line . '`r`n'															; add current line to output, whether changes were made or not
		}
		outStr := RegExReplace(outStr, '\r\n$',,,1)											; remove last (extra) CRLF from output
		Mask_R(&outStr, 'C&S')																; restore comments/strings
		return outStr																		; return output
	}
	;############################################################################
	static _hkhsToFunc()																	; deals with HK,HS 'labels'
	{
		wcFuncsToUpdate := Map_I()															; used to track named-blocks for HKs (for adding wildcard param)

		; convert HK/HS to func as needed
		for idx, sect in this.Sects {

			isBrcBlk := false																; ini flag for each section
			;####################################################################
			; first, weed out situations to skip
			if (sect.tType = 'BLKFUNC') {													; if section is a func (tag)...
				if (wcFuncsToUpdate.Has(sect.Tag)											; ... if that func requires wildcard param...
				&& funcCode := this._addWildcardParam(sect))								; ... AND the param is successfully added...
					sect.Line1 := funcCode													; ...	update line 1 to include wildcard param
				continue																	; ... continue to next section
			}
			else if (!(sect.tType ~= '(?i)HK|HS')) {										; if not HK/HS (is label)...
				continue																	; ... skip it, goto next section
			}
			else if (sect.tType = 'HK' && sect.HasCaller) {									; if is HK and has a caller (gosub, goto)
				; allow bypass, to HK checks below											; ... drop to HK checks below (support for Issue #322)
			}
			else if (sect.L1.cmd) {															; if cmd on same line as HK/HS...
				continue																	; ... skip it, goto next section
			}
			else if (blkDetails := isBraceBlock(sect.Blk)) {								; if already has brace-blk...
				isBrcBlk := true															; ... flag as a brace-block and allow checks below
				;continue																	; ... skip it, goto next section
			}
			else if (idx < this.Sects.length && !sect.Blk) {								; [if no cmd on line 1], and has no code block...
				nextSect := this.sects[idx+1]												; ... get next section
				nextType := nextSect.tType													; ... get next section type
				if (nextType ~= '(?i)HK|HS') {												; if next section is also HK/HS...
					sect.FuncStr := 'SKIP'													; ... flag it so NO func is created later
					continue																; ... is pass-thru... skip it, goto next section
				}
				else if (nextType = 'BLKFUNC') {											; if next section is a func...
					wcFuncsToUpdate[nextSect.Tag] := sect.LabelName							; ... flag func (tag) to be updated with new wildcard param
					sect.FuncName := nextSect.LabelName										; ... update funcName for current sect so it points to named-func
					continue																; ... continue to next section
				}
			}
			;####################################################################
			; handle HK/HS situations
			lblName	 := sect.LabelName														; get HK/HS declaration
			; HotStrings
			if (sect.tType = 'HS'															; if is HS...
				&& !isBrcBlk && sect.Blk)		{											; ... AND NOT a brace-block, but has code to execute...
					uniqStr	 := ' for [' trim(lblName) ']'									; ... include HS trigger in msg...
					sect.Blk := sect._addBraces(uniqStr)									; ... surround code-block with braces (convert to func)
					continue
			}
			; HotKeys
			if (sect.tType = 'HK'															; if is HK... (support for Issue #322)
				&& sect.L1.cmd																; ... AND has cmd on Line1
				&& sect.HasCaller)				{											; ... AND HK has a caller (gosub,goto)
					sect.HK_1LineToML()														; ...	convert single line HK to multi-line HK
					this._makeFuncHK(&sect)													; ...	convert HK to func (will be moved below global code)
					continue
			}
			nextLink := this._nextLogicLink(lblName)										; get next link in logic-chain
			if (sect.tType = 'HK'															; if is HK
				&& !isBrcBlk																; ... AND NOT a brace-block...
				&& (sect.Blk || nextLink))		{											; ... AND has code to execute OR will execute code elsewhere...
					if (scriptHasL2F())			{											; ... if ANY labels will be converted to func...
						this._makeFuncHK(&sect)												; ...	convert HK to func (will be moved below global code)
					}																		;		[will be added to script in _makeFuncsStr()]
					else						{											; ... NO labels will be converted to func, so...
						uniqStr	 := ' for [' trim(lblName) ']'								; ... 	[include HK trigger in msg]
						sect.Blk := sect._addBraces(uniqStr)								; ... 	surround code-block with braces, but don't move it
					}
					continue
			}
			; 2026-06-07 AMB, ADDED to simulate v1 logic flow for brace-blocks				; allowing logic flow beyond the brace-block
			if (sect.tType ~= '(?i)HK|LBL'													; if is HK or LBL...
				&& isBrcBlk																	; ... AND IS brace-block...
				&& nextLink && sect.AllowBridge){											; ... AND nextLink is avail and AllowBridge is set...
					sect.BridgeLogicFlow(nextLink)											; ...	allow code execution to extend beyond brace-block
			}
		}
	}
	;############################################################################
	Static _labelFromTag(tag)																; extracts label name from a masked tag
	{	; TODO - add tag validation

		origStr	:= clsMask.GetOrig[tag]														; get orig code from tag
		return	getV1Label(origStr,0)														; extract/return label name
	}
	;############################################################################
	Static _logicFlow																		; extracts logic flow between LBL/HK/HS/FUNC/CLS/Global code
	{
		get {
			if (this.LogicFlowStr) {
				return this.LogicFlowStr													; only need to process once
			}
			pChar	:= gPauseChar	; ⟼													; char for flowStr - pause, execute code, then continue
			jChar	:= gJumpChar	; ⟹													; char for flowStr - pass thru (jump - has no code)
			xChar	:= gExitChar	; ✖													; char for flowStr - has exit cmd (link concluded)
			flowStr	:= ''																	; [working/output var]
			if (this.sects.Length = 1) {													; if there is only 1 section...
				this.LogicFlowStr := this.sects[1].LabelName								; ... add that section...
				return this.LogicFlowStr													; ... exit early
			}
			for idx, curSect in this.sects {												; for each section...
				if (!(curSect.tType ~= '(?i)(?:HK|HS|LBL|GBL)')) {							; if cur section is Not HK,HS,LBL,GBL...
					continue																; ... skip it (probably FUNC/CLS)
				}
				curLabel := curSect.LabelName												; capture name of current section
				if (idx = this.sects.Length) {												; if is last section...
					flowStr .= curLabel														; ... add section and stop
					break																	; ... no more links to process
				}
				if (curSect.HasExit) {														; if current section HAS exit cmd (or single line HK/HS)...
					flowStr .= curLabel xChar		; ✖									; ... mark section as terminated (not a pass-thru)
					continue																; ... proceed to next section
				}
				; current section has NO EXIT												; what does it pass-thru to?
				; get next section that is NOT a function									; [will determine where next logical stop is]
				offset := 1																	; used to bypass funcs that breakup flow
				while(true) {																; go thru array looking for next HK/HS/LBL (bypass funcs)
					if (idx+offset > this.sects.Length)										; if reached end of array...
						break																; ... all done
					nextSect := this.sects[idx+offset]										; get next section object (offset allows bypass of funcs)
					if (nextSect.tType = 'HS') {											; if next section is HS...
						flowStr .= curLabel xChar	; ✖									; ... mark HS as terminated (not a pass-thru)
						break																; ... goto next section
					}
					if (curSect.tType = 'HK'												; if current section is HK...
						&& !curSect.Blk														; ... and HK has NO code to execute
						&& nextSect.tType ~= '(?i)FUNC') {									; ... and next sect is a func...
						flowStr .= curLabel xChar	; ✖									; ... mark HK as terminated (has named func)
						break																; ... goto next section
					}
					if (curSect.tType = 'HK'												; if current section is HK...
						&& curSect.Blk														; ... and HK has code to execute [but no exit cmd]...
						&& nextSect.tType = 'HK') {											; ... and next sect is also HK
						flowStr .= curLabel xChar	; ✖									; ... mark cur HK as terminated (not a pass-thru)
						break																; ... goto next section
					}
					if (curSect.tType = 'HK'												; if current section is HK
						&& curSect.Blk														; ... and HK has code to execute [but no exit cmd]...
						&& nextSect.tType = 'LBL') {										; ... and next sect is a LBL
						flowStr .= curLabel pChar	; ⟼									; ... mark HK as pause, exec, continue
						break																; ... goto next section
					}
					if (curSect.tType = 'LBL'												; if current section is a label
						&& curSect.Blk) {													; ... and LBL has code to execute [but no exit cmd]...
						flowStr .= curLabel pChar	; ⟼									; ... mark LBL as pause, exec, continue
						break																; ... goto next section
					}
					; ADD MORE TERMINTION CHECKS AS NEEDED

					; Any other scenario for next section... catch all
					if (nextSect.tType ~= '(?i)(?:HK|HS|LBL)'){								; if next section is a lBL/HK/HS...
						flowStr .= curLabel . jChar	; ⟹									; ... marks section as pass-thru (jump over)
						break																; ... goto next section
					} else {																; next section is not LBL/HK/HS (probably a func)...
						offset++															; ... bypass it, and keep searching for "next" lBL/HK/HS
					}
				}
			}
			;MsgBox "[" flowStr "]"
			this.LogicFlowStr := flowStr													; save results as var shortcut
			return this.LogicFlowStr														; return link-tracking string
		}
	}
	;############################################################################
	; 2026-03-29 AMB, UPDATED: to fix missing indent
	Static _makeFuncHK(&sect)																; creates BrcBlk/func (and funcCall) from HK code, as needed
	{
		if (sect.tType != 'HK'																; if not a HK...
		||  sect.L1.cmd) {																	; ... OR HK has cmd on its own line...
			return ''																		; ... no processing req here
		}

		nextLink := this._nextLogicLink(sect.LabelName)										; get next link in logic-chain after this one (if present)
		if (!sect.Blk && !nextLink) {														; if HK has no block/body, and no next-link...
			return ''																		; ... no change/func required
		}

		outFunc	:= ''																		; ini output
		blk		:= sect.Blk, blk := clsCodeChop.RestoreMasksAll(blk)						; get current block/body, and restore its orig code
		Mask_T(&blk, 'C&S')																	; ... but we need comments/strings masked
		lblName	:= sect.LabelName															; get HK trigger str
		convMsg	:= ' `; V1toV2: HK->Func'													; msg to user about new func creation

		; does HK block/body already have braces?
		if (bbObj := isBraceBlock(blk)) {													; if body already has braces...
			blk			:= bbObj.bbc														; extract just the guts of that body (without braces)
			indent		:= RegExReplace(Trim(blk,'`r`n'), '(?s)^(\h*).*', '$1')				; get block indent
			blk			:= indent '`;global' blk											; add global keyword, but comment out (will be used as landmark later)
			funcName	:= getV2Name(lblName)												; v2 func name
			func_DnC	:= funcName '()'													; create func declaration/call, with no params
			sect.Line1	:= sect.L1.LWS sect.L1.decl func_DnC sect.L1.TC						; add any ws and trailing comments to func call for HK line
			outFunc		:= func_DnC bbObj.TCT '{' convMsg '`r`n' blk '}'					; create entire func
			this.ToFunc[funcName] := outFunc												; add func to funclist, using funcname as key
			sect.FuncStr:= outFunc															; add func to HK obj so it can be added to code later
			sect.Blk	:= ''																; remove HK code-body from obj
			return		outFunc																; return the new func (if needed by caller and to flag success)
		}

		; body does not (already) have braces
		blk		:= this._gotoToFC_new(blk)													; convert any Goto within HK code-block to funcCall
		indent	:= RegExReplace(Trim(blk,'`r`n'), '(?s)^(\h*).*', '$1')						; get block indent
		blk		:= indent 'global' blk														; add global keyword to beginning of body/blk
		if (nextLink && !sect._xCmd) {														; if there is a next-logic-link, and no exit command...
			if (nxSect := this.SectionObj[nextLink]) {										; ... get the section obj for the next link
				RegExReplace(blk, '\R$',,&cnt), CRLF := (cnt) ? '' : '`r`n'					; ... determine required CRLF
				blk .= CRLF indent nxSect.sect.FuncName '()'								; ... create funcCall for next-link, append call to body
			}
		}
		funcName	:= sect.FuncName
		func_DnC	:= funcName . '()'														; create func declaration/call, with no params
		sect.Line1	:= sect.L1.LWS . sect.L1.decl func_DnC sect.L1.TC						; add any ws and trailing comments to func call for HK line
		sect.tBlk	:= (sect.hasExit) ? '`r`n' sect._xCmd . sect.tBlk : sect.tBlk			; 2025-10-23 UPDATED to fix missing trailing code
		outFunc		:= func_DnC ' {' convMsg '`r`n' . blk . '`r`n}'							; create entire func
		this.ToFunc[funcName] := outFunc													; add func to funclist, using funcname as key
		sect.FuncStr:= outFunc																; add func to HK obj so it can be added to code later
		sect.Blk	:= ''																	; remove HK code-body from obj
		return		outFunc																	; return the new func (if needed by caller and to flag success)
	}
	;############################################################################
	; 2025-10-26 AMB, UPDATED
	; 2026-03-29 AMB, UPDATED: to add SetDefaultGui() and fix missing indent
	Static _makeFuncLBL(&sect)																; creates BrcBlk/func (and funcCall) from LBL code, as needed
	{
		global gmGuiFuncCBChecks

		if (sect.tType != 'LBL') {															; process for labels only
			return ''
		}
		if (!sect.Blk && !sect.HasCaller) {													; if label has no block/body and no caller...
			return ''																		; ... prevent empty/useless labelToFunc conversion
		}

		; ini
		outFunc	 := ''																		; ini output
		blk		 := sect.Blk, blk := clsCodeChop.RestoreMasksAll(blk)						; get current block/body, and restore its orig code
		Mask_T(&blk, 'C&S')																	; ... but we need comments/strings masked
		lblName	 := sect.LabelName															; get label name
		convMsg	 := ' `; V1toV2: Lbl->Func'													; msg to user about new func creation
		nextLink := this._nextLogicLink(lblName)											; get next link in logic-chain after this one (if present)
		defGui	 := (gDynGuiNaming && gfHasDynamicGui)										; if using dynamic gui naming and script has dynamic attributes ...
				 ?  '(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)'					; ... will apply SetDefaultGui() call, as needed
				 :  ''																		; ... otherwise, set to empty

		; does lbl block/body already have braces?
		if (bbObj := isBraceBlock(blk)) {													; if body already has braces...
			blk		:= bbObj.bbc															; extract just the guts of that body (without braces)
			indent	:= RegExReplace(Trim(blk,'`r`n'), '(?s)^(\h*).*', '$1')					; get block indent
			defGui	:= (defGui) ? '`r`n' indent defGui : defGui								; apply SetDefaultGui() call, as needed
			blk		:= indent 'global' defGui blk											; update block with changes
			if (nextLink && !sect._xCmd) {													; if there is a next-logic-link, and no exit command...
				if (nxSect := this.SectionObj[nextLink]) {									; ... get the section obj for the next link
					RegExReplace(blk, '\R$',,&cnt), CRLF := (cnt) ? '' : '`r`n'				; ... determine required CRLF
					blk .= CRLF indent nxSect.sect.FuncName '()`r`n'						; ... create funcCall for next-link, append call to body
				}
			}
			funcName	:= getV2Name(lblName)												; get name to use for new func
			func_DnC	:= funcName . '()'													; create func declaration/call, with no params
			outFunc		:= func_DnC bbObj.TCT '{' convMsg '`r`n' blk '}'					; create entire func
			this.ToFunc[funcName] := outFunc												; add func to funclist, using funcname as key
			sect.FuncStr:= outFunc															; add func to Lbl obj so it can be added to code later
			sect.Blk	:= '`r`n' func_DnC													; replace orig blk/body with a func call
			exitCmd		:= RegExReplace(sect._xCmd, '(?i)^(\h*RETURN).*', '$1')				; 2025-10-27 - remove anything following Return cmd
			sect.Blk		.= (exitCmd) ? ('`r`n' . exitCmd) : '`r`nreturn'				; add any orig-lbl exit-command after func call, otherwise add simple return
			return		outFunc																; return the new func
		}

		; body does not (already) have braces
		blk		:= this._gotoToFC_new(blk)													; convert any Goto within LBL code-block to funcCall
		indent	:= RegExReplace(Trim(blk,'`r`n'), '(?s)^(\h*).*', '$1')						; get block indent
		defGui	:= (defGui) ? '`r`n' indent defGui : defGui									; apply SetDefaultGui() call, as needed
		blk		:= indent 'global' defGui blk												; update block with changes
		if (nextLink && !sect._xCmd) {														; if there is a next-logic-link, and no exit command...
			if (nxSect := this.SectionObj[nextLink]) {										; ... get the section obj for the next link
				RegExReplace(blk, '\R$',,&cnt), CRLF := (cnt) ? '' : '`r`n'					; ... determine required CRLF
				blk .= CRLF indent nxSect.sect.FuncName '()'								; ... create funcCall for next-link, append call to body
			}
		}
		funcName	:= getV2Name(lblName)													; get name to use for new func
		func_DnC	:= funcName . '()'														; create func declaration/call, with no params
		outFunc		:= func_DnC ' {' convMsg '`r`n' . blk . '`r`n}'							; create entire func
		this.ToFunc[funcName] := outFunc													; add func to funclist, using funcname as key
		sect.FuncStr:= outFunc																; add func to Lbl obj so it can be added to code later
		sect.Blk	:= '`r`n' func_DnC														; replace orig blk/body with a func call
		exitCmd		:= RegExReplace(sect._xCmd, '(?i)^(\h*RETURN).*', '$1')					; 2025-10-27 - remove anything following Return cmd
		sect.Blk	.= (exitCmd) ? ('`r`n' . exitCmd) : '`r`nreturn'						; add any orig-lbl exit-command after func call, otherwise add simple return
		;gmGuiFuncCBChecks[funcName] := true
		return		outFunc																	; return the new func
	}
	;############################################################################
	Static _makeFuncsStr()																	; creates single string containing all newly created funcs
	{
		if (!scriptHasL2F()) {																; if NO labels will be converted to funcs...
			return ''																		; ... don't include ANY new funcs
		}

		outStr := ''																		; ini output
		divStr := ';' StrReplace(Format('{:46}',''),' ','#')								; func separator
		for idx, sect in this.Sects {														; for each section in array list...
			if (sect.FuncStr = 'SKIP') {													; if cur section should not get new func...
				continue																	; ... skip it
			}
			else if (sect.FuncStr) {														; if cur sect already has func string created...
				div := (outStr) ? divStr '`r`n' : ''										; ... include divider (except for first func)
				outStr .= '`r`n' div sect.FuncStr											; ... add func to output string
			}
			else if (this._makeFuncLBL(&sect)) {											; if cur section is label and func creation was successful...
				div := (outStr) ? divStr '`r`n' : ''										; ... include divider (except for first func)
				outStr .= '`r`n' div sect.FuncStr											; ... add func to output string
			}
		}
		return outStr																		; return all new funcs within single string
	}
	;############################################################################
	Static _nextLogicLink(curLbl)															; identifies next logical section that will be executed (from curLbl)
	{
		; build needle to find next link after curlbl (will not capture curLbl)
		term	:= '(?<term>[' gPauseChar gExitChar ']|$)'
		lbl		:= '(?<lbl>[^' gJumpChar gPauseChar gExitChar ']+)'
		path1	:= '[' gJumpChar gPauseChar ']'
		paths	:= '(?:' lbl gJumpChar ')*'
		targ	:= '(?<targ>(?&lbl))'
		nFlow	:= escRegexChars(curLbl) . path1 . paths . targ . term
		; curLbl[⟹⟼](?:(?<lbl>[^⟹⟼✖]+)⟹)*(?<targ>(?&lbl))(?<term>[⟼✖]|$)			; does not capture curLbl

		flowStr	:= this._logicFlow															; get logic flow reference string
		if (RegExMatch(flowStr, nFlow, &m)) {												; if next link is available...
			return m.targ																	; ... return next link
		}
		return ''																			; next-link not found
	}
	;############################################################################
	; 2026-03-29 AMB, ADDED
	Static _updateLblBlock(brcBlk, declare)													; updates block with A_GuiControl attributes
	{
		; TODO - MIGHT NEED TO REMOVE THIS VALIDATION ?
		if (!InStr(declare,'A_GuiControl'))													; if func params do not contain A_GuiControl...
			return brcBlk																	; ... do not update func block

		nSetDef	:= '(?im)^\h*;?\(IsSet\(.+?SetDefaultGui\(.+\v+'							; needle for SetDefaultGui() calls
		brcBlk	:= RegExReplace(brcBlk,nSetDef)												; remove SetDefaultGui() calls from block
		nBrcBlk	:= '(?s)^(\{(?<LWS>\s*)(?<guts>(?>[^{}]++|(?-3))*+)\})$'					; needle to parse brace-block
		if (!RegExMatch(brcBlk, nBrcBlk, &m))												; if srcStr is not a properly formatted brace block...
			return brcBlk																	; ... return orig str

		; split block into top/bottom section
		LWS		:= m.LWS, blkGuts := m.guts													; grab lead ws and block contents
		GCStr	:= '', setDef := '', lead := '{' . LWS, nl := '`r`n', indent := ''			; ini
		if (RegExMatch(LWS, '^\h*\v+(\h+)', &mIndent)) {									; if block has leading indent...
			indent := mIndent[1]															; ... capture indent
		} else {																			; otherwise...
			nGuts := '^(?is)^(?<lead>.+?global.*?\s+)(?<blk>.+)$'							; ... [needle for block that has global declaration]
			if (RegExMatch(blkGuts, nGuts, &guts)) {										; ... if block has 'global landmark'...
				lead	.= guts.lead, blkGuts := guts.blk									; ...	split block using 'global' as delimiter
				indent	:= Trim(RegExReplace(lead, '(?s)^.+?(\h*)$', '$1'),'`r`n')			; ...	capture indent
			}
		}
		nl .= indent																		; add indent to CRLF
		if (gDynGuiNaming && gfHasDynamicGui) {												; if using dynamic naming and v1 script has dynamic gui attributes
			param	:= 'A_GuiControl'														; ... set common param
			setDef	:= '(IsSet(' param ')) && SetDefaultGui(' param ')' nl					; ... set SetDefaultGui() call (string)
		}
		if (InStr(declare,'A_GuiControl') && gaScriptStrsUsed.A_GuiControl) {				; if add A_GuiControl vars to block (as needed)
			GCStr	:= 'A_GuiControl := (A_GuiControl.Name) '								; A_GuiControl replacement
					. '? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") '
					. '? A_GuiControl.Text : A_GuiControl)'	nl
		}
		return lead . setDef . GCStr . blkGuts . '}'										; return updated block contents
	}
	;############################################################################
	; 2025-11-01 AMB, UPDATED key case-sensitivity for gmList_LblsToFunc
	; 2026-02-22 AMB, UPDATED guiContStr
	; 2026-03-29 AMB, UPDATED to move A_GuiControl addition to dedicated func
	Static _updateLblToFuncs(code)															; applies A_GuiEvent/A_GuiControl params/vars, Regex replacements
	{
		While(pos := RegexMatch(code,gPtn_Blk_FUNC, &mFunc, pos??1))						; for each func found in code...
		{
			origStr := mFunc[], funcName := mFunc.fName										; get details of func
			; was current func the result of a LBL to FUNC conversion?
			if (!gmList_LblsToFunc.Has(funcName)) {											; if func was NOT converted from a label...
				pos += StrLen(origStr)														; ... prep for next func search
				continue																	; ... skip current func (no update needed)
			}
			; func was converted from label - updated it as needed
			brcBlk	:= mFunc.brcBlk															; get brace-block for function
			TCT		:= mFunc.TCT															; get code found between func declaration and brace-blk
			L2F_Obj	:= gmList_LblsToFunc[funcName]											; get L2F object
			declare	:= L2F_Obj.funcName '(' L2F_Obj.params ')'								; add any associated params to func declaration
			brcBlk	:= this._updateLblBlock(brcBlk, declare)								; add A_GuiControl manipulations to brace block contents
			funcStr	:= declare . TCT . brcBlk												; rebuild func
			for idx, reObj in L2F_Obj.RegExList {											; apply regexs as needed
				funcStr := applyRegex(funcStr, L2f_Obj.RegExList)							; perform ALL occurrences of ALL needles
			}
			;code	:= RegExReplace(code,escRegexChars(origStr),funcStr,,1,pos)				; apply updates to orig code (will fault if needle length > 40K)
			code	:= StrReplaceAt(code, origStr, funcStr,, pos, 1)						; 2026-01-17 - apply updates to orig code
			pos		+= StrLen(funcStr)														; prep for next func search
		}
		return code																			; return updated code
	}
}
;################################################################################
;################################################################################
; 2026-06-05 AMB, UPDATED
class clsLFSectList extends clsSectList			; see Scope.ahk for parent class
{
	_newSect(sect) {										; override						; creates section object
		if (!sd := this._getSectDetails(sect))												; validate that section is a legit target
			return false																	; ... flag as invalid
		return clsLFSect({oStr:sect,sb:sd.sb,tag:sd.tag})	; different						; create new section object and return it
	}
}
;################################################################################
;################################################################################
; 2026-06-05 AMB, UPDATED
class clsLFSect extends clsSect					; see Scope.ahk for parent class
{
	_nV2FC		:= ''																		; func name to use for labelToFunc conversion
	_nHKFC		:= ''																		; func name to use for HKs that have named-blocks (funcs)
	_newFunc	:= ''																		; new (entire) func (if being converted to func)
	_softExit	:= 0																		; flag that will prevent exit cmd from controlling logic flow
	LabelName	=> this._name																; name of LBL/FUNC/CLS, or HK/HS trigger (public shortcut)
	HasExit		=> !!(!this._softExit && ((this._xCmd && this._xPos) || this.L1.cmd))		; OVERRIDE - does section have an exit cmd, or should exit be ignored?
	AllowBridge	=> this._softExit															; flag to allow logic/execution to flow outside of brace-block
	HasCaller	=> (gmList_LblsToFunc.Has(this.LabelName)									; to assist prevention of empty labelToFunc conversions
				||  gmList_LblsToFunc.Has(this.FuncName)
				|| 	gmList_GosubToFunc.Has(this.LabelName)
				|| 	gmList_GotoLabel.Has(this.LabelName))
	;############################################################################
	__New(obj)																				; constructor
	{
		super.__New(obj)																	; use parent constructor
		this._getV2Name()																	; get v2 func name
	}
	;############################################################################
	; Provides simulated v1 logic flow for v1 brace-blocks
	; this only applies to sections that were originally brace-blocks in v1 script
	; 2026-06-07 AMB, ADDED
	BridgeLogicFlow(lblName)																; adds a logical link pointing to code beyond current brace-block
	{
		; add a lblName() call that continues logical code execution
		blk := this.Blk																		; get current sect block
		if (!bbObj := isBraceBlock(blk))													; if not a brace-block...
			return false																	; ... no changes are required

		TCT			:= bbObj.TCT															; get leading WS/comments for block
		guts		:= bbObj.bbc															; get block code (within braces)
		indent		:= RegExReplace(Trim(guts,'`r`n'), '(?s)^(\h*).*', '$1')				; capture indent
		msg			:= ' `; V1toV2: remove if unnecessary'									; user msg for added line
		guts		.= indent lblName '()' msg '`r`n'										; add call for next-link label (to bottom of block)
		this.Blk	:= TCT . '{' . guts . '}'												; finish new brace-block, update this object

		; flag labelname to be (forced) converted to func, as needed
		if (!gmList_LblsToFunc.Has(lblName)) {												; if labelname is NOT already listed...
			funcName := getV2Name(lblName)													; ... get valid v2 func name
			gmList_LblsToFunc[lblName] := clsConvLabel('FORCE', lblName,'',funcName)		; ... add labelname obj to list
		}
		return this.Blk																		; return updated brace-block to caller (why not?)
	}
	;############################################################################
	; This OVERRIDE allows logic flow to bypass exitCmd, as needed for v1 brcBlks
	; 2026-06-07 AMB, ADDED to OVERRIDE original method
	_exitCmdSplit(blk)																		; sub-divides sect blk based on position of exit cmd (if present)
	{																						;	also extracts exit cmd if present
		Mask_T(&blk, 'IWTLFS')																; mask [For,If,Loop,Switch,Try,While] within sect block
		saveBlk		:= blk																	; used to split code above/below exit command
		nExit		:= '(?im)^\h*\b(?:RETURN|EXITAPP|EXIT|RELOAD)\b.*'						; exit command needle (targets full line)
		xCmdLine 	:= '', tBlk := ''														; ini, in case no exit cmd

		; if section is a v1 brace-block, allow alternate logic flow
		isV1Blk := false
		if (this._isV1BrcBlk && isBB := isBraceBlock(blk)) {								; if section was a v1 brace-block originally...


			; TODO - IF FIRST CMD AFTER BRACE BLOCK AN EXIT CMD, DO NOT ADD LINK TO OUTSIDE


			pos			:= 0, xCmdLine := ''												; ... flag block as having NO EXIT CMD
			blk			:= isBB.TCT . isBB.bb '`r`n'										; ... limit block to just the brace-block itself
			tBlk		:= isBB.trail, this.tBlk := tBlk									; ... get code following brace-blk
			isV1Blk		:= 1	; still allows capture for v1 brcBlk exitCmd line			; ... flag for Regex search below
			this._softExit := 1																; ... set flag that can be used later
		}
		; find FIRST exit command in block
		if (pos	:= RegExMatch(blk, nExit, &m)) {											; locate FIRST exit command (if present)
			xCmdLine	:= m[]	; still allows capture for v1 brcBlk exitCmd line			; first exit command (full line)
			if (!isV1Blk) {																	; if flag was NOT set above...
				endPos	:= pos + StrLen(xCmdLine)											; ... position of last character on exitCmd line
				blk		:= SubStr(saveBlk, 1, endPos-1)										; ... block, including exitCmd (full line)
				tBlk	:= SubStr(saveBlk, endPos)											; ... trailing code after exitCmd - will not be executed within block...
			}
		}																					; ... but might be converted to new global section
		return {xCmd:xCmdLine,xPos:pos,blk:blk,tBlk:tBlk}									; return details, whether exitCmd exist or not
	}
	;############################################################################
	HKFunc		; PUBLIC (might add validations later)										; func (name) that is sometimes used as HK block code
	{
		; for HKs only - https://www.autohotkey.com/docs/v1/Hotkeys.htm#Function
		get => this._nHKFC
		set => this._nHKFC := value
	}
	;############################################################################
	FuncName	; PUBLIC (might add validations later)										; name to use for func when section is converted to func
	{
		get => (this.HKFunc) ? this.HKFunc : ((this._nV2FC) ? this._nV2FC : this._name)
		set => this._nV2FC := value
	}
	;############################################################################
	FuncStr {	; PUBLIC (might add validations later)										; newly created func that will hold section code
		get => this._newFunc
		set => this._newFunc := value
	}
	;############################################################################
	_addBraces(uniqStr:='', RegexObj:=unset, &fExit:=false)									; adds braces (and conv msgs) to section block
	{
		oBrc	:= '`r`n{ `; V1toV2: Added opening brace' . uniqStr							; opening brace to be added  to top of sect
		glbl	:= '`r`nglobal `; V1toV2: Made function global'								; global keyword to be added to top of sect
		cBrc	:= '`r`n} `; V1toV2: Added closing brace' . uniqStr							; closing brace to be added to sect exit
		fExit	:= false																	; ini, in case no exit found
		blkStr	:= this.Blk																	; initial code block
		if (this.HasExit) {																	; if section has an exit command...
			oExitCmd := this._xCmd, pos := this._xPos										; ... record details about exit cmd line
			rExitCmd := (IsSet(RegexObj))													; if Regex replacement is required...
						? applyRegex(oExitCmd, RegexObj)									; ... apply regex changes
						: oExitCmd															; ... otherwise, keep orig exit command
			EOBStr	 := rExitCmd . cBrc														; exit cmd with closing brace
			;blkStr	 := RegExReplace(blkStr, escRegexChars(oExitCmd), EOBStr,,1,pos)		; ! Removes $ by mistake for some reason !
			blkStr	 := StrReplaceAt(blkStr,oExitCmd,EOBStr,,pos,1)							; add closing brace after exit cmd
			fExit	 := true																; notify caller that a sect exit was found
		}
		else {
			blkStr	.= cBrc . ' (NO CLEAR EXIT FOUND)'										; no exit-cmd found, add closing brace to end of sect
		}
		blkStr		:= oBrc . glbl . blkStr													; assemble output
		;this.Blk	:= blkStr																; this is updated by caller (avoid extra save)
		return		blkStr																	; return updated (brace) block
	}
	;############################################################################
	_getV2Name()																			; gets v2 func name for section type
	{
		switch this.tType,0 {
			case 'LBL','FUNC','CLS': this._nV2FC := getV2Name(this._name)					; standard v2 compatible name
			case 'HK','HS':			 this._nV2FC := clsLabelSect.uHKFcName[this._name]		; get a unique v2 name for HK/HS
		}
	}
	;############################################################################
	HK_1LineToML()	; support for issue #322												; converts one-line HK to multi-line HK
	{
		if (this.tType != 'HK' || !this.L1.cmd)												; make sure this is HK and has cmd on line1
			return
		this.Blk	:= '`r`n' . this.L1.cmd . '`r`nreturn'									; move Line1 cmd to sect block/body
		LWS			:= this.L1.LWS															; grab Line1 leading ws
		decl		:= this.L1.decl															; grab Line1 declaration
		TC			:= this.L1.TC															; grab Line1 trailing comment
		tag			:= this.L1.tag
		this.Line1	:= LWS . decl . TC														; remove cmd from Line1
		this._L1Obj	:=	{ tag:	tag															; preserve Line1 tag
						, decl:	decl														; preserve Line1 declaration
						, cmd:	''															; remove   Line1 cmd from line details
						, TC:	TC															; preserve Line1 trailing comment
						, LWS:	LWS }														; preserve Line1 leading ws
	}
}
;################################################################################
;################################################################################
; structured class to replace details found in gaList_LblsToFuncO
; see gmList_LblsToFunc now, and clsLabelSect._updateLblToFuncs()
; holds details related to label conversions for the following hosts...
;	HK - Hotkey, HS - HotString, MN - Menu, ST - SetTimer,
;	OX - OnExit, OOC - OnClipbordChnge, GUI - gui, AG - A_Gui
class clsConvLabel
{
	hostType	:= ''																		; host type - HK, HS, MN, ST, OX, OOC, GUI, AG
	labelName	:= ''																		; label name that is being called
	params		:= ''																		; func params if applicable for host
	funcName	:= ''																		; func name if applicable
	RegExList	:= []																		; regex needles and replacements - array of map objs

	__new(hostType, lblName, params, funcName := '', regex := '')
	{
		this.hostType	:= hostType
		this.labelName	:= lblName
		this.params		:= params
		this.funcName	:= (funcName) ? funcName : lblName
		if (regex != '') {
			this.RegExList.Push(regex)
		}
	}
}
;################################################################################
; 2026-05-04 AMB, MOVED out of class
applyRegex(srcStr, RegexArr)																; applies regex replacements as required to some sect/blks
{
	if (Type(RegexArr)='array') {															; if regexs are available in RegexArr...
		for idx, obj in RegexArr {															; ... apply all regex replacements (can be more than 1)
			if (obj.NeedleRegEx) {
				loop {																		; ensure all replacements are made within srcStr
					saveSrcStr := srcStr													; will be used to control loop exit
					srcStr := RegExReplace(srcStr, obj.NeedleRegEx, obj.Replacement)		; apply replacement as necessary
				} Until (srcStr = saveSrcStr)												; exit loop when ALL occurrence are replaced
			}
		}
	}
	return srcStr
}
;################################################################################
; Provides access to conversion of Labels, HK, HS thru clsLabelSect.Main_ProcessSects()
; attempts to overcome limitations caused by the removal of Gosub from AHKv2,
;	and allow the combination of Goto and func calls to behave the same as...
;	they did in v1 script...
; 2025-10-05 AMB, ADDED
Update_LBL_HK_HS(code)
{
;	code := LF2(code)
	code := clsLabelSect.Main_ProcessSects(code)
	code := fixLabelNames(code)																; ensure no name conflicts for labels/funcs
	return code
}
;################################################################################
fixLabelNames(code)
{
	retStr := ''
	for idx, line in StrSplit(code, '`n', '`r') {
		if (v1Label := getV1Label(Line)) {
			saveLine := line
			Label	:= getV2Name(v1Label) . ":"
			Line	:= RegexReplace(Line, "(\h*)\Q" v1Label "\E(.*)", "$1" Label "$2")
		}
		retStr .= line . '`r`n'
	}
	retStr := RegExReplace(retStr, '`r`n$',,,1)
	return retStr
}
;################################################################################
; Determines whether script has labels that req conversion to funcs
; 2026-05-04 AMB, MOVED out of class
scriptHasL2F(lblName:='')
{
	if (lblName) {
		return (gmList_LblsToFunc.Has(lblname)												; true if LBLName requires conversion
				|| gmList_GosubToFunc.Has(lblname)
				|| gmList_GotoLabel.Has(lblname))											; 2025-11-18 ADDED as part of fix for #409
	}
	return	!!(gmList_LblsToFunc.Count														; true when ANY label requires conversion
			|| gmList_GosubToFunc.Count
			|| gmList_GotoLabel.Count )														; 2025-11-18 ADDED as part of fix for #409
}
;################################################################################
; Determines whether v1 script has specified label
; 2025-11-01 AMB, ADDED
; 2026-03-29 AMB, UPDATED to mask regex special chars in needle
scriptHasLabel(labelName)
{
	return (gAllV1LabelNames ~= '(?i)\b' escRegexChars(labelName) ',')
}
;################################################################################
; Determines whether v1 script has specified function
; 2025-11-01 AMB, ADDED
; 2026-03-29 AMB, UPDATED to mask regex special chars in needle
; TODO - add support for detecting class methods as legit funcs
scriptHasFunc(funcName)
{
	return (gAllFuncNames ~= '(?i)\b' escRegexChars(funcName) ',')
}
;################################################################################
; Determines whether v1 script has specified class
; 2025-11-01 AMB, ADDED
; 2026-03-29 AMB, UPDATED to mask regex special chars in needle
scriptHasClass(className)
{
	return (gAllClassNames ~= '(?i)\b' escRegexChars(className) ',')
}
;################################################################################
; Determines whether v1 script has specified class-method
; 2026-03-08 AMB, ADDED
scriptHasMethod(srcStr)
{
	if (RegExMatch(srcStr, '^(?<cls>[^\s]+)\.(?<meth>[^.]+)$', &m)							; if input is a class method...
	&& ((scriptHasClass(m.cls) && scriptHasFunc(m.meth))))									; AND method exists in v1 script...
		return {cls:m.cls,method:m.meth}													; ... return cls and method (object)
	return false																			; not an existing class method
}
;################################################################################
; Returns srcStr if any valid v1 label is found in string
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_Blk_LBLD for label declaration needle
; 2025-06-12 AMB, ADDED
hasValidV1Label(&srcStr)
{
	tempStr := trim(RemovePtn(srcStr, 'LC'))												; remove line comments and trim ws
	; return full srcStr if valid v1 label is found anywhere in srcStr
	if (tempStr ~= '(?m)' . gPtn_Blk_LBLP)													; multi-line check
		return srcStr																		; appears to have valid v1 label somewhere
	return ''																				; no valid v1 label found in srcStr
}
;################################################################################
; Returns extracted label if it resembles a valid v1 label
; 	does not verify that it is a valid v2 label (see validV2Label for that)
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_Blk_LBLD for details of label declaration needle (in MaskCode.ahk)
; 2025-06-12 AMB, ADDED
isValidV1Label(srcStr)
{
	tempStr := trim(RemovePtn(srcStr, 'LC'))												; remove line comments and trim ws
	; return just the label if...
	;	it resembles a valid v1 label
	if (RegExMatch(tempStr, gPtn_Blk_LBLP, &m))												; single-line check
		return m[1]																			; appears to be valid v1 label
	return ''																				; not a valid v1 label
}
;################################################################################
; Returns extracted label if it resembles a valid v1 label
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; 2024-07-07 AMB, ADDED
; 2025-06-12 AMB, UPDATED - calls new function now
; 2025-07-06 AMB, UPDATED - minor adj
getV1Label(srcStr, returnColon:=true)
{
	if (label := isValidV1Label(srcStr)) {
		return ((returnColon) ? label : RTrim(label, ':'))
	}
	return ''	; not a valid v1 label
}
;################################################################################
; Replaces GetV2Label()
; 2024-07-07 AMB, ADDED
; 2025-07-06 AMB, UPDATED
; 2025-10-05 AMB, UPDATED to support unit tests (restore strings)
getV2Name(v1LabelName)
{
	Mask_R(&v1LabelName, 'STR')																; only req for unit tests, which may have tags
	labelName := RTrim(v1LabelName, ':')													; remove any colon if present
	return (gmAllV2LablNames.Has(labelName)) ? gmAllV2LablNames[labelName] : labelName
}
;################################################################################
; Ensures name is unique (support for v1 to v2 label naming)
; 2024-07-07 AMB, ADDED
; 2024-07-09 AMB, UPDATED to check existing label names also
; 2025-07-06 AMB, UPDATED to add label name to global func list
; 2025-11-01 AMB, UPDATED as part of Scope support
_getUniqueV2Name(v1LabelName)
{
	global gAllFuncNames, gAllV1LabelNames

	holdName := newName := v1LabelName
	; if labelName is already being used by another label or function, change the name
	; keep renaming until unique name is created
	while (scriptHasFunc(newName)
		|| scriptHasLabel(newName)) {
		newName := holdName . '_' . A_Index+1
	}
	; add to labelName list if not already
	if (!scriptHasLabel(newName)) {
		gAllV1LabelNames .= newName . ','
	}
	; TO DO - add support for v1 to v2 function naming
	; add to function list if not already
	if (!scriptHasFunc(newName)) {
		gAllFuncNames .= newName . ','
	}
	return newName
}
;################################################################################
; Returns valid v2 label with or without colon based on flag [returnColon]
; makes sure returned name is unique and does not conflict with existing function names
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; 2024-07-07 AMB, ADDED
; 2025-07-06 AMB, CHANGED func name and ADJ
validV2LabelName(srcStr, returnColon:=true)
{
	; makes sure it is a valid v1 label first
	if (!LabelName := getV1Label(srcStr,0))
		return ''
	; handle OnClipboardChange
	LabelName := (LabelName = 'OnClipboardChange') ? 'OnClipboardChange_v2' : LabelName
	; convert to valid v2 label
	newName		:= ''
	Loop Parse LabelName {
		char	:= A_LoopField
		needle	:= (A_Index=1)
				? '(?i)(?:[^[:ascii:]]|[a-z_])'
				: '(?i)(?:[^[:ascii:]]|\w)'
		newName	.= ((char~=needle)
				? char : ((A_Index=1 && char~='\d')
				? '_' char : '_'))
	}
	newName := (LabelName=newName) ? newName : _getUniqueV2Name(newName)
	return (newName . ((newName!='' && returnColon) ? ':' : ''))
}
;################################################################################
; 2025-11-30 AMB, UPDATED to prevent Default: within Switch from being mistaken for label
getV1LabelNames(code)
{
	v1LabelNames := ''
	Mask_T(&code, 'SW', 1)	; hide Default: within Switch blocks
	Mask_R(&code, 'STR')	; restore strings
	for idx, line in StrSplit(code, '`n', '`r') {
		if (v1Label := getV1Label(line, returnColon:=false)) {
			v1LabelNames .= v1Label . ','
		}
	}
	return v1LabelNames
}
;################################################################################
; Converts v1 label names to valid v2 (label/funcName)...
;	... and returns a map for global gmAllV2LablNames
; 2024-07-07 AMB, ADDED
; 2025-07-06 AMB, UPDATED - changed func name and refactor...
;	... now uses v1 labelNamelist created with getV1LabelNames(), as source
getV2LabelNames(v1LabelNameList)
{
	labelMap := Map_I(), corrections := ''
	for idx, v1Name in StrSplit(v1LabelNameList,',') {										; for each v1 label name...
		labelMap[v1Name] := validV2LabelName(v1Name ':',0)									; ... ensure a valid v2 label/funcName
	}
	return labelMap
}
;################################################################################
; Moves labels to their own line...
;	... when they are on same line as opening/closing brace
; can be adjusted o handle occurrences for any other trailing item as well
;	(to make sure braces are isolated to their own line)
; 2025-06-22 AMB, ADDED
isolateLabels(code)
{
	outCode	:= ''
	for idx, line in StrSplit(code, '`n', '`r') {											; for each line in code string...
		tempLine := line																	; in case we need to revert back to orig
		if (RegExMatch(line, '^(\h*)([{}][\h}{]*)(.*)', &m)) {								; separate leading brace(s) from rest of line
			indent		:= m[1]																; preserve indentation
			brace		:= m[2]																; leading brace(s)
			trail		:= m[3]																; rest of line
			tempLine	:= RTrim(indent . brace)											; set initial value
			clnTrail	:= Trim(RemovePtn(trail, 'LC'))										; clean trailing string - remove line comment and ws
			if (isValidV1Label(clnTrail)) {													; if a label is found, move it to its own line
			; THIS CAN BE USED TO HANDLE OTHER ITEMS (protects HKs)
			;if (clnTrail && !(clnTrail ~= '::$' )) {										; if not empty, and not a hotkey
				tempLine .= '`r`n' . indent . trim(trail)									; drop trailer str below brace (to next line)
			}
			else {																			; no label found on same line as brace(s)
				tempLine := line															; restore line to original
			}
		}
		outCode .= tempLine . '`r`n'														; build output string
	}
	outCode := RegExReplace(outCode, '\r\n$',,,1)											; remove final CRLF (added in loop)
	return outCode
}
;################################################################################
; Converts  Goto, label  -->>  Goto("label")
;	also adds trailing Return as needed
;	places Goto/Return into a single-line tag
; tags will be restored in restoreGotoReturn(), which is called from PreProcessLines()
; this func is called from PreProcessLines() and HK1LToML()
; 2025-11-23 AMB, ADDED - replaces previous Goto handling (part of fix for #413)
; 2025-11-30 AMB, UPDATED call for Zip()
; 2026-01-01 AMB, UPDATED with cleanCWS() call
convertGoto(line, idx, &lines)
{
	global gmList_GotoLabel

	nExitCmd	:= '(?i)^\b(RETURN|EXITAPP)\b'												; needle for exit commands
	nGoto		:= '(?im)^(\h*)(GOTO)(.+)'													; needle for 'Goto, Label'
	returnStr	:= 'Return `; V1toV2: post-return for Goto'									; user msg to add as needed
	if (!RegexMatch(line, nGoto, &m))														; if line does NOT have Goto command...
		return line																			; ... exit early

	; convert Goto
	LWS := m[1], gotoStr := m[2], param := m[3]												; extract line/goto parts
	Mask_R(&param, 'LC')																	; expose any trailing line comment
	param		:= separateComment(param, &TC:='')											; separate trailing line comment (first occurrence)
	param		:= Trim(LTrim(param, ','))													; remove leading comma if present
	v1LabelName	:= param																	; should be left with v1 label name
	v2FuncName	:= Trim(getV2Name(v1LabelName))												; get v2 funcname associated with v1 label name
	gmList_GotoLabel[v1LabelName] := true													; 2025-11-18 ADDED as part of fix for #409
	gotoStr		:= gotoStr . '("' . param . '")'											; updated v2 Goto command
	retStr		:= '', nextCmd := '', offset := 1											; ini

	; add Return line as needed
	While(idx+offset <= lines.Length && !nextCmd) {											; find the next line that has ahk code (ignore comments/empty)
		nextLn	:= lines[idx + offset++]													; ... get next line
		nextCmd	:= cleanCWS(nextLn)															; ... remove comments, and whitespace (see MaskCode.ahk)
		retStr	:= (nextCmd ~= nExitCmd)													; ... if next line already has an exit cmd...
				? ''																		; ...	do NOT add a Return
				: '`r`n' . LWS . returnStr													; ...	otherwise, add a Return Line (preserving leading indent)
	}

	; finalize output
	line		:= LWS . gotoStr . TC . retStr												; update line with changes (if any)
	if (retStr)																				; if Return was added...
		line	:= Zip(line, 'GOTORET')														; ... compress added lines into single-line tag
	return line
}
;################################################################################
; Moves same-line HK commands below HK declaration, in certain cases
; 2025-11-23 AMB, ADDED - part of fix for #413
HK1LToML(line, idx, &lines)
{
	nHK := '(?im)^(?<LWS>\h*)(?<HKDecl>' gPtn_HOTKEY . ')(?<cmd>.*)'						; needle for HK full line
	Mask_R(&line, 'LC')																		; expose any trailing line comment
	if (RegExMatch(line, nHK, &m)) {														; if line is a HK...
		hk	:= m.HK, cmd := m.cmd															; get parts of line
		cmd	:= separateComment(cmd, &TC:='')												; separate trailing line comment from line command

		; Goto cmd
		if (cmd ~= '(?i)(GOTO)') {															; if line cmd is Goto...
			line2	:= m.LWS . cmd . TC														; ... cmd will be a separate line
			line2	:= convertGoto(line2, idx, &lines)										; ... convert the Goto command
			line	:= m.LWS . m.HKDecl . '`r`n' . line2									; ... move cmdline below HK line
		}

		; Gui
		else if (cmd ~= '(?i)(GUI)') {														; if line cmd is Gui...
			line2	:= '`r`n' . m.LWS . cmd . TC											; ... cmd will be a separate line
			line3	:= '`r`n' . m.LWS . 'Return'											; ... must add return
			line	:= m.LWS . m.HKDecl . line2 . line3										; ... move cmd and return below HK line
		}

		; Gosub cmd
		else if (cmd ~= '(?i)(GOSUB)') {													; if line cmd in GoSub...
			;line	:= m.LWS . m.HKDecl . '`r`n' . cmd . TC									; ... move cmd below HK line
		}

		; Other
		else if (cmd && !(cmd ~= '(?i)(EXITAPP|MSGBOX|RELOAD|SEND|SUSPEND)')) {
			;MsgBox line "`n`nHK :=`t[" HK "]`nCMD :=`t[" cmd "]`nLC :=`t[" TC "]"			; DEBUG/Testing
		}
	}
	return line
}
;################################################################################
; Adds 'Return' line above each HK (except same logic HKs)
; 2026-06-05 AMB, ADDED
HKReturn(&code)
{

	retMsg	:= 'return `; V1toV2: remove if unnecessary'									; line to add
	TCT		:= commonBlockNeedles().TCT														; needle for trailing tags/comments
	nHKTag	:= UniqueTag('HK\w+')															; needle for HK tags
	nHKLn	:= '(?im)^(' nHKTag '.*)'														; needle for HK line declaration
	nDblHK	:= nHKLn '(' TCT ')' retMsg '\s+(' nHKTag ')'									; needle for double HK tag

	; add preceding return lines to each HK declaration
	Mask_T(&code, 'HK')																		; mask HK declarations
	pos := 1																				; ini
	While(pos := RegexMatch(code, nHKLn, &m, pos??1)) {										; for each HK declaration tag...
		match	:= m[1]																		; ... grab full match
		rMatch	:= match, Mask_R(&rMatch, 'HK'), LWS := ''									; ... prep to extract lead ws
		if (RegExMatch(rMatch, '^\h+', &mLWS))												; ... if match has lead horz ws...
			LWS := mLWS[]																	; ... grab LWS
		repl	:= LWS . retMsg . '`r`n' . match											; ... [replacement]
		code	:= RegExReplace(code, escRegexChars(match), repl,,1,pos)					; ... add preceding 'return' line
		pos		+= StrLen(repl)																; ... prep for next pass
	}
	; remove return lines between logically chained HKs
	pos := 1																				; ini
	While(pos := RegexMatch(code,nDblHK, &m, pos??1)) {										; for each double-HK...
		match	:= m[], HK1 := m[1], HK2 := m[5]											; ... [fill working vars]
		LWS		:= m[2],LWS	:= RegExReplace(LWS, '\h+$')									; ... grab lead ws
		repl	:= HK1 . LWS . HK2															; ... [fill working vars]
		code	:= RegExReplace(code, escRegexChars(match), repl,,1,pos)					; ... remove return lines between logic-HKs
		pos		+= StrLen(HK1)																; ... prep for next pass
	}
	Mask_R(&code, 'HK')																		; restore HK declarations
	;FixRedundantExits(&code, retMsg '\r\n')
}
;################################################################################
; Removes unnecessary exit commands
; 2026-06-05 AMB, ADDED
FixRedundantExits(&code, targ:='')
{
	Mask_T(&code, 'C&S'), Mask_T(&code, 'IWTLFS')											; hide comments, strings, and logic blocks
	nExitCmd	:= '\b(RETURN\b|(?:EXITAPP|RELOAD)(?:\(\))?)'								; needle for exit commands
	nRetVal		:= '(?<val>.*)'																; needle for values after Return cmds
	targ		:= (targ) ? targ : nExitCmd nRetVal											; determine the targeted exit cmds
	TCT			:= commonBlockNeedles().TCT													; needle for trailing tags/comments
	nExit1		:= '(?im)^(\h*' nExitCmd ')'												; needle for exit cmd that will be preserved
	nExitTarg	:= nExit1 '('  TCT ')' . targ												; needle for double exit commands
	loop {																					; allows recursion until all double-exits are eliminated
		updated := false																	; flag to determine when all double-exits are eliminated
		pos := 1																			; ini with each loop
		While(pos := RegexMatch(code, nExitTarg, &m, pos)) {								; for each HK declaration tag...
			match	:= m[], ec1 := m[1], val := ''											; ... [fill working vars]
			if (InStr(targ, nRetVal))														; ... if searching for default target (targ not passed by caller)...
				val := m.val, val := cleanCWS(val)											; ... get the actual value that may follow Return cmd
			LWS		:= m[4], LWS := RegExReplace(LWS, '\r\n\h*$',,,1)						; ... get lead ws, remove last CRLF and horz ws from end
			repl	:= ec1 . LWS															; ... set replacement
			if (val	 = '') {																; ... if a value does NOT follow the exit cmd...
				code:= RegExReplace(code, escRegexChars(match), repl,,1,pos)				; ... remove redundant exit cmd
				updated	:= true																; ... flag that code was updated
			}
			pos		+= StrLen(repl)															; ... prep for next pass
		}
	} Until (!updated)																		; continue the search until all double-exits have been eliminated
	code := clsCodeChop.RestoreMasksAll(code)												; remove all masking from code
}
;################################################################################
; See addHKCmdCBArgs() for adding param to func declaration
; 2025-10-12 AMB, ADDED to fix #328
addHKCmdFunc(varName)
{
	nFunc	 := '(?i)' varName '\h*:=\h*FUNC\(([^)]+)\)'									; needle to locate... var := Func("funcName")
	funcName := '', oStr := gOScriptStr._origStr
	if (RegExMatch(oStr, nFunc, &m)) {														; if a func is associated with varName
		funcName := Trim(m[1], '"')															; capture that funcName
		gmList_HKCmdToFunc[funcName] := clsConvLabel('HKY',varName,'ThisHotkey',funcName)	; add funcName and func param to obj/array
	}
	return funcName																			; return funcName, in case caller can use it
}
;################################################################################
; 2025-10-12 AMB, Added to support #328
; 2026-02-07 AMB, UPDATED needle to prevent false positive with [`r`n`t]
addHKCmdCBArgs(&code)
{
	;Mask_T(&code, 'C&S')	; 2025-10-12 - handled in FinalizeConvert()
	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>(?<!``)[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')		; 2025-06-12, remove exclusion
	nDeclare:= '(?im)' nCommon '\))(?<trail>.*)'											; make needle for func declaration
	nArgs	:= '(?im)' nCommon '\K\)).*'													; make needle for func params/args
	m := [], declare := []
	for key, obj in gmList_HKCmdToFunc {													; for each entry in list...
		paramsToAdd	:= obj.params															; get params that will need added
		funcName	:= obj.FuncName															; get func (name) to add params to
		nTargFunc	:= RegExReplace(nFUNC, 'i)\Q?<fName>(?<!``)[_a-z]\w*+\E', funcName)		; target specific function name
		If (pos := RegExMatch(code, nTargFunc, &m)) {										; look for the func declaration...
			; target function found
			if (RegExMatch(m[], nDeclare, &declare)) {										; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail						; extract params and trailing portion of line
				LWS			:= TWS := '', params := ''										; ini existing params details, inc lead/trail ws
				if (RegExMatch(argList, '\((\h*)(.+?)(\h*)\)', &mWS)) {						; separate lead/trail ws in params
					LWS := mWS[1], params := mWS[2], TWS := mWS[3]							; extract existing params and preserve lead/trail ws
				}
				params		.= (params && paramsToAdd) ? ', ' : ''							; add trailing comma only when needed
				newArgs		:= '(' LWS . params . paramsToAdd . TWS ')'						; preserve lead/trail ws while rebuilding params list
				addArgs		:= RegExReplace(m[],  '\Q' argList '\E', newArgs,,1)			; replace function params/args
				code		:= RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)			; replace function within the code
			}
		}
	}
	return ; code by reference
}
;################################################################################
; Adds Static keyword to methods that require it
; 2026-03-08 AMB, ADDED
addStaticKywdToMethod(&code)
{
	nCommon	:= '^(\h*)((?<fName>(?<!``)[_a-z]\w*+)\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')
	nDeclare:= '(?im)' nCommon '\)(?<trail>.*))'											; make needle for func declaration
	for key, val in gmMethodsToStatic {														; for each entry in list...
		funcName	:= key																	; get func name
		nTargFunc	:= RegExReplace(nFUNC, 'i)\Q?<fName>(?<!``)[_a-z]\w*+\E', funcName)		; target specific func name
		If (!pos := RegExMatch(code, nTargFunc, &m))										; look for the func declaration...
			continue																		; ... skip if not found
		if (!RegExMatch(m[], nDeclare, &decl))												; get just declaration line
			continue																		; ... skip if unable to get func decl (should not happen)
		newDecl		:= decl[1] . 'Static ' decl[2]											; add static keyword to func declaration, preserve leading ws
		addStatic	:= RegExReplace(m[],  '\Q' decl[] '\E', newDecl,,1)						; update func declaration
		code		:= RegExReplace(code, '\Q' m[] '\E', addStatic,,, pos)					; update entire function within code
	}
}
;################################################################################
/**
* Creates a Map of labels who can be replaced by other labels...
*	(if labels are defined above each other)
* @param {*} ScriptString string containing a script of multiple lines
* 2024-07-07 AMB, UPDATED - to use common getV1Label() func that covers...
*	detection of all valid v1 label chars
* 2025-06-12 AMB, UPDATED - changed some var and func names...
*	gOScriptStr is now an object
*/
GetAltLabelsMap(ScriptString)
{
	RemovePtn(ScriptString, 'BC')															; remove block-comments
;	ScriptStr := StrSplit(ScriptString, "`n", "`r")
	ScriptStr := ScriptCode(ScriptString)
	LabelPrev := ""
	mAltLabels := Map_I()
	loop ScriptStr.Length {
;		Line := ScriptStr[A_Index]
		Line := ScriptStr.GetLine(A_Index)

		if (trim(RemovePtn(line, 'LC'))='') {												; remove any line comments and whitespace
			continue																		; is blank line or line comment
		} else if (v1Label := getV1Label(line)) {
			Label := SubStr(v1Label, 1, -1)													; remove colon
			Result .= Label "-" LabelPrev "`r`n"
			if (LabelPrev = "") {
				LabelPrev := Label
			} else {
				mAltLabels[Label] := LabelPrev
			}
		} else {
			LabelPrev := ""
		}
	}
	return mAltLabels
}