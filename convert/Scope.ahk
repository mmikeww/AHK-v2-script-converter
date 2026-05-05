;################################################################################
/*
	2025-11-01 AMB, ADDED to support Macro-Scope (and eventually Micro-Scope)
	2026-05-04 AMB, UPDATED to merge common code from LabelAndFunc.ahk
	TODO - WORK IN PROGRESS!
		* Sub-divide functions (internal funcs) and classes (methods)
		* Consider grouping HKs found between #IF boundaries
		*	either way, might need to account for left-behind #IFs
*/
;#Include %A_Desktop%\My_AHK\tools\VisCompareV2.ahk											; for error detection

;################################################################################
; 2025-11-01 AMB, ADDED
; 2025-12-24 AMB, UPDATED output to object
;	Separates code into sections
;	Each section contains sub-string blocks for one of the following...
;	 Label, HK, HS, Func, Class, or global (may be multiple global sections)
GetScopeSections(code)
{
	sects		:= clsScopeSect.GetSections(&code)											; separate code into sections
	outSects := []																			; [output array]
	for idx, sect in sects {																; for each section...
		sectType := sect.tType																; ... get section type
		sectCode := sect.RawSectStr															; ... restore masking
		outSects.Push({sect:sect,sectCode:sectCode,sectType:sectType})						; ... update output array
	}
	return outSects																			; return output array (simple sub-strings for each section)
}
;################################################################################
; 2026-05-04 AMB, UPDATED to merge common code from LabelAndFunc.ahk
class clsScopeSect
{
	_oStr		:= ''																		; original section string (has lots of masking)
	_L1Obj		:= ''																		; line 1 details (object)
	Line1		:= ''																		; line 1 [will be tagged/masked declaration (unless global)]
	Tag			:= ''																		; actual tag found on line 1
	tType		:= ''																		; tag/section type (LBL,HK,HS,FUNC,CLS,GBL)
	_name		:= ''																		; name of LBL/FUNC/CLS, or HK/HS trigger
	PCWS		:= ''																		; comments/CRLFs/WS before block code
	Blk			:= ''																		; block code, up to and including any exit command
	_xCmd		:= ''																		; exit command (full line)
	_xPos		:= ''																		; position of exit command (with masking applied)
	tBlk		:= ''																		; any block code that follows first exit command
	TCWS		:= ''																		; any trailing comments/CRLFs/WS after meaningful block code

	; PUBLIC section properties
	L1			=> this._line1Details														; line 1 details and its parts (public shortcut)
	GetSectStr	=> this.PCWS . this.Line1 . this.Blk . this.tBlk . this.TCWS				; final section string (still has masking)
	RawSectStr	=> codeChop.RestoreMasksAll(this.GetSectStr)								; final section string with masking removed
	HasExit		=> !!((this._xCmd && this._xPos) || this.L1.cmd)							; does section have an exit command?

	;############################################################################
	__new(obj)																				; CONSTRUCTOR
	{
		this._oStr			:= obj.oStr														; orig code for section (can be just a tag)
		this.Line1			:= obj.sb.Line1													; declaration line (is masked as tag initially, unless global)
		this.Blk			:= obj.sb.Blk													; full block initially [prior to ._exitCmdDetails()]
		this.TCWS			:= obj.sb.TCWS													; trailing comments/CRLFs after meaningful block code (cmds)
		this.Tag			:= obj.tag														; actual masked-tag (if present) on Line 1
		this.tType			:= (this.Tag)													; section type (if tag is present)
							? getTagType(this.Tag)											; ... section type is one of the following [LBL,HK,HS,FUNC,CLS]
							: 'GBL'															; ... otherwise is a global section
		if (this.tType = 'GBL') {															; if section is global
			this.Blk := separatePreCWS(this.Blk, &pre:='')									; ... separate preceding comments/CRLFs from significant blk code
			this.PCWS := pre																; ... [preceding comments/CRLFs before blk code]
		}
		this._exitCmdDetails()																; get details about exit command, its position, and any trailing code
		this._extractName()																	; extract the name of LBL/FUNC/CLS, or trigger of HK/HS
	}
	;############################################################################
	_extractName()
	{
		tag := this.Tag																		; get Line 1 tag
		switch this.tType,0 {
			case 'GBL':																		; global tag - has NO NAME
			case 'LBL':																		; for labels
				this._name	:= getV1Label(this.L1.decl,0)									; ... get label name from line 1 declaration
			case 'HK','HS':																	; for HK,HS...
				this._name := RegExReplace(this.L1.decl,'::$')								; ... get HK/HS trigger from Line 1 declaration
			case 'BLKFUNC', 'BLKCLS':														; for CLS,FUNC
				this._name := clsNodeMap.GetName[tag]										; ... get CLS/FUNC name from mask orig code
		}
	}
	;############################################################################
	_exitCmdDetails()																		; gets first legit exit command within section code-block
	{
		if (this.tType ~= '(?i)(?:FUNC|CLS)') {												; if func or class...
			this._xCmd := 'return'															; [implied, regrdless]	value doesn't matter for func/cls
			this._xPos := 'end'																; [end of func]			value doesn't matter for func/cls
			return
		}
		if (!(this.tType ~= '(?i)(?:HK|HS|LBL|GBL)')) {										; if not HK,HS,LBL,GBL...
			return																			; ... exit
		}
		sec := this._exitCmdSplit(this.Blk)													; sub-divide code block, extract exit cmd if present
		if (sec.xCmd) {																		; if section has exit cmd...
			this._xCmd		:= sec.xCmd														; ... update exit cmd for section (entire line)
			this._xPos		:= sec.xPos														; ... update exit cmd pos within code-block (with masking applied)
			if (brcBlk := isBraceBlock(this.Blk)) {											; if block already has braces...
				this.Blk	:= brcBlk.TCT . brcBlk.bb										; ... save brace block details...
				this.tBlk	:= brcBlk.trail													; ... and portion after brace block (might become new global section)
			} else {																		; does not have brace block already...
				this.Blk	:= sec.Blk														; ... update obj-blk (to include masking) so recorded pos is acurate
				this.tBlk	:= sec.tBlk														; ... will not be executed within block (might become new global section)
			}
		}
	}
	;############################################################################
	_exitCmdSplit(blk)																		; sub-divides sect blk based on position of exit cmd (if present)
	{																						;	also extracts exit cmd if present
		Mask_T(&blk, 'IWTLFS')																; mask [For,If,Loop,Switch,Try,While] within sect block
		saveBlk := blk																		; used to split code above/below exit command
		nExit	:= '(?im)^\h*\b(?:RETURN|EXITAPP|EXIT|RELOAD)\b.*'							; exit command needle (targets full line)
		xCmdLine := '', tBlk := ''															; ini, in case no exit cmd
		if (pos	:= RegExMatch(blk, nExit, &m)) {											; locate FIRST exit command (if present)
			xCmdLine	:= m[]																; first exit command (full line)
			endPos		:= pos + StrLen(xCmdLine)											; position of last character on exitCmd line
			blk			:= SubStr(saveBlk, 1, endPos-1)										; block, including exitCmd (full line)
			tBlk		:= SubStr(saveBlk, endPos)											; trailing code after exitCmd - will not be executed within block...
		}																					; ... but might be converted to new global section
		return {xCmd:xCmdLine,xPos:pos,blk:blk,tBlk:tBlk}									; return details, whether exitCmd exist or not
	}
	;############################################################################
	_line1Details																			; extracts details of Line 1 (declaration lne)
	{
		get {
			if (this._L1Obj)																; if details have already been parsed...
				return this._L1Obj															; ... return those details
			if (this.tType = 'GBL')															; if section is global code...
				return (this._L1Obj := {tag:'',decl:'',cmd:'',TC:'',LWS:''})				; ... Line1 details are irrelevant
			; not global code - get line1 details
			line1	:= this.Line1															; get line1 (should be masked)
			tag		:= this.Tag																; [should already have tag]
			decl	:= tag, Mask_R(&decl, this.tType)										; extract orig code for declaration (not trailing parts)
			line1	:= RegExReplace(line1, tag)												; remove tag from line 1
			Mask_R(&line1, 'C&S')															; restore comments/strings for line 1
			cmd		:= separateComment(line1, &TC:='')										; extract any cmd if present, separate trailing comment
			cmd		:= Trim(cmd)															; trim ws from cmd (causes issues otherwise)
			LWS		:= RegExReplace(cmd, '(\h*).+','$1')									; get leading ws for line1
			return	(this._L1Obj := {tag:tag,decl:decl,cmd:cmd,TC:TC,LWS:LWS})				; set/return Line 1 details
		}
	}
	;############################################################################
	;###################################  STATIC  ###############################
	;############################################################################
	; STATIC Class properties
	Static Sects		:= []																; array to hold (final) section objects
	Static GblLblCnt	:= 0																; counter for creating unique label/funcs, from stray global code
	Static NextGblLbl	=> ++this.GblLblCnt													; returns next value for GblLblCnt
	Static _orderGbl	:= ''																; enables global code to be processed first
	Static OrderGbl		=> this._sortSections()												; PUBLIC
	Static codeTop		:= ''	; used by LabelAndFunc.ahk calls							; code that occurs before any LBL/HK/HS/FUNC/CLS
	Static codeBot		:= ''	; used by LabelAndFunc.ahk calls							; code that occurs after  all LBL/HK/HS/FUNC/CLS sections
	;############################################################################
	Static Reset()
	{
		this.Sects		:= []
		this.GblLblCnt	:= 0
		this._orderGbl	:= ''
		this.codeTop	:= ''
		this.codeBot	:= ''
	}
	;############################################################################
	Static GetSections(&code,LnF:=0)			; LnF:=1 for LabelAndFunc calls				; separates and returns scope sections
	{
		this.Reset()																		; resets static vars - required when performing bulk/unit testing
		rawSects	:= this._getRawSects(&code,LnF)											; chop code into very raw sections
		rawSects	:= this._shiftTCWS(rawSects)											; rearrange trailing comments/CRLFs between sections
		dummy		:= this._rawToFinal(rawSects,LnF)										; create global sects between LBL,HK,HS,FUNC,CLS (as needed)
		return		this.Sects		; is filled in _rawToFinal()							; output final sects array
	}
	;############################################################################
	Static _getRawSects(&code,LnF:=0)			; LnF:=1 for LabelAndFunc calls				; separates script code into raw sections (GBL,LBL,HK,HS,FUNC,CLS)
	{
		sectObj	 := codeChop.MarkSects(code)												; add chop/section markers to code
		rawSects := []																		; [output array]
		for idx, sect in sectObj.chops {													; for each script section...
			if (LnF && idx = 1) {															; if LnF sect AND current code is above first tagged section...
				this.codeTop := sect														; ... capture code located above first tagged section
			} else if (sObj := this._newSect(sect)) {										; if cur section is valid/targ section...
				if (LnF && idx = sectObj.chops.Length)										; ... if LnF sect AND is last section...
					this.codeBot := sObj.TCWS, sObj.TCWS := ''								; ...	relocate trailing comments/CRLFs from cur sect to lower script sect
				rawSects.Push(sObj)															; ... add section object to array
			}
		}
		return rawSects																		; return array of raw sections
	}
	;############################################################################
	Static _rawToFinal(rawSects,LnF:=0)			; LnF:=1 for LabelAndFunc calls				; handles global code between sections, creates final Sects array
	{
		; relocate executable global code between sections (for LnF only)
		fConvGblOK := false																	; controls whether global code should be conv to lbl/func
		for idx, sect in rawSects {															; for each raw section...
			newGblSectList := []															; ini
			if ((sect.tType ~= '(?i)(?:LBL|HK|HS)')) {										; if section is label,HK,HS...
				if (brcBlk := isBraceBlock(sect.blk)) {										; if section already has braces...
					sec := sect._exitCmdSplit(brcBlk.bbc)									; ... get exit cmd details for brace-block
					if (sec.xCmd															; if brace-block has exit cmd...
					&& this._cleanCode(sect.tBlk)) {										; ... and, section has executable code following brcBlk
						sect._xCmd := sec.xCmd, sect._xPos := sec.xPos						; ... update exit cmd info for current section
						gblBlk := sect.tBlk . sect.TCWS										; ... gather remaining code for current section
						if (this._cleanCode(gblBlk, true)) {								; ... if executable code is something other than just exitCmds...
							newGblSectList	:= this._makeGblSections(gblBlk,LnF)			; ...	convert trailing executable code to new section
							sect.tBlk		:= '', sect.TCWS := ''							; ...	update current section
						}
						fConvGblOK	:= false												; ... don't allow global code to be called ? (TODO - MAKE SURE THIS IS CORRECT)
					}
					else if (!sec.xCmd) {													; if brace-block has NO exit cmd...
						if (this._cleanCode(brcBlk.trail)) {								; if section has executable code following brcBlk
							sect.Blk := brcBlk.TCT . brcBlk.bb								; ... blk code for cur sect should just be brace-blk
							gblBlk	 := brcBlk.trail . sect.TCWS							; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk,LnF)		; ...	convert trailing executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ...	update current section
								fConvGblOK		:= true										; ...	allow executable global code to be called (see below)
							}
						}
						else if (this._cleanCode(sect.tblk)) {								; if section has executable code following brcBlk
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk,LnF)		; ...	convert trailing executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ...	update current section
								fConvGblOK		:= true										; ...	allow executable global code to be called (see below)
							}
						}
					}
				}
				else {																		; section code DOES NOT have braces
					if (sect.tBlk) {														; if section has code following exitCmd...
						if (sect.HasExit && this._cleanCode(sect.tBlk)) {					; if section has executable code following exitCmd...
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk,LnF)		; ...	convert that executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ...	update current section
							}
						}
						else if (idx < rawSects.Length) { ; non-executBLE code				; if current section is not the last section...
							nextPCWS := sect.tBlk . sect.TCWS . rawSects[idx+1].PCWS		; ... gather remaining code for current sect, and beginning of next sect
							rawSects[idx+1].PCWS := nextPCWS								; ... move non-executable code to beginning of next section
							sect.tBlk := '', sect.TCWS := ''								; ... update current section
						}
					}
					fConvGblOK := (scriptHasL2F() && !sect.HasExit)							; allow gbl code calls when sect has no exit, and lbls will be conv to func
				}
			}
			else if (sect.tType ~= '(?i)(?:CLS|FUNC)'										; if section is CLS/FUNC...
			&& fConvGblOK																	; ... and gbl code will have a caller...
			&& this._cleanCode(sect.Blk)													; ... and the CLS/FUNC section has trailing executable code...
			&& rawSects.Length > 1) {														; ... and this is not the only section...
				gblBlk			:= sect.Blk . sect.TCWS										; ... 	gather remaining code for current section
				newGblSectList	:= this._makeGblSections(gblBlk,LnF)						; ... 	convert global code to new lbl/func
				sect.Blk		:= '', sect.TCWS := ''										; ...	update current section
				fConvGblOK		:= false													; ... 	reset flag
			}
			; TODO - WATCH FOR #IF lines
			else {	; not a LBL,HK,HS,FUNC,CLS - global code?								; may need to add code here in future
			}

			; update permanent Sects array
			this.Sects.Push(sect)															; add orig section... whatever it is
			if (newGblSectList.Length) {													; if new global section(s) were created (can be more than one)...
				for idx, sect in newGblSectList {											; for each new section created...
					this.Sects.Push(sect)													; ... add them to Sect list
				}
			}
		}
		return this.Sects																	; return to support external calls (mainly for labelAndFunc.ahk calls)
	}
	;############################################################################
	Static _makeGblSections(code,LnF:=0)		; LnF:=1 for LabelAndFunc calls				; creates new global sections from passed code
	{																						;	creates as many sections as code contains
		sectList:= []																		; output array - to return multiple new sections
		done	:= false																	; flag to determine when all sections have been created
		while (!done) {																		; loop until all sections have been created
			cs := this._newGblSect(code,LnF)												; create new section from curCode
			if (cs.tType																	; if new section was created...
			&&  cs.tBlk) {																	; ... and more sections need to be created...
				code	:= cs.tBlk . cs.TCWS												; ... 	grab code for next section to be created
				cs.tBlk	:= '', cs.TCWS := ''												; ... 	remove next-section-code from current section
			} else {
				done := true																; no more sections will be created
			}
			sectList.Push(cs)																; add current section to list
		}
		return sectList																		; return list of newly created sections
	}
	;############################################################################
	Static _newGblSect(code,LnF:=0)				; LnF:=1 for LabelAndFunc calls				; creates new section object from code
	{
		if (LnF)																			; if LabelAndFunc call...
			return this._convGblToLblAndFunc(&code)											; ... convert global code to Label/Func
		return this._newSect(code)															; otherwise, return new section obj
	}
	;############################################################################
	Static _newSect(sect)																	; creates section object
	{
		if (!sd := this._getSectDetails(sect))												; validate that section is a legit target
			return false																	; ... flag as invalid
		return this({oStr:sect,sb:sd.sb,tag:sd.tag})										; create new section object and return it
	}
	;############################################################################
	Static _convGblToLblAndFunc(&code)														; converts stray global code to label/func (for labelAndFunc calls only)
	{
		if (RegExMatch(code, '(?s)^(\s*)(.*)', &m))											; separate lead ws from code
			LWS := m[1], code := m[2]
		lblCnt		:= this.NextGblLbl														; get unique value for label name
		lbl			:= 'V1toV2_GblCode_' . Format('{:03}',lblCnt) . ':'						; make/format label str
		Mask_T(&lbl, 'LBL')																	; mask the label for consistency
		sectObj		:= this._newSect(lbl '`r`n' code)										; create section object
		sectObj.PCWS:= LWS																	; reapply LWS (ensure section will start on new line)
		return		sectObj																	; return section object
	}
	;############################################################################
	Static _getSectDetails(sect)															; ensures that sect is a legit target
	{
		if (!Trim(sect))																	; if section is empty...
			return false																	; ... invalid

		sb	 	:= this._splitSect(sect)													; separate line1, sect, and trailing ws/comments
		sbLine1	:= sb.Line1																	; [first line of current section]
		Mask_R(&sbLine1, 'C&S')																; restore line1 comments and strings
		sbBlk := sb.Blk, sbTCWS := sb.TCWS													; section blk and trailing ws/comments

		; if section type is one of the following...
		tag := hasTag(sbLine1)																; extract orig contents of tag (line1)
		if (RegExMatch(tag, '(?i)(HK|HS|LBL|BLKCLS|BLKFUNC)', &m))							; if line1 has a valid target tag...
			return {type:m[1],sb:sb,tag:tag}												; ... return tag and section-parts (obj)

		return {type:'GBL',sb:sb,tag:''}													; must be global section
	}
	;############################################################################
	Static _splitSect(sect)																	; sub-divides section into Line1, block, TCWS
	{
		L1 := blk := ''																		; ini
		sect := separateTrailCWS(sect, &TCWS:='')											; separate trailing comments/CRLFs from section
		if (RegExMatch(sect, '(?s)^([^\v]*)(.*)', &m)) {									; separate line 1 from rest of section
			L1 := m[1], blk := m[2]															; Line1 and block
		}
		if (!(L1 ~= '(?i)' gTagChar '(?:LBL|HK|HS|BLKFUNC|BLKCLS)')) {						; if Line1 does not have a section declaration tag...
			L1 := '', blk := sect															; ... it should just be global code
		}
		return {Line1:L1,Blk:blk,TCWS:TCWS}													; return separated parts
	}
	;############################################################################
	Static _shiftTCWS(sectsArr)																; moves trailing comments/CRLFs of one sect to beginning of next sect
	{
		for idx, sect in sectsArr {															; for each section in array...
			if (idx = sectsArr.length)														; dont process last section in array (already updated)
				break
			nextSect		:= sectsArr[idx+1]												; get next section
			nextSect.PCWS	:= sect.TCWS . nextSect.PCWS									; move   trailing comments/CRLFs to beginning of next section
			sect.TCWS		:= ''															; remove trailing comments/CRLFs from current section
		}
		return sectsArr																		; return updated array
	}
	;############################################################################
	Static _cleanCode(code, inclExit:=false)												; removes comments, ws, etc, so executable code is easier to decect
	{
		if (inclExit) {																		; if exit cmds should be removed...
			code := RegExReplace(code, '(?i)\bRETURN\b')									; ... remove return
			code := RegExReplace(code, '(?i)\bEXITAPP\b(?:\(\))?')							; ... remove exitapp
		}
		code := cleanCWS(code)																; remove comments, and whitespace (2026-01-01 see MaskCode.ahk)
		return code																			; remainder should be 'executable' code
	}
	;############################################################################
	Static _sortSections()																	; organize section-indexes so global-code is processed first
	{
		if (this._orderGbl) {																; if global-index-order has already been determined...
			return this._orderGbl															; ... return order string
		}
		orderStr := '', orderOth := ''														; ini
		for idx, sect in this.Sects {														; for each section...
			if (sect.tType = 'GBL') {														; ... if sect is global...
				orderStr .= idx ','															; ...	record index of global sections
			} else {																		; ... otherwise...
				orderOth .= idx ','															; ...	record index of non-global sections
			}
		}
		orderStr .= orderOth																; place global sections before any other sections
		orderStr := Trim(orderStr, ',')														; cleanup
		return (this._orderGbl := orderStr)													; set/return index order string
	}
}
;################################################################################
;################################################################################
class codeChop	; responsible for marking script code with tags that separate sections
{
	Static _chopTag := ';[' . gTagChar . 'CHOP' . gTagChar . ']`r`n'						; ;[★CHOP★]

	;############################################################################
	; PUBLIC - adds tags ;[★CHOP★] to mark declarations of CLS/FUNC/HK/HS/LBL...
	;	... so each 'code-sect' can be found/isolated easily for processing
	; output (three forms): code with chopTags, array of sects (chops), chopTag itself
	Static MarkSects(code, fLabels:=true, restorePM:=false)
	{
		this.MaskSects(&code, fLabels, restorePM)											; perform masking to prep for sect identification
		nTargBlks	:= 'BLKCLS|BLKFUNC|HK|HS'												; needle for specific tag types
		nTargBlks	.= (fLabels) ? '|LBL' : ''												; include labels if requested
		nTargBlks	:= '_?(?:' nTargBlks ')\w+'												; needle for all targetted tag types
		nBlkTags	:= uniqueTag(nTargBlks)													; needle for tags themselves
		chopTag		:= this._chopTag														; tag to add - ;[★CHOP★]
		While(pos	:= RegexMatch(code, nBlkTags, &mTag, pos??1)) {							; find each masked declaration (tags)
			tag		:= mTag[]																; [masked-declaration tag]
			repl	:= chopTag . tag														; add CHOP tag above masked-declaration
			code	:= RegExReplace(code, tag, repl,,1,pos)									; place CHOP tag into code
			pos		+= StrLen(repl)															; prep for next search
		}
		chops := StrSplit(code, chopTag)			 										; array holding each separate section
		return {code:code,chops:chops,chopTag:chopTag}										; return multiple versions of output
	}
	;############################################################################
	Static MaskSects(&code, fLabels:=true, restorePM:=false)								; masks section declarations, funcs, classes
	{
		sessID := clsMask.NewSession()														; new masking session for isolation
		Mask_T(&code, 'C&S',1,sessID)														; mask comments/strings
		Mask_T(&code, 'HIF', ,sessID)														; mask HotIfs
		code := this._isolateTrailBraces(code)												; move opening braces to their own line
		sectTypes := ['CLS&FUNC','HK','HS']													; look for FUNC, CLS, HK. HS...
		if (fLabels)
			sectTypes.Push('LBL')															; ... and labels if requested
		Loop sectTypes.Length {																; for each section type...
			mType := sectTypes[A_Index]														; ... get section type
			Mask_T(&code, mType,,,false)													; ... mask section type
		}
		; NOT performed by default
		if (restorePM) {																	; if requested...
			;Mask_R(&code, 'V1MLS',	,sessID)												; ... 2026-01-17 - removed - restore legacy ML strings
			Mask_R(&code, 'C&S',	,sessID)												; ... restore comments/strings
		}
	}
	;############################################################################
	Static RestoreMasksAll(code)															; restores orig code for specified tags
	{
		tagTypes := ['CLS&FUNC','HIF','HK','HS','LBL','IWTLFS','MLPBT','KVO','C&S']			; 2026-04-13 - added MLPBT
		outStr := code
		Mask_R(&outStr, tagTypes)
		; restore any opening-braces that were move temporarily
		nTempMove	:= '(?im)\r\n(\h*\{\h*)\h`;' gTagChar 'TEMP_MOVE_BRC' gTagChar
		While(pos	:= RegexMatch(outStr, nTempMove, &m, pos??1)) {
			match	:= m[], brc := m[1]
			outStr	:= RegExReplace(outStr, match, brc,,,pos)
			pos		+= StrLen(brc)
		}
		return outStr
	}
	;############################################################################
	Static _isolateTrailBraces(code)														; moves trailing braces to their own line (temporarily)
	{
		outStr := '', ntrailBrc := '^(.+?)(\h*\{\h*)$'										; ini output and trailing-brace needle
		tempBrc := ' `;' . gTagChar "TEMP_MOVE_BRC" gTagChar								; tag/msg for braces that will be moved
		lines  := StrSplit(code, '`n', '`r')												; get lines of script
		for idx, line in lines {															; for each line...
			Mask_R(&line, 'LC')																; restore line comments on line
			brc := ''																		; ini
			curLine := separateComment(line, &TC:='')										; separate trailing line comment from rest of line
			if (RegExMatch(curLine, ntrailBrc, &m)) {										; if line has a trailing brace...
				curLine := m[1], brc := '`r`n' m[2] tempBrc									; ... setup vars
			}
			outStr .= (curLine . brc . TC . '`r`n')											; move brace to its own line, reapply line comment
		}
		outStr := RegExReplace(outStr, '`r`n$',,,1)											; remove final (extra) CRLF from output
		Mask_T(&outStr, 'LC')																; 2025-11-01 - remask line comments
		return outStr																		; return updated script
	}
}