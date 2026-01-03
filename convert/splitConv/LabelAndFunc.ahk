;################################################################################
; 2025-10-05 Added LabelAndFunc.ahk to organize support/conversion/interaction of...
;	LBL,HK,HS,Func/Class
;################################################################################
; class clsSection - 2025-10-05 AMB, ADDED
; To support new stucture for labels, hotkeys, hotstrings, and...
;	the interaction between them, global-scope-code, and funcs
; The goal of this class is to organize individual LBLs/HKs/HSs,
;	their code-blocks, and the logic flow between them
; Original Funcs/Classes are not a main focus for this class (only as necessary)
; This class separates the original code into sections/chunks. The borders of...
;	... these sections occur where LBL/HK/HS/FUNC/CLS/GLOBAl-CODE meet.
;	Each section holds the code associated with one of those section types.
;################################################################################
class clsSection
{
; 2025-11-01 AMB, UPDATED key case-sensitivity for gmList_LblsToFunc, gmList_GosubToFunc

	; PRIVATE - individual section properties
	_oStr		:= ''																		; original section string
	Line1		:= ''																		; line 1 [will be tagged/masked declaration]
	_L1			:= ''																		; line 1 details (object)
	_tag		:= ''																		; actual tag found on line 1
	_tType		:= ''																		; tag/section type (LBL,HK,HS,FUNC,CLS)
	_name		:= ''																		; name of LBL/FUNC/CLS, or HK/HS trigger
	_nV2FC		:= ''																		; func name to use for labelToFunc conversion
	_nHKFC		:= ''																		; func name to use for HKs that have named-blocks (funcs)
	PCWS		:= ''																		; comments/CRLFs/WS before block code
	Blk			:= ''																		; block code, up to and including any exit command
	_xCmd		:= ''																		; exit command (full line)
	_xPos		:= ''																		; position of exit command (with masking applied)
	_newFunc	:= ''																		; new (entire) func (if being converted to func)
	tBlk		:= ''																		; any block code that follows first exit command
	TCWS		:= ''																		; any trailing comments/CRLFs/WS after meaningful block code

	; acts as constuctor
	__new(obj) {
		this._oStr			:= obj.oStr														; orig code for section
		this.Line1			:= obj.sb.Line1													; declaration line (is masked as tag initially)
		this.Blk			:= obj.sb.Blk													; full block initially [prior to ._exitCmdDetails()]
		this.TCWS			:= obj.sb.TCWS													; trailing comments/CRLFs after meaningful block code (cmds)
		this._tag			:= obj.tag														; actual masked-tag on Line 1
		this._tType			:= (this._tag)													; section type - if tag is present...
							? getTagType(this._tag)											; ...  section type is one of the following [LBL,HK,HS,FUNC,CLS]
							: 'GBL'															; ... otherwise is a global section (may not be necessary)
		if (this._tType = 'GBL') {															; if section is NOT Lbl,HK.HS,FUNC,CLS...
			this.Blk := separatePreCWS(this.Blk, &pre:='')									; ... separate preceding comments/CRLFs from significant blk code
			this.PCWS := pre																; ... [preceding comments/CRLFs before blk code]
		}
		this._extractName()																	; extract the name of LBL/FUNC/CLS, or trigger of HK/HS
		this._exitCmdDetails()																; get details about exit command, its position, and any trailing code
	}

	; PUBLIC section properties
	GetSectStr	=> this.PCWS . this.Line1 . this.Blk . this.tBlk . this.TCWS				; assemble final (converted) section code
	HasExit		=> !!((this._xCmd && this._xPos) || this.L1.cmd)							; does section have an exit command?
	LabelName	=> this._name																; name of LBL/FUNC/CLS, or HK/HS trigger (public shortcut)
	L1			=> this._line1Details														; line 1 details and its parts (public shortcut)
	HasCaller	=> (gmList_LblsToFunc.Has(this.LabelName)									; to assist prevention of empty labelToFunc conversions
				||  gmList_LblsToFunc.Has(this.FuncName)
				|| 	gmList_GosubToFunc.Has(this.LabelName)
				|| 	gmList_GotoLabel.Has(this.LabelName))

	;################################################################################
	HKFunc {	; PUBLIC (mght add validations later)										; func (name) that is sometimes used as HK block code
		; for HKs only - https://www.autohotkey.com/docs/v1/Hotkeys.htm#Function
		get => this._nHKFC
		set => this._nHKFC := value
	}
	;################################################################################
	FuncName {	; PUBLIC (mght add validations later)										; name to use for func when section is converted to func
		get => (this.HKFunc) ? this.HKFunc : ((this._nV2FC) ? this._nV2FC : this._name)
		set => this._nV2FC := value
	}
	;################################################################################
	FuncStr {	; PUBLIC (mght add validations later)										; newly created func that will hold section code
		get => this._newFunc
		set => this._newFunc := value
	}
	;################################################################################
	_addBraces(uniqStr:='', RegexObj:=unset, &fExit:=false)									; adds braces (and conv msgs) to section block
	{
		oBrc	:= '`r`n{ `; V1toV2: Added opening brace' . uniqStr							; opening brace to be added  to top of sect
		glbl	:= '`r`nglobal `; V1toV2: Made function global'								; global keyword to be added to top of sect
		cBrc	:= '`r`n} `; V1toV2: Added closing brace' . uniqStr							; closing brace to be added to sect exit
		fExit	:= false																	; ini, incase no exit found
		blkStr	:= this.Blk																	; initial code block
		if (this.HasExit) {																	; if section has an exit command...
			oExitCmd := this._xCmd, pos := this._xPos										; ... record details about exit cmd line
			rExitCmd := (IsSet(RegexObj))													; if Regex replacement is required...
						? clsSection._applyRegex(oExitCmd, RegexObj)						; ... apply regex changes
						: oExitCmd															; ... otherwise, keep orig exit command
			EOBStr	 := rExitCmd . cBrc														; exit cmd with closing brace
;			blkStr	 := RegExReplace(blkStr, escRegexChars(oExitCmd), EOBStr,,1,pos)		; ! Removes $ by mistake for some reason !
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
	;################################################################################
	; 2025-10-27 AMB, UPDATED
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
				this.Blk	:= brcBlk.TCT . brcBlk.bb										; ... save brace block details...
				this.tBlk	:= brcBlk.trail													; ... and portion after brace block (might become new global lbl/func)
			}
			else {																			; does not have brace block already
				this.Blk	:= sec.Blk														; update obj-blk (to include masking) so recorded pos is acurate
				this.tBlk	:= sec.tBlk														; will not be executed within block (might become new global lbl/func)
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
			xCmdLine	:= m[]																; first exit command
			endPos		:= pos + StrLen(xCmdLine)											; position of last character on return line
			blk			:= SubStr(saveBlk, 1, endPos-1)										; block including return cmd/line
			tBlk		:= SubStr(saveBlk, endPos)											; trailing code after exit cmd - will not be executed within block...
		}																					; ... but might be converted to new label/func (global code)
		return {xCmd:xCmdLine,xPos:pos,blk:blk,tBlk:tBlk}									; return details, whether exitCmd exist or not
	}
	;################################################################################
	_extractName()																			; extracts labelName/Trigger from masked tag on line 1
	{
		tag := this._tag
		if (this._tType = 'LBL') {
			origStr		:= clsMask.GetOrig[tag]
			this._name	:= getV1Label(origStr,0)											; extract label name
			this._nV2FC	:= getV2Name(this._name)											; v2 funcName
		}
		else if (this._tType ~= '(?i)(?:HK|HS)') {
			decl		:= this.L1.decl
			decl		:= RegExReplace(decl, '::$')
			this._name	:= decl																; extract HK/HS trigger
			this._nV2FC	:= this._hkToFuncName[this._name]									; v2 funcName
		}
		else if (this._tType ~= '(?i)FUNC') {
			str := tag, Mask_R(&str, 'CLS&FUNC')
			if (RegExMatch(str, '(?i)^\h*([a-z]\w+)', &m)) {
				this._name	:= m[1]															; extract func name
				this._nV2FC	:= getV2Name(this._name)										; v2 funcName
			}
		}
		else if (this._tType ~= '(?i)CLS') {
			str := tag, Mask_R(&str, 'CLS&FUNC')
			if (RegExMatch(str, '(?i)^\h*class\h+([a-z]\w+)', &m)) {
				this._name	:= m[1]															; extract class name
				this._nV2FC	:= getV2Name(this._name)										; v2 class
			}
		}
	}
	;################################################################################
	_hkToFuncName[hkStr]																	; HK only - creates unique func name based on HK trigger
	{
		get {
			hkName := ''
			if (RegExMatch(hkStr, '(?i)[^a-z]*(\w+.*)', &m)) {								; extract just the alphaNumeric portion of trigger
				hkName := RegExReplace(m[1], '\h+', '_')									; replace ws with underscore
			}
			unique := 'HK' clsSection.NextHKCnt '_'											; HK prefix and unique counter
			return unique RTrim(validV2LabelName(hkName ':'), ':')							; return unique func name
		}
	}
	;################################################################################
	HK_1LineToML()	; support for issue #322												; converts one-line HK to multi-line HK
	{
		if (this._tType != 'HK' || !this.L1.cmd)											; make sure this is HK and has cmd on line1
			return
		this.Blk	:= '`r`n' . this.L1.cmd . '`r`nreturn'									; move Line1 cmd to sect block/body
		LWS			:= this.L1.LWS															; grab Line1 leading ws
		decl		:= this.L1.decl															; grab Line1 declaration
		TC			:= this.L1.TC															; grab Line1 trailing comment
		this.Line1	:= LWS . decl . TC														; remove cmd from Line1
		this._L1	:=	{ decl:	decl														; preserve Line1 declaration
						, cmd:	''															; remove   Line1 cmd from line details
						, TC:	TC															; preserve Line1 trailing comment
						, LWS:	LWS }														; preserve Line1 leading ws
	}
	;################################################################################
	_line1Details																			; extracts details of Line 1 (declaration lne)
	{
		get {
			if (this._L1)																	; if details have already been parsed...
				return this._L1																; ... return those details
			line1	:= this.Line1															; get line1 (should be masked)
			tag		:= this._tag															; [should already have tag]
			decl	:= tag, Mask_R(&decl, this._tType)										; extract orig code for declaration (not trailing parts)
			line1	:= RegExReplace(line1, tag)												; remove tag from line 1
			Mask_R(&line1, 'C&S')															; restore comments/strings for line 1
			cmd		:= separateComment(line1, &TC:='')										; extract any cmd if present, separate trailing comment
			cmd		:= Trim(cmd)															; trim ws from cmd (causes issues otherwise)
			LWS		:= RegExReplace(cmd, '(\h*).+','$1')									; get leading ws for line1
			this._L1:= {decl:decl,cmd:cmd,TC:TC,LWS:LWS}									; save details locally for quick access
			return	this._L1																; return Line 1 details
		}
	}
	;################################################################################
	;###################################  STATIC  ###################################
	;################################################################################
	; STATIC Class properties
	Static codeOrig			:= ''															; original script code
	Static codeTop			:= ''															; code that occurs before any LBL/HK/HS/FUNC/CLS
	Static codeBot			:= ''															; code that occurs after  all LBL/HK/HS/FUNC/CLS sections
	Static Sects			:= []															; array to hold section objects
	Static ToFunc			:= Map_I()														; map to hold all newly created funcs (strings)
	Static LogicFlowStr		:= ''															; string that holds logic-links between sections
	Static GblLblCnt		:= 0															; counter for creating unique label/funcs, from stray global code
	Static HKFuncCnt		:= 0															; counter for creating unique func names, from HKs
	Static NextGblLbl		=> ++this.GblLblCnt												; returns next value for GblLblCnt
	Static NextHKCnt		=> ++this.HKFuncCnt												; returns next value for HKFuncCnt
	Static HasSects			=> (this.Sects.Length > 0)										; does code have any sections at all? (convenience)
	Static SectsStr			=> this._buildSectStr											; final output (convenience)

	;################################################################################
	Static Reset()																			; resets static props (needed for UNIT TESTING)
	{
		this.codeOrig		:= ''
		this.codeTop		:= ''
		this.codeBot		:= ''
		this.Sects			:= []
		this.ToFunc			:= Map_I()
		this.LogicFlowStr	:= ''
		this.GblLblCnt		:= 0
		this.HKFuncCnt		:= 0
	}
	;################################################################################
	Static SectionObj[lblName]																; returns sect obj associated wth lblName param
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
	;################################################################################
	Static Main_ProcessSects(code)															; Main operation for this class
	{
	; 2026-01-01 AMB, UPDATED - added 'Unreachable' directive

		/*
		1. separate code into sections
			each section will be one of the following (lbl,hk,hs,func,class)
			there will also be a top global section, and trailing code section
		2. if ANY lbls will be converted to func...
			plan to convert ALL labels to func, but also keep orig labels intact
			a. convert multi-line HKs to func, and move these funcs below global code
				call HK funcs using same-line func calls
				leave orig same-line HKs as is
				leave orig pass-thru HKs as is
			b. convert multi-line HSs to func, but dont move code
				leave orig same-line HSs as is
				leave orig pass-thru HSs as is
			c. stray global code between lbl,hk,hs,func,class...
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
			update func params for v2 comatibility, as needed
		*/

		clsSection.Reset()																	; resets static vars - required when performing bulk/unit testing
		rawSects	:= this._getRawSects(code)												; get raw sections from orig code
		rawSects	:= this._shiftTCWS(rawSects)											; rearrage comments/CRLFs between sections
		dummy		:= this._rawToFinal(rawSects)											; organize global code between sects, create final Sects array
		newFuncList	:= ''																	; ini
		if (this.HasSects) {																; if sections were established...
			flowStr		:= this._logicFlow													; determine logic flow between sections
			dummy		:= this._hkhsToFunc()												; convert HK/HS to funcs (will be added in next step)
			newFuncList	:= this._buildFuncsList()											; string with all new funcs, to be added to lower portion of script
			lowerSect	:= separateTrailCWS(this.codeBot, &TCWS:='', false)					; extracts trailing comments/CRLFs so they remain at bottom of script
			code := this.codeTop . this.SectsStr . lowerSect . newFuncList . TCWS			; assemble new script-code format
		}
		code := this._updateLblToFuncs(code)												; adds v2 formatting to new label funcs
		code := this._gotoToFC_orig(code)													; converts goto to funcCalls as needed (for orig script funcs only)
		code := codeChop.RestoreMasksAll(code)												; removes temp-masking, performs cleanup of script code
		code := this._gosubUpdate(code)														; update Gosub calls (to reflect changes made here, and fix issue #322)
		if (newFuncList)																	; if labels/HKs were converted to funcs...
			code := '#Warn Unreachable, Off`r`n' . code										; ... prevent 'unreachable' warning (add to top of script)
		return code																			; return updated script code
	}
	;################################################################################
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
	;################################################################################
	Static _applyRegex(srcStr, RegexArr)													; applies regex replacements as required some sect/blks
	{
		if (Type(RegexArr)='array') {														; if regexs are available in RegexArr...
			for idx, obj in RegexArr {														; ... apply all regex replacements (can be more than 1)
				if (obj.NeedleRegEx) {
					loop {																	; ensure all replacements are made within srcStr
						saveSrcStr := srcStr												; will be used to control loop exit
						srcStr := RegExReplace(srcStr, obj.NeedleRegEx, obj.Replacement)	; apply replacement as necessary
					} Until (srcStr = saveSrcStr)											; exit loop when ALL occurence are replaced
				}
			}
		}
		return srcStr
	}
	;################################################################################
	Static _buildFuncsList()																; gathers all new funcs into single string
	{
		if (!funcListStr := this._makeFuncsStr()) {											; if funcListStr creation is NOT successful...
			return ''																		; ... return empty str
		}
		div			:= StrReplace(Format('{:15}',''),' ','#')								; generic divider
		divline		:= '`r`n`r`n`;' div '  V1toV2 FUNCS  ' div								; mark very top of func list
		return		divLine . funcListStr													; return func list string
	}
	;################################################################################
	Static _buildSectStr																	; assembles all (final) section strings into single string
	{
		get {
			outStr := ''
			for idx, sect in this.Sects
				outStr .= sect.GetSectStr													; add each section string to output
			return outStr
		}
	}
	;################################################################################
	; 2025-10-27, 2026-01-01 AMB, UPDATED
	Static _cleanCode(code, inclExit:=false)												; removes comments, ws, etc, so executable code is easier to decect
	{
		if (inclExit) {																		; if exit cmds should be removed...
			code := RegExReplace(code, '(?i)\bRETURN\b')									; ... remove return
			code := RegExReplace(code, '(?i)\bEXITAPP\b(?:\(\))?')							; ... remove exitapp
		}
		code := cleanCWS(code)																; remove comments, and whitespace (see MaskCode.ahk)
		return code																			; remainder should be 'executable' code
	}
	;################################################################################
	Static _extractL1(obj)																	; sub-divides line 1 into its sub-components
	{
		if (!(obj._tType ~= '(?i)(?:HK|HS)'))												; line 1 parts are only important for HK,HS
			return false
		line1	:= obj.Line1																; get full line1 (should be masked)
		tag		:= obj._tag																	; line 1 tag (masked declare)
		decl	:= tag, Mask_R(&decl, obj._tType)											; restore orig declare
		line1	:= RegExReplace(line1, tag)													; remove tag from line 1
		Mask_R(&line1, 'C&S')																; restore line1 comments and strings
		cmd		:= separateComment(line1, &TC:='')											; separate cmd from trailing comment
		LWS		:= RegExReplace(cmd, '(\h*).+','$1')										; get leading ws for line 1
		return	{decl:decl,cmd:cmd,TC:TC,LWS:LWS}											; return extracted parts
	}
	;################################################################################
	Static _getRawSects(code)																; separates script code into raw sections (LBL,HK,HS,FUNC,CLS)
	{
	; 2025-11-18 AMB, UPDATED as part of fix for #409

		this.codeOrig	:= code																; save original script code
		incLBL			:= this._hasL2F														; 2025-11-18 AMB, UPDATED as part of fix for #409
		sectObj			:= codeChop.MarkSects(code, incLBL)									; add chop/section markers to code
		rawSects		:= []																; output array
		for idx, sect in sectObj.chops {													; for each script section...
			if (idx = 1) {																	; if current code is above first tagged section...
				this.codeTop := sect														; ... capture code located above first tagged section
			}
			else if (sObj := this._newSect(sect)) {											; if cur section is valid/targ section...
				if (idx = sectObj.chops.Length) {											; if last section...
					this.codeBot := sObj.TCWS, sObj.TCWS := ''								; ... relocate trailing comments/CRLFs from cur sect to lower script sect
				}
				rawSects.Push(sObj)															; ... add section object to array
			}
		}
		return rawSects																		; return array of raw sections
	}
	;################################################################################
	; Goto Label -> label()... for labels converted to funcs
	;	targets gotos within orig func/cls ONLY, not global Goto's or those in new funcs
	;################################################################################
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
	;################################################################################
	; Goto Label -> label()... for labels converted to funcs
	;	targets gotos within newly created funcs ONLY
	;################################################################################
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
	;################################################################################
	Static _gosubUpdate(code)																; handles v1 Gosub to v2 funcCall conversion
	{
	; 2025-11-01 AMB, UPDATED key case-sensitivity for gmList_GosubToFunc

		Mask_T(&code, 'C&S')																; mask comments/strings (since src code has already been restored)
		outStr := ''																		; ini output
		nGosub := '(?i)(GOSUB\h+)([^\s]+)(.*)'												; gosub needle [only supports changes made in _Gosub()]
		for idx, line in StrSplit(code, '`n', '`r') {										; for each line in script...
			if (pos := InStr(line, 'gosub')) {												; get position of Gosub call, if present
				leftStr := SubStr(line, 1, pos-1)											; capture characters before Gosub
				if (RegExMatch(line, nGosub, &m, pos)) {									; capture	Gosub call details
					GS := m[1], Lbl := m[2], trail := m[3]									; save		Gosub call details
					if (gmList_GosubToFunc.Has(Lbl)) {										; if label was recorded in _Gosub()...
						if (obj := clsSection.SectionObj[Lbl]) {							; ... if object is avail for label
							funcName:= obj.sect.FuncName									; ...	get func name (may be different than labelname)
							msg		:= ' `; V1toV2: Gosub'									; ...	[conv msg to user]
							line	:= leftStr . funcName . '()' . msg . trail				; ...	replace Gosub call with func call
						}
						else {																; ... UNKNOWN label - probably not global (located in a func maybe?)
							msg		:= ' `; V1toV2: Gosub (Manual edit required)'			; ... 	flag Gosub call as a manual edit
							line	:= leftStr . GS . Lbl . msg . trail						; ...	add mssg to Gusub call
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
	;################################################################################
	; does script require ANY label conversions? (label to func)
	;	if lblName is passed, will only be true when lblName requires conversion
	;################################################################################
	Static _hasL2F[lblName:='']																; to determine whether label(s) will be conv to func
	{
	; 2025-11-01 AMB, UPDATED key case-sensitivity for...
	;	... gmList_LblsToFunc, gmList_GosubToFunc
	; 2025-11-18 AMB, UPDATED as part of fix for #409

		get {
			if (lblName) {
				return (gmList_LblsToFunc.Has(lblname)										; true if LBLName requires conversion
						|| gmList_GosubToFunc.Has(lblname)
						|| gmList_GotoLabel.Has(lblname))									; 2025-11-18 ADDED as part of fix for #409
			}
			return	!!(gmList_LblsToFunc.Count												; true when ANY label requires conversion
					|| gmList_GosubToFunc.Count
					|| gmList_GotoLabel.Count )												; 2025-11-18 ADDED as part of fix for #409
		}
	}
	;################################################################################
	static _hkhsToFunc()																	; deals with HK,HS 'labels'
	{
		wcFuncsToUpdate := Map_I()															; used to track named-blocks for HKs (for adding wildcard param)

		; convert HK/HS to func as needed
		for idx, sect in this.Sects {

			;########################################################################
			; first, weed out situations to skip
			if (sect._tType = 'BLKFUNC') {													; if section is a func (tag)...
				if (wcFuncsToUpdate.Has(sect._tag)											; ... if that func requires wildcard param...
				&& funcCode := this._addWildcardParam(sect))								; ... AND the param is successfully added...
					sect.Line1 := funcCode													; ...	update line 1 to include wildcard param
				continue																	; ... continue to next section
			}
			else if (!(sect._tType ~= '(?i)(?:HK|HS)')) {									; if not HK/HS (is label)...
				continue																	; ... skip it, goto next section
			}
			else if (sect._tType = 'HK' && sect.HasCaller) {								; if is HK and has a caller (gosub, goto)
				; allow bypass, to HK checks below											; ... drop to HK checks below (support for Issue #322)
			}
			else if (sect.L1.cmd) {															; if cmd on same line as HK/HS...
				continue																	; ... skip it, goto next section
			}
			else if (blkDetails := isBraceBlock(sect.Blk)) {								; if already has brace-blk...
				continue																	; ... skip it, goto next section
			}
			else if (idx < this.Sects.length && !sect.Blk) {								; [if no cmd on line 1], and has no code block...
				nextSect := this.sects[idx+1]												; ... get next section
				nextType := nextSect._tType													; ... get next section type
				if (nextType ~= '(?i)(?:HK|HS)') {											; if next section is also HK/HS...
					sect.FuncStr := 'SKIP'													; ... flag it so NO func is created later
					continue																; ... is pass-thru... skip it, goto next section
				}
				else if (nextType = 'BLKFUNC') {											; if next section is a func...
					wcFuncsToUpdate[nextSect._tag] := sect.LabelName						; ... flag func (tag) to be updated with new wilcard param
					sect.FuncName := nextSect.LabelName										; ... update funcName for current sect so it points to named-func
					continue																; ... continue to next section
				}
			}
			;########################################################################
			; handle HK/HS situations
			lblName	 := sect.LabelName														; get HK/HS declaration
			; HotStrings
			if (sect._tType = 'HS' && sect.Blk) {											; if is HS AND has code to execute [but no cmd on L1]...
				uniqStr	 := ' for [' trim(lblName) ']'										; ... include HS trigger in msg...
				sect.Blk := sect._addBraces(uniqStr)										; ... surround code-block with braces (convert to func)
				continue
			}
			; HotKeys
			if (sect._tType = 'HK'															; if is HK... (support for Issue #322)
				&& sect.L1.cmd																; ... AND has cmd on Line1
				&& sect.HasCaller) {														; ... AND HK has a caller (gosub,goto)
					sect.HK_1LineToML()														; ...	convert single line HK to multi-line HK
					this._makeFuncHK(&sect)													; ...	convert HK to func (will be moved below global code)
					continue
			}
			nextLink := this._nextLogicLink(lblName)										; get next link in logic-chain
			if (sect._tType = 'HK'															; if is HK...
				&& (sect.Blk || nextLink))	{												; ... AND has code to execute OR will execute code elsewhere...
				if (this._hasL2F)			{												; ... if ANY labels will be converted to func...
					this._makeFuncHK(&sect)													; ...	convert HK to func (will be moved below global code)
				}																			;		[will be added to script in _makeFuncsStr()]
				else						{												; ... NO labels will be converted to func, so...
					uniqStr	 := ' for [' trim(lblName) ']'									; ... 	[include HK trigger in msg]
					sect.Blk := sect._addBraces(uniqStr)									; ... 	surround code-block with braces, but don't move it
				}
			}
		}
	}
	;################################################################################
	Static _labelFromTag(tag)																; extracts label name from a masked tag
	{	; TODO - add tag validation

		origStr	:= clsMask.GetOrig[tag]														; get orig code from tag
		return	getV1Label(origStr,0)														; extract/return label name
	}
	;################################################################################
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
				if (!(curSect._tType ~= '(?i)(?:HK|HS|LBL)')) {								; if cur section is Not HK,HS,LBL...
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
					if (nextSect._tType = 'HS') {											; if next section is HS...
						flowStr .= curLabel xChar	; ✖									; ... mark HS as terminated (not a pass-thru)
						break																; ... goto next section
					}
					if (curSect._tType = 'HK'												; if current section is HK...
						&& !curSect.Blk														; ... and HK has NO code to execute
						&& nextSect._tType ~= '(?i)FUNC') {									; ... and next sect is a func...
						flowStr .= curLabel xChar	; ✖									; ... mark HK as terminated (has named func)
						break																; ... goto next section
					}
					if (curSect._tType = 'HK'												; if current section is HK...
						&& curSect.Blk														; ... and HK has code to execute [but no exit cmd]...
						&& nextSect._tType = 'HK') {										; ... and next sect is also HK
						flowStr .= curLabel xChar	; ✖									; ... mark cur HK as terminated (not a pass-thru)
						break																; ... goto next section
					}
					if (curSect._tType = 'HK'												; if current section is HK
						&& curSect.Blk														; ... and HK has code to execute [but no exit cmd]...
						&& nextSect._tType = 'LBL') {										; ... and next sect is a LBL
						flowStr .= curLabel pChar	; ⟼									; ... mark HK as pause, exec, continue
						break																; ... goto next section
					}
					if (curSect._tType = 'LBL'												; if current section is a label
						&& curSect.Blk) {													; ... and LBL has code to execute [but no exit cmd]...
						flowStr .= curLabel pChar	; ⟼									; ... mark LBL as pause, exec, continue
						break																; ... goto next section
					}
					; ADD MORE TERMINTION CHECKS AS NEEDED

					; Any other scenerio for next section... catch all
					if (nextSect._tType ~= '(?i)(?:HK|HS|LBL)'){							; if next section is a lBL/HK/HS...
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
	;################################################################################
	Static _makeFuncHK(&obj)																; creates BrcBlk/func (and funcCall) from HK code, as needed
	{
		if (obj._tType != 'HK'																; if not a HK...
		||  obj.L1.cmd) {																	; ... OR HK has cmd on its own line...
			return ''																		; ... no processing req here
		}

		nextLink := this._nextLogicLink(obj.LabelName)										; get next link in logic-chain after this one (if present)
		if (!obj.Blk && !nextLink) {														; if HK has no block/body, and no next-link...
			return ''																		; ... no change/func required
		}

		outFunc	:= ''																		; ini output
		blk		:= obj.Blk, blk := codeChop.RestoreMasksAll(blk)							; get current block/body, and restore its orig code
		Mask_T(&blk, 'C&S')																	; ... but we need comments/strings masked
		lblName	:= obj.LabelName															; get HK trigger str
		convMsg	:= ' `; V1toV2: HK->Func'													; msg to user about new func creation

		; does HK block/body already have braces?
		if (bbObj := isBraceBlock(blk)) {													; if body already has braces...
			blk			:= bbObj.bbc														; extract just the guts of that body (without braces)
			blk			:= '`;global' blk													; add global keyword, but comment out (will be used as landmark later)
			funcName	:= getV2Name(lblName)
			func_DnC	:= funcName '()'													; create func declaration/call, with no params
			obj.Line1	:= obj.L1.LWS obj.L1.decl func_DnC obj.L1.TC						; add any ws and trailing comments to func call for HK line
			outFunc		:= func_DnC bbObj.TCT '{' convMsg '`r`n' blk '}'					; create entire func
			this.ToFunc[funcName] := outFunc												; add func to funclist, using funcname as key
			obj.FuncStr	:= outFunc															; add func to HK obj so it can be added to code later
			obj.Blk		:= ''																; remove HK code-body from obj
			return		outFunc																; return the new func (if needed by caller and to flag success)
		}

		; body does not (already) have braces
		blk	:= this._gotoToFC_new(blk)														; convert any Goto within HK code-block to funcCall
		blk	:= 'global' blk																	; add global keyword to beginning of body/blk
		if (nextLink && !obj._xCmd) {														; if there is a next-logic-link, and no exit command...
			if (nxSect := this.SectionObj[nextLink]) {										; ... get the section obj for the next link
				blk .= '`r`n' nxSect.sect.FuncName '()'										; ... create funcCall for next-link, append call to body
			}
		}
		funcName	:= obj.FuncName
		func_DnC	:= funcName . '()'														; create func declaration/call, with no params
		obj.Line1	:= obj.L1.LWS . obj.L1.decl func_DnC obj.L1.TC							; add any ws and trailing comments to func call for HK line
		obj.tBlk	:= (obj.hasExit) ? '`r`n' obj._xCmd . obj.tBlk : obj.tBlk				; 2025-10-23 UPDATED to fix missing trailing code
		outFunc		:= func_DnC ' {' convMsg '`r`n' . blk . '`r`n}'							; create entire func
		this.ToFunc[funcName] := outFunc													; add func to funclist, using funcname as key
		obj.FuncStr	:= outFunc																; add func to HK obj so it can be added to code later
		obj.Blk		:= ''																	; remove HK code-body from obj
		return		outFunc																	; return the new func (if needed by caller and to flag success)
	}
	;################################################################################
	; 2025-10-26 AMB, UPDATED
	Static _makeFuncLBL(&obj)																; creates BrcBlk/func (and funcCall) from LBL code, as needed
	{
		if (obj._tType != 'LBL') {															; process for labels only
			return ''
		}
		if (!obj.Blk && !obj.HasCaller) {													; if label has no block/body and no caller...
			return ''																		; ... prevent empty/useless labelToFunc conversion
		}

		; ini
		outFunc	 := ''																		; ini output
		blk		 := obj.Blk, blk := codeChop.RestoreMasksAll(blk)							; get current block/body, and restore its orig code
		Mask_T(&blk, 'C&S')																	; ... but we need comments/strings masked
		lblName	 := obj.LabelName															; get label name
		convMsg	 := ' `; V1toV2: Lbl->Func'													; msg to user about new func creation
		nextLink := this._nextLogicLink(lblName)											; get next link in logic-chain after this one (if present)

		; does lbl block/body already have braces?
		if (bbObj := isBraceBlock(blk)) {													; if body already has braces...
			blk	:= bbObj.bbc																; extract just the guts of that body (without braces)
			blk	:= '`;global' blk															; add global keyword, but comment out (will be used as landmark later)
			if (nextLink && !obj._xCmd) {													; if there is a next-logic-link, and no exit command...
				if (nxSect := this.SectionObj[nextLink]) {									; ... get the section obj for the next link
					blk .= '`r`n' nxSect.sect.FuncName '()`r`n'								; ... create funcCall for next-link, append call to body
				}
			}
			funcName	:= getV2Name(lblName)												; get name to use for new func
			func_DnC	:= funcName . '()'													; create func declaration/call, with no params
			outFunc		:= func_DnC bbObj.TCT '{' convMsg '`r`n' blk '}'					; create entire func
			this.ToFunc[funcName] := outFunc												; add func to funclist, using funcname as key
			obj.FuncStr	:= outFunc															; add func to Lbl obj so it can be added to code later
			obj.Blk		:= '`r`n' func_DnC													; replace orig blk/body with a func call
			exitCmd		:= RegExReplace(obj._xCmd, '(?i)^(\h*RETURN).*', '$1')				; 2025-10-27 - remove anything following Return cmd
			obj.Blk		.= (exitCmd) ? ('`r`n' . exitCmd) : '`r`nreturn'					; add any orig-lbl exit-command after func call, otherwise add simple return
			return		outFunc																; return the new func
		}

		; body does not (already) have braces
		blk	:= this._gotoToFC_new(blk)														; convert any Goto within LBL code-block to funcCall
		blk	:= 'global' blk																	; add global keyword to beginning of body/blk
		if (nextLink && !obj._xCmd) {														; if there is a next-logic-link, and no exit command...
			if (nxSect := this.SectionObj[nextLink]) {										; ... get the section obj for the next link
				blk .= '`r`n' nxSect.sect.FuncName '()'										; ... create/add func call for next link
			}
		}
		funcName	:= getV2Name(lblName)													; get name to use for new func
		func_DnC	:= funcName . '()'														; create func declaration/call, with no params
		outFunc		:= func_DnC ' {' convMsg '`r`n' . blk . '`r`n}'							; create entire func
		this.ToFunc[funcName] := outFunc													; add func to funclist, using funcname as key
		obj.FuncStr	:= outFunc																; add func to Lbl obj so it can be added to code later
		obj.Blk		:= '`r`n' func_DnC														; replace orig blk/body with a func call
		exitCmd		:= RegExReplace(obj._xCmd, '(?i)^(\h*RETURN).*', '$1')					; 2025-10-27 - remove anything following Return cmd
		obj.Blk		.= (exitCmd) ? ('`r`n' . exitCmd) : '`r`nreturn'						; add any orig-lbl exit-command after func call, otherwise add simple return
		return		outFunc																	; return the new func
	}
	;################################################################################
	Static _makeFuncsStr()																	; creates single string containing all newly created funcs
	{
		if (!this._hasL2F) {																; if NO labels will be converted to funcs...
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
	;################################################################################
	Static _makeGblSections(code)															; 2025-10-27 - creates new global sections from passed code
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
	; 2025-10-27 AMB, UPDATED
	Static _newGblSect(code)																; converts stray global code to label/func
	{
		if (RegExMatch(code, '(?s)^(\s*)(.*)', &m)) {										; separate lead ws from code
			LWS := m[1], code := m[2]
		}
		lblCnt		:= this.NextGblLbl														; get unique value for label name
		lbl			:= 'V1toV2_GblCode_' . Format('{:03}',lblCnt) . ':'						; make/format label str
		Mask_T(&lbl, 'LBL')																	; mask the label for consistency
		sectObj		:= this._newSect(lbl '`r`n' code)										; create section object
		sectObj.PCWS:= LWS																	; reapply LWS (ensure section will start on new line)
		return		sectObj																	; return section object
	}
	;################################################################################
	Static _newSect(sect)																	; creates section object
	{
		if (!vs := this._validateSect(sect))												; validate that section is a legit target
			return false
		return clsSection({oStr:sect,sb:vs.sb,tag:vs.tag})									; create new section object and return it
	}
	;################################################################################
	Static _nextLogicLink(curLbl)															; identifies next logical section that will be executed (from curLbl)
	{
		; build needle to find next link after curlbl (will not capture curLbl)
		term	:= '(?<term>[' gPauseChar gExitChar ']|$)'
		lbl		:= '(?<lbl>[^' gJumpChar gPauseChar gExitChar ']+)'
		path1	:= '[' gJumpChar gPauseChar ']'
		paths	:= '(?:' lbl gJumpChar ')*'
		targ	:= '(?<targ>(?&lbl))'
		nFlow	:= escRegexChars(curLbl) . path1 . paths . targ . term
		; curLbl[⟹⟼](?:(?<lbl>[^⟹⟼✖]+)⟹)*(?<targ>(?&lbl))(?<term>[⟼✖]|$)		; does not capture curLbl

		flowStr	:= this._logicFlow															; get logic flow reference string
		if (RegExMatch(flowStr, nFlow, &m)) {												; if next link is available...
			return m.targ																	; ... return next link
		}
		return ''																			; next-link not found
	}
	;################################################################################
	; 2025-10-27 AMB, UPDATED
	Static _rawToFinal(rawSects)															; handles global code between sections, creates final Sects array
	{
		; relocate executable global code between sections
		fConvGblOK := false																	; controls whether global code should be conv to lbl/func
		for idx, sect in rawSects {															; for each raw section...
			newGblSectList := []															; ini
			if ((sect._tType ~= '(?i)(?:LBL|HK|HS)')) {										; if section is label,HK,HS...
				if (brcBlk := isBraceBlock(sect.blk)) {										; if section already has braces...
					sec := sect._exitCmdSplit(brcBlk.bbc)									; ... get exit cmd details for brace-block
					if (sec.xCmd															; if brace-block has exit cmd...
					&& this._cleanCode(sect.tBlk)) {										; ... and, section has executable code following brcBlk
						sect._xCmd := sec.xCmd, sect._xPos := sec.xPos						; ... update exit cmd info for current section
						gblBlk := sect.tBlk . sect.TCWS										; ... gather remaining code for current section
						if (this._cleanCode(gblBlk, true)) {								; ... if executable code is something other than just exitCmds...
							newGblSectList	:= this._makeGblSections(gblBlk)				; ... convert trailing executable code to new section
							sect.tBlk		:= '', sect.TCWS := ''							; ... update current section
						}
						fConvGblOK	:= false												; ... don't allow global code to be called ? (TODO - MAKE SURE THIS IS CORRECT)
					}
					else if (!sec.xCmd) {													; if brace-block has NO exit cmd...
						if (this._cleanCode(brcBlk.trail)) {								; if section has executable code following brcBlk
							sect.Blk := brcBlk.TCT . brcBlk.bb								; ... blk code for cur sect should just be brace-blk
							gblBlk	 := brcBlk.trail . sect.TCWS							; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk)			; ... convert trailing executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ... update current section
								fConvGblOK		:= true										; ... allow executable global code to be called (see below)
							}
						}
						else if (this._cleanCode(sect.tblk)) {								; if section has executable code following brcBlk
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk)			; ... convert trailing executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ... update current section
								fConvGblOK		:= true										; ... allow executable global code to be called (see below)
							}
						}
					}
				}
				else {																		; section code DOES NOT have braces
					if (sect.tBlk) {														; if section has code following exitCmd...
						if (sect.HasExit && this._cleanCode(sect.tBlk)) {					; if section has executable code following exitCmd...
							gblBlk := sect.tBlk . sect.TCWS									; ... gather remaining code for current section
							if (this._cleanCode(gblBlk, true)) {							; ... if executable code is something other than just exitCmds...
								newGblSectList	:= this._makeGblSections(gblBlk)			; ... convert that executable code to new section
								sect.tBlk		:= '', sect.TCWS := ''						; ... update current section
							}
						}
						else if (idx < rawSects.Length) { ; non-executBLE code				; if current section is not the last section...
							nextPCWS := sect.tBlk . sect.TCWS . rawSects[idx+1].PCWS		; ... gather remaining code for current sect, and beginning of next sect
							rawSects[idx+1].PCWS := nextPCWS								; ... move non-executable code to beginning of next section
							sect.tBlk := '', sect.TCWS := ''								; ... update current section
						}
					}
					fConvGblOK := (this._hasL2F && !sect.HasExit)							; allow gbl code calls when sect has no exit, and lbls will be conv to func
				}
			}
			else if (sect._tType ~= '(?i)(?:CLS|FUNC)'										; if section is CLS/FUNC...
			&& fConvGblOK																	; ... and gbl code will have a caller...
			&& this._cleanCode(sect.Blk)													; ... and the CLS/FUNC section has trailing executable code...
			&& rawSects.Length > 1) {														; ... and this is not the only section...
				gblBlk			:= sect.Blk . sect.TCWS										; ... 	gather remaining code for current section
				newGblSectList	:= this._makeGblSections(gblBlk)							; ... 	convert global code to new lbl/func
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
		return {Line1:L1,Blk:blk,TCWS:TCWS}													; return separated parts
	}
	;################################################################################
	Static _updateLblToFuncs(code)															; applies A_GuiEvent/A_GuiControl params/vars, Regex replacements
	{
	; 2025-11-01 AMB, UPDATED key case-sensitivity for gmList_LblsToFunc

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
			if (InStr(declare, 'A_GuiControl') && gaScriptStrsUsed.A_GuiControl) {			; add A_GuiControl vars to block (as needed)
				guiContStr := 'A_GuiControl := HasProp(A_GuiControl, "Text") '
							. '? A_GuiControl.Text : A_GuiControl'
				brcBlk := RegExReplace(brcBlk, '(?im)^(`;?global)$', '$1`r`n' guiContStr)	; use 'global' keyword to determine placement of new vars
			}
			funcStr := declare . TCT . brcBlk												; rebuild func
			for idx, reObj in L2F_Obj.RegExList {											; apply regexs as needed
				funcStr := this._applyRegex(funcStr, L2f_Obj.RegExList)						; perform ALL occurences of ALL needles
			}
			code := RegExReplace(code,escRegexChars(origStr),funcStr,,1,pos)				; apply updates to orig code
			;code := StrReplaceAt(code, orig, funcStr,, pos, 1)
			pos += StrLen(funcStr)															; prep for next func search
		}
		return code																			; return updated code
	}
	;################################################################################
	Static _validateSect(sect)																; ensures that sect is a legit target
	{
		if (!Trim(sect))																	; if section is empty...
			return false																	; ... invalid

		; prep section blk
		Mask_T(&sect, 'C&S')																; mask comments and strings
		sb	 		:= this._splitSect(sect)												; separate line1, sect, and trailing ws/comments
		sbLine1		:= sb.Line1																; [first line of current section]
		Mask_R(&sbLine1, 'C&S')																; restore line1 comments and strings
		sbBlk := sb.Blk, sbTCWS := sb.TCWS													; section blk and trailing ws/comments

		; make sure first line is a target tag
		tag := hasTag(sbLine1)																; extract orig contents of tag (line1)
		if (!(tag ~= '(?i)(HK|HS|LBL|BLKCLS|BLKFUNC)'))										; if line1 does not have a valid target tag...
			return false																	; ... invalid

		return {sb:sb,tag:tag}																; return tag and section-parts (obj)
	}
}

;################################################################################
;################################################################################
class codeChop	; responsible for marking script code with tags that separate sections
{
	Static _chopTag := ';[' . gTagChar . 'CHOP' . gTagChar . ']`r`n'						; ;[★CHOP★]

	;################################################################################
	; PUBLIC - adds tags ;[★CHOP★] to mark declarations of CLS/FUNC/HK/HS/LBL...
	;	... so each 'code-sect' can be found/isolated easily for processing
	; output (three forms): code with chopTags, array of sects (chops), chopTag itself
	Static MarkSects(code, fLabels:=false, restorePM:=false)
	{
		this.MaskSects(&code, fLabels, restorePM)											; perform masking to prep for sect identification
		nTargBlks	:= 'BLKCLS|BLKFUNC|HK|HS'												; needle for specific tag types
		;nTargBlks	.= (fLabels) ? '|LBL|LBLBLK' : ''										; include labels if requested
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
	;################################################################################
	Static MaskSects(&code, fLabels:=false, restorePM:=false)								; masks section declarations, funcs, classes
	{
		sessID := clsMask.NewSession()														; new masking session for isolation
		Mask_T(&code, 'C&S',1,sessID)														; mask comments/strings
		Mask_T(&code, 'HIF', ,sessID)														; mask HotIfs
		code := this._isolateTrailBraces(code)												; move opening braces to their own line
		sectTypes := ['CLS&FUNC','HK','HS']													; look for FUNC, CLS, HK. HS...
		if (fLabels) {
			sectTypes.Push('LBL') ;, sectTypes.Push('LBLBLK')								; ... and labels if requested
		}
		Loop sectTypes.Length {
			mType := sectTypes[A_Index]
			Mask_T(&code, mType,,,false)													; mask all section types
		}
		if (restorePM) {																	; if requested...
			Mask_R(&code, 'V1MLS',	,sessID)												; ... restore legacy ML strings
			Mask_R(&code, 'C&S',	,sessID)												; ... restore comments/strings
		}
	}
	;################################################################################
	Static RestoreMasksAll(code)															; restores orig code for specified tags
	{
		tagTypes := ['CLS&FUNC','HIF','HK','HS','LBL','V1MLS','IWTLFS','KVO','C&S']
		outStr := code
		for idx, tag in tagTypes {
			Mask_R(&outStr, tag)															; restore orig code for tags specified
		}
		; restore any opening-braces that were move temporarily
		nTempMove	:= '(?im)\r\n(\h*\{\h*)\h`;' gTagChar 'TEMP_MOVE_BRC' gTagChar
		While(pos	:= RegexMatch(outStr, nTempMove, &m, pos??1)) {
			match	:= m[], brc := m[1]
			outStr	:= RegExReplace(outStr, match, brc,,,pos)
			pos		+= StrLen(brc)
		}
		return outStr
	}
	;################################################################################
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
;################################################################################
; structured class to replace details found in gaList_LblsToFuncO
; see gmList_LblsToFunc now, and clsSection_updateLblToFuncs()
; holds details related to label conversions for the following hosts...
;	HK - Hotkey, HS - HotString, MN - Menu, ST - SetTimer,
;	OX - OnExit, OOC - OnClipbordChnge, GUI - gui, AG - A_Gui
;################################################################################
class ConvLabel
{
	hostType	:= ''																		; host type - HK, HS, MN, ST, OX, OOC, GUI, AG
	labelName	:= ''																		; label name that is being called
	params		:= ''																		; func params if applicable for host
	funcName	:= ''																		; func name if applicable
	RegExList	:= []																		; rexex needles and replacements - array of map objs

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
														   Update_LBL_HK_HS(code)
;################################################################################
{
; 2025-10-05 AMB, ADDED
; provides access to conversion of Labels, HK, HS thru clsSection.Main_ProcessSects()
; attempts to overcome limitations caused by the removal of Gosub from AHKv2,
;	and allow the combination of Goto and func calls to behave the same as...
;	they did in v1 script...

	code := clsSection.Main_ProcessSects(code)
	code := fixLabelNames(code)																; ensure no name conflicts for labels/funcs
	return code
}
;################################################################################
															  fixLabelNames(code)
;################################################################################
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
														scriptHasLabel(labelName)
;################################################################################
{
; 2025-11-01 AMB, ADDED - determines whether v1 script has specified label
	return (gAllV1LabelNames ~= '(?i)\b' labelName ',')
}
;################################################################################
														  scriptHasFunc(funcName)
;################################################################################
{
; 2025-11-01 AMB, ADDED - determines whether v1 script has specified function
	return (gAllFuncNames ~= '(?i)\b' funcName ',')
}
;################################################################################
														scriptHasClass(className)
;################################################################################
{
; 2025-11-01 AMB, ADDED - determines whether v1 script has specified class
	return (gAllClassNames ~= '(?i)\b' className ',')
}
;################################################################################
														 hasValidV1Label(&srcStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED
; returns srcStr if any valid v1 label is found in string
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_Blk_LBLD for label declaration needle

	tempStr := trim(RemovePtn(srcStr, 'LC'))												; remove line comments and trim ws

	; return full srcStr if valid v1 label is found anywhere in srcStr
	if (tempStr ~= '(?m)' . gPtn_Blk_LBLP)													; multi-line check
		return srcStr																		; appears to have valid v1 label somewhere
	return ''																				; no valid v1 label found in srcStr
}
;################################################################################
														   isValidV1Label(srcStr)
;################################################################################
{
; 2025-06-12 AMB, ADDED
; returns extracted label if it resembles a valid v1 label
; 	does not verify that it is a valid v2 label (see validV2Label for that)
; https://www.autohotkey.com/docs/v1/misc/Labels.htm
; invalid v1 label chars are...
;	comma, double-colon (except at beginning),
;	whitespace, accent (that's not used as escape)
; see gPtn_Blk_LBLD for details of label declaration needle (in MaskCode.ahk)

	tempStr := trim(RemovePtn(srcStr, 'LC'))												; remove line comments and trim ws

	; return just the label if...
	;	it resembles a valid v1 label
	if (RegExMatch(tempStr, gPtn_Blk_LBLP, &m))												; single-line check
		return m[1]																			; appears to be valid v1 label
	return ''																				; not a valid v1 label
}
;################################################################################
											getV1Label(srcStr, returnColon:=true)
;################################################################################
{
; 2024-07-07 AMB, ADDED
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; returns extracted label if it resembles a valid v1 label
; 2025-06-12 AMB, UPDATED - calls new function now
; 2025-07-06 AMB, UPDATED - minor adj

	if (label := isValidV1Label(srcStr)) {
		return ((returnColon) ? label : RTrim(label, ':'))
	}
	return ''	; not a valid v1 label
}
;################################################################################
														   getV2Name(v1LabelName)
;################################################################################
{
; 2024-07-07 AMB, ADDED - Replaces GetV2Label()
; 2025-07-06 AMB, UPDATED
; 2025-10-05 AMB, UPDATED to support unit tests (restore strings)

	Mask_R(&v1LabelName, 'STR')																; only req for unit tests, which may have tags
	labelName := RTrim(v1LabelName, ':')													; remove any colon if present
	return (gmAllV2LablNames.Has(labelName)) ? gmAllV2LablNames[labelName] : labelName
}
;################################################################################
													_getUniqueV2Name(v1LabelName)
;################################################################################
{
; 2024-07-07 AMB, ADDED - Ensures name is unique (support for v1 to v2 label naming)
; 2024-07-09 AMB, UPDATED to check existing label names also
; 2025-07-06 AMB, UPDATED to add label name to global func list
; 2025-11-01 AMB, UPDATED as part of Scope support

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
									  validV2LabelName(srcStr, returnColon:=true)
;################################################################################
{
; 2024-07-07 AMB, ADDED
; srcStr label MUST HAVE TRAILING COLON to be considered valid
; returns valid v2 label with or without colon based on flag [returnColon]
; makes sure returned name is unique and does not conflict with existing function names
; 2025-07-06 AMB, CHANGED func name and ADJ

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
															getV1LabelNames(code)
;################################################################################
{
; 2025-11-30 AMB, UPDATED to prevent Default: within Switch from being mistaken for label

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
												 getV2LabelNames(v1LabelNameList)
;################################################################################
{
; 2024-07-07 AMB, ADDED
; converts v1 label names to valid v2 (label/funcName)...
;	... and returns a map for global gmAllV2LablNames
; 2025-07-06 AMB, UPDATED - changed func name and refactor...
;	... now uses v1 labelNamelist created with getV1LabelNames(), as source

	labelMap := Map_I(), corrections := ''
	for idx, v1Name in StrSplit(v1LabelNameList,',') {										; for each v1 label name...
		labelMap[v1Name] := validV2LabelName(v1Name ':',0)									; ... ensure a valid v2 label/funcName
	}
	return labelMap
}
;################################################################################
															  isolateLabels(code)
;################################################################################
{
; 2025-06-22 AMB, ADDED - to move labels to their own line...
;	... when they are on same line as opening/closing brace
; can be adjusted o handle occurences for any other trailing item as well
;	(to make sure braces are isolated to their own line)

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
												   convertGoto(line, idx, &lines)
;################################################################################
{
; 2025-11-23 AMB, ADDED - replaces previous Goto handling (part of fix for #413)
; 2025-11-30 AMB, UPDATED call for Zip()
; 2026-01-01 AMB, UPDATED with cleanCWS() call
; converts  Goto, label  -->>  Goto("label")
;	also adds trailing Return as needed
;	places Goto/Return into a single-line tag
; tags will be restored in restoreGotoReturn(), which is called from PreProcessLines()
; this func is called from PreProcessLines() and HK1LToML()

	global gmList_GotoLabel

	nExitCmd	:= '(?i)^\b(RETURN|EXITAPP)\b'												; needle for exit commands
	nGoto		:= '(?im)^(\h*)(GOTO)(.+)'													; needle for 'Goto, Label'
	returnStr	:= 'Return `; V1toV2: post-return for Goto'									; user msg to add as needed
	if (!RegexMatch(line, nGoto, &m))														; if line does NOT have Goto command...
		return line																			; ... exit early

	; convert Goto
	LWS := m[1], gotoStr := m[2], param := m[3]												; extract line/goto parts
	Mask_R(&param, 'LC')																	; expose any trailing line comment
	param		:= separateComment(param, &TC:='')											; separate trailing line comment (first occurence)
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
													  HK1LToML(line, idx, &lines)
;################################################################################
{
; 2025-11-23 AMB, ADDED - part of fix for #413
; moves same-line HK commands below HK declaration, in certain cases

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
addHKCmdFunc(varName) {
; 2025-10-12 AMB, ADDED to fix #328
; see addHKCmdCBArgs() for adding param to func declaration
	nFunc	 := '(?i)' varName '\h*:=\h*FUNC\(([^)]+)\)'									; needle to locate... var := Func("funcName")
	funcName := '', oStr := gOScriptStr._origStr
	if (RegExMatch(oStr, nFunc, &m)) {														; if a func is associated with varName
		funcName := Trim(m[1], '"')															; capture that funcName
		gmList_HKCmdToFunc[funcName] := ConvLabel('HKY', varName, 'ThisHotkey', funcName)	; add funcName and func param to obj/array
	}
	return funcName																			; return funcName, in case caller can use it
}
;################################################################################
addHKCmdCBArgs(&code) {
; 2025-10-12 AMB, Added to support #328

	;Mask_T(&code, 'C&S')	; 2025-10-12 - handled in FinalizeConvert()
	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')		; 2025-06-12, remove exclusion
	nDeclare:= '(?im)' nCommon '\))(?<trail>.*)'											; make needle for func declaration
	nArgs	:= '(?im)' nCommon '\K\)).*'													; make needle for func params/args
	m := [], declare := []
	for key, obj in gmList_HKCmdToFunc {													; for each entry in list...
		paramsToAdd	:= obj.params															; get params that will need added
		funcName	:= obj.FuncName															; get func (name) to add params to
		nTargFunc	:= RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', funcName)			; target specific function name
		If (pos := RegExMatch(code, nTargFunc, &m)) {										; look for the func declaration...
			; target function found
			if (RegExMatch(m[], nDeclare, &declare)) {										; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail						; extract params and trailing portion of line
				LWS			:= TWS := '', params := ''										; ini exisiting params details, inc lead/trail ws
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
/**
* Creates a Map of labels who can be replaced by other labels...
*	(if labels are defined above each other)
* @param {*} ScriptString string containing a script of multiple lines
* 2024-07-07 AMB, UPDATED - to use common getV1Label() func that covers...
*	detection of all valid v1 label chars
* 2025-06-12 AMB, UPDATED - changed some var and func names...
*	gOScriptStr is now an object
*/
GetAltLabelsMap(ScriptString) {

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
;################################################################################
_Gosub(p) {
; 2024-07-07 AMB, UPDATED - as part of label-to-function naming
; 2025-10-05 AMB, UPDATED - to use new gmList_GosubToFunc, updated msg to user
; 2025-11-01 AMB, UPDATED - key case-sensitivity for gmList_GosubToFunc
; TODO - try to add support for %label%

	; check for Gosub %label% - not yet supported
	p[1] := RegExReplace(p[1], '%\h*([^%]+?)\h*$', '%$1%')
	If (InStr(p[1], '%')) {
		EOLComment	:= ' `; V1toV2: Gosub (Manual edit required)'
		return 'Gosub ' . Trim(p[1]) . EOLComment
	}

	; should have legit label, but the labelname may change after calling Update_LBL_HK_HS()
	; ... so, just record the Gosub call for now, with no chnages to script
	; ... clsSection._gosubUpdate() will make the final changes ass part of Update_LBL_HK_HS()
	; ... this also provides support for isssue #322, and similar
	v1LabelName := Trim(p[1])
	gmList_GosubToFunc[v1LabelName] := true
	return 'Gosub ' .  v1LabelName	; no changes here
}