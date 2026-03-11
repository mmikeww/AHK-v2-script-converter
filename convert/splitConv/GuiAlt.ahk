
;################################################################################
GuiAlt(p)
{
; 2026-03-11 AMB, ADDED to support updated gui cmd handling
; simulates orig gui handling (with updated features) or provides new dynamic gui handling

	if (hasTernary(gV1Line))																; if line has ternary expression
		return LTrim(gV1Line) ' `; V1toV2: Ternary not yet supported (coming soon)'			; ... SKIP it for now
	line	:= clsGuiLine(p)																; convert v1 gui line to v2
	return	line.lineOut																	; return v2 converted line
}
;################################################################################
class clsGuiLine
{
	guiObj		:= unset																	; will allow access to current gui object
	oParams		:= ''																		; original params
	p1			:= ''																		; Gui param 1 (from current script line)
	p2			:= ''																		; Gui param 2 (from current script line)
	p3			:= ''																		; Gui param 3 (from current script line)
	p4			:= ''																		; Gui param 4 (from current script line)
	_lineOut	:= ''																		; (PRIVATE) final converted output for current line
	origGuiName := ''																		; original v1 gui name
	namenum		:= ''																		; gui name/number combo for current line
	hasOrigName := false																	; whether v1 line specified a name/num for gui on current line
	isNewGui	:= false																	; flag that sets whether ':= NewV2Gui()' should be applied

	__new(p)
	{
		p := this._cleanParams(p)															; remove any lead/trail WS, including CRLF
		this.oParams := p																	; save all Gui params in original form
		this.p1 := p[1], this.p2 := p[2], this.p3 := p[3], this.p4 := p[4]					; separate params into local properties
		this._preProcessP1()																; PRE-process param1
		this._processSubCmd()																; process param1 as sub command
		this._processNewGui()																; final actions for new guis
	}
	;############################################################################
	GetLine																					; formatted output for logging/testing/debugging
	{
		get {
			try {																			; try - in case guiObj is not set
				pStr := ''																	; ini
				loop 4 {																	; create cascading param list
					LWS	 := Format("{:" . A_Index*2 . "}", "")								; 	leading whitespace (cascading indents)
					pStr .= ('`r`n' . LWS . this.guiObj.p%A_Index%)							; 	param str
				}
				fpath	 := '' ;'`r`n' gFilePAth											; current v1 script filepath
				origP1	 := '`t`t(ORIG P1)`t[' this.guiObj.oParams[1] ']'					; original param1
				return	 fPath '`r`n' this.guiObj.guiVarName origP1 pStr					; assembled output string
			}
			return 'GETLINE: has no guiObj'													; error occurred - guiObj is not set
		}
	}
	;############################################################################
	LineOut																					; (PUBLIC) final converted output for current line
	{
		get {
			this._lineOut := this._cleanCommas(this._lineOut)								; remove trailing ws from commas
			try this._lineOut .= this.guiObj.ListCWS	; empty 99.99% of the time			; add lines that might have comments/WS extracted between list fragments
			if (InStr(this._lineOut, '`n')) {												; if lineout is multi-line...
				return Zip(this._lineOut, 'GUIML')											; ... compress multi-line into single-line tag
			}
			return this._lineOut															; not multi-line... return as is
		}
	}
	;############################################################################
	_cleanCommas(srcStr)																	; remove trailing ws from commas
	{
		if (!gDynGuiNaming || !(srcStr ~= ',\h+'))											; if using old naming, or already clean...
			return srcStr																	; ... return orig str
		if (InStr(srcStr, 'MarginY'))														; if srcStr contains 'MarginY'
			return srcStr																	; ... do not remove ws after comma
		sessID := clsMask.NewSession()														; create a new masking session
		Mask_T(&srcStr,'C&S',,sessID)														; mask/hide comments and strings
		srcStr := RegExReplace(srcStr, ',\h+', ',')											; remove trailing ws from commas
		Mask_R(&srcStr,'C&S',,sessID)														; restore comments/strings
		return srcStr																		; return cleaned str
	}
	;############################################################################
	_cleanParams(p)																			; remove lead/trail WS/CRLF, and trailing commas, from params
	{
		p1 := this._cleanLine(p[1]), p2 := this._cleanLine(p[2])							; clean params 1,2
		p3 := this._cleanLine(p[3]), p4 := this._cleanLine(p[4])							; clean params 3,4
		return [p1,p2,p3,p4]																; return array of clean params
	}
	;############################################################################
	_cleanLine(srcStr)																		; remove lead/trail WS/CRLF, and trailing comma, from srcStr
	{
		if (srcStr ~= gPtn_PrnthBlk)														; if srcStr is ML parentheses block...
			return srcStr																	; ... do not clean it, just return it
		return Rtrim(Trim(srcStr, ' `t`r`n'), ' ,')											; remove lead/trail WS/CRLF, and trailing comma, from str
	}
	;############################################################################
	_preProcessP1()																			; PRE-process param1 for current line
	{
	; separates gui name/number from subCommand
	; preps clsGuiLine instance/object for handling subCommands later

		global gfNewScope																	; used to assist controlling of scope (not used yet)

		namenum	:= this._getGuiNameNum() ; also stored in this.namenum						; extract name/number of gui (if present)
		hwndVar	:= clsExtract.ExtHwndVar(&p2:=this.p2,false)								; extract gui hwnd variable (if present)

		; do not allow new guis to be created with these
		nException	:= '(?i)\b(CANCEL|DESTROY|FONT|HIDE|MENU|SUBMIT)\b'						; watch for these exceptions, for P1

		if (this.p1 = 'NEW') {																; if P1 has the NEW cmd...
			this.guiObj := clsGuiObj.newGuiObj(this.origGuiName,hwndVar,force:=true)		; ... create new gui object
			this.guiObj.UpdateParams(this.oParams, this.p1)									; ... sync line params with current gui object
			this.isNewGui	:= false														; ... ' := NewV2Gui()' is handled in _processSubCmd()
			gfNewScope		:= false														; ... NOT new scope
		}
		else if (this.p1 = 'DEFAULT') {														; if P1 is DEFAULT cmd...
			if (!nameNum) {																	; if gui name/num is NOT specified...
				if (guiObj	:= clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=false)) {		; ... if a gui obj was already recorded from a prev line...
					this.guiObj	:= guiObj													; ... 	store the gui obj locally
					this.guiObj.UpdateParams(this.oParams, this.p1)							; ... 	sync line params with current gui object
				}
			} else if (guiObj := clsGuiObj.SetCurGuiName(nameNum,hwndVar)) {				; if gui name/num IS specified, set it as current...
				this.guiObj	:= guiObj														; ... store the gui obj locally
				this.guiObj.UpdateParams(this.oParams, this.p1)								; ... sync line params with current gui object
			}
			this.isNewGui := false															; do not add NEW declaration
		}
		else if (this.p1 = 'LISTVIEW') {													; if P1 is LISTVIEW cmd...
			; in V2, listView is not a valid param for p1									; ... not valid in v2
			; will comment out the line in _processSubCmd()									; ... will be handled in _processSubCmd()
		}
		else if (this.p1 ~= nException && !nameNum && clsGuiObj.HasAny) {					; if P1 is an exception, and gui has NO v1 name/num, and not the first gui line...
			this.guiObj	:= clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=false,false)		; ... determine gui object, for current script line
			this.guiObj.UpdateParams(this.oParams, this.p1)									; ... sync line params for current gui object
			this.isNewGui := false															; ... do not add NEW declaration
		}
		else if (this.p1 ~= nException && nameNum) {										; if P1 is an exception, and gui HAS a v1 name/num...
			this.guiObj	:= clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=false)			; ... determine gui object, for current script line
			this.guiObj.UpdateParams(this.oParams, this.p1)									; ... sync line params for current gui object
			this.isNewGui := false															; ... do not add NEW declaration
		}
		else {																				; default handling
			this.guiObj	:= clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=false)			; ... determine gui object, for current script line
			this.guiObj.UpdateParams(this.oParams, this.p1)									; ... sync line params for current gui object
			this.isNewGui := isNew															; ... new gui declaration may or may not be added
		}
	}
	;############################################################################
	_getGuiNameNum()																		; extract gui name/num from param1
	{
		p1 := Trim(this.p1), namenum := ''													; ini
		if (RegExMatch(p1, '^((\w*(%)?[\w.]+(?(-1)%|)\w*)\h*:(?!=)\h*)', &m)) {				; if P1 is [NameNum:ANY]... (namenum may be surrounded by %)
			namenum			 	:= m[2]														; ... [portion before :] extract gui name/num
			this.p1				:= Trim(RegExReplace(p1, '^' m[]))							; ... [portion after  :] (remove gui name/num from param1)
			this.origGuiName	:= namenum													; ... save original v1 name/number
			this.hasOrigName	:= true														; ... set flag that v1 gui had a designated name/num
		}
		else if (RegExMatch(p1, '^\h*%([^%]+?)(":(\w+)")$', &m)) {							; if p1 is [% var ":COMMAND"]...
			namenum			 	:= '% ' Trim(m[1])											; ... [portion before :] extract gui name/num
			this.p1				:= Trim(m[3])												; ... [portion after  :]
			this.origGuiName	:= namenum													; ... save original v1 name/number
			this.hasOrigName	:= true														; ... set flag that v1 gui had a designated name/num
		}
		; included just for clarity
		else if (p1 ~=	'(?i)\b(ADD|CANCEL|COLOR|DEFAULT|DESTROY|FONT|HIDE'					; if P1 is a COMMAND...
					.	'|LISTVIEW|MARGIN|MENU|NEW|SHOW|SUBMIT|TAB)\b') {					; ... v1 gui has NO name or number
		}																					; ... commands will be handled in _processSubCmd()
		; included just for clarity
		else if (p1 ~= '^[+-]\w+.*$') {														; if P1 is a list of OPTIONS...
			; options not handled here														; ... v1 gui has NO name or number
		}																					; ... options will be handled in _processSubCmd()
		else {
			if (!p1) {																		; should not happen...
				errorMsg := 'GUI - Param 1 is empty`n'										; ... but just in case (DEBUG)
			} else {																		; CAN happen sometimes...
				if (hasTernary(gV1Line)) {													; if P1 has ternary expression...
					msg := ' `; V1toV2: Ternary not yet supported (coming soon)'			; ... ternary is not yet supported
					this._lineOut := LTrim(gV1Line) . msg									; ... notify user with line output
				}
				errorMsg := 'GUI - Param 1 was NOT anticipated`n[' p1 ']`n'					; ... P1 is OTHER
			}
			MsgBox(A_ThisFunc "`n`n" errorMsg LTrim(gV1Line))								; display debug msg
		}
		this.namenum := namenum																; CAN be empty string
		return namenum																		; return namenum to caller
	}
	;############################################################################
	_processSubCmd()																		; process gui subCommand from line
	{
		global gGuiActiveFont																; used in GuiControlConv()

		try guiName := this.guiObj.guiVarName												; TRY - guiObj not yet set for NEW/LISTVIEW

		switch this.p1, false {																; P1 - NOT case-sensitive

			;####################################################################
			case 'ADD':
				this._process_ADD()															; this._lineOut will be set during call

			;####################################################################
			case 'CANCEL', 'HIDE':
				this._lineOut	:= guiName . '.Hide()'										; assemble final output

			;####################################################################
			case 'COLOR':
				this._lineOut	:= guiName . '.BackColor := ' toExp(this.p2,,1)				; assemble final output

			;####################################################################
			case 'DEFAULT':
				; Gui object is set indirectly via _preProcessP1()
				;	so no need to do it manually here
				this._lineOut	:= '`;' LTrim(gV1Line)										; comment out the line
				xtra			:= (this.namenum) ? ', but applied' : ''					; msg - extra msg content
				this._lineOut	.= ' `; V1toV2: removed' xtra								; add user msg
				this._lineOut	.= NL.CRLF gLineFillMsg										; add fill line in case commented out line causes error
				clsGuiObj.SetThdGuiObj(this.guiObj)

			;####################################################################
			case 'DESTROY':
				this._lineOut	:= 'Try ' . guiName . '.' this.p1 '()'						; assemble final output (preserve orig cmd)

			;####################################################################
			case 'FONT':																	; 4% of cases
				comma			:= (gDynGuiNaming) ? ',' : ', '								; comma with/without trailing ws
				p2				:= (this.p2 != '') ? toExp(this.p2,,1) : ''					; format param2
				p3				:= (this.p3 != '') ? toExp(this.p3,,1) : ''					; format param3
				params			:= Trim(p2 comma p3, comma)									; assemble, remove any trailing comma
				gGuiActiveFont	:= params													; used in GuiControlConv()
				this._lineOut	:= guiName '.SetFont(' params ')'							; assemble final output

			;####################################################################
			case 'LISTVIEW':

				ctrlID := Trim(this.p2)														; use var
				if (InStr(ctrlID, '%')) {													; if ctrlID contains %...
					; TODO - ADD HANDLING FOR % VAR, %VAR%, if needed						; ... HANDLING WILL BE ADDED LATER
				}
				if (ctrlObj := clsGuiObj.CtrlObjFromCtrlID(ctrlID)) {						; get listview ctrl obj, if it exists (is known about)...
					this._setDefaultNames('LISTVIEW', ctrlObj.V2GCVar)						; ... set listview default name
					varName := ctrlObj.V2GCVar												; ... get listview var name
					varName := (gDynGuiNaming) ? varName : "'" varName "'"					; ... add surrounding quotes as needed
					msg	:= ' `; V1toV2: removed, but applied'								; ... msg to user...
					this._lineOut	:= (gDynGuiNaming)										; ... assemble final output
									? 'global gV2CurLV := ' varName							; ... set script var to point to cur listview as default
									: '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg			; ... add user msg to output, also add fill line
					return
				}
				; listview ctrl (ctrlID) not identified using v1 script (so far)...			; but, dynamic handling may be able to identify it
				if (gDynGuiNaming) {														; if using dynamic naming method...
					varName			:= gDynMapGC '[["",' toExp(ctrlID,1,1) ']]'				; ... use map as variable
					this._lineOut	:= 'global gV2CurLV := ' varName						; ... assemble final output
				} else {																	; if using orig naming method (simple)
					msg := " `; V1toV2: [" ctrlID "] not found. Manual edit required."		; ... msg to user...
					this._lineOut := LTrim(gV1Line) . msg									; ... post original v1 line with msg to user
				}

			;####################################################################
			case 'MARGIN':

				p2				:= toExp(this.p2,,1), p3 := toExp(this.p3,,1)				; format param2,3
				mX				:= guiName '.MarginX := ' p2								; format x
				my				:= guiName '.MarginY := ' p3								; format y
				this._lineOut	:= mx . ((my) ? ', ' my : '')								; assemble final output

			;####################################################################
			case 'MENU':
				this._lineOut	:= guiName '.MenuBar := ' this.p2							; assemble output

			;####################################################################
			case 'NEW':
				this._process_NEW()															; this._lineOut will be set during call

			;####################################################################
			case 'SHOW':

				p2				:= (this.p2 != '') ? toExp(this.p2,,1) : ''					; format param2
				showStr			:= guiName '.' this.p1 '(' p2 ')'							; output string for 'Show()'
				titleStr		:= ''														; ini
				if (title		:= this.p3) {												; if a title was included with v1 Show command...
					this.guiObj._guiTitle := title											; ... save orig gui title
					titleStr	:= guiName '.Title := ' toExp(title,1,1) . NL.CRLF			; ... output string for 'title'
				}
				this._lineOut	:= titleStr . showStr										; assemble final output

			;####################################################################
			case 'SUBMIT':

				exclude		:=	'|ACTIVEX|BUTTON|GROUPBOX|LINK|PIC|PICTURE'					; exclusions
							.	'|PROGRESS|STATUSBAR|TEXT|'

				ctrlVarStr	:= '', dynCall := '', hasDynVar := false						; ini
				param		:= (this.p2 = 'NoHide') ? '0' : ''								; [NoHide param]
				dynGui		:= gDynMapGui '[gCurGuiID]'										; [dynamic gui string]
				for key, ctrl in this.guiObj.CtrlList {										; for each ctrl in gui ctrl list...
					if (key ~= '(?i)^[^/]+/\w+:\d+$')										; if key is a v1 Control[Num]...
						continue															; ... it's a dup - skip it
					ctrlVar	:= ctrl.CtrlVar													; grab current ctrl variable
					if (ctrlVar ~= '[%\h]') {												; if current ctrl-var has % or ws...
						hasDynVar := true													; ... it is a dynamic var, set flag (for below)
					}
					else if ((ctrlVar)														; if current ctrl has a normal variable...
					&&		(!InStr(exclude, '|' ctrl.CtrlType '|'))) {						; ... AND ctrl type is NOT in exclude list...
						str			:= 'Try ' ctrlVar ' := oSaved.' ctrlVar					; ... create an assignment for the var
						ctrlVarStr	.= (NL.CRLF . str)										; ... append assignment to var list string
					}
				}
				if (gDynGuiNaming && hasDynVar && !dynCall) {								; if using dynamic naming, AND gui has dynamic ctrlVar
					p			:= (param='') ? '' : ',' param								; ... add leading comma to param, if param is present
					dynCall		:= 'V2DynSubmitResult := ' gDynSubmit '(' dynGui p ')'		; ... [dynamic call string]
				}
				guiVarStr		:= (gDynGuiNaming) ? dynGui : this.guiObj.guiVarName		; [gui var str]
				val				:= guiVarStr '.' this.p1 '(' param ')' ctrlVarStr			; assignment value, and list of ctrlVar assignments
				CRLF			:= (ctrlVarStr && dynCall) ? NL.CRLF : ''					; apply CRLF, as needed
				oSavedStr		:= (!dynCall) ? 'oSaved := ' val : ''						; [oSaved str]
				this._lineOut	:= oSavedStr . CRLF . dynCall								; assemble final output, incl dynamic call as needed

			;####################################################################
			case 'TAB','TAB2','TAB3':

				if (!gDynGuiNaming) {														; if using orig naming method (simple)
					tabPage			:= (this.p2) ? toExp(this.p2) : ''						; ... get/format tab page from P2
					this._lineOut	:= 'Tab.UseTab(' tabPage ')'							; ... assemble final output
					return
				}
				; using dynamic naming method...
				tabPage			:= (this.p2) ? this.p2 : 0									; param2 is the tab page,	set to 0 if empty
				tabCtrlIdx		:= (this.p3) ? this.p3 : 1									; param3 is the ctrl index,	set to 1 if empty
				tabCtrlName		:= ''														; ini - in case Try fails
				try {
					tabCtrlName	:= this.guiObj.tabCtrlList[tabCtrlIdx].V2GCVar				; get current default Tab
				}
				catch as e {																; if error occurred...
					MsgBox "TAB NAME ASSIGNEMENT FAILED`n" e.Message						; ... display a debug msg
				}
				this._lineOut := tabCtrlName . '.UseTab(' toExp(tabPage) ')'				; sets default Tab that future controls will be added to

			;####################################################################
			default:																		; this will catch OPTIONS (6% of cases)
				if (optStr := this._isOptions(this.p1)) {									; if P1 is Options...
					this._lineOut := optStr													; ... could set this within _isOptions() instead
				}
				else {
					; UNKNOWN, but should be caught in _getGuiNameNum() first
				}
			;####################################################################
		}
	}
	;############################################################################
	_process_ADD()																			; processed ADD SubCommand
	{
		global gmGuiCtrlType																; used in GuiControlConv() and GuiControlGetConv()

		ctrl	:= this.P2																	; control to add - use var for clarity
		ctrlObj	:= this.guiObj.AddCtrl()													; creates ctrl obj from v1 gui line-params
		keyName := (gDynGuiNaming) ? ctrlObj.KeyName : ctrlObj.V2GCVar						; determine keyname to use below
		gmGuiCtrlType[keyName] := ctrl														; used in GuiControlConv() and GuiControlGetConv()

		; build declare string (for p1,p2,p3)
		guiVarStr:= this.guiObj.guiVarName													; string that acts as a variable for GUI obj (within converted script)
		p2		:= (ctrlObj.p2 != '') ? toExp(ctrlObj.p2,1,1) : ''							; format param2 - should always have a value
		p3		:= (ctrlObj.p3 != '') ? toExp(ctrlObj.p3,1,1) : ''							; format param3 - usually has a value
		p4		:= (ctrlObj.p4 != '') ? toExp(ctrlObj.p4,1,1) : ''							; format param4 - sometimes has a value
		decl	:= guiVarStr '.' this.p1 '(' p2 ', ' p3										; declaration ini (includes p1,p2,p3)
		; add p4 as needed
		nP4Ctrls := '(?i)\b(COMBOBOX|DDL|DROPDOWNLIST|LISTBOX|LISTVIEW|TAB[23]?)\b'			; ctrls that may be associated with param4
		if (ctrl ~= nP4Ctrls) {																; if added ctrl is one of these ctrls...
			p4	:= (ctrlObj.P4Str) ? ctrlObj.P4Str : ''										; ... get array list (if applicable)
		}
		decl	.= ((p4) ? ', ' p4 : ''), decl := Trim(decl, ' ,') . ')'					; finalize decl string

		; add var declaration as needed
		curLVStr	:= ''																	; ini current Listview str
		declStr		:= ''																	; ini final declare str
		ctrlVarStr	:= ctrlObj.V2GCVar														; string that acts as a variable for CTRL obj (within converted script)

		if (!gDynGuiNaming																	; if using ORIG naming method...
		&& (ctrl ~= '(?i)\b(BUTTON|LISTVIEW|TREEVIEW)\b' || ctrlObj.CtrlLabel)) {			; AND ctrl is one of these, OR has an associated label...
			declStr := ctrlVarStr ' := ' decl												; ... include a 'var := ' (to match ORIG formatting)
		}
		else if (ctrl ~= '(?i)\b(LISTVIEW|STATUSBAR|TREEVIEW)\b') {							; if added ctrl is one of these...
			declStr	:= ctrlVarStr ' := ' decl												; ... var declaration - FORCED
			if (gDynGuiNaming && ctrl = 'LISTVIEW') {										; if using dynamic naming AND added ctrl is ListView...
				ctrlVarStr	:= (gDynGuiNaming) ? ctrlVarStr : "'" ctrlVarStr "'"			; ... add quotes as needed
				curLVStr	:= NL.CRLF "global gV2CurLV := " ctrlVarStr						; ... update declare str
			}
		}
		else if (ctrl = 'ACTIVEX') {														; if added ctrl is ActiveX...
			declStr := ctrlVarStr ' := ' decl												; ... var declaration - needed
			declStr .= NL.CRLF ctrlObj.CtrlID ' := ' ctrlVarStr '.Value'					; ... update declare str
		}
		else if (ctrlObj.CtrlID || ctrlObj.OnEventStr) {									; if added ctrl has a ctrlID or Event...
			declStr := ctrlVarStr ' := ' decl												; ... var declaration - needed
		}
		else {																				; any other situation...
			declStr := decl																	; ... var declaration - NOT needed
		}

		declStr := (!gDynGuiNaming && ctrl ~= '(?i)\bTAB[23]?\b')							; if using ORIG naming method, and ctrl is a TAB
				? 'Tab := ' declStr															; ... add 'Tab := ' (to match ORIG formatting)
				: declStr																	; ... otherwise, no changes to decl str

		; finalize output
		this._lineOut	:= declStr ctrlObj.CtrlMsg											; these can both be empty strings sometimes
		join			:= ((this._lineOut)													; if output str is NOT empty...
						?  ((gDynGuiNaming || ctrlObj.CtrlMsg) ?  NL.CRLF					; ... add CRLF as needed  (for dynamic naming method)
						: ', ') : '')														; ... add comma as needed (for ORIG naming method)
		CtrlHwndStr		:= (ctrlObj.CtrlHwndStr) ? join ctrlObj.CtrlHwndStr		: ''		; add hwnd assignment,	 if applicable
		EHStr			:= (ctrlObj.OnEventStr)  ? NL.CRLF ctrlObj.OnEventStr	: ''		; add event declaration, if applicable (new	line)
		this._lineOut	.= CtrlHwndStr EHStr curLVStr										; assemble final output

		; set default names as needed
		this._setDefaultNames(ctrl, ctrlVarStr)												; set default name for LV,SB,TV (as applicable)
	}
	;############################################################################
	_process_NEW()																			; processes NEW SubCommand
	{
	; TODO - CREATE SINGLE ROUTINE FOR PROCESSING OPTIONS TO SHARE WITH ISOPTIONS()

		if (hwndVar		:= clsExtract.ExtHwndVar(&p2:=this.p2,true))						; if gui hwnd present, extract it...
			this.p2		:= p2																; ... p2 with hwnd removed
		if (pLabel		:= clsExtract.ExtPLabel(&p2:=this.p2,true))							; if pLabel present, extract it...
			this.p2		:= p2																; ... p2 with pLabel removed
		; handle params
		params			:= ''																; ini
		params			.= (this.p2 != '') ?		toExp(this.p2,1,1) : ''					; format param2 (options)
		params			.= (this.p3 != '') ? ', '	toExp(this.p3,1,1) : ''					; format param3 (title)
		needQuotes		:= !!(params && !InStr(params, '"'))								; if quotes are needed...
		params			:= (needQuotes) ? '"'	params '"' : params							; ... add surrounding quotes
		params			:= (params)		? ', ' params	   : params							; add comma as needed (TODO - REMOVE TRAILING WS FROM COMMA ?)
		; get gui var name and id (strings)
		varNameObj		:= this._getGuiVarName()											; obj that has varNameStr and ID
		guiVarStr		:= varNameObj.varNameStr											; string that acts as a variable for GUI obj (within converted script)
		varId			:= varNameObj.id													; key that is used to identify gui obj in real time (during execution)
		params			:= Trim(varId . params, ', ')										; trim ws and extra commas from params
		; make declaration strings
		guiDecl			:= (gDynGuiNaming) ? 'NewV2Gui' : 'Gui'								; gui declaration, depending on which naming method is being used
		newGuiStr		:= guiVarStr ' := ' guiDecl '(' params ')'							; string used to create new Gui
		join			:= ((gDynGuiNaming) ? NL.CRLF : ', ')								; use CRLF/comma to join commands, depending on which naming method is being used
		HwndStr			:= (hwndVar) ? join hwndVar ' := ' guiVarStr '.Hwnd': ''			; string that assigns hwnd to hwndVar
		newGuiStr		.= HwndStr															; append hwnd var assignemnt to output str
		defEventsStr	:= this.guiObj.DefaultEvents(pLabel)								; string that defines gui event handler (if applicable)
		if (pLabel && !defEventsStr) {														; if function/method for +Label was not found...
			msg			 := ' `; V1toV2: Unable to locate [' pLabel '] for +Label'			; ... user msg
			defEventsStr := '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg					; ... comment-out orig v1 line, add msg to user and fill line
		}
		newGuiStr		.= (defEventsStr) ? (NL.CRLF . defEventsStr) : ''					; append event handler assignment to output str
		newGuiStr		:= LTrim(newGuiStr, ' `t`r`n')										; remove any leading CRLF, just in case
		this._lineOut	:=	newGuiStr														; assemble final output
	}
	;############################################################################
	_setDefaultNames(ctrl, v2GCVar)															; enables tracking of default LV,SB,TV ctrls within conv script (real time)
	{
		global gLVNameDefault, gSBNameDefault, gTVNameDefault
		if (ctrl='LISTVIEW')
			gLVNameDefault	:= (gDynGuiNaming) ? 'gV2CurLV' : v2GCVar						; set default LV ctrl name (if applicable)
		if (ctrl='STATUSBAR')
			gSBNameDefault	:= v2GCVar														; set default SB ctrl name (if applicable)
		if (ctrl='TREEVIEW')
			gTVNameDefault	:= v2GCVar														; set default TV ctrl name (if applicable)
	}
	;############################################################################
	_isOptions(srcStr)																		; handles formatting/output of Gui options
	{
	; TODO - CREATE SINGLE ROUTINE FOR PROCESSING OPTIONS TO SHARE WITH _process_NEW()

		if (!RegExMatch(srcStr, '^\h*[+-]\w.*$', &m))										; if srcStr does not contain options...
			return false																	; ... exit, notify caller

		; got options - extract each hwnd from srcStr
		opts		:= m[]																	; ini extracted options
		pLabel		:= clsExtract.ExtPLabel(&opts,true)										; if pLabel present, extract/remove it
		hwndVars	:= []																	; ini
		nHwnd		:= '(?i)((\h*)(("\h*)?[+-]?\bHWND(\w+)\b(\h*")?)(\h*))'					; hwnd needle
		While(pos	:= RegexMatch(opts, nHwnd, &m, pos??1)) {								; for each hwnd within srcStr...
			hwndVars.Push(m[5])																; ... extract hwnd variable
			opts	:= RegExReplace(opts, escRegexChars(m[2] m[3]),,,1)						; ... remove hwnd from string
		}
		opts		:= Trim(opts)															; trim any stray ws
		guiVarStr	:= this.guiObj.guiVarName												; string that acts as a variable for GUI obj (within converted script)
		optsStr		:=	(opts) ? guiVarStr '.Opt(' toExp(opts,,1) ')' : ''					; create options string
		hwndVarsStr	:= ''																	; ini hwnd assignment declarations
		for idx, var in hwndVars {															; for each hwnd var that was extracted above...
			join		:= ((gDynGuiNaming) ? NL.CRLF : ', ')								; ... use CRLF/comma to join commands, depending on naming method being used
			curStr		:= join var ' := ' guiVarStr '.Hwnd'								; ... create a hwnd var assignment
			hwndVarsStr	.= curStr															; ... add assignment to hwnd assignemnt declarations str
		}
		hwndVarsStr	:= (optsStr) ? hwndVarsStr	: LTrim(hwndVarsStr, ', `r`n')				; trim leading CRLF/comma as needed
		optsStr		.= hwndVarsStr															; update output str
		defEventsStr:= (pLabel) ? this.guiObj.DefaultEvents(pLabel) : ''					; get events string ONLY WHEN +Label option is present
		if (pLabel && !defEventsStr) {														; if function/method for +Label was not found...
			msg		:= ' `; V1toV2: Unable to locate [' pLabel '] for +Label'				; ... user msg
			defEventsStr := '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg					; ... comment-out orig v1 line, add user msg and fill line
		}
		optsStr		.= (defEventsStr) ? (NL.CRLF . defEventsStr) : ''						; update output str
		optsStr		:= LTrim(optsStr, ' `t`r`n')											; trim leading ws and CRLFs as needed
		return		optsStr																	; return final output
	}
	;############################################################################
	_processNewGui()																		; creates/outputs new gui delaration as needed
	{
		global gfNewScope

		if (!this.isNewGui) {																; if new gui declaration should not be added...
			return																			; ... exit
		}
		if (!gDynGuiNaming) {																; if using ORIG naming method...
			params			:= ''															; ... ini
			defEventsStr	:= this.guiObj.DefaultEvents()									; ... [event string] if present
			varNameObj		:= this._getGuiVarName()										; ... get var name details (object)
			guiVarName		:= varNameObj.varNameStr										; ... variable for gui declaration
			varId			:= varNameObj.id												; ... gui map key (TODO - IS THIS BEING USED HERE?)
			params			:= (params) ? ', ' params : params								; ... new gui params
			params			:= Trim(varId . params, ', ')									; ... trim lead/trail ws/commas
			newGuiStr		:= guiVarName ' := Gui(' params ')'								; ... gui assignment
			newGuiStr		.= (defEventsStr) ? (NL.CRLF defEventsStr) : ''					; ... add event string if present
			newGuiStr		.= (this._lineOut) ? NL.CRLF : ''								; ... add leading CRLF as needed
			this._lineOut	:= newGuiStr . this._lineOut									; ... assemble final output
			return																			; ... return   final output
		}
		; using dynamic naming method...
		params			:= ''																; ini
		doubleIndent	:= NL.CRLF . gSingleIndent											; [indent one more than normal]
		defEventsStr	:= this.guiObj.DefaultEvents()										; [event string] if present
		defEventsStr	:= RegExReplace(defEventsStr, '`r`n\h*', doubleIndent)				; reformat whitespace for event string
		varNameObj		:= this._getGuiVarName()											; get var name details (object)
		guiVarName		:= varNameObj.varNameStr											; string that acts as a variable for GUI obj (within converted script)
		varId			:= varNameObj.id													; gui map key
		params			:= (params) ? ', ' params : params									; new gui params
		params			:= Trim(varId . params, ', ')										; trim lead/trail ws/commas
		newGuiStr		:= guiVarName ' := NewV2Gui(' params ')'							; gui assignment
		newGuiStr		.= (defEventsStr) ? (doubleIndent . defEventsStr) : ''				; add event string if present
		ifDecl			:= 'If (!HasV2Gui(' varId '))'										; IF declaration for IF block
		ifBlk			:= ' {' doubleIndent . newGuiStr . NL.CRLF . '}'					; IF brace block
		ifBlk			.= (this._lineOut) ? NL.CRLF : ''									; add CRLF, as needed
		;gfNewScope		:= false															; set new-scope flag
		this._lineOut	:= ifDecl . ifBlk . this._lineOut									; return final output
	}
	;############################################################################
	_getGuiVarName()																		; returns gui var name details as an object
	{
		varNameStr	:= this.guiObj.guiVarName												; gui 'variable name' (string) that will be displayed in converted script
		id			:= ''																	; ini
		nVarName	:= gDynMapGui '\[([^\)]+)\]'											; needle used to extract the ID from varName
		if (RegExMatch(varNameStr, nVarName, &m))											; extract the ID portion of the VarName string
			id	:= m[1]																		; extracted ID
		return {varNameStr:varNameStr,id:id}												; obj with VarName-string and ID
	}
}
;################################################################################
;################################################################################
class clsGuiObj
{
	_v1OrigNm 		:= ''																	; orig v1 gui name/num (could be empty)
	_v1GuiName		:= ''																	; v1 gui name
	_v1GuiNum		:= ''																	; v1 gui num
	_guiTitle		:= ''																	; gui title
	_guiHwnd		:= ''																	; gui hwnd
	_listCWS		:= ''																	; (rare) comments/WS surrounding list fragments
	oParams			:= []																	; original v1 gui params
	p1				:= ''																	; orig v1 param1
	p2				:= ''																	; orig v1 param2
	p3				:= ''																	; orig v1 param3
	p4				:= ''																	; orig v1 param4
	_ctrlList		:= map()																; list of all controls for this gui
	_tabCtrlList	:= []																	; list of tab controls for this gui
	TabCtrlList		=> this._tabCtrlList													; list of tab controls for this gui (PUBLIC)
	CtrlList		=> this._ctrlList														; list of all controls for this gui (PUBLIC)
	CtrlCount		=> this._ctrlList.Count													; number of controls for this gui (PUBLIC)
	V1OrigNm		=> this._v1OrigNm														; orig v1 gui name/num (PUBLIC)
	V1GuiName		=> this._v1GuiName														; v1 gui name (PUBLIC)
	V1GuiNameFm 	=> this._v1GuiName . ((this._v1GuiNum) ? gGuiSep1 this._v1GuiNum : '')	; combines gui name with number (using separator)
	v2DynName		=> (this.V1OrigNm) ? this.V1OrigNm : this._v1GuiName . this._v1GuiNum
	KeyName			=> (this.V1OrigNm) ? this.V1OrigNm : this.V1GuiName						; gui keyname to be used as part of keyname for ctrls

	;############################################################################
	__New(v1Name,v1Num,v1OrigName)															; constuctor
	{
		this._v1GuiName	:= v1Name															; record v1 gui name
		this._v1GuiNum	:= v1Num															; record v1 gui number
		this._v1OrigNm	:= v1OrigName														; record v1 orig gui name/num
	}
	;############################################################################
	GuiVarName																				; string that acts as a variable for gui, in script
	{
		get {
			if (gDynGuiNaming) {															; if using dynamic naming method...
				name	:= toExp(this.v2DynName,1,1)										; ... format v2 dyn name
				return	gDynMapGui '[' name ']'												; ... return formatted dyn var string
			}
			; using orig naming method
			name		:= this._v1GuiName													; ini name
			if (!clsGuiObj._isSpecialDefault(this._v1GuiName,this._v1GuiNum))				; if gui is NOT special default
				name	.= this._v1GuiNum													; ... add gui number to name
			name		:= RegExReplace(name, '%(\w+)%', '$1')								; remove any surrounding %
			return 		Trim(toExp(name,1,1),'"')											; convert v1 expr to v2, and trim DQs, return it
		}
	}
	;############################################################################
	AddCtrl()																				; create ctrl obj, add to ctrl lists
	{
		ctrlObj	:= clsGuiCtrl(this)															; create new ctrl obj (pass entire gui object)
		ctrlKey	:= ctrlObj.CtrlObjFmNm														; unique ctrl name to use as map key (includes gui prefix and separator)
		this._ctrlList[ctrlKey] := ctrlObj													; add ctrl obj to local ctrl list
		if (ctrlObj.CtrlType ~= '(?i)TAB[23]?') {											; if ctrl is a tab ctrl
			this.tabCtrlList.Push(ctrlObj)													; ... add it to local tabCtrlList
		}
		clsGuiObj.iniMapLists()																; make sure map lists are not case-sensitive
		clsGuiObj.sCtrlList[ctrlKey] := ctrlObj												; add ctrl obj to static ctrl list
		return ctrlObj																		; return ctrl obj
	}
	;############################################################################
	UpdateParams(oParams, p1)																; allows external routines to update GuiObj params
	{
		this.oParams := oParams
		this.p1		 := p1
		this.p2		 := this.oParams[2]
		this.p3		 := this.oParams[3]
		this.p4		 := this.oParams[4]
	}
	;############################################################################
	GenCtrlIndex(ctrlObj)																	; generate unique ctrl index for control type
	{
		loop {
			key := this.V1GuiNameFm gGuiSep3 ctrlObj.CtrlType gGuiSep1 A_Index				; use gui prefix to ensure key is unique
			if(!this._ctrlList.Has(key)) {													; if key not found...
				this._ctrlList[key]			:= ctrlObj										; ... add it to local	list
				clsGuiObj.sCtrlList[key]	:= ctrlObj										; ... add it to static list
				return A_Index																; return the index to caller
			}
		}
	}
	;############################################################################
	DefaultEvents(pref:='')																	; returns all event strings associated with Gui object
	{
		global gmList_LblsToFunc															; (see labelAndFunc.ahk)

		pref		:= (pref) ? pref : 'Gui'												; allow the setting of custom prefix
		origGuiName	:= (this._v1OrigNm = 1)  ? ''	: this._v1OrigNm						; only fill if not default
		origGuiName	:= (pref != 'Gui')		 ? ''	: origGuiName							; do not duplicate GuiName
		origClose	:= origGuiName . pref . 'Close'
		origEsc		:= origGuiName . pref . 'Escape'
		origCMenu	:= origGuiName . pref . 'ContextMenu',
		origDFiles	:= origGuiName . pref . 'DropFiles'
		origSize	:= origGuiName . pref . 'Size'
		dpfParams	:= 'thisGui:="", Ctrl:="", FileArray:="", *'
		sizParams	:= 'thisGui:="", MinMax:="", A_GuiWidth:="", A_GuiHeight:=""'
		defParams	:= '*'

		; push each default event (and attributes) into an array
		defEvents	:= []
		defEvents.Push({origlabel: origClose,	event:	'Close'
						, newFunc: origClose,	params:	defParams	})
		defEvents.Push({origlabel: origEsc,		event:	'Escape'
						, newFunc: origEsc,		params:	defParams	})
		defEvents.Push({origlabel: origSize,	event:	'Size'
						, newFunc: origSize,	params: sizParams	})
		defEvents.Push({origlabel: origCMenu,	event:	'ContextMenu'
						, newFunc: origCMenu,	params:	defParams	})
		defEvents.Push({origlabel: origDFiles,	event:	'DropFiles'
						, newFunc: origDFiles,	params:	dpfParams	})

		eventLines := '', guiName := this.guiVarName										; ini
		for idx, curEvent in defEvents {													; for each event in default events...
			if (!scriptHasLabel(curEvent.origlabel))										; if event label does not exist in script...
				continue																	; ... skip it
			lbl		:= curEvent.origlabel													; record label name
			fn		:= getV2Name(curEvent.newFunc)											; record func name
			params	:= curEvent.params														; record func params
			gmList_LblsToFunc[getV2Name(lbl)]:=ConvLabel('GUI',lbl,params,fn)				; create conversion object (see labelAndFunc.ahk), place in map
			comma	:= (gDynGuiNaming) ? ',' : ', '											; [trailing ws will depend on naming method]
			eventLines .= guiName '.OnEvent("' curEvent.event '"' comma						; create .onEvent string
						. (getV2Name(curEvent.newFunc) ')' NL.CRLF)
		}
		eventLines	:= RegExReplace(eventLines, '\s+$')										; remove final trailing-ws and CRLF
		return		eventLines																; return event string
	}
	;############################################################################
	ListCWS																					; comments/WS string that may have been extracted between list fragments
	{
		get {
			str	:= this._listCWS, this._listCWS := ''										; grab value, then reset
			return str																		; return value
		}
		set {
			this._listCWS := value															; save value
		}
	}
	;############################################################################
	Static uid					:= 0
	Static nnGuiStr				:= (gDynGuiNaming) ? gDynDefGuiNm : gGuiNameDefault
	Static oGuiStr				:= (gDynGuiNaming) ? 'v1Gui' : 'oGui'
	Static defNameStr			:= this.oGuiStr
	Static _curGuiObj			:= ''
	Static _thdGuiObj			:= ''
	Static sGuiList				:= Map()
	Static sCtrlList			:= Map()
	Static HasAny				=> this.sGuiList.Count
	Static nextID				=> String(++this.uid)

	;############################################################################
	Static ResetDefaultGuiNames()															; called for AUTO Gui-Naming
	{
		this.nnGuiStr			:= (gDynGuiNaming) ? gDynDefGuiNm : gGuiNameDefault
		this.oGuiStr			:= (gDynGuiNaming) ? 'v1Gui' : 'oGui'
		this.Reset()																		; also required
	}
	;############################################################################
	Static Reset()
	{
		this.uid				:= 0														; initial value, will be continually updated
		this.defNameStr			:= this.nnGuiStr											; permanent value
		this._curGuiObj			:= ''														; initial value, will be continually updated
		this._thdGuiObj			:= ''
		this.sGuiList			:= Map()
		this.sCtrlList			:= Map()
		this.iniMapLists()
	}
	;############################################################################
	; TODO - REPLACE WITH LIVE DYNAMIC CHECK INSTEAD ?
	Static CtrlObjFromCtrlID(ctrlID, guiNameNum := '')										; returns ctrl obj that matches ctrlID
	{
		if (obj := this._findControl(ctrlID, guiNameNum)) {
			return obj
		}
		return false
	}
	;############################################################################
	Static _findControl(ctrlID, guiNameNum)
	{
		nKey := '^[^\\]+\\.+'																; verification of key formatting
		for key, ctrl in this.sCtrlList {													; for each ctrl in static ctrl list...
			curID := ctrl.CtrlID, curVar := ctrl.CtrlVar									; [use local vars]
			curHwnd := ctrl.CtrlHwndVar, curTxt := ctrl.CtrlCapTxt							; [use local vars]
			ccid	:= RegExReplace(ctrlID, '\W+')											; clean ctrlID - remove all non-word chars
			if (key ~= nKey) {																; if key is proper format...
				if (curVar	= ctrlID														; ... if target	matches ctrl variable
				||	curHwnd	= ctrlID														; ... OR		matches ctrl hwnd
				||  curTxt	= ccid															; ... OR		matches ctrl Text
				||	curID	= ctrlID) {														; ... OR		matches ctrl ID...
						return ctrl															; ...	return matching ctrl obj
				}
			}
		}
		; see if ctrlID matches the event label												; ONLY DO THIS AS A LAST RESORT
		; COULD MATCH WRONG CTRL IF MULTIPLE CTRLS USE SAME EVENT HANDLER					; TODO - HOW TO PREVENT RETURNING WRONG CTRL?
		for key, ctrl in this.sCtrlList {													; for each ctrl in static ctrl list...
			if (key ~= nKey) {																; if key is proper format...
				curLbl := ctrl.CtrlEventFunc												; ... get ctrl event function
				if (curLbl && curLbl = ctrlID)												; ... if target matches event func...
					return ctrl																; ...	return matching ctrl obj
			}
		}
		return false																		; matching ctrl not found
	}
	;############################################################################
	Static Has(namenum)																		; convenience method for gui lookup
	{
		if (this.sGuiList.Has(String(namenum)))												; if list has key...
			return this.sGuiList[String(namenum)]											; ... return associated gui obj
		return false																		; key not found
	}
	;############################################################################
	Static _isSpecialDefault(name:='', num:='')												; returns whether name/num is the ini default gui name/num
	{
		return (name = this.defNameStr && num = 1)
	}
	;############################################################################
	; for special default
	Static _iniUid()																		; ensures uid is set to at least 1
	{
		(this.uid=0) && this.uid:=1															; if uid is 0, set it to 1
	}
	;############################################################################
	Static iniMapLists()																	; ensures maps are case-insensitive
	{
		if (!this.sGuiList.Count)															; [map must be empty to disable case-sensitivity]
			 this.sGuiList.CaseSense := 0													; disable case-sensitivity for keys
		if (!this.sCtrlList.Count)															; [map must be empty to disable case-sensitivity]
			 this.sCtrlList.CaseSense := 0													; disable case-sensitivity for keys
	}
	;############################################################################
	Static GetCurGuiObj(guiName, hwndVar, &isNew:=false, newAllowed:=true)					; tracks and returns the current gui object
	{
		if (guiName='') {																	; if guiName is empty...
			if (!this._thdGuiObj															; ... if threadGui container has not been filled yet...
			&&  newAllowed) {																; ... AND cmd allows new gui obj to be created (see exclusions)...
				newObj := this.newGuiObj(guiName,hwndVar,,&isNew:=true)						; ...	create new gui obj, using guiName
				this.SetThdGuiObj(newObj)													; ...	place new gui obj in threadGui container (also placed in currentGui container)
			}
			; these two containers may not reflect same obj at given time
			return (this._thdGuiObj) ? this._thdGuiObj : this._curGuiObj					; ... otherwise, return obj from threadGui, or from currentGui container
		}

		; guiName is not empty
		; if guiName is a variable, need to use dynamic gui naming, or auto-naming
		; 	otherwise, v2 vars are not guarnteed to work correctly
		if (guiObj := this.Has(guiName)) {													; if guiName was created/recorded previously...
			this._setCurGuiObj(guiObj)														; ... place specified gui obj into currentGui container
			return guiObj																	; ... return the prev recorded gui obj
		}

		; guiName has not yet been created/recorded
		if (!newAllowed)																	; if cmd does not allow new gui obj to be created (see exclusions)...
			return this._curGuiObj															; ... just return current gui obj

		; new allowed
		newObj := this.newGuiObj(guiName,hwndVar,,&isNew:=true)								; create new gui obj using guinName
		if (guiName = '1'																	; if guiName is the default number...
		&& !this._thdGuiObj)																; AND threadGui container has not been filled yet...
			this.SetThdGuiObj(newObj)														; ... place new gui obj in threadGui container (also placed in currentGui container)
		return newObj																		; return the new gui obj
	}
	;############################################################################
	; included for +Default
	Static SetCurGuiName(guiName, hwndVar, &isNew:=false, newAllowed:=true)					; manually sets the current gui name (and obj)
	{
		if (guiObj := this.Has(guiName)) {													; if guiName was created/recorded previously...
			this._setCurGuiObj(guiObj)														; ... place specified gui obj into currentGui container
			return guiObj																	; ... return the prev recorded gui obj
		}

		; guiName has not yet been created/recorded
		if (!newAllowed)																	; if cmd does not allow new gui obj to be created (see exclusions)...
			return '' ; should not happen, but return something else just in case?			; ... return now

		; new allowed (should always be the case)
		newObj := this.newGuiObj(guiName,hwndVar,,&isNew:=true)								; create new gui obj using guinName
		if (guiName = '1'																	; if guiName is the default number...
		&& !this._thdGuiObj)																; AND threadGui container has not been filled yet...
			this.SetThdGuiObj(newObj)														; ... place new gui obj in threadGui container (also placed in currentGui container)
		else																				; otherwise...
			this._setCurGuiObj(newObj)														; ... place specified gui obj into currentGui container
		return newObj																		; return the new gui obj
	}
	;############################################################################
	Static _setCurGuiObj(guiObj)															; sets current Gui-object
	{
		this._curGuiObj	:= guiObj															; current-line gui-Object
	}
	;############################################################################
	Static SetThdGuiObj(guiObj)																; sets current-thread Gui-object
	{
		this._thdGuiObj	:= guiObj															; default-line gui-Object
		this._setCurGuiObj(guiObj)															; also set current gui object
	}
	;############################################################################
	Static newGuiObj(namenum,hwndVar,force:=false,&isNew:=true)								; creates a new gui object, also determines the name/number for that object
	{
		this.iniMapLists()																	; ensure case-sensitivity is disabled for map-key

		enterName := namenum																; make note of original (v1) gui namenum

		this._getNewGuiNameNum(namenum, hwndVar, &name:='', &num:='', force)				; determine the name/num to use for new gui

		if (this._isSpecialDefault(name,num)) {												; Gui 1 (or first no-name) requires special treatment
			this._iniUid()																	; ... make sure uid is at least 1
			entername := '1'																; ... this will be set as the original (v1) gui name
		}

		guiObj := this(name,num,orig:=enterName)											; create Gui-Object using name/num
		if (entername && (!this.Has(enterName)))											; if orig (v1) name/num is not yet listed...
			this.sGuiList[String(enterName)] := guiObj										; ... add it to list (so it can be referenced later)
		curGuiName					:= name . num											; gui name/num will be used as map-key for gui object list
		this.sGuiList[curGuiName]	:= guiObj												; curGuiName may not be same as entername (add both to list)
		(force) && this.SetThdGuiObj(guiObj)												; force update of current-thread gui obj, if requested
		return guiObj																		; return gui object to caller
	}
	;############################################################################
	Static _getNewGuiNameNum(namenum, hwndVar, &name:='', &num:='', force:=false)			; separates/returns name/num that should be used for new Gui
	{
		if (namenum && RegExMatch(nameNum, '^\h*(.*?)(\d*)\h*$', &m)) {						; extract name and number if they are available
			name := m[1], num := m[2]														; separate name from number (if avail)
		}
		if (gDynGuiNaming) {																; if using new naming convention...
			this._dynGuiNaming(&name, &num, hwndVar)										; ... handle with dynamic gui naming method
		}
		else {
			this._origGuiNaming(&name, &num) ;, hwndVar)									; use orig gui naming method
		}
	}
	;############################################################################
	Static _dynGuiNaming(&name, &num, hwndVar)												; returns name/num using NEW naming convention
	{
		if (name='' && num='' && hwndVar!='') {												; if name/number are both empty, but hwnd is not...
			name	:= this.oGuiStr gGuiSep1 hwndVar										; ... add prefix and separator to hwnd (as name)
			num		:= (this.Has(name)) ? this.nextID : ''									; ... only include number if name has been used before
		}
		else if (name='' && num='') {														; if name/number are both empty...
			name	:= this.nnGuiStr														; ... use non-named gui name
			num		:= this.nextID															; ... increment number
		}
		else if (name='' && num!='') {														; if no name, but has a gui number...
			name	:= (num=1)																; ... if num = 1...
					? this.defNameStr														; ...	use default name
					: this.oGuiStr															; ...	otherwise use named guiname
		}
		else if (name) {																	; if orig v1 already had a gui name...
			name	:= this.oGuiStr gGuiSep1 name											; ... add prefix and separator to orig name
		}
	}
	;############################################################################
	Static _origGuiNaming(&name, &num) ;, hwndVar)											; returns name/num using old/orig naming convention
	{
		if (name && num) {																	; if orig v1 has both name and number...
			return																			; ... use existing name/num
		}
		else if (name='' && num='') {														; if name/number are both empty...
			name	:= this.nnGuiStr														; ... use non-named gui name
			num		:= this.nextID															; ... increment number
		}
		else if (name='' && num!='') {														; if no name, but has a gui number...
			name	:= (num=1)																; ... if num = 1...
					? this.defNameStr														; ...	use default name
					: this.oGuiStr															; ...	otherwise use named guiname
		}
	}
}
;################################################################################
;################################################################################
class clsGuiCtrl
{
	Static ctrlPref := gCtrlPfx

	p2					:= ''
	p3					:= ''
	p4					:= ''
	_p4Str				:= ''
	_ctrlID				:= ''
	_ctrlVar			:= ''
	_ctrlLabel			:= ''
	_ctrlType			:= ''
	_ctrlCapTxt			:= ''
	_ctrlMsg			:= ''
	_ctrlObjFmNm		:= ''																; ctrl obj formatted name (includes gui prefix and separator)
	_ctrlIdx			:= ''																; unique index for ctrlType
	_hwndVar			:= ''
	_ctrlEventFunc		:= ''
	_onEventStr			:= ''
	guiObj				:= ''

	P4Str				=> this._p4Str
	CtrlID				=> this._ctrlID
	CtrlVar				=> this._ctrlVar
	CtrlLabel			=> this._ctrlLabel
	CtrlType			=> this._ctrlType
	CtrlCapTxt			=> this._ctrlCapTxt
	CtrlMsg				=> this._ctrlMsg
	CtrlObjFmNm			=> this._ctrlObjFmNm												; ctrl obj formatted name (includes gui prefix and separator)
	CtrlHwndVar			=> this._hwndVar
	CtrlHwndStr			=> (this.CtrlHwndVar)
						?	this.CtrlHwndVar ' := ' this.V2GCVar '.hwnd' :	''
	CtrlEventFunc		=> this._ctrlEventFunc
	OnEventStr			=> RegExReplace(this._onEventStr, '_{2,}', '_')
	UCtrlType			=> '@' StrUpper(this.CtrlType)										; to prevent conflicts with ClassNN
	CtrlName			=> (this.CtrlID) ? this.CtrlID : this.UCtrlType this._ctrlIdx
	KeyName				=> RegExReplace(this.guiObj.KeyName '_' this.CtrlName, ':')


	;############################################################################
	__new(guiObj)
	{
		this.guiObj		:= guiObj															; entire gui object was passed
		this.p2			:= this.guiObj.p2													; param2
		this.p3			:= this.guiObj.p3													; param3
		this.p4			:= this.guiObj.p4													; param4
		this._ctrlType	:= this.p2															; ctrl type
		this._ctrlIdx	:= this.guiObj.GenCtrlIndex(this)									; generate unique index for ctrlType
		this._processCtrlType()																; process ctrl, based on type
	}
	;############################################################################
	V2GCVar {																				; returns string that acts as a variable for ctrl, in v2 script
		get {
			if (gDynGuiNaming) {															; if using dynamic naming method...
				dp		:= this.CtrlDynProps												; ... get ctrl dynamic name properties
				return	gDynMapGC '[[' dp.guiName ',' dp.ctrlID ']]'						; ... return formated dyn var string
			}
			; using orig naming method
			return this._getNameParts(this.CtrlObjFmNm).CtrlName							; extract ctrl name and return it
		}
	}
	;############################################################################
	CtrlDynProps {																			; return dynamic name properties for ctrl
		get {
			guiName	:= toExp(this.guiObj.v2DynName,1,1)										; gui name
			ctrlID	:= toExp(this.CtrlName,1,1)												; control id
			return	{guiName:guiName,ctrlID:ctrlID}											; return obj
		}
	}
	;############################################################################
	_processCtrlType()																		; process ctrl type
	{
		switch this.CtrlType,0 {	; not case-sensitive
			;####################################################################
			case 'BUTTON','CHECKBOX','PIC','PICTURE','UPDOWN':
			; TODO - should PIC/PICTURE use FileName as ctrlID? See ShowAudioMeter.ahk

				this._createCtrlObjName()													; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'ACTIVEX','DATETIME','EDIT','HOTKEY','LINK','MONTHCAL'
				,'PROGRESS','RADIO', 'SLIDER','STATUSBAR','TEXT','TREEVIEW':

				txtAsID	 := false															; default rule - do not use Text (p4) as CtrlID
				nExcept	 := '(?i)\b(?:EDIT)\b'												; exceptions to default rule
				if (!gDynGuiNaming && (this.CtrlType ~= nExcept))							; if using orig naming, and ctrl is one of the exceptions...
					txtAsID := true															; ... allow Text (p4) to be used as CtrlID (for now)
				this._createCtrlObjName(txtAsID)											; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'COMBOBOX','DDL','DROPDOWNLIST','LISTBOX','LISTVIEW'
				,'TAB', 'TAB2', 'TAB3':

				p2 := this.p2, p3 := this.p3, p4 := this.p4									; [use local vars]
				this._getP4List(p2, p3, p4)													; format list string (p4), if present
				this._createCtrlObjName(false)	; text not used as CtrlID					; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'CUSTOM':

				this._createCtrlObjName(false)	; text not used as CtrlID					; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'GROUPBOX':

				txtAsID := !!gDynGuiNaming													; allow text to be used as ctrlID for dynamic naming only
				this._createCtrlObjName(txtAsID)											; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			Default:
				if (this.CtrlType) {
					msg := '`n[' this.CtrlType '] does not have handling'
					MsgBox(A_ThisFunc msg )													; debug
				}
		}
	}
	;############################################################################
	_createCtrlObjName(useCtrlText:=true)													; creates unique (internal) name (string) for gui object
	{
	; useCtrlText - whether to allow ctrl text to be used as ctrl ID

		ctrlID := this._getCtrlID(useCtrlText)												; get controlID
		if (gDynGuiNaming) {																; if using dynamic naming method...
			ctrlName := (ctrlID)															; ... if ctrlID is present...
					 ?  this.CtrlType  gGuiSep1 . ctrlID									; ... 	type:id
					 :  this.UCtrlType gGuiSep1 . this._ctrlIdx								; ... 	TYPE:idx (uppercase)
		}
		else { ; orig naming method															; try to duplicate orig name handling...
			ctrlName := this._getOrigCtrlName(&ctrlID)										; ... get ctrlName and updated ctrlID
		}
		sep := (ctrlID) ? gGuiSep2 : gGuiSep3												; which separator (2 = \, 3 = /)
		ctrlName := this.guiObj.V1GuiNameFm . sep . ctrlName								; build internal ctrl name
		this._ctrlObjFmNm := RegExReplace(ctrlName, '\.')									; remove any dots, store as object property
		this._updateGuiCtrlObjMap()															; update GuiCtrlObj map entries (for orig naming method only)
		return this.CtrlObjFmNm																; return formatted ctrl "name" to caller
	}
	;############################################################################
	_getOrigCtrlName(&ctrlID)						; simulate orig gui naming				; returns ctrl name used for orig naming method
	{
		ctrlType := this.CtrlType, ctrlName := ''											; use local var, ini
		if (ctrlVar  := this.CtrlVar) {														; if ctrl has an associated var...
			cType	 := (InStr(ctrlVar, SubStr(ctrlType, 1, 4))) ? '' : ctrlType			; ... if 1st 4chars of ctrlType are within varName, do not duplicate ctrlType in name
			ctrlName := gCtrlPfx . cType . this.CtrlVar										; ... set ctrl name
		}
		else if (ctrlHwnd := this.CtrlHwndVar) {											; if ctrl has an associated hwnd...
			if (txt := this._ctrlCapTxt) {													; ... if ctrl has text in param4...
				ctrlHwnd	:= StrReplace(ctrlHwnd, 'hwnd')									; ...	can cause empty string, but need to simulate orig naming method
				txt			:= (InStr(ctrlHwnd, SubStr(txt, 1, 4))) ? '' : txt				; ...	if 1st 4chars of text field are within hwndVar, do not duplicate txt in name
				ctrlName	:= gCtrlPfx . txt .  ctrlHwnd									; ...	set ctrl name
			} else {																		; ... if ctrl does NOT have text in param4
				ctrlName	:= ctrlType this._ctrlIdx										; ...	set ctrl name - use ctrlType + index as name
			}
		}
		else if (ctrlType ~= '(?i)\b(?:BUTTON|LISTVIEW|TREEVIEW)\b'							; if ctrlType is one of these...
		|| this.CtrlLabel ) {																; OR ctrl has glabel...
			ctrlName := gCtrlPfx . ctrlType . this._ctrlCapTxt								; ... set ctrl name - use text
		}
		else if (ctrlType = 'LISTBOX') {													; if ctrlType is listview...
			ctrlName	:= (this.CtrlVar) ? gCtrlPfx . ctrlID :	ctrlID						; ... set ctrl name based on availability of ctrlVar
		}
		else if (ctrlType = 'STATUSBAR') {													; if ctrlType is statusbar...
			ctrlName	:= gSBNameDefault													; ... set ctrl name to SB default name
		}
		else {																				; other controls...
			cType		:= (ctrlID ~= '(?i)' ctrlType) ? '' : ctrlType						; ... adj ctrlType as needed
			ctrlID		:= RegExReplace(ctrlID, cType,,,1)									; ... remove ctrlType from ctrlID
			ctrlName	:= gCtrlPfx . cType . ctrlID										; ... set ctrl name
		}
		return ctrlName																		; return ctrl name that simualtes orig naming method
	}
	;############################################################################
	_getNameParts(srcStr)																	; extracts guiname/ctrlname (and other details) from srcStr
	{
		nDiv1		:= escRegexChars(gGuiSep1)												; escape Regex chars for divider 1
		nDiv2		:= escRegexChars(gGuiSep2)												; escape Regex chars for divider 2
		nDiv3		:= escRegexChars(gGuiSep3)												; escape Regex chars for divider 3
		nGuiFull	:= '([^\v' nDiv2 nDiv3 ']++)[' nDiv2 nDiv3 ']'							; needle to extract full ID for gui
		nCtrlFull	:= '(.++)'																; needle to extract full ID for control
		needle		:= '^' . nGuiFull . nCtrlFull . '$'										; assemble final needle
		guiName		:= guiNum := ctrlType := ctrlName := ''									; ini
		if (RegExMatch(srcStr, needle, &m)) {												; if srcStr is properly formatted...
			guiFull			:= m[1], ctrlFull := m[2]										; ... extract full ID for gui and control
			guiParts		:= StrSplit(guiFull, gGuiSep1)									; ... separate subParts from full gui ID
			try guiName		:= guiParts[1]													; ... extract gui name
			try guiNum		:= guiParts[2]													; ... extract gui number
			ctrlParts		:= StrSplit(ctrlFull, gGuiSep1)									; ... separate subParts from full ctrl ID
			if (ctrlParts.Length=1) {														; ... if ctrlStr has only 1 part...
				ctrlName := ctrlParts[1]													; ...	it becomes ctrl name
			} else if (ctrlParts.Length) {													; ... if ctrlStr has 2 parts...
				try ctrlType	:= ctrlParts[1]												; ...	extract ctrl type
				try ctrlName	:= ctrlParts[2]												; ...	extract ctrl name
			}
		}
		return {	guiName		:guiName													; return extracted details (object)
				,	guiNum		:guiNum
				,	ctrlType	:ctrlType
				,	ctrlName	:ctrlName
				,	nDiv1		:nDiv1
				,	nDiv2		:nDiv2
				,	nDiv3		:nDiv3	}
	}
	;############################################################################
	_updateGuiCtrlObjMap()																	; add entries to map as needed
	{
		if (gDynGuiNaming || !this.V2GCVar)													; if using dynamic naming method, OR ctrl has no associated v2 var str...
			return																			; ... do not update map
		global gmGuiCtrlObj																	; [used in GuiControlConv() and GuiControlGetConv()]
		if (this.CtrlVar)																	; if ctrl has associated v1 var
			gmGuiCtrlObj[this.CtrlVar] := this.V2GCVar										; ... associate v1 var	  (key) with v2 var str
		if (this.CtrlHwndVar) {																; if ctrl has associated v1 hwnd...
			gmGuiCtrlObj[this.CtrlHwndVar]			:= this.V2GCVar							; ... associate v1 hwnd   (key) with v2 var str
			gmGuiCtrlObj['% ' this.CtrlHwndVar]		:= this.V2GCVar							; ... associate % v1 hwnd (key) with v2 var str
			gmGuiCtrlObj['%' this.CtrlHwndVar '%']	:= this.V2GCVar							; ... associate %v1 hwnd% (key) with v2 var str
		}
	}
	;############################################################################
	_getP4List(p2, p3, p4)																	; converts p4 list to array, and determines selected item
	{
		if (p4='')																			; if p4 is empty...
			return																			; ... no list to process - exit

		oList	:= this._getListFragments()													; get full list, if fragmented on multiple lines
		p4		.= oList.listFrags															; add fragmentd parts (if present) to p4
		this.guiObj.ListCWS := oList.listCWS												; comments/WS that may be between list fragments (rare)
		; is list a variable?
		if (RegExMatch(p4, '%([^%]+)%', &m)) {												; if list is a variable...
			this._p4Str	 := 'StrSplit(' m[1] ', "|")'										; ... add dynamic extraction
			this._ctrlMsg := ' `; V1toV2: Ensure ' p2 ' has correct choose value'			; ... msg will be added to output later
			return
		}
		; v2 uses ChooseN for selection
		if (InStr(p3, 'Choose'))															; if p3 already includes "choose"... (RARE)
			p4 := RegexReplace(p4, '\|+', '|')												; ... replace all pipe groups (TODO - this breaks empty choices?)
		else if (!InStr(p3, 'Choose') && InStr(p4, '||')) {									; if p3 does not have ChooseN, but p4 has double-pipe... (COMMON)
			; convert || to ChooseN
			selIdx	:= this._getListSelIdx(&p4)												; ... get selection index for list
			choose	:= (selIdx) ? ' Choose' selIdx : ''										; ... [ChooseN] (should not be empty, but just in case)
			p3		.= (p3) ? choose : Trim(choose)											; ... add ChooseN to p3 (trim as needed)
		}
		; assemble array list
		arrList := ''																		; ini
		for idx, item in StrSplit(p4, '|', ' ') {											; for each item in list...
			sep := ((arrList) ? ', ' : ''), arrList .= (sep ToExp(item,1,1))				; ... add item to array list
		}
		arrList := '[' arrList ']'															; add surrounding brackets to array list
		; transfer results to obj properties
		this.p3 := p3, this.p4 := p4, this._p4Str := arrList								; save object properties
	}
	;############################################################################
	_getListFragments()																		; returns fragmented parts of list, if present
	{
	; captures list fragments that are broken up by comments/CRLFs

		global gO_Index
		; get list continuation (on lines following current global loop-line)
		listFrags := '', listCWS := '', lOffset := 1										; ini
		while (gOScriptStr.Has(gO_Index + lOffset))	{										; while additional lines are avail...
			origLine	:= gOScriptStr.GetLine(gO_Index + lOffset)							; get next/current line
			cleanStr	:= cleanCWS(origLine)												; remove all comments and extra WS
			if (cleanStr = '') {															; if line is empty after cleaning...
				listCWS .= '`r`n' origLine													; ... save comments/WS that might be needed later
			} else {																		; line may have list fragment...
				if (SubStr(cleanStr,1,1) != '|')											; if 1st char is not a pipe symbol...
					break																	; ... no more fragments avail - stop
				listFrags .= cleanStr														; line has fragment of list, add to output
			}
			lOffset++																		; prep for next line search
		}
		; verify list was actually fragmented
		if (listFrags)																		; if list fragments were found...
			gO_Index += (lOffset-1), gOScriptStr.SetIndex(gO_Index)							; ... adjust global loop-line index
		else																				; list was NOT fragmented...
			listCWS := ''																	; ... purge - not needed after all
		return {listFrags:listFrags,listCWS:listCWS}										; return result (object)
	}
	;############################################################################
	_getListSelIdx(&p4)																		; ascertain the selection index for list
	{
		selIdx 	:= 0																		; ini
		dPipes	:= StrSplit(p4, '||')														; split p4 string at each double-pipe
		for idx, str in dPipes {															; for each subStr...
			if (idx < dPipes.length) {														; ... if not last group/str...
				RegExReplace(str, '\|',,&curCnt)											; ... 	count number of pipes in substr
				selIdx += (curCnt + 1)														; ... 	determine selection index
			}
		}
		p4		:= RTrim(StrReplace(p4, '||', '|'), '|')									; remove douple-pipes from p4 (returned byRef)
		return	selIdx																		; return selection index
	}
	;############################################################################
	_getCtrlID(incCapTxt:=true)																; ascertain the ctrlID to use for control
	{
	; https://www.autohotkey.com/docs/v1/lib/GuiControl.htm
	;	ctrlID priority - var, ClassNN, cap/text, pic ctrl filename, hwnd

		ctrlType := this.CtrlType															; [control type] - use local var
		this._ctrlCapTxt := RegExReplace(this.p4,'\W+')										; remove non-word chars from caption/text
		this._getCtrlVar()																	; get ctrl var, if present
		this._getCtrlHwnd()																	; get hwnd var, if present
		oLabel := this._getCtrlGLabel()														; get gLabel,	if present
		if (gDynGuiNaming) {																; if using dynamic naming method...
			if (ctrlType = 'BUTTON') {														; ... if ctrl is BUTTON...
				ctrlID	:= (this.CtrlVar)		? this.CtrlVar								; ...	if has ctrlVar,		use it as CtrlID
						:  (this.CtrlCapTxt)	? this.CtrlCapTxt							; ...	if has text,		use it as CTRLID
						;:  (oLabel.label)		? oLabel.label								; ...	if has gLabel,		use it as CtrlID (not supported in v1)
						:  (this.CtrlHwndVar)	? this.CtrlHwndVar							; ...	if has hwndVar,		use it as CtrlID (not supported in v1)
						:  ''																; ...	otherwise empty
			}
			else {																			; ... if ctrl is something other than Button...
				ctrlID	:= (this.CtrlVar)		? this.CtrlVar								; ...	if has ctrlVar,		use it as CtrlID
						:  (this.CtrlHwndVar)	? this.CtrlHwndVar							; ...	if has hwndVar,		use it as CtrlID
						;:  (oLabel.label)		? oLabel.label								; ...	if has gLabel,		use it as CtrlID
						:  (incCapTxt														; ...	if text should be used as CRLID...
							&& this.CtrlCapTxt)	? this.CtrlCapTxt							; ...		if has text,	use it as CTRLID
						:  ''																; ...	otherwise empty
			}
		}
		else {																				; if using orig naming method...
			if (ctrlType ~= '(?i)\b(?:BUTTON|LISTVIEW|TREEVIEW)\b') {						; ... if ctrl is one of these...
				ctrlID	:= (this.CtrlVar)		? this.CtrlVar								; ...	if has ctrlVar,		use it as CtrlID
						:  (this.CtrlCapTxt)	? this.CtrlCapTxt							; ...	if has text,		use it as CTRLID
						;:  (oLabel.label)		? oLabel.label								; ...	if has gLabel,		use it as CtrlID (not supported in v1)
						:  (this.CtrlHwndVar)	? this.CtrlHwndVar							; ...	if has hwndVar,		use it as CtrlID (not supported in v1)
						:  ctrlType . this._ctrlCapTxt										; ...	otherwise use TypeText combo
			}
			else if (ctrlType = 'LISTBOX') {												; ... if ctrl is Listbox
				ctrlID	:= (this.CtrlVar)		? this.CtrlVar								; ...	if has ctrlVar,		use it as CtrlID
						:  ctrlType . this._ctrlIdx											; ...	otherwise use TypeIdx
			}
			else {																			; ... if ctrl is anything else...
				ctrlID	:= (this.CtrlVar)		? this.CtrlVar								; ...	if has ctrlVar,		use it as CtrlID
						:	(incCapTxt														; ...	if text should be used as CRLID...
							&& this.CtrlCapTxt)	? this.CtrlCapTxt							; ...		if has text,	use it as CTRLID
						:	(this.CtrlHwndVar)	? this.CtrlHwndVar							; ...	if has hwndVar,		use it as CtrlID
						:  ''																; ...	otherwise empty
			}
		}
		this._ctrlID	:= ctrlID															; save CTRLID to obj property
		return			getV2Name(ctrlID)													; ensure CtrlID does not have strange chars
	}
	;############################################################################
	_getCtrlGLabel()																		; extract gLabel from param3
	{
		oGLabel			:= clsExtract.ExtGLabel(this.p3) 									; extract using external method
		this._ctrlLabel	:= oGLabel.Label													; save label to obj property
		return			oGLabel																; return label object
	}
	;############################################################################
	_getCtrlHwnd()																			; extract hwnd variable from param3
	{
		if (hwndVar := clsExtract.ExtHwndVar(&p3:=this.p3,true)) {							; if param3 has hwndVar...
			this._hwndVar	:= hwndVar														; ... save hwndVar to obj property
			this.p3			:= p3															; ... param3 with hwnd removed
		}
		return this.CtrlHwndVar																; return result in case needed by caller
	}
	;############################################################################
	_getCtrlVar()																			; extract control variable from param3
	{
		ctrlVar			:= clsExtract.ExtCtrlVar(this.p3)									; extract using external method
		this._ctrlVar	:= (gDynGuiNaming)													; if using dynamic naming method...
						?	ctrlVar															; ... save ctrlVar as extracted
						:	RegExReplace(toExp(ctrlVar,1,1), '\W+')							; ... otherwise, remove non-word chars (TODO - MAKE SURE THIS IS CORRECT)
		return this.CtrlVar																	; return result in case needed by caller
	}
	;############################################################################
	_getEventFunc()																			; ascertain whether control has an event handler
	{
		if (!label := this._validateEventLabel()) {											; if ctrl does NOT have a valid event handler...
			return false																	; ... exit - notify caller
		}
		this._labelToOnEvent(label)		; sets this.CtrlEventFunc							; has valid handler - setup OnEvent (from label)
		return this.CtrlEventFunc															; return result in case needed by caller
	}
	;############################################################################
	_labelToOnEvent(ctrlLabel)																; convert label to OnEvent funcName and string
	{
		global gmList_LblsToFunc, gmMethodsToStatic, gmList_MethToFunc						; used in other funcs

		if (!ctrlLabel)																		; if label is empty...
			return																			; ... exit

		clsObj := scriptHasMethod(ctrlLabel), isMethod := !!(clsObj)						; determine whether 'Label' is a class method

		; setup OnEvent script-string
		comma		:= (gDynGuiNaming) ? ',' : ', '											; include surrounding ws for orig naming method only
		if (this.CtrlType ~= '(?i)LISTVIEW|TREEVIEW') {										; for these controls...
			funcName := getV2Name(ctrlLabel)												; ... ensure func name is v2 compatible
			msg		 := ' `; V1toV2: enable as needed'										; ... user msg for Click/Select events
			ev1 := this.V2GCVar '.OnEvent("DoubleClick"'	. comma							; ... double-click event
						. funcName '.Bind("DoubleClick"))'									; ... 	enabled by default
			ev2 := ';' this.V2GCVar '.OnEvent("Click"'		. comma							; ... click-event
						. funcName '.Bind("Click"))'		. msg							; ... 	disabled by default
			ev3 := ';' this.V2GCVar '.OnEvent("ItemSelect"'	. comma							; ... Item-select event
						. funcName '.Bind("Select"))'		. msg							; ... 	disabled by default
			this._onEventStr := ev1															; ... setup OnEvent str
			this._onEventStr .= (gDynGuiNaming) ? NL.CRLF ev2 NL.CRLF ev3 : ''				; ... add events 2/3 for dynamic naming method only
		}
		else {
			ctrlEvent := "Change"															; ini default
			if (this.CtrlType	~= '(?i)BUTTON|CHECKBOX|LINK|RADIO'							; for these controls...
								.	'|PIC|PICTURE|STATUSBAR|TEXT') {						; ...
				ctrlEvent := "Click"														; ... set click event/action
			}
			else if (this.CtrlType ~= '(?i)COMBOBOX|LISTBOX') {								; for these list controls...
				ctrlEvent := "DoubleClick"													; ... set double-click event/action
			}
			funcName	:= getV2Name(ctrlLabel)												; ensure func name is v2 compatible
			bindClass	:= (isMethod) ? clsObj.cls comma : ''								; include class param for class methods only
			bindParam	:= (ctrlEvent~='(?i)\b(CHANGE|CLICK)') ? 'Normal' : ctrlEvent		; set bind param
			bindStr		:= funcName '.Bind(' bindClass '"' bindParam '")'					; set bind string
			if (gfHasDynamicGLabel) {														; if v1 had dynamic glabel...
				dp	:= this.CtrlDynProps													; ... get dynamic properties
				ev1	:= gDynEH '(' dp.guiName  comma dp.ctrlID								; ... setup OnEvent str
					. comma '"' ctrlEvent '"' comma bindStr ')'								; ... cont
			} else {																		; if NOT dynamic glabel...
				ev1	:= this.V2GCVar '.OnEvent("' ctrlEvent '"' comma bindStr ')'			; ... setup OnEvent str
			}
			this._onEventStr := ev1															; ... save to obj property
		}

		; setup OnEvent function
		if (scriptHasFunc(ctrlLabel)) {														; if script has function with labelname...
			gmGuiFuncCBChecks[ctrlLabel] := true											; ... set flag needed in addGuiCBArgs()
		}
		else if (isMethod) {																; if script has class method with labelname...
			gmGuiFuncCBChecks[clsObj.method] := true										; ... set flag needed in addGuiCBArgs()
			gmMethodsToStatic[clsObj.method] := true										; ... add method to be converted to static
		}
		if (scriptHasLabel(ctrlLabel)) {													; if script has a matching label...
			params := 'A_GuiEvent:="", A_GuiControl:="", Info:="", *'						; ... setup attributes req for labelToFunc conversion
			gmList_LblsToFunc[funcName] := ConvLabel('AG', ctrlLabel, params				; ... [needed in multiple routines]
			, funcName, { NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$"
						, Replacement: "$1Info$2" })
		}
		this._ctrlEventFunc := funcName		; already includes GuiName prefix				; set obj property for event funcName
	}
	;############################################################################
	_validateEventLabel()																	; determines whether ctrl has VALID event handler
	{
		oLabel := this._getCtrlGLabel()														; extract assigned gLabel from param3, if available
		if (oLabel.label) {																	; if param3 has an ASSIGNED gLabel...
			label	:= oLabel.label															; ... it may become v2 OnEvent-bind
			this.p3	:= RegExReplace(this.p3, escRegexChars(oLabel.full))					; ... remove v1 gLabel from param3
		}
		else {																				; if param3 has NO assigned gLabel...
			label := this.CtrlType . this.CtrlCapTxt										; ... use v1 default label, which may become v2 OnEvent-bind
			if ((guiOrigID := this.guiObj.V1OrigNm) != 1									; ... if gui name is not default name...
			&& this.CtrlType = 'BUTTON') {													; ... AND ctrl is a button...
				label := guiOrigID . label													; ...	add guiname prefix to labelName
			}																				; TODO - might need to add more scenerios here
		}
		label	:= getV2Name(label)															; ensure label name is v2 compatable
		return	(this._handlerExists(label)) ? label : ''									; return label (only if handler exists)
	}
	;############################################################################
	_handlerExists(name)																	; returns whether event handler exists in script
	{
		return (scriptHasLabel(name) || scriptHasFunc(name) || scriptHasMethod(name))
	}
}
;################################################################################
;################################################################################
class clsExtract
{
	Static tagChar := chr(0x2605)
	;############################################################################
	Static ExtGLabel(srcStr)																; extract gLabel, if present
	{
		full	:= glabel := ''																; ini
		srcStr	:= RegExReplace(srcStr, '(?i)(\bGRID\b)', this.tagChar '$1')				; mask stand-alone 'Grid' to avoid false-positive as glabel
		nGLabel	:= '(\h*("\h*)?(?<=^|\h)g([^,\h``"]+)(\h*")?)'								; [gLabel needle]
		if (RegExMatch(srcStr, nGLabel, &m)) {												; if srcStr has a v1 gLabel...
			full := m[1], glabel := Trim(m[3], ' ()')										; ... extract v1 gLabel details
		}
		return {full:full,label:glabel}														; return result (object)
	}
	;############################################################################
	Static ExtPLabel(&srcStr,removeTarg:=false)												; extract pLabel, if present
	{
		pLabel := ''																		; ini
		nLabel := '(?i)((\h*)(("\h*)?[+-]?\bLABEL([^,\s]+)\b(\h*")?)(\h*))'					; [labelPrefix needle]
		if (RegExMatch(srcStr, nLabel, &m)) {												; if srcStr has pLabel...
			LWS := m[2], pLabel := m[5] ;, TWS := m[7]										; ... copy lead WS, extract labelPrefix
			LDQ := m[4], RDQ := m[6]
			CDQ	:= (LDQ && RDQ)	? ''	: Trim(LDQ)											; ... if left  double-quote is a CLOSER, copy it
			RDQ := (Trim(LDQ))	? ''	: RDQ												; ... if right double-quote should be added below
			CDQ	.= (CDQ)		? ' '	: ''												; ... add space after closing-DQ (for separation)
			if (removeTarg) {																; ... if removal requested...
				needle := this._escRXChars(m[1])
				srcStr := Trim(RegExReplace(srcStr, needle, LWS . CDQ)) . RDQ				; ... 	remove pLabel from srcStr (keep LWS/closing-DQ, add trail DQ if needed)
			}
		}
		return pLabel																		; return pLabel variable
	}
	;############################################################################
	Static ExtHwndVar(&srcStr,removeTarg:=false)											; extract hwnd variable, if present
	{
		hwndVar := ''																		; ini
		nHwnd := '(?i)((\h*)(("\h*)?[+-]?\bHWND(\w+)\b(\h*")?)(\h*))'						; [hwndVar needle]
		if (RegExMatch(srcStr, nHwnd, &m)) {												; if srcStr has hwndVar...
			LWS := m[2], hwndVar := m[5] ;, TWS := m[7]										; ... copy lead WS, extract hwndVar
			LDQ := m[4], RDQ := m[6]
			CDQ	:= (LDQ && RDQ)	? ''	: Trim(LDQ)											; ... if left  double-quote is a CLOSER, copy it
			RDQ := (Trim(LDQ))	? ''	: RDQ												; ... if right double-quote should be added below
			CDQ	.= (CDQ)		? ' '	: ''												; ... add space after closing-DQ (for separation)
			if (removeTarg) {																; ... if removal requested...
				needle := this._escRXChars(m[1])
				srcStr := Trim(RegExReplace(srcStr, needle, LWS . CDQ)) . RDQ				; ... 	remove hwnd from srcStr (keep LWS/closing-DQ, add trail DQ if needed)
			}
		}
		return hwndVar																		; return hwnd variable
	}
	;############################################################################
	Static ExtCtrlVar(srcStr)																; extract control variable, if present
	{
		ctrlVar	:= ''																		; ini
		nOpt	:= '(?i)'																	; options (case-insensitive)
		nDecl	:= '(?<![-+])(?<=^|["\h])V'													; V for gui varible (can be preceded by DQ/WS/nothing)
		ncc		:= '(?<cc>(?<ccv>\w+)(?<ccp>(?:%\w+%)+))'									; Concat		[w%w% vVar%n%]
		nIdx	:= '(?<aIdx>(\w*)"\h+(?:\h*\.\h*)?(A_INDEX))'								; A_Index		[% "x" x " vVar" . A_Index]
		nXVar1	:= '"\h+(?<xVar1>[^,\s]+)'													; Expression	[% "x" x " v"  This.BtnNum]
		nXVar2	:= '(?<xVar2>\w*"\h+(?:\h*\.\h*)?\w+)'										; Expression	[% "x" x " vLV_" . lv]
		nNorm	:= '(?<norm>\w+\h*)'														; Normal var	[vButton1]
		nVar	:= nOpt nDecl '(?<var>' ncc '|' nIdx '|' nXVar1 '|' nXVar2 '|' nNorm ')'	; assemble final needle

		srcStr	:= RegExReplace(srcStr, '(?i)(\bVSCROLL\b)', this.tagChar '$1')				; mask "vscroll" to avoid false-positive as variable
		if (RegExMatch(srcStr, nVar, &m)) {													; if srcStr has controlVar...
			; extract/reformat Var CONCAT													; [w%w% vVar%n%] ->> [% "Var" . n]
			if (var := Trim(m.cc, ' "')) {													; if is a concat string...
				ccp := RegExReplace(m.ccp, '%(\w+)%', ' . $1')								; ... extract var, remove surrounding %s, var -> concat
				ctrlVar := '% "' m.ccv '"' . ccp											; ... add leading % and surrounding quotes, reformatted concat
			}
			; extract/reformat EXPRESSION A_INDEX											; [% "x" x " vVar" . A_Index] ->> [% "Var" . A_Index]
			if (var := Trim(m.aIdx, ' "')) {												; if has A_Index... (could still have closing DQ before A_Index)
				ctrlVar := (var = 'A_Index') ? m[7] : '% "' var								; ... extract/reformat
			}
			; extract/reformat NORMAL expression 1											; [% "x" x " v" This.BtnNum] ->> [% This.BtnNum]
			else if (var := Trim(m.xVar1, ' "')) {											; if has expression var...
				ctrlVar := '% ' var															; ... extract/reformat
			}
			; extract/reformat NORMAL expression 2											; [% "x" x " vLV_" lv] ->> [% "LV_" . lv]
			else if (var := Trim(m.xVar2, ' "')) {											; if has expression var...
				ctrlVar := '% "' var														; ... extract/reformat
			}
			; extract normal var															; [vButton1] ->> [Button1]
			else if (var := Trim(m.norm)) {													; if is a normal ctrl variable
				ctrlVar := var																; ... extract var
			}
		}
		return ctrlVar																		; return result
	}
	;############################################################################
	Static _escRXChars(srcStr)
	{
	; escapes regex special chars so regex can treat them literally
	; for use with RegexReplace to target replacements using position accuracy

		outStr			:= srcStr
		specialChars	:= '\.?*+|^$(){}[]<>'
		for idx, char in StrSplit(specialChars) {
			outStr := StrReplace(outStr, char, '\' char)									; add preceding \ to special chars
		}
		return outStr
	}
}
;################################################################################
;################################################################################
detectDynamicGuiState(srcLine)
{
; 2026-03-11 AMB, ADDED - to detect whether dynamic naming should be enabled

	global gDynGuiNaming, gfHasDynamicGui ;, gAutoGuiNaming, gfHasDynamicGLabel

	nGui			:= '(?im)\bGUI\b.+'														; Gui cmd
	nGuiCtrl		:= '(?im)\bGUICONTROL\b.+'												; GuiControl cmd
	nAGui			:= '(?i)\bA_(DEFAULT)?GUI\b'											; A_Gui or A_DefaultGui

	if (srcLine ~= nAGui) {																	; if line has A_Gui or A_DefaultGui
		if ((gAutoGuiNaming || gDynGuiNaming) && !gfHasDynamicGui) {						; if gui naming is set to auto OR dynamic, AND dynamic has not been enabled yet...
			gfHasDynamicGui := gDynGuiNaming := true										; ... set dynamic naming to enabled
		}
	} else if (srcLine ~= nGui || srcLine ~= nGuiCtrl)  {									; if line has Gui or GuiControl cmd...
		if (gAutoGuiNaming && !gfHasDynamicGui) {											; if gui naming is set to auto, AND dynamic has not been enabled yet...
			gfHasDynamicGui	:= hasDynamicGuiNaming(srcLine)									; ... check line to determine if it has dynamic gui attributes
			gDynGuiNaming	:= gfHasDynamicGui												; ... set dynamic naming as appropriate
		} else if (!gAutoGuiNaming && gDynGuiNaming) {										; if gui naming is set to dynamic...
			(!gfHasDynamicGLabel) && isDynamicGuiCtrl(srcLine)								; ... determine whether the script has GuiControl, +/-G
			gfHasDynamicGui := gDynGuiNaming ; true											; ... set flag to true
		}
	}
	return
}
;################################################################################
hasDynamicGuiNaming(srcStr)
{
; 2026-03-11 AMB, ADDED - to detect dynamic Gui attributes

	return ((isDynamicGui(srcStr)) || (isDynamicGuiCtrl(srcStr)))
}
;################################################################################
isDynamicGui(srcStr)
{
; 2026-03-11 AMB, ADDED - to detect dynamic Gui attributes for Gui cmd
; TODO - WORK IN PROGRESS !
;	include:	default


	nGui := '(?im)\bGUI\b(?:\h*,\h*)?(.+)'													; detection for gui line (in general)
	if (!(srcStr ~= nGui))																	; if not a Gui command line...
		return false																		; ... exit, notify caller (NOT dynamic)

	; probably has Gui cmd

	; prep line and recheck
	srcStr := cleanCWS(srcStr)																; remove any comments and lead/trail ws
	Mask_T(&srcStr, 'HK'), srcStr := RemovePtn(srcStr, UniqueTag('LC\w+')) 					; remove any leading HK
	if (!RegExMatch(srcStr, nGui, &m))														; if line no longer has legit gui cmd...
		return false																		; ... exit, notify caller (NOT dynamic)

	; separate params
	paramStr := m[1], params := []															; ini
	params := V1ParamSplit(paramStr)														; separate params
	if (!params.Length)																		; if no params found...
		return false																		; ... exit, notify caller (NOT dynamic)

	; check param1 for dynamic attributes
	p1 := Trim(params[1])																	; [use local var]
	if (p1 ~= '^%')																			; if param1 appears to have dynamic var...
		return true																			; ... exit, notify caller (IS dynamic)

	; check param3 for dynamic CtrlVar
	p3 := ''																				; ini
	if (params.Has(3)) {																	; if param3 is present...
		p3 := Trim(params[3]), p3o := p3													; ... STRINGS ARE MASKED at this point
		Mask_R(&p3, 'STR'), ctrlVar := Trim(clsExtract.ExtCtrlVar(p3))						; ... get CtrlVar, if present
		if (ctrlVar ~= '^%' && ctrlVar ~= '"' && p3o ~= '(?<!%)\h+(?!%)')					; ... if param3 appears to have dynamic CtrlVar
			return true																		; ... exit, notify caller (IS dynamic)
	}

	; TODO - ADD MORE CHECKS AS NECESSARY
	;	ADD check for "Default"

	return false																			; does not appear to have dynamic attributes
}
;################################################################################
isDynamicGuiCtrl(srcStr)
{
; 2026-03-11 AMB, ADDED - to detect dynamic Gui attributes for GuiCtrl cmd
; TODO - WORK IN PROGRESS !

	nGuiCtrl := '(?im)\bGUICONTROL\b(?:\h*,\h*)?(.+)'
	if (!(srcStr ~= nGuiCtrl))																; if not a Gui command line...
		return false																		; ... exit, notify caller (NOT dynamic)

	; probably has GuiControl cmd

	; prep line and recheck
	srcStr := cleanCWS(srcStr)																; remove any comments and lead/trail ws
	Mask_T(&srcStr, 'HK'), srcStr := RemovePtn(srcStr, UniqueTag('LC\w+')) 					; remove any leading HK
	if (!RegExMatch(srcStr, nGuiCtrl, &m))													; if line no longer has legit guiCtrl cmd...
		return false																		; ... exit, notify caller (NOT dynamic)

	; separate params
	paramStr := m[1], params := []															; ini
	params := V1ParamSplit(paramStr)														; separate params
	if (!params.Length)																		; if no params found...
		return false																		; ... exit, notify caller (NOT dynamic)

	; check param1 for dynamic attributes
	p1 := Trim(params[1]), p1o := p1, Mask_R(&p1, 'STR'), p1e := Trim(toExp(p1,1,1))		; [use local vars]
	if (p1 ~= '(?i)\+?\bDEFAULT\b')															; if param1 has +Default
		return true																			; ... exit, notify caller (IS dynamic)

	if (p1e ~= '"' && p1o ~= '(?<!%)\h+(?!%)')												; if param1 appears to have dynamic var...
		return true																			; ... exit, notify caller (IS dynamic)

	if (p1o ~= '(?i)[+-]G') {																; if param1 has +/-G...
		global gfHasDynamicGLabel := true													; ... set flag
		return true																			; ... exit, notify caller (IS dynamic)
	}

	; check param2 for dynamic attributes
	p2 := ''																				; ini
	if (params.Has(2)) {																	; if param2 is present...
		p2	:= Trim(params[2]), p2o := p2, Mask_R(&p2, 'STR')								; ... prep param2
		p2e	:= Trim(toExp(p2,1,1))															; ... param2 as expression
		if (isClassNN(p2)																	; ... if param2 is a ClassNN...
		|| (p2e ~= '"' && p2o ~= '(?<!%)\h+(?!%)'))											; ... OR param2 appears to have dynamic var...
			return true																		; ... exit, notify caller (IS dynamic)
	}

	; TODO - ADD MORE CHECKS AS NECESSARY

	return false																			; does not appear to have dynamic attributes
}
;################################################################################
isClassNN(id)
{
; 2026-03-11 AMB, ADDED - returns whether id appears to be a ClassNN

	ClassNNList :=	'AtlAxWin|Button|ComboBox|ComboBoxEx32|'
				.	'Edit|ListBox|'
				.	'msctls_hotkey32|msctls_progress32|'
				.	'msctls_trackbar32|msctls_statusbar32|msctls_updown32|'
				.	'SysDateTimePick32|SysLink|SysListView32|SysMonthCal32|'
				.	'SysTabControl32|SysTreeView32|Static|'

	if (RegExMatch(Trim(id), '^(\D+(?:32)?)(\d+)$', &m)) {
		return InStr(ClassNNList, m[1] '|')													; return whether id appears to be a ClassNN
	}
	return false																			; does not appear to be a ClassNN
}