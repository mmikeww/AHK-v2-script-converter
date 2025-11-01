/*
	2025-11-01 AMB, ADDED to support Macro-Scope (and eventually Micro-Scope)
	TODO - WORK IN PROGRESS!
		* Sub-divide functions (internal funcs) and classes (methods)
		* Consider grouping HKs found between #IF boundaries
		*	either way, might need to account for left-behind #IFs
*/
;#Include %A_Desktop%\My_AHK\tools\VisCompareV2.ahk											; for error detection

;################################################################################
														   GetScopeSections(code)
;################################################################################
{
; 2025-11-01 AMB, ADDED
;	Separates code into sections, returns SIMPLE sub-strings (for now)
;	Each section contains sub-string blocks for one of the following...
;	 Label, HK, HS, Func, Class, or global (may be multiple global sections)
; Currently returns SIMPLE sub-strings for each section
; TODO:
;	* will eventually output objects that have...
;		... detailed attributes for each of these sections
;	* Sub-divide functions (internal funcs) and classes (methods)

	sects		:= clsScopeSect.GetSections(code)											; separate code into sections
	outSects := []																			; [output array]
	for idx, sect in sects {																; for each section...
		sectStr := codeChop.RestoreMasksAll(sect.GetSectStr)								; ... restore masking
		outSects.Push(sectStr)																; ... update output array
	}
	return outSects																			; return output array (simple sub-strings for each section)
}
;################################################################################
class clsScopeSect
{
	; PRIVATE - individual section properties
	_oStr		:= ''																		; original section string
	Line1		:= ''																		; line 1 [will be tagged/masked declaration (unless global)]
	_L1			:= ''																		; line 1 details (object)
	_tag		:= ''																		; actual tag found on line 1
	_tType		:= ''																		; tag/section type (LBL,HK,HS,FUNC,CLS,GBL)
	_name		:= ''																		; name of LBL/FUNC/CLS, or HK/HS trigger
	PCWS		:= ''																		; comments/CRLFs/WS before block code
	Blk			:= ''																		; block code, up to and including any exit command
	_xCmd		:= ''																		; exit command (full line)
	_xPos		:= ''																		; position of exit command (with masking applied)
	tBlk		:= ''																		; any block code that follows first exit command
	TCWS		:= ''																		; any trailing comments/CRLFs/WS after meaningful block code

	; acts as constuctor
	__new(obj) {
		this._oStr			:= obj.oStr														; orig code for section
		this.Line1			:= obj.sb.Line1													; declaration line (is masked as tag initially, unless global)
		this.Blk			:= obj.sb.Blk													; full block initially [prior to ._exitCmdDetails()]
		this.TCWS			:= obj.sb.TCWS													; trailing comments/CRLFs after meaningful block code (cmds)
		this._tag			:= obj.tag														; actual masked-tag (if present) on Line 1
		this._tType			:= (this._tag)													; section type (if tag is present)
							? getTagType(this._tag)											; ... section type is one of the following [LBL,HK,HS,FUNC,CLS]
							: 'GBL'															; ... otherwise is a global section
		if (this._tType = 'GBL') {															; if section is global
			this.Blk := separatePreCWS(this.Blk, &pre:='')									; ... separate preceding comments/CRLFs from significant blk code
			this.PCWS := pre																; ... [preceding comments/CRLFs before blk code]
		}
		this._exitCmdDetails()																; get details about exit command, its position, and any trailing code
	}

;	; PUBLIC section properties
	GetSectStr	=> this.PCWS . this.Line1 . this.Blk . this.tBlk . this.TCWS				; assemble final section code
	L1			=> this._line1Details														; line 1 details and its parts (public shortcut)
	HasExit		=> !!((this._xCmd && this._xPos) || this.L1.cmd)							; does section have an exit command?

	;################################################################################
	_exitCmdDetails()																		; gets first legit exit command within section code-block
	{
		if (this._tType ~= '(?i)(?:FUNC|CLS)') {											; if func or class...
			this._xCmd := 'return'															; [implied, regrdless]	value doesn't matter for func/cls
			this._xPos := 'end'																; [end of func]			value doesn't matter for func/cls
			return
		}
		if (!(this._tType ~= '(?i)(?:HK|HS|LBL|GBL)')) {									; if not HK,HS,LBL,GBL...
			return																			; ... exit
		}
		sec := this._exitCmdSplit(this.Blk)													; sub-divide code block, extract exit cmd if present
		if (sec.xCmd) {																		; if section has exit cmd...
			this._xCmd		:= sec.xCmd														; ... update exit cmd for section (entire line)
			this._xPos		:= sec.xPos														; ... update exit cmd pos within code-block (with masking applied)
			if (brcBlk := isBraceBlock(this.Blk)) {											; if block already has braces...
				this.Blk	:= brcBlk.TCT . brcBlk.bb										; ... save brace-block details...
				this.tBlk	:= brcBlk.trail													; ... and portion after brace-block (might become new global section)
			}
			else {																			; does not have brace-block already
				this.Blk	:= sec.Blk														; update obj-blk (to include masking) so recorded pos is acurate
				this.tBlk	:= sec.tBlk														; will not be executed within block (might become new global section)
			}
		}
	}
	;################################################################################
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
	;################################################################################
	_line1Details																			; extracts details of Line 1 (declaration lne)
	{
		get {
			if (this._L1)																	; if details have already been parsed...
				return this._L1																; ... return those details
			if (this._tType = 'GBL') {														; if section is global code...
				return (this._L1 := {decl:'',cmd:'',TC:'',LWS:''})							; ... Line1 details are irrelevant
			}
			; not global code - get line1 details
			line1	:= this.Line1															; get line1 (should be masked)
			tag		:= this._tag															; [should already have tag]
			decl	:= tag, Mask_R(&decl, this._tType)										; extract orig code for declaration (not trailing parts)
			line1	:= RegExReplace(line1, tag)												; remove tag from line 1
			Mask_R(&line1, 'C&S')															; restore comments/strings for line 1
			cmd		:= separateComment(line1, &TC:='')										; extract any cmd if present, separate trailing comment
			cmd		:= Trim(cmd)															; trim ws from cmd (causes issues otherwise)
			LWS		:= RegExReplace(cmd, '(\h*).+','$1')									; get leading ws for line1
			return	(this._L1 := {decl:decl,cmd:cmd,TC:TC,LWS:LWS})							; set/return Line 1 details
		}
	}
	;################################################################################
	;###################################  STATIC  ###################################
	;################################################################################
	; STATIC Class properties
	Static codeOrig			:= ''															; original script code
	Static _orderGbl		:= ''															; enables global code to be processed first
	Static Sects			:= []															; array to hold (final) section objects

	;################################################################################
	Static Reset()																			; resets static props (needed for UNIT TESTING)
	{
		this.codeOrig		:= ''
		this._orderGbl		:= ''
		this.Sects			:= []
	}
	Static OrderGbl			=> this._sortSections()

	;################################################################################
	Static GetSections(code)
	{
		this.Reset()																		; resets static vars - required when performing bulk/unit testing
		this.codeOrig	:= code																; save orig code
		sectObj			:= codeChop.MarkSects(code, true)									; mark sections
		; fill raw array
		rawSects := []																		; raw section-block-strings
		for idx, sect in sectObj.chops {													; for each raw section...
			sObj := this._newSect(sect)														; ... create section object
			rawSects.Push(sObj)																; ... add sect obj to raw array
		}
		; rearrange/move trailing comments/CRLFs
		if (rawSects.Length > 1) {
			rawSects := this._shiftTCWS(rawSects)											; rearrange trailing comments/CRLFs
		}
		; finalize sections, create final section array
		dummy := this._rawToFinal(rawSects)													; create final sects array
		; output
		return this.Sects																	; output final sects array
	}
	;################################################################################
	Static _sortSections()																	; organize section-indexes so global-code is processed first
	{
		if (this._orderGbl) {																; if global-index-order has already been determined...
			return this._orderGbl															; ... return order string
		}
		orderStr := '', orderOth := ''														; ini
		for idx, sect in this.Sects {														; for each section...
			if (sect._tType = 'GBL') {														; ... order global sections so they are first to be processed
				orderStr .= idx ','															; ... record index of global sections
			} else {
				orderOth .= idx ','															; ... record index of non-global sections
			}
		}
		orderStr .= orderOth																; place global sections before any other sections
		orderStr := Trim(orderStr, ',')														; cleanup
		return (this._orderGbl := orderStr)													; set/return index order string
	}
	;################################################################################
	Static _cleanCode(code, inclExit:=false)												; removes comments, ws, etc, so executable code is easier to decect
	{
		if (inclExit) {																		; if exit cmds should be removed...
			code := RegExReplace(code, '(?i)\bRETURN\b')									; ... remove return
			code := RegExReplace(code, '(?i)\bEXITAPP\b(?:\(\))?')							; ... remove exitapp
		}
		code := RegExReplace(code, uniqueTag('BC\w+'))										; remove block-comment tags
		code := RegExReplace(code, uniqueTag('LC\w+'))										; remove line-comment tags
		code := RegExReplace(code, '\s')													; remove all whitespace
		return code																			; remainder should be 'executable' code
	}
	;################################################################################
	Static _getSectDetails(sect)															; ensures that sect is a legit target
	{
		sb	 		:= this._splitSect(sect)												; separate line1, sect, and trailing ws/comments
		sbLine1		:= sb.Line1																; [first line of current section]
		Mask_R(&sbLine1, 'C&S')																; restore line1 comments and strings
		sbBlk := sb.Blk, sbTCWS := sb.TCWS													; section blk and trailing ws/comments

		; if section type is one of the following...
		tag := hasTag(sbLine1)																; extract orig contents of tag (line1)
		if (RegExMatch(tag, '(?i)(HK|HS|LBL|BLKCLS|BLKFUNC)', &m))							; if line1 has a valid target tag...
			return {type:m[1],sb:sb,tag:tag}												; return tag and section-parts (obj)

		return {type:'GBL',sb:sb,tag:''}													; must be global section
	}
	;################################################################################
	Static _rawToFinal(rawSects)															; handles global code between sections, creates final Sects array
	{
		; relocate executable global code between sections
		for idx, sect in rawSects {															; for each raw section...
			newGblSectList := []															; ini
			if ((sect._tType ~= '(?i)(?:LBL|HK|HS)')) {										; if section is label,HK,HS...
				if (brcBlk := isBraceBlock(sect.blk)) {										; if section already has braces...
					sec := sect._exitCmdSplit(brcBlk.bbc)									; ... get exit cmd details for brace-block
					if (sec.xCmd															; if brace-block has exit cmd...
					&& this._cleanCode(sect.tBlk)) {										; ... and, section has executable code following brcBlk
						sect._xCmd := sec.xCmd, sect._xPos := sec.xPos						; ... update exit cmd info for current section
						gblBlk := sect.tBlk . sect.TCWS										; ... gather remaining code for current section
						newGblSectList	:= this._makeGblSections(gblBlk)					; ... convert trailing executable code to new section(s)
						sect.tBlk		:= '', sect.TCWS := ''								; ... update current section
					}
					else if (!sec.xCmd) {													; if brace-block has NO exit cmd...
						if (this._cleanCode(brcBlk.trail)) {								; if section has executable code following brcBlk
							sect.Blk := brcBlk.TCT . brcBlk.bb								; ... blk code for cur sect should just be brace-block
							gblBlk	 := brcBlk.trail . sect.TCWS							; ... gather remaining code for current section
							newGblSectList	:= this._makeGblSections(gblBlk)				; ... convert trailing executable code to new section(s)
							sect.tBlk		:= '', sect.TCWS := ''							; ... update current section
						}
						else if (this._cleanCode(sect.tblk)) {								; if section has executable code following brcBlk
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							newGblSectList	:= this._makeGblSections(gblBlk)				; ... convert trailing executable code to new section(s)
							sect.tBlk		:= '', sect.TCWS := ''							; ... update current section
						}
					}
				}
				else {																		; section code DOES NOT have braces
					if (sect.tBlk) {														; if section has code following exitCmd...
						if (sect.HasExit && this._cleanCode(sect.tBlk)) {					; if section has executable code following exitCmd...
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							newGblSectList	:= this._makeGblSections(gblBlk)				; ... convert that executable code to new section
							sect.tBlk		:= '', sect.TCWS := ''							; ... update current section
						}
						else if (idx < rawSects.Length) { ; non-executBLE code				; if current section is not the last section...
							nextPCWS := sect.tBlk . sect.TCWS . rawSects[idx+1].PCWS		; ... gather remaining code for current sect, and beginning of next sect
							rawSects[idx+1].PCWS := nextPCWS								; ... move non-executable code to beginning of next section
							sect.tBlk := '', sect.TCWS := ''								; ... update current section
						}
					}
				}
			}
			else if (sect._tType ~= '(?i)(?:CLS|FUNC)'										; if section is CLS/FUNC...
			&& this._cleanCode(sect.Blk)													; ... and the CLS/FUNC section has trailing executable code...
			&& rawSects.Length > 1) {														; ... and this is not the only section...
				gblBlk			:= sect.Blk . sect.TCWS										; ... 	gather remaining code for current section
				newGblSectList	:= this._makeGblSections(gblBlk)							; ... 	convert global code to new lbl/func
				sect.Blk		:= '', sect.TCWS := ''										; ...	update current section
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
	}
	;################################################################################
	Static _makeGblSections(code)															; 2025-11-01 - creates new global sections from passed code
	{																						;	creates as many sections as code contains
		sectList:= []																		; output array - to return multiple new sections
		done	:= false																	; flag to determine when all sections have been created
		while (!done) {																		; loop until all sections have been created
			cs := this._newGblSect(code)													; create new section from curCode
			if (cs._tType																	; if new section was created...
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
	;################################################################################
	Static _newGblSect(code)																; converts stray global code to label/func
	{
		return this._newSect(code)															; creates section object
	}
	;################################################################################
	Static _newSect(sect)																	; creates section object
	{
		if (!sd := this._getSectDetails(sect))												; validate that section is a legit target
			return false
		return this({oStr:sect,sb:sd.sb,tag:sd.tag})										; create new section object and return it
	}
	;################################################################################
	Static _shiftTCWS(sectsArr)																; moves trailing comments/CRLFs of one sect to beginning of next sect
	{
		for idx, sect in sectsArr {															; for each section in array...
			if (idx = sectsArr.length)														; dont process last section in array (already updated)
				break
			nextSect			:= sectsArr[idx+1]											; get next section
			nextSect.PCWS		:= sect.TCWS . nextSect.PCWS								; move   trailing comments/CRLFs to beginning of next section
			sect.TCWS			:= ''														; remove trailing comments/CRLFs from current section
		}
		return sectsArr																		; return updated array
	}
	;################################################################################
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
}