global gV1GuiLine := unset
;################################################################################
GuiAlt(p)
{
; 2026-03-11 AMB, ADDED to support updated gui cmd handling
; 2026-03-29 AMB, UPDATED to allow tracking of v1 orig gui line contents
; simulates orig gui handling (with updated features) or provides new dynamic gui handling

	if (hasTernary(gV1Line))																; if line has ternary expression
		return LTrim(gV1Line) ' `; V1toV2: Ternary not yet supported (coming soon)'			; ... SKIP it for now
	global gV1GuiLine																		; provides access to details about current v1 script gui line
	gV1GuiLine	:= clsGuiLine(p)															; perform pre-processing of current gui line
	if (gV1GuiLine.PreProcessOK)															; if pre-processing was successful...
		gV1GuiLine.ProcessParams()															; ... perform the rest of the processing
	lineout		:= gV1GuiLine.LineOut														; save new v2 script line
	return		lineout																		; return v2 converted line
}
;################################################################################
class clsGuiLine
{
	_guiObj			:= unset																; will allow access to current gui object
	_oParams		:= ''																	; original params
	_p1				:= ''																	; Gui param 1 (from current script line)
	_p2				:= ''																	; Gui param 2 (from current script line)
	_p3				:= ''																	; Gui param 3 (from current script line)
	_p4				:= ''																	; Gui param 4 (from current script line)
	_lineOut		:= ''																	; (PRIVATE) final converted output for current line
	_namenum		:= ''																	; gui name/number combo for current line
	_isNewGui		:= false																; flag that sets whether ':= NewV2Gui()' should be applied
	PreProcessOK	:= false																; flag that reports whether pre-processing was successful
	HasOrigName 	=> this._namenum														; whether v1 line specified a name/num for gui on current line

	;############################################################################
	__new(p)																				; constructor
	{
		p:= this._cleanParams(p)															; remove any lead/trail WS, including CRLF
		this._oParams := p																	; save all Gui params in original form
		this._p1 := p[1], this._p2 := p[2], this._p3 := p[3], this._p4 := p[4]				; separate params into local properties
		this.PreProcessOK := this._preProcessP1()											; PRE-process param1, set flag
	}
	;############################################################################
	ProcessParams()
	{
		this._processSubCmd()																; process param1 as sub command
		this._processNewGui()																; final actions for new guis
	}
	;############################################################################
	CascadeParams																			; formatted output for logging/testing/debugging
	{
		get {
			try {																			; try - in case guiObj is not set
				pStr := ''																	; ini
				loop 4 {																	; create cascading param list
					LWS	 := Format("{:" . A_Index*2 . "}", "")								; 	leading whitespace (cascading indents)
					pStr .= ('`r`n' . LWS . this._guiObj.P%A_Index%)						; 	param str
				}
				fpath	 := '' ;'`r`n' gFilePAth											; current v1 script filepath
				origP1	 := '`t`t(ORIG P1)`t[' this._guiObj.oParams[1] ']'					; original param1
				return	 fPath '`r`n' this._guiObj.GuiVarName origP1 pStr					; assembled output string
			}
			return 'GETLINE: has no guiObj'													; error occurred - guiObj is not set
		}
	}
	;############################################################################
	LineOut																					; (PUBLIC) final converted output for current line
	{
		get {
			this._lineOut := this._cleanCommas(this._lineOut)								; remove trailing ws from commas
			try this._lineOut .= this._guiObj.ListCWS	; empty 99.99% of the time			; add lines that might have comments/WS extracted between list fragments
			if (InStr(this._lineOut, '`n'))													; if lineout is multi-line...
				return Zip(this._lineOut, 'GUIML')											; ... compress multi-line into single-line tag
			return this._lineOut															; not multi-line... return as is
		}
	}
	;############################################################################
	_cleanCommas(srcStr)																	; remove trailing ws from commas
	{
		if (!gDynGuiNaming || !(srcStr ~= ',\h+'))											; if not using dynamic naming method, or already clean...
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
	; 2026-04-22 AMB, UPDATED as part of fix for #479

		global gfNewScope																	; used to assist controlling of scope (not used yet)

		namenum	:= this._getGuiNameNum() ; also stored in this._namenum						; extract name/number of gui (if present)
		hwndVar	:= clsExtract.ExtHwndVar(&p2:=this._p2,false)								; extract gui hwnd variable (if present)

		; do not allow new guis to be created with these
		;nException	:= '(?i)\b(CANCEL|DESTROY|FONT|HIDE|MENU|SUBMIT)\b'						; watch for these exceptions, for P1
		nException	:= '(?i)\b(CANCEL|DESTROY|HIDE|MENU|SUBMIT)\b'							; watch for these exceptions, for P1 (2026-04-22 - remove FONT)

		if (this._p1 = 'NEW') {																; if P1 has the NEW cmd...
			this._guiObj := clsGuiObj.NewGuiObj(this.HasOrigName,hwndVar,force:=1)			; ... create new gui object
			this._guiObj.UpdateParams(this._oParams, this._p1)								; ... sync line params with current gui object
			this._isNewGui	:= false														; ... ' := NewV2Gui()' is handled in _processSubCmd()
			gfNewScope		:= false														; ... NOT new scope
		}
		else if (this._p1 = 'DEFAULT') {													; if P1 is DEFAULT cmd...
			if (namenum																		; ... if gui name was specified...
			&& clsGuiObj.Has(nameNum)														; ... AND gui name has already been recorded...
			&& guiObj := clsGuiObj.SetCurGuiName(nameNum,hwndVar,&isNew:=0,0)) {			; ... AND gui obj can be set...
					this._guiObj := guiObj													; ... 	store the gui obj locally
					this._guiObj.UpdateParams(this._oParams, this._p1)						; ... 	sync line params with current gui object
					this._isNewGui := false													; ...	do not add NEW declaration
					return true																; ...	continue normal processing of Default cmd
			}
			; default command cannot be processed normally
			this._lineOut := this._processP1Exception(this._p1, namenum)					; ... set line, without normal processing (short-circuit)
			return false																	; ... notify caller of short-circuit
		}
		else if (gDynGuiNaming && this._p1 = 'DESTROY') {									; if P1 is DEFAULT cmd... (new gui not allowed)
			this._lineOut := this._processP1Exception(this._p1, namenum)					; ... 	set line, without normal processing (short-circuit)
			return false																	; ... 	notify caller of short-circuit
		}
		else if (this._p1 = 'LISTVIEW') {													; if P1 is LISTVIEW cmd...
			; in V2, listView is not a valid param for p1									; ... not valid in v2
			; will comment out the line in _processSubCmd()									; ... will be handled in _processSubCmd()
		}
		else if (this._p1 ~= nException && !nameNum && clsGuiObj.HasAny) {					; if P1 is an exception, and gui has NO v1 name/num, and NOT first gui line...
			this._guiObj := clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=0,0)				; ... determine gui object, for current script line
			this._guiObj.UpdateParams(this._oParams, this._p1)								; ... sync line params for current gui object
			this._isNewGui := false															; ... do not add NEW declaration
		}
		else if (this._p1 ~= nException && nameNum) {										; if P1 is an exception, and gui HAS a v1 name/num...
			this._guiObj := clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=0)				; ... determine gui object, for current script line
			this._guiObj.UpdateParams(this._oParams, this._p1)								; ... sync line params for current gui object
			this._isNewGui := false															; ... do not add NEW declaration
		}
		else {																				; default handling
			this._guiObj := clsGuiObj.GetCurGuiObj(nameNum,hwndVar,&isNew:=0)				; ... determine gui object, for current script line
			this._guiObj.UpdateParams(this._oParams, this._p1)								; ... sync line params for current gui object
			this._isNewGui := isNew															; ... new gui declaration may or may not be added
		}
		return true
	}
	;############################################################################
	_getGuiNameNum()																		; extract gui name/num from param1
	{
		p1 := Trim(this._p1), namenum := ''													; ini
		if (RegExMatch(p1, '^((\w*(%)?[\w.]+(?(-1)%|)\w*)\h*:(?!=)\h*)', &m)) {				; if P1 is [NameNum:ANY]... (namenum may be surrounded by %)
			namenum	 := m[2]																; ... [portion before :] extract gui name/num
			this._p1 := Trim(RegExReplace(p1, '^' m[]))										; ... [portion after  :] (remove gui name/num from param1)
		}
		else if (RegExMatch(p1, '^\h*%([^%]+?)(":(\w+)")$', &m)) {							; if p1 is [% var ":COMMAND"]...
			namenum	 := '% ' Trim(m[1])														; ... [portion before :] extract gui name/num
			this._p1 := Trim(m[3])															; ... [portion after  :]
		}
		; included just for clarity
		else if (p1 ~=	'(?i)\b(ADD|CANCEL|COLOR|DEFAULT|DESTROY|FONT|HIDE'					; if P1 is a COMMAND...
					.	'|LISTVIEW|MARGIN|MENU|NEW|SHOW|SUBMIT|TAB)\b') {					; ... v1 gui has NO name or number
		}																					; ... commands will be handled in _processSubCmd()
		; included just for clarity
		else if (p1 ~= '^[+-]\w+.*$') {														; if P1 is a list of OPTIONS...
			; options not handled here														; ... v1 gui has NO name or number
		}																					; ... options will be handled in _processSubCmd()
		else {																				; if P1 is value other than above...
			if (!p1) {																		; ... if P1 is empty (should not happen)...
				errorMsg := 'GUI - Param 1 is empty`n'										; ... 	but just in case (DEBUG)
			} else {																		; ... CAN happen sometimes...
				if (hasTernary(gV1Line)) {													; ...	if P1 has ternary expression...
					uMsg := ' `; V1toV2: Ternary not yet supported (coming soon)'			; ... 		ternary is not yet supported
					this._lineOut := LTrim(gV1Line) . uMsg									; ... 		notify user with line output
				}
				errorMsg := 'GUI - Param 1 was NOT anticipated`n[' p1 ']`n'					; ... 	P1 is OTHER
			}
			MsgBox(A_ThisFunc "`n`n" errorMsg LTrim(gV1Line))								; ... debug popup
		}
		this._namenum := namenum															; CAN be empty string
		return			 namenum															; return namenum to caller
	}
	;############################################################################
	_processP1Exception(cmd, guiName)														; processes P1 cmd exceptions
	{
		lineOut := gV1Line																	; default output (orig v1 line)
		switch cmd,0																		; NOT case-sensitive
		{
			;####################################################################
			case 'DEFAULT':																	; for DEFAULT
				if (gDynGuiNaming) {														; if using dynamic gui naming...
					gn		:= ToExp(guiName,1,1)											; ... formatted gui name
					lineOut	:= 'SetDefaultGui(' gn ')'										; ... add dynamic call to set dynamic gui
				} else {																	; if using simple gui naming...
					lineOut	:= '`;' LTrim(gV1Line)											; ... comment out the line
					xtra	:= '' ;(this.namenum) ? ', but applied' : ''					; ... msg - extra msg content
					lineOut	.= ' `; V1toV2: removed' xtra									; ... add user msg
					lineOut	.= NL.CRLF gLineFillMsg											; ... add fill line in case commented out line causes error
				}
			;####################################################################
			case 'DESTROY':																	; for DESTROY
				if (gDynGuiNaming) {														; if using dynamic gui naming...
					gn		:= ToExp(guiName,1,1)											; ... formatted gui name
					lineOut	:= 'DestroyGui(' gn ')'											; ... add dynamic call to destroy gui
				} else {																	; if using simple gui naming...
					; should not get here													; ... see _processSubCmd()
				}
		}
		return lineOut																		; return v2 line
	}
	;############################################################################
	_processSubCmd()																		; process gui subCommand from line
	{
		global gGuiActiveFont																; used in GuiControlConv()

		incGuiName := !(gDynGuiNaming && !this.HasOrigName)									; include gui name?
		try guiName := this._guiObj.GuiVarName[incGuiName]									; TRY - guiObj not yet set for NEW/LISTVIEW

		switch this._p1,0 {																	; P1 - NOT case-sensitive

			;####################################################################
			case 'ADD':
				this._processAddCmd()														; this._lineOut will be set during call

			;####################################################################
			case 'CANCEL', 'HIDE':
				this._lineOut := guiName . '.Hide()'										; assemble final output

			;####################################################################
			case 'COLOR':
				this._lineOut := guiName . '.BackColor := ' toExp(this._p2,,1)				; assemble final output

			;####################################################################
			case 'DEFAULT':
			; 2026-03-29 AMB, UPDATED to add SetDefaultGui() call
				; Gui object is set indirectly via _preProcessP1()
				;	so no need to do it manually here
				if (gDynGuiNaming) {														; if using dynamic gui naming...
					gn := ToExp(this._guiObj.GuiName,1,1)									; ... format guiName
					this._lineout	:= 'SetDefaultGui(' gn ')'								; ... add dynamic call string
				} else {																	; if using simple gui naming...
					this._lineOut	:= '`;' LTrim(gV1Line)									; ... comment out the line
					xtra			:= (this._namenum) ? ', but applied' : ''				; ... msg - extra msg content
					this._lineOut	.= ' `; V1toV2: removed' xtra							; ... add user msg
					this._lineOut	.= NL.CRLF gLineFillMsg									; ... add fill line in case commented out line causes error
				}
				clsGuiObj.SetThdGuiObj(this._guiObj)										; set default obj for conversion (can cause issues)

			;####################################################################
			case 'DESTROY':
				if (!gDynGuiNaming) {														; if using simple gui naming...
					this._lineOut	:= 'Try ' . guiName . '.' this._p1 '()'					; ... assemble final output (preserve orig cmd)
				} else { ; gDynGuiNaming													; if using dynamic gui naming...
					; should not get here													; ... see _processP1Exception()
				}

			;####################################################################
			case 'FONT':
			; 2026-04-22 AMB, UPDATED as part of fix for issue #479
				comma			:= (gDynGuiNaming) ? ',' : ', '								; comma with/without trailing ws
				p2				:= RegExReplace(this._p2,'(?i)(\bNORM)AL\b','$1')			; "Normal" -> "Norm" (part of fix for #479)
				p2				:= (p2		 != '')	? toExp(p2		,,1) : ''				; format param2
				p3				:= (this._p3 != '') ? toExp(this._p3,,1) : ''				; format param3
				params			:= Trim(p2 comma p3, comma)									; assemble, remove any trailing comma
				gGuiActiveFont	:= params													; used in GuiControlConv()
				this._lineOut	:= guiName '.SetFont(' params ')'							; assemble final output

			;####################################################################
			case 'LISTVIEW':
				ctrlID := Trim(this._p2)													; use var
				if (InStr(ctrlID, '%')) {													; if ctrlID contains %...
					; TODO - ADD HANDLING FOR % VAR, %VAR%, if needed						; ... HANDLING WILL BE ADDED LATER
				}
				if (ctrlObj := clsGuiObj.CtrlObjFromCtrlID(ctrlID)) {						; get listview ctrl obj, if it exists (is known about)...
					this._setDefaultNames('LISTVIEW', ctrlObj.V2GCVar)						; ... set listview default name
					varName := ctrlObj.V2GCVar												; ... get listview var name
					varName := (gDynGuiNaming) ? varName : "'" varName "'"					; ... add surrounding quotes as needed
					msg		:= ' `; V1toV2: removed, but applied'							; ... msg to user...
					this._lineOut	:= (gDynGuiNaming)										; ... assemble final output
									? 'global gV2CurLV := ' varName							; ... set script var to point to cur listview as default
									: '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg			; ... add user msg to output, also add fill line
					return
				}
				; listview ctrl (ctrlID) not identified using v1 script (so far)...			; but, dynamic handling may be able to identify it
				if (gDynGuiNaming) {														; if using dynamic naming method...
					varName			:= gDynMapGC '[["",' toExp(ctrlID,1,1) ']]'				; ... use map as variable
					this._lineOut	:= 'global gV2CurLV := ' varName						; ... assemble final output
				} else {																	; if using simple naming method
					msg := " `; V1toV2: [" ctrlID "] not found. Manual edit required."		; ... msg to user...
					this._lineOut := LTrim(gV1Line) . msg									; ... post original v1 line with msg to user
				}

			;####################################################################
			case 'MARGIN':
				p2				:= toExp(this._p2,,1), p3 := toExp(this._p3,,1)				; format param2,3
				mX				:= guiName '.MarginX := ' p2								; format x
				my				:= guiName '.MarginY := ' p3								; format y
				this._lineOut	:= mx . ((my) ? ', ' my : '')								; assemble final output

			;####################################################################
			case 'MENU':
				this._lineOut	:= guiName '.MenuBar := ' this._p2							; assemble output

			;####################################################################
			case 'NEW':
				this._processNewCmd()														; this._lineOut will be set during call

			;####################################################################
			case 'SHOW':
				p2				:= (this._p2 != '') ? toExp(this._p2,,1) : ''				; format param2
				showStr			:= guiName '.' this._p1 '(' p2 ')'							; output string for 'Show()'
				titleStr		:= ''														; ini
				if (title		:= this._p3) {												; if a title was included with v1 Show command...
					this._guiObj.GuiTitle := title											; ... save orig gui title
					titleStr	:= guiName '.Title := ' toExp(title,1,1) . NL.CRLF			; ... output string for 'title'
				}
				this._lineOut	:= titleStr . showStr										; assemble final output

			;####################################################################
			case 'SUBMIT':
			; 2026-03-29 AMB, UPDATED to add V2DynSubmit()
				param := (this._p2 = 'NoHide') ? '0' : ''									; [NoHide param]
				if (gDynGuiNaming) {														; if using dynamic naming...
					dynGui			:= gDynMapGui '[A_DefaultGui]'							; ... [dynamic gui string]
					p				:= (param='') ? '' : ',' param							; ... add leading comma to param, if param is present
					this._lineOut	:= 'V2DSResult := ' gDynSubmit '(' dynGui p ')'			; ... assemble final output
				} else {																	; if using simple naming method
					ctrlVarStr		:= this._getSubmitCtrlVarList()							; ... get ctrl var assignment list
					guiVarStr		:= this._guiObj.GuiVarName								; ... [gui var str]
					val				:= guiVarStr '.' this._p1 '(' param ')' ctrlVarStr		; ... assignment value, and list of ctrlVar assignments
					this._lineOut	:= 'oSaved := ' val										; ... assemble final output
				}

			;####################################################################
			case 'TAB','TAB2','TAB3':
			; 2026-04-23 AMB, UPDATED as part of fix for issue #480
				emptyVal		:= (gDynGuiNaming) ? 0 : ''									; val to use if param 2 is empty
				tabPage			:= (this._p2) ? toExp(this._p2) : emptyVal					; tab page value
				this._lineOut	:= 'V2TabCtrl.UseTab(' tabPage ')'							; ... assemble final output

			;####################################################################
			default:																		; this will catch OPTIONS (6% of cases)
				if (optStr := this._isOptions(this._p1)) {									; if P1 is Options...
					this._lineOut := optStr													; ... could set this within _isOptions() instead
				}
				else {
					; UNKNOWN, but should be caught in _getGuiNameNum() first
				}
			;####################################################################
		}
	}
	;############################################################################
	; 2026-04-23 AMB, UPDATED as part of fix for issue #480
	_processAddCmd()																		; processed ADD SubCommand
	{
		global gmGuiCtrlType																; used in GuiControlConv() and GuiControlGetConv()

		ctrl	:= this._p2																	; control to add - use var for clarity
		ctrlObj	:= this._guiObj.AddCtrl()													; creates ctrl obj from v1 gui line-params
		keyName := (gDynGuiNaming) ? ctrlObj.KeyName : ctrlObj.V2GCVar						; determine keyname to use below
		gmGuiCtrlType[keyName] := ctrl														; used in GuiControlConv() and GuiControlGetConv()
		; build declare string (for p1,p2,p3)
		incGuiName := !(gDynGuiNaming && !this.HasOrigName)									; include gui name ?
		guiVarStr:= this._guiObj.GuiVarName[incGuiName]										; string that acts as a variable for GUI obj
		p2		:= (ctrlObj.P2 != '') ? toExp(ctrlObj.P2,1,1) : ''							; format param2 - should always have a value
		p3		:= (ctrlObj.P3 != '') ? toExp(ctrlObj.P3,1,1) : ''							; format param3 - usually has a value
		p4		:= (ctrlObj.P4 != '') ? toExp(ctrlObj.P4,1,1) : ''							; format param4 - sometimes has a value
		decl	:= guiVarStr '.' this._p1 '(' p2 ', ' p3									; declaration ini (includes p1,p2,p3)
		; add p4 as needed
		nP4Ctrls := '(?i)\b(COMBOBOX|DDL|DROPDOWNLIST|LISTBOX|LISTVIEW|TAB[23]?)\b'			; ctrls that may be associated with param4
		if (ctrl ~= nP4Ctrls) {																; if added ctrl is one of these ctrls...
			p4	:= (ctrlObj.P4Str) ? ctrlObj.P4Str : ''										; ... get array list (if applicable)
		}
		decl	.= ((p4) ? ', ' p4 : ''), decl := Trim(decl, ' ,') . ')'					; finalize decl string
		; add var declaration as needed
		curLVStr	:= ''																	; ini current Listview str
		declStr		:= ''																	; ini final declare str
		ctrlVarStr	:= ctrlObj.V2GCVar[incGuiName]											; string that acts as a variable for CTRL obj
		if (!gDynGuiNaming																	; if using simple naming method...
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
		declStr := (ctrl ~= '(?i)\bTAB[23]?\b')												; if ctrl is a TAB (2026-04-23 - now applies to all gui modes)
				? 'V2TabCtrl := ' declStr													; ... allows tracking of current tab control
				: declStr																	; ... otherwise, no changes to decl str
		; finalize output
		this._lineOut	:= declStr ctrlObj.V2CtrlMsg										; these can both be empty strings sometimes
		join			:= ((this._lineOut)													; if output str is NOT empty...
						?  ((gDynGuiNaming || ctrlObj.V2CtrlMsg) ?  NL.CRLF					; ... add CRLF as needed  (for dynamic naming method)
						: ', ') : '')														; ... add comma as needed (for simple  naming method)
		CtrlHwndStr		:= (ctrlObj.CtrlHwndStr) ? join ctrlObj.CtrlHwndStr	  : ''			; add hwnd assignment,	 if applicable
		EHStr			:= (ctrlObj.OnEventStr)  ? NL.CRLF ctrlObj.OnEventStr : ''			; add event declaration, if applicable (new	line)
		this._lineOut	.= CtrlHwndStr EHStr curLVStr										; assemble final output
		; set default names as needed
		this._setDefaultNames(ctrl, ctrlVarStr)												; set default name for LV,SB,TV (as applicable)
	}
	;############################################################################
	_processNewCmd()																		; processes NEW SubCommand
	{
	; 2026-03-29 AMB, UPDATED
		if (hwndVar		:= clsExtract.ExtHwndVar(&p2:=this._p2,true))						; if gui hwnd present, extract it...
			this._p2	:= p2																; ... p2 with hwnd removed
		if (pLabel		:= clsExtract.ExtPLabel(&p2:=this._p2,true))						; if pLabel present, extract it...
			this._p2	:= p2																; ... p2 with pLabel removed
		; handle params
		params			:= ''																; ini
		params			.= (this._p2 != '') ?		toExp(this._p2,1,1) : ''				; format param2 (options)
		params			.= (this._p3 != '') ? ', '	toExp(this._p3,1,1) : ''				; format param3 (title)
		needQuotes		:= !!(params && !InStr(params, '"'))								; if quotes are needed...
		params			:= (needQuotes) ? '"'	params '"' : params							; ... add surrounding quotes
		params			:= (params)		? ', ' params	   : params							; add comma as needed (TODO - REMOVE TRAILING WS FROM COMMA ?)
		; get gui var name and id (strings)
		varNameObj		:= this._getGuiVarName()											; obj that has varNameStr and ID
		guiVarStr		:= varNameObj.varNameStr											; string that acts as a variable for GUI obj
		varId			:= varNameObj.id													; key that is used to identify gui obj in real time (during execution)
		if (gDynGuiNaming && !this.HasOrigName) {											; if using dynamic gui naming AND v1 gui line does NOT have gui name...
			guiVarStr := this._guiObj.GuiVarName[0]											; ... do not use guiName in var declaration...
			varId := '""'																	; ... use "" instead.
		}
		varId			.= (gDynGuiNaming) ? ',1' : ''										; [for dynamic naming] add param ("1") to force SetDefaultGui
		params			:= Trim(varId . params, ', ')										; trim ws and extra commas from params
		; make declaration strings
		guiDecl			:= (gDynGuiNaming) ? 'NewV2Gui' : 'Gui'								; gui declaration, depending on which naming method is being used
		newGuiStr		:= guiVarStr ' := ' guiDecl '(' params ')'							; string used to create new Gui
		join			:= ((gDynGuiNaming) ? NL.CRLF : ', ')								; use CRLF/comma to join commands, depending on which naming method is being used
		HwndStr			:= (hwndVar) ? join hwndVar ' := ' guiVarStr '.Hwnd': ''			; string that assigns hwnd to hwndVar
		newGuiStr		.= HwndStr															; append hwnd var assignemnt to output str
		defEventsStr	:= this._guiObj.DefaultEvents(pLabel)								; string that defines gui event handler (if applicable)
		if (pLabel && !defEventsStr) {														; if function/method for +Label was NOT found...
			msg			 := ' `; V1toV2: Unable to locate [' pLabel '] for +Label'			; ... user msg
			defEventsStr := '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg					; ... comment-out orig v1 line, add msg-to-user and fill-line
		}
		newGuiStr		.= (defEventsStr) ? (NL.CRLF . defEventsStr) : ''					; append event handler assignment to output str
		newGuiStr		:= LTrim(newGuiStr, ' `t`r`n')										; remove any leading ws, just in case
		this._lineOut	:=	newGuiStr														; assemble final output
	}
	;############################################################################
	_processNewGui()																		; creates/outputs new gui delaration as needed
	{
		if (!this._isNewGui) {																; if new gui declaration should not be added...
			return																			; ... exit
		}
		if (!gDynGuiNaming) {																; if using simple naming method...
			params			:= ''															; ... ini
			defEventsStr	:= this._guiObj.DefaultEvents()									; ... [event string] if present
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
		defEventsStr	:= this._guiObj.DefaultEvents()										; [event string] if present
		defEventsStr	:= RegExReplace(defEventsStr, '`r`n\h*', doubleIndent)				; reformat whitespace for event string
		varNameObj		:= this._getGuiVarName()											; get var name details (object)
		guiVarStr		:= varNameObj.varNameStr											; string that acts as a variable for GUI obj
		varId			:= varNameObj.id													; gui map key
		params			:= (params) ? ', ' params : params									; new gui params
		params			:= Trim(varId . params, ', ')										; trim lead/trail ws/commas
		newGuiStr		:= guiVarStr ' := NewV2Gui(' params ')'								; gui assignment
		newGuiStr		.= (defEventsStr) ? (doubleIndent . defEventsStr) : ''				; add event string if present
		ifDecl			:= 'If (!HasV2Gui(' varId '))'										; IF declaration for IF block
		ifBlk			:= ' {' doubleIndent . newGuiStr . NL.CRLF . '}'					; IF brace block
		ifBlk			.= (this._lineOut) ? NL.CRLF : ''									; add CRLF, as needed
		this._lineOut	:= ifDecl . ifBlk . this._lineOut									; return final output
	}
	;############################################################################
	_getGuiVarName()																		; returns gui var name details as an object
	{
		id			:= ''																	; ini
		varNameStr	:= this._guiObj.GuiVarName												; gui 'variable name' (string) that will be displayed in converted script
		nVarName	:= gDynMapGui '\[([^\)]+)\]'											; needle used to extract the ID from varName
		if (RegExMatch(varNameStr, nVarName, &m))											; extract the ID portion of the VarName string
			id	:= m[1]																		; extracted ID
		return {varNameStr:varNameStr,id:id}												; obj with VarName-string and ID
	}
	;############################################################################
	_getSubmitCtrlVarList()																	; returns list of ctrl var assignments for Submit cmd
	{
	; 2026-03-29 AMB, ADDED
		exclude		:=	'|ACTIVEX|BUTTON|GROUPBOX|LINK|PIC|PICTURE'							; excluded ctrl types
					.	'|PROGRESS|STATUSBAR|TEXT|'
		ctrlVarStr	:= '', ctrlList := '|'													; ini
		for key, ctrl in this._guiObj.CtrlList {											; for each ctrl in gui ctrl list...
			ctrlVar := Trim(ctrl.ctrlVar), ctrlType := ctrl.CtrlType						; ... get current ctrl var and type
			if (ctrlVar = ''																; ... if ctrl var is empty...
			|| ctrlVar ~= '[%\h]'															; ... OR is dynamic...
			|| key ~= '(?i)^[^/]+/\w+:\d+$'													; ... OR is a v1 Control[Num]...
			|| InStr(ctrlList, '|' ctrlVar  '|')											; ... OR is a duplicate...
			|| Instr(exclude,  '|' ctrlType '|'))											; ... OR type should be excluded...
				continue																	; ... 	skip it
			ctrlList	.= ctrlVar . '|'													; ... add ctrl varName to list (for detecting dups)
			ctrlVarStr	.= NL.CRLF 'Try ' ctrlVar ' := oSaved.' ctrlVar						; ... create an assignment for the var
		}
		return ctrlVarStr																	; return assignment list
	}
	;############################################################################
	_isOptions(srcStr)																		; handles formatting/output of Gui options
	{
		if (!RegExMatch(srcStr, '^\h*[+-]\w.*$', &m))										; if srcStr does not contain options...
			return false																	; ... exit, notify caller
		; has options
		opts		:= m[]																	; ini extracted options
		pLabel		:= clsExtract.ExtPLabel(&opts,true)										; if pLabel present, extract/remove it
		hwndVars	:= []																	; ini
		nHwnd		:= '(?i)((\h*)(("\h*)?[+-]?\bHWND(\w+)\b(\h*")?)(\h*))'					; hwnd needle
		While(pos	:= RegexMatch(opts, nHwnd, &m, pos??1)) {								; for each hwnd within srcStr...
			hwndVars.Push(m[5])																; ... extract hwnd variable
			opts	:= RegExReplace(opts, escRegexChars(m[2] m[3]),,,1)						; ... remove hwnd from string
		}
		opts		:= Trim(opts)															; trim any stray ws
		guiVarStr	:= this._guiObj.GuiVarName												; string that acts as a variable for GUI obj
		optsStr		:=	(opts) ? guiVarStr '.Opt(' toExp(opts,,1) ')' : ''					; create options string
		hwndVarsStr	:= ''																	; ini hwnd assignment declarations
		for idx, var in hwndVars {															; for each hwnd var that was extracted above...
			join		:= ((gDynGuiNaming) ? NL.CRLF : ', ')								; ... use CRLF/comma to join commands, depending on naming method being used
			curStr		:= join var ' := ' guiVarStr '.Hwnd'								; ... create a hwnd var assignment
			hwndVarsStr	.= curStr															; ... add assignment to hwnd assignemnt declarations str
		}
		hwndVarsStr	:= (optsStr) ? hwndVarsStr	: LTrim(hwndVarsStr, ', `r`n')				; trim leading CRLF/comma as needed
		optsStr		.= hwndVarsStr															; update output str
		defEventsStr:= (pLabel) ? this._guiObj.DefaultEvents(pLabel) : ''					; get events string ONLY WHEN +Label option is present
		if (pLabel && !defEventsStr) {														; if function/method for +Label was NOT found...
			msg		:= ' `; V1toV2: Unable to locate [' pLabel '] for +Label'				; ... user msg
			defEventsStr := '`;' LTrim(gV1Line) msg NL.CRLF gLineFillMsg					; ... comment-out orig v1 line, add user msg and fill line
		}
		optsStr		.= (defEventsStr) ? (NL.CRLF . defEventsStr) : ''						; update output str
		optsStr		:= LTrim(optsStr, ' `t`r`n')											; trim leading ws and CRLFs as needed
		return		optsStr																	; return final output
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
}
;################################################################################
;################################################################################
class clsGuiObj
{
	_v1OrigNm 		:= ''																	; v1 gui name from orig v1 script (could be empty)
	_v1GuiName		:= ''																	; v1 gui NAME
	_v1GuiNum		:= ''																	; v1 gui NUMBER
	_guiHwnd		:= ''																	; gui hwnd
	_listCWS		:= ''																	; (rare) comments/WS surrounding list fragments
	_forceName		:= false																; provides ability to force gui name
	_ctrlList		:= map()																; list of all controls for this gui
	_tabCtrlList	:= []																	; list of tab controls for this gui
	oParams			:= []																	; original v1 gui params
	P1				:= ''																	; orig v1 param1
	P2				:= ''																	; orig v1 param2
	P3				:= ''																	; orig v1 param3
	P4				:= ''																	; orig v1 param4
	GuiTitle		:= ''																	; gui title
	TabCtrlList		=> this._tabCtrlList													; list of tab controls for this gui (PUBLIC)
	CtrlList		=> this._ctrlList														; list of all controls for this gui (PUBLIC)
	CtrlCount		=> this._ctrlList.Count													; number of controls for this gui (PUBLIC)
	HasOrigV1Nm		=> this._v1OrigNm														; v1 gui name from orig v1 script (PUBLIC)
	V1GuiNameFm 	=> this._v1GuiName . ((this._v1GuiNum) ? gGuiSep1 this._v1GuiNum : '')	; combines gui name with number (using separator)
	_v1NameNum		=> this._v1GuiName . this._v1GuiNum										; concat name & num
	_v2DynName		=> (this.HasOrigV1Nm)	? this.HasOrigV1Nm								; name varies depending on certain factors
					:  ((gDynGuiNaming)		? ((this._forceName)
					?  this._v1NameNum : ''): this._v1NameNum)
	GuiName			=> (gDynGuiNaming)		? this._v2DynName  : this._v1GuiName			; 2026-03-29 AMB, ADDED
	KeyName			=> (this.HasOrigV1Nm)	? this.HasOrigV1Nm : this._v1GuiName			; is sometimes empty

	;############################################################################
	__New(v1Name,v1Num,v1OrigName,forceName)												; constuctor
	{
		this._v1GuiName	:= v1Name															; record v1 gui name
		this._v1GuiNum	:= v1Num															; record v1 gui number
		this._v1OrigNm	:= v1OrigName														; record v1 orig gui name/num
		this._forceName	:= forceName														; record whether name should be forced
	}
	;############################################################################
	GuiVarName[incName:=1]																	; string that acts as a variable for gui, in script
	{
		get {
			if (gDynGuiNaming) {															; if using dynamic naming method...
				if (!incName)																; ... if gui name shoud be empty
					return gDynMapGui '[""]'												; ...	return dyn var string with NO name
				name	:= this.GuiName														; ... format v2 dyn name
				name	:= (name) ? ToExp(name,1,1) : '""'									; ... format name further
				return	gDynMapGui '[' name ']'												; ... return dyn var string WITH name
			}
			; using simple naming method
			name		:= this._v1GuiName													; ini name
			if (!clsGuiObj.IsSpecialDefault(this._v1GuiName,this._v1GuiNum))				; if gui is NOT special default
				name	.= this._v1GuiNum													; ... add gui number to name
			name		:= RegExReplace(name, '%(\w+)%', '$1')								; remove any surrounding %
			return 		Trim(toExp(name,1,1),'"')											; convert v1 expr to v2, and trim DQs, return it
		}
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
	AddCtrl()																				; create ctrl obj, add to ctrl lists
	{
		ctrlObj	:= clsGuiCtrl(this)															; create new ctrl obj (pass entire gui object)
		ctrlKey	:= ctrlObj.CtrlObjFmNm														; unique ctrl name to use as map key (includes gui prefix and separator)
		this._ctrlList[ctrlKey] := ctrlObj													; add ctrl obj to local ctrl list
		if (ctrlObj.CtrlType ~= '(?i)TAB[23]?') {											; if ctrl is a tab ctrl
			this._tabCtrlList.Push(ctrlObj)													; ... add it to local tabCtrlList
		}
		clsGuiObj.IniMapLists()																; make sure map lists are not case-sensitive
		clsGuiObj.sCtrlList[ctrlKey] := ctrlObj												; add ctrl obj to static ctrl list
		return ctrlObj																		; return ctrl obj
	}
	;############################################################################
	UpdateParams(oParams, p1)																; allows external routines to update GuiObj params
	{
		this.oParams := oParams
		this.P1		 := p1
		this.P2		 := this.oParams[2]
		this.P3		 := this.oParams[3]
		this.P4		 := this.oParams[4]
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
		origGuiName	:= (this.HasOrigV1Nm = '1')	? ''	: this.HasOrigV1Nm					; only fill if not default
		origGuiName	:= (pref != 'Gui')		 	? ''	: origGuiName						; do not duplicate GuiName
		origClose	:= origGuiName . pref . 'Close'
		origEsc		:= origGuiName . pref . 'Escape'
		origCMenu	:= origGuiName . pref . 'ContextMenu'
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

		incGuiName	:= !(gDynGuiNaming && !gV1GuiLine.HasOrigName)							; include gui name ?
		eventLines	:= '', guiName := this.guiVarName[incGuiName]							; ini
		for idx, curEvent in defEvents {													; for each event in default events...
			if (!scriptHasLabel(curEvent.origlabel))										; ... if event label does not exist in script...
				continue																	; ...	skip it
			lbl		:= curEvent.origlabel													; ... record label name
			fn		:= getV2Name(curEvent.newFunc)											; ... record func name
			params	:= curEvent.params														; ... record func params
			gmList_LblsToFunc[getV2Name(lbl)]:=ConvLabel('GUI',lbl,params,fn)				; ... create conversion object (see labelAndFunc.ahk), place in map
			comma	:= (gDynGuiNaming) ? ',' : ', '											; ... [trailing ws will depend on naming method]
			eventLines .= guiName '.OnEvent("' curEvent.event '"' comma						; ... create .onEvent string
						. (getV2Name(curEvent.newFunc) ')' NL.CRLF)
		}
		eventLines	:= RegExReplace(eventLines, '\s+$')										; remove final trailing-ws and CRLF
		return		eventLines																; return event string
	}
	;############################################################################
	Static uid					:= 0
	Static nnGuiStr				:= (gDynGuiNaming) ? gDynDefGuiNm : gGuiNameDefault
	Static oGuiStr				:= (gDynGuiNaming) ? 'v1Gui' : 'oGui'
	Static defNameStr			:= this.nnGuiStr
	Static _curGuiObj			:= ''
	Static ThdGuiObj			:= ''														; 2026-03-29 AMB, UPDATED
	Static ThdGuiName			:= ''														; 2026-03-29 AMB, ADDED
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
		this.defNameStr			:= (gDynGuiNaming) ? this.oGuiStr : this.nnGuiStr												; permanent value
		this._curGuiObj			:= ''														; initial value, will be continually updated
		this.ThdGuiObj			:= ''
		this.ThdGuiName			:= ''														; 2026-03-29 AMB, ADDED
		this.sGuiList			:= Map()
		this.sCtrlList			:= Map()
		this.IniMapLists()
	}
	;############################################################################
	; TODO - REPLACE WITH LIVE DYNAMIC CHECK INSTEAD ?
	Static CtrlObjFromCtrlID(ctrlID, guiID := '')											; returns ctrl obj that matches ctrlID
	{
		if (guiID && obj := this._findCtrlInGui(ctrlID, guiID))	{							; if gui was specified, search only that gui for matching ctrl
			return obj																		; ... if ctrl-match found, return it
		}
		else if (obj := this._findCtrlInAny(ctrlID))			{							; if gui was not specified, search all ctrls for matching ctrl
			return obj																		; ... if ctrl-match found, return it
		}
		return false																		; ctrl-match not found
	}
	;############################################################################
	Static _findCtrlInGui(ctrlID, guiID)													; returns ctrl obj if it exists for specified gui
	{
		if (!this.sGuiList.Has(guiID))														; if gui not found...
			return false																	; ... ctrl cant be found for missing gui
		guiObj	:= this.sGuiList[guiID]														; get gui obj
		if (matches := this._findCtrlInList(ctrlID,guiObj.CtrlList))						; if one or more ctrl-matches found...
			return (matches.Length > 1) ? false : matches[1]								; ... return ctrl ONLY IF it is unique (more than 1 match is ambiguous)
		return	false																		; ctrl-match not found
	}
	;############################################################################
	Static _findCtrlInAny(ctrlID)															; returns ctrl-match (obj), as long as only 1 ctrl-match exists
	{
		; search all guis, for all ctrls matching ctrlID
		if (matches := this._findCtrlInList(ctrlID,this.sCtrlList))							; if one or more ctrl-matches found...
			return (matches.length > 1) ? false : matches[1]								; ... return ctrl ONLY IF it is unique (more than 1 match is ambiguous)
		return false																		; ctrl-match not found
	}
	;############################################################################
	Static _findCtrlInList(ctrlID,srcList)													; finds all matching ctrls in list
	{
		matches := []																		; ini match list
		nKey	:= '^[^\\]+\\.+'															; verification of key formatting
		for key, ctrl in srcList {															; for each ctrl in list...
			curID := ctrl.CtrlID, curVar := ctrl.CtrlVar									; [use local vars]
			curHwnd := ctrl.CtrlHwndVar, curTxt := ctrl.CtrlCapTxt							; [use local vars]
			ccid	:= RegExReplace(ctrlID, '\W+')											; clean ctrlID - remove all non-word chars
			if (!(key ~= nKey))																; if key is NOT in proper format...
				continue																	; ... skip it
			if (curVar	= ctrlID															; if target	matches ctrl variable
			||	curHwnd	= ctrlID															; OR		matches ctrl hwnd
			||  curTxt	= ccid																; OR		matches ctrl Text
			||	curID	= ctrlID)															; OR		matches ctrl ID...
					matches.push(ctrl)														; 	add ctrl to match list
		}
		if (matches.Length)																	; if ANY match found...
			return matches																	; ... return list of matches

		; see if ctrlID matches the event label												; ONLY DO THIS AS A LAST RESORT
		for key, ctrl in srcList {															; for each ctrl in list...
			if (!(key ~= nKey))																; if key is NOT in proper format...
				continue																	; ... skip it
			curLbl := ctrl.CtrlEventFunc													; get ctrl event function
			if (curLbl && curLbl = ctrlID)													; if target matches event func...
				matches.push(ctrl)															; ... return matching ctrl obj
		}
		return (matches.Length) ? matches : false											; return list of matching ctrls, or false
	}
	;############################################################################
	Static Has(namenum)																		; convenience method for gui lookup
	{
		if (this.sGuiList.Has(String(namenum)))												; if list has key...
			return this.sGuiList[String(namenum)]											; ... return associated gui obj
		return false																		; key not found
	}
	;############################################################################
	Static IsSpecialDefault(name:='', num:='')												; returns whether name/num is the ini default gui name/num
	{
		return (name = this.defNameStr && string(num) = '1')
	}
	;############################################################################
	; for special default
	Static _iniUid()																		; ensures uid is set to at least 1
	{
		(this.uid=0) && this.uid:=1															; if uid is 0, set it to 1
	}
	;############################################################################
	Static IniMapLists()																	; ensures maps are case-insensitive
	{
		if (!this.sGuiList.Count)															; [map must be empty to disable case-sensitivity]
			 this.sGuiList.CaseSense := 0													; disable case-sensitivity for keys
		if (!this.sCtrlList.Count)															; [map must be empty to disable case-sensitivity]
			 this.sCtrlList.CaseSense := 0													; disable case-sensitivity for keys
	}
	;############################################################################
	Static GetCurGuiObj(guiName, hwndVar, &isNew:=false, newAllowed:=true)					; tracks and returns the current gui object
	{
		if (guiObj := this.Has(guiName)) {													; if guiName was created/recorded previously...
			this._setCurGuiObj(guiObj)														; ... place specified gui obj into currentGui container
			return guiObj																	; ... return the prev recorded gui obj
		}
		else if (guiName='') {																; if guiName is empty...
			if (!this.ThdGuiObj																; ... if threadGui container has not been filled yet...
			&&  newAllowed) {																; ... AND cmd allows new gui obj to be created (see exclusions)...
				newObj := this.NewGuiObj(guiName,hwndVar,,&isNew:=true)						; ...	create new gui obj, using guiName
				this.SetThdGuiObj(newObj)													; ...	place new gui obj in threadGui container (also placed in currentGui container)
			}
			; these two containers may not reflect same obj at given time
			return (this.ThdGuiObj) ? this.ThdGuiObj : this._curGuiObj						; ... return obj from threadGui, or from currentGui container
		}

		; guiName has not yet been created/recorded
		if (!newAllowed)																	; if cmd does not allow new gui obj to be created (see exclusions)...
			return this._curGuiObj															; ... just return current gui obj

		; new allowed
		newObj := this.NewGuiObj(guiName,hwndVar,,&isNew:=true)								; create new gui obj using guinName
		if (guiName = '1'																	; if guiName is the default number...
		&& !this.ThdGuiObj)																	; AND threadGui container has not been filled yet...
			this.SetThdGuiObj(newObj)														; ... place new gui obj in threadGui container (also placed in currentGui container)
		return newObj																		; return the new gui obj
	}
	;############################################################################
	; included for +Default
	Static SetCurGuiName(guiName, hwndVar, &isNew:=false, newAllowed:=true)					; manually sets the current gui name (and obj)
	{
		if (guiObj := this.Has(guiName)) {													; if guiName was created/recorded previously...
			this.SetThdGuiObj(guiObj)														; ... place specified gui obj into threadGui container
			return guiObj																	; ... return the prev recorded gui obj
		}

		; guiName has not yet been created/recorded
		if (!newAllowed)																	; if cmd does not allow new gui obj to be created (see exclusions)...
			return '' ; should not happen, TODO but return something else just in case?		; ... return now

		; new allowed (should always be the case)
		newObj := this.NewGuiObj(guiName,hwndVar,,&isNew:=true)								; create new gui obj using guinName
		if (guiName = '1'																	; if guiName is the default number...
		&& !this.ThdGuiObj)																	; AND threadGui container has not been filled yet...
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
		this.ThdGuiObj	:= guiObj															; default-line gui-Object
		this._setCurGuiObj(guiObj)															; also set current gui object
		(gDynGuiNaming) && (this.ThdGuiName := this.ThdGuiObj.GuiName)						; set public thread default guiName

	}
	;############################################################################
	Static NewGuiObj(namenum,hwndVar,force:=false,&isNew:=true)								; creates a new gui object, also determines the name/number for that object
	{
		this.IniMapLists()																	; ensure case-sensitivity is disabled for map-key

		enterName := namenum																; make note of original (v1) gui namenum

		this._getNewGuiNameNum(namenum, hwndVar, &name:='', &num:='', force)				; determine the name/num to use for new gui

		if (this.IsSpecialDefault(name,num)) {												; Gui 1 (or first no-name) requires special treatment
			this._iniUid()																	; ... make sure uid is at least 1
			(!gDynGuiNaming) && (entername := '1')											; ... if using simple gui naming, set v1 gui name to 1
		}

		guiObj := this(name,num,orig:=enterName,force)										; create Gui-Object using name/num
		if (entername && (!this.Has(enterName)))											; if orig (v1) name/num is not yet listed...
			this.sGuiList[String(enterName)] := guiObj										; ... add it to list (so it can be referenced later)
		altKeyName := name . num															; this will be used as alternate map-key for gui object list
		this.sGuiList[altKeyName] := guiObj													; altKeyName usually the same as entername (add both to list)
		(force) && this.SetThdGuiObj(guiObj)												; force update of current-thread gui obj, if requested
		return guiObj																		; return gui object to caller
	}
	;############################################################################
	Static _getNewGuiNameNum(namenum, hwndVar, &name:='', &num:='', force:=false)			; separates/returns name/num that should be used for new Gui
	{
		if (namenum && RegExMatch(nameNum, '^\h*(.*?)(\d*)\h*$', &m)) {						; if namenum is not empty...
			name := m[1], num := m[2]														; ... separate name from number
		}
		if (gDynGuiNaming) {																; if using dynamic naming method...
			this._dynGuiNaming(&name, &num, hwndVar)										; ... handle accordingly
		}
		else {																				; if using simple naming method...
			this._simpleGuiNaming(&name, &num)												; ... handle accordingly
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
	Static _simpleGuiNaming(&name, &num)													; returns name/num using simple naming method
	{
		if (name && num) {																	; if v1 has both name and number...
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
	_hwndVar			:= ''																; v1 ctrl hwnd variable
	_ctrlVar			:= ''																; v1 ctrl variable
	_ctrlLabel			:= ''																; v1 ctrl glabel
	_ctrlCapTxt			:= ''																; v1 ctrl caption/text
	_ctrlID				:= ''																; v1 ctrl ID
	_ctrlType			:= ''																; ctrl type
	_ctrlObjFmNm		:= ''																; ctrl obj formatted name (includes gui prefix and separator)
	_ctrlIdx			:= ''																; unique index for ctrlType
	_ctrlEventFunc		:= ''																; event function name for v2 script
	_onEventStr			:= ''																; event string for v2 script
	_p4Str				:= ''																; param4 for v2 script (usually array list)
	_v2CtrlMsg			:= ''																; user message for v2 script
	_guiObj				:= ''																; to allow access to parent guiObj

	P2					:= ''																; PUBLIC - orig gui line param2
	P3					:= ''																; PUBLIC - orig gui line param3
	P4					:= ''																; PUBLIC - orig gui line param4
	CtrlVar				=> this._ctrlVar													; PUBLIC
	CtrlLabel			=> this._ctrlLabel													; PUBLIC
	CtrlCapTxt			=> this._ctrlCapTxt													; PUBLIC
	CtrlID				=> this._ctrlID														; PUBLIC
	CtrlType			=> this._ctrlType													; PUBLIC
	CtrlObjFmNm			=> this._ctrlObjFmNm												; PUBLIC
	CtrlEventFunc		=> this._ctrlEventFunc												; PUBLIC
	OnEventStr			=> RegExReplace(this._onEventStr, '_{2,}', '_')						; PUBLIC
	P4Str				=> this._p4Str														; PUBLIC
	V2CtrlMsg			=> this._v2CtrlMsg													; PUBLIC
	CtrlHwndVar			=> this._hwndVar													; PUBLIC
	CtrlHwndStr			=> (this.CtrlHwndVar)												; PUBLIC
						?	this.CtrlHwndVar ' := ' this.V2GCVar '.hwnd' :	''
	UCtrlType			=> '@' StrUpper(this.CtrlType)										; PUBLIC - to prevent conflicts with ClassNN
	CtrlName			=> (this.CtrlID) ? this.CtrlID : this.UCtrlType this._ctrlIdx		; PUBLIC
	KeyName				=> RegExReplace(this._guiObj.KeyName '_' this.CtrlName, ':')		; PUBLIC - map-key

	;############################################################################
	__new(guiObj)
	{
		this._guiObj	:= guiObj															; entire gui object was passed
		this.P2			:= this._guiObj.P2													; param2
		this.P3			:= this._guiObj.P3													; param3
		this.P4			:= this._guiObj.P4													; param4
		this._ctrlType	:= this.P2															; ctrl type
		this._ctrlIdx	:= this._guiObj.GenCtrlIndex(this)									; generate unique index for ctrlType
		this._processCtrlType()																; process ctrl, based on type
	}
	;############################################################################
	V2GCVar[inclGui:=''] {																	; returns string that acts as a variable for ctrl, in v2 script
		get {
			if (!gDynGuiNaming)																; if using simple naming method...
				return this._getNameParts(this.CtrlObjFmNm).CtrlName						; ... extract ctrl name and return it
			; using dynamic naming method													; if using dynamic naming method...
			dp		:= this.CtrlDynProps													;  get ctrl dynamic name properties
			inclGui := (inclGui!='')														;  if caller specified whether gui name should be included or not...
					? inclGui																;  ... honor caller's request
					: !(gDynGuiNaming && !gV1GuiLine.HasOrigName)							;  ... otherwise, include gui name ONLY IF v1 line specified a name
			guiName := (inclGui) ? dp.guiName : '""'										;  gui name (included or not)
			return	gDynMapGC '[[' guiName ',' dp.ctrlID ']]'								;  return formated dyn var string
		}
	}
	;############################################################################
	CtrlDynProps {																			; return dynamic name properties for ctrl
		get {
			guiName	:= this._guiObj.GuiName													; gui name
			guiName	:= (guiName) ? toExp(guiName,1,1) : '""'								; gui name formatted
			ctrlID	:= toExp(this.CtrlName,1,1)												; control id formatted
			return	{guiName:guiName,ctrlID:ctrlID}											; return obj
		}
	}
	;############################################################################
	_processCtrlType()																		; process ctrl type
	{
		switch this.CtrlType,0 {															; not case-sensitive
			;####################################################################
			case 'BUTTON','CHECKBOX','PIC','PICTURE','UPDOWN':
			; TODO - should PIC/PICTURE use FileName as ctrlID? See ShowAudioMeter.ahk

				this._createCtrlObjName(1)		; text ALLOWED as CtrlID					; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'ACTIVEX','DATETIME','EDIT','HOTKEY','LINK','MONTHCAL'
				,'PROGRESS','RADIO', 'SLIDER','STATUSBAR','TEXT','TREEVIEW':

				txtAsID	 := 0																; default rule - DONT allow Text (p4) as CtrlID
				nExcept	 := '(?i)\b(?:EDIT)\b'												; exceptions to default rule
				if (!gDynGuiNaming && (this.CtrlType ~= nExcept))							; if using simple naming, and ctrl is one of the exceptions...
					txtAsID := 1															; ... allow Text (p4) to be used as CtrlID (for now)
				this._createCtrlObjName(txtAsID)											; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'COMBOBOX','DDL','DROPDOWNLIST','LISTBOX','LISTVIEW'
				,'TAB', 'TAB2', 'TAB3':

				p2 := this.P2, p3 := this.P3, p4 := this.P4									; [use local vars]
				this._getP4List(p2, p3, p4)													; format list string (p4), if present
				this._createCtrlObjName(0)		; text NOT allowed as CtrlID				; create unique ctrl obj name
				this._getEventFunc()														; get glabel/eventFunc if applicable

			;####################################################################
			case 'CUSTOM':

				this._createCtrlObjName(0)		; text NOT allowed as CtrlID				; create unique ctrl obj name
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
					;MsgBox(A_ThisFunc msg )												; debug
				}
		}
	}
	;############################################################################
	_createCtrlObjName(useCtrlText:=true)													; creates unique (internal) name (string) for ctrl object
	{
	; useCtrlText - whether to allow ctrl text to be used as ctrl ID

		ctrlID := this._getCtrlID(useCtrlText)												; get controlID
		if (gDynGuiNaming) {																; if using dynamic naming method...
			ctrlName := (ctrlID)															; ... if ctrlID is present...
					 ?  this.CtrlType  gGuiSep1 . ctrlID									; ... 	type:id
					 :  this.UCtrlType gGuiSep1 . this._ctrlIdx								; ... 	TYPE:idx (uppercase)
		}
		else { ; simple naming method														; try to duplicate orig name handling...
			ctrlName := this._getOrigCtrlName(&ctrlID)										; ... get ctrlName and updated ctrlID
		}
		sep := (ctrlID) ? gGuiSep2 : gGuiSep3												; which separator (2 = \, 3 = /)
		ctrlName := this._guiObj.V1GuiNameFm . sep . ctrlName								; build internal ctrl name
		this._ctrlObjFmNm := RegExReplace(ctrlName, '\.')									; remove any dots, store as object property
		this._updateGuiCtrlObjMap()															; update GuiCtrlObj map entries (for simple naming method only)
		return this.CtrlObjFmNm																; return formatted ctrl "name" to caller
	}
	;############################################################################
	_getOrigCtrlName(&ctrlID)						; simulate orig gui naming				; returns ctrl name used for simple naming method
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
				ctrlName	:= ctrlType . this._ctrlIdx										; ...	set ctrl name - use ctrlType + index as name
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
		this._guiObj.ListCWS := oList.listCWS												; comments/WS that may be between list fragments (rare)
		; is list a variable?
		if (RegExMatch(p4, '%([^%]+)%', &m)) {												; if list is a variable...
			this._p4Str	 := 'StrSplit(' m[1] ', "|")'										; ... add dynamic extraction
			this._v2CtrlMsg := ' `; V1toV2: Ensure ' p2 ' has correct choose value'			; ... msg will be added to output later
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
		this.P3 := p3, this.P4 := p4, this._p4Str := arrList								; save object properties
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
		this._ctrlCapTxt := RegExReplace(this.P4,'\W+')										; remove non-word chars from caption/text
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
		else {																				; if using simple naming method...
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
		oGLabel			:= clsExtract.ExtGLabel(this.P3) 									; extract using external method
		this._ctrlLabel	:= oGLabel.Label													; save label to obj property
		return			oGLabel																; return label object
	}
	;############################################################################
	_getCtrlHwnd()																			; extract hwnd variable from param3
	{
		if (hwndVar := clsExtract.ExtHwndVar(&p3:=this.P3,true)) {							; if param3 has hwndVar...
			this._hwndVar	:= hwndVar														; ... save hwndVar to obj property
			this.P3			:= p3															; ... param3 with hwnd removed
		}
		return this.CtrlHwndVar																; return result in case needed by caller
	}
	;############################################################################
	_getCtrlVar()																			; extract control variable from param3
	{
		ctrlVar			:= clsExtract.ExtCtrlVar(this.P3)									; extract using external method
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
		comma	:= (gDynGuiNaming) ? ',' : ', '												; include surrounding ws for simple naming method only

		incGuiName := !(gDynGuiNaming && !gV1GuiLine.HasOrigName)							; include gui name ?
		ctrlVar	:= this.V2GCVar[incGuiName]													; get v2 ctrl variable
		if (this.CtrlType ~= '(?i)LISTVIEW|TREEVIEW') {										; for these controls...
			funcName := getV2Name(ctrlLabel)												; ... ensure func name is v2 compatible
			msg		 := ' `; V1toV2: enable as needed'										; ... user msg for Click/Select events
			ev1		 :=		ctrlVar '.OnEvent("DoubleClick"'	. comma						; ... double-click event
							. funcName '.Bind("DoubleClick"))'								; ... 	enabled by default
			ev2		 := ';'	ctrlVar '.OnEvent("Click"'			. comma						; ... click-event
							. funcName '.Bind("Click"))'		. msg						; ... 	disabled by default
			ev3		 := ';'	ctrlVar '.OnEvent("ItemSelect"'		. comma						; ... Item-select event
							. funcName '.Bind("Select"))'		. msg						; ... 	disabled by default
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
				dp		:= this.CtrlDynProps												; ... get dynamic properties
				guiName	:= (gV1GuiLine.HasOrigName) ? dp.guiName : '""'						; ... gui name
				ev1		:= gDynEH '(' guiName  comma dp.ctrlID								; ... setup OnEvent str
						. comma '"' ctrlEvent '"' comma bindStr ')'							; ... cont
			} else {																		; if NOT dynamic glabel...
				ev1		:= ctrlVar '.OnEvent("' ctrlEvent '"' comma bindStr ')'				; ... setup OnEvent str
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
			;gmList_MethToFunc[clsObj.method] := true										; ... add method to allow param adjustments
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
			this.P3	:= RegExReplace(this.P3, escRegexChars(oLabel.full))					; ... remove v1 gLabel from param3
		}
		else {																				; if param3 has NO assigned gLabel...
			label := this.CtrlType . this.CtrlCapTxt										; ... use v1 default label, which may become v2 OnEvent-bind
			if (((guiOrigID := this._guiObj.HasOrigV1Nm) != '1')							; ... if gui name is not default name...
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
; 2026-03-14 AMB, UPDATED: added return value

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
	return gfHasDynamicGui
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
;################################################################################
dynIncludeToLib()
{
; 2026-03-14 AMB, ADDED: copies dynamic include file to global library, as needed

	if (!gCopyIncl) {	; see Global_Declare.ahk											; if auto-copy is disabled...
		return false																		; ... do not copy include file to library
	}

	; ini include-file paths
	dynGuiFN	:= 'v2DynGui.ahk'															; include-file name
	sFile		:= A_ScriptDir '\Lib\'				dynGuiFN								; include-file source folder
	dFile		:= A_MyDocuments '\AutoHotkey\Lib\'	dynGuiFN								; include-file destination folder (global library)
	; is include-file found in source folder?
	if (!dynIncludeExist(sFile)) {															; if src include-file missing...
		return false																		; ... exit (will terminate instead)
	}
	; is include-file found in global library folder?
	if (!FileExist(dFile)) {																; if include-file not found in destination folder...
		try FileCopy(sFile, dFile)															; ... copy src file to destination
		return !!(FileExist(dFile))															; ... return whether dest file now exists
	}
	; src and dest files found - compare contents between files
	if (FileRead(sFile) == FileRead(dFile)) {												; if src and dest contents match...
		return true																			; ... return success
	}

	; src file is different than dest file...
	; rename current dest file, copy src to dest
	SplitPath(dFile, &FName, &dir, &ext, &FnNoExt, &drv)									; extract path parts for orig dest file
	dFile2	:= dir '\' FnNoExt '_BKUP_' A_Now '.' ext										; append current date-time to dest filename
	FileMove(dFile, dFile2)																	; rename orig dest file
	try FileCopy(sFile, dFile)																; copy src file to dest
	return !!(FileExist(dFile))																; return whether dest file exists
}
;################################################################################
dynIncludeExist(srcPath:='',showMsg:=true,terminate:=true)
{
; 2026-03-14 AMB, ADDED
;	determines whether include-file exists, can show msg and terminate, if requested

	dPath	:= A_ScriptDir '\Lib\v2DynGui.ahk'												; default src path/file
	srcPath	:= (srcPath!='') ? srcPath : dPath												; [Include file path]
	if (FileExist(srcPath))																	; if file exists...
		return srcPath																		; ... return path as success flag
	; file does not exist
	if (showMsg) {																			; if msg display is requested (default)...
		SplitPath(srcPath, &FName)															; get #Include file name
		msg := 'Dynamic Gui Handling requires a special #Include file...'
		msg .= '`n`nThe following file is missing!`n' srcPath
		msg .= '`n`nPlease ensure ' FName ' is placed in the proper path, '
		msg .= 'or choose a mode that does not use Dynamic Gui Handling.'
		msg .= (terminate) ? '`n`nThe converter will now terminate.' : ''
		MsgBox(msg,'V1toV2 Converter - Missing #Include file')								; ... show msg
	}
	(terminate) && ExitApp																	; terminate if requested
	return false																			; otherwise, return 'file missing' flag
}
;################################################################################
buildCtrlVarAssignFunc(indent:='`t')					; 2026-03-29 AMB, ADDED				; builds function (string) that initiates gui ctrl vars
{
	if (!ctrlListArr := getGuiCtrls())														; get array list of all ctrl vars for all guis in v1 script
		return ''																			; ... return empty string if no ctrl vars found
	assignStr := ''																			; ini
	for idx, cn in ctrlListArr																; for each ctrl var name...
		assignStr .= indent cn ' := ""`r`n'													; ... add assignment str
	funcNm	:= gGuiCtrlVarAssignFN															; get func name
	crlf	:= (gHasV2Funcs) ? '' : '`r`n' ; see clsSection._buildFuncsList					; Add CRLF when no other V2 funcs have been added in LabelAndFunc.ahk
	banner	:= crlf . ';##############################################`r`n'					; separator banner
	userMsg	:= ' `; V1toV2: initializes gui control variables'								; msg to user
	funcStr	:= banner funcNm ' {' userMsg '`r`n' indent 'global`r`n' assignStr '}'			; build  function string
	return	funcStr																			; return function string
}
;################################################################################
getGuiCtrls()											; 2026-03-29 AMB, ADDED				; returns array list of all ctrl variable-names for all guis
{
	exclude		:=	'|ACTIVEX|BUTTON|GROUPBOX|LINK|PIC|PICTURE'								; excluded ctrl types
				.	'|PROGRESS|STATUSBAR|TEXT|'
	ctrlList	:= '|'																		; ini
	for gKey, oGui in clsGuiObj.sGuiList {													; for each gui found in v1 script...
		for cKey, ctrl in oGui.CtrlList  {													; ... get ctrl list for gui
			ctrlVar := Trim(ctrl.ctrlVar), ctrlType := ctrl.CtrlType						; ... get current ctrl var and type
			if (ctrlVar = ''																; ... if ctrl var is empty...
			|| ctrlVar ~= '[%\h]'															; ... OR is dynamic...
			|| cKey ~= '(?i)^[^/]+/\w+:\d+$'												; ... OR is a v1 Control[Num]...
			|| InStr(ctrlList, '|' ctrlVar  '|')											; ... OR is a duplicate...
			|| Instr(exclude,  '|' ctrlType '|'))											; ... OR type should be excluded...
				continue																	; ...	skip it
			ctrlList .= ctrlVar . '|'														; ... add ctrl varName to list
		}
	}
	ctrlList := Trim(ctrlList, '| ')														; trim pipe/space chars from ends of ctrl list
	if (ctrlList='')																		; if ctrl list is now empty...
		return ''																			; ... return empty str
	ctrlList := sort(ctrlList, 'D|')														; sort control vars by name
	return	 StrSplit(ctrlList, '|')														; return array list of ctrl names
}