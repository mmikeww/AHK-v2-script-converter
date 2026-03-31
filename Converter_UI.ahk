/*
	Provides user interface supporting the following:
	 * User conversion-settings
	 * convenient launch pad for QCV2/v2Converter, after changing settings

	Change Log:
	2026-01-26 AMB, ADDED
	2026-03-11 AMB, UPDATED: to enable selection of simple/dynamic/auto gui handling
	2026-03-14 AMB, UPDATED:
					added validation for guiName/ctrlPfx formatting
					added #Include-file auto-copy option (but mandatory for now)
					changed some var/func/settings names
	2026-03-18 AMB, UPDATED: validation to allow unicode and dis-allow AHK reserved words (for guiname)
	2026-03-30 AMB, UPDATED:
					to provide faster validation for gui name. Validation now uses a reserved-word list
					also added faster audio response when variable name is invalid

*/

#Include Convert\6ReservedWords.ahk																	; 2026-03-30 has gV2ReservedWords list
#SingleInstance force
CoordMode('Tooltip','Screen')
clsUserUI()
;################################################################################
class clsUserUI {																					; Gui handling

	oGui			:= ''																			; gui object
	wGui			:= 470																			; gui width
	hGui			:= 225																			; gui height
	wText			:= this.wGui - 105																; width of text controls
	iniFile			:= 'Converter.ini'																; file to save settings
	autoSave		:= ''																			; ini auto-save setting
	fTTActive		:= false																		; tooltip flag
	;############################################################################
	__New() {
		this._makeGui()																				; create Gui
		OnMessage(0x0020, ObjBindMethod(this, "OnMouseMove"))
	}
	;############################################################################
	_makeGui() {

		; gui/ctrl settings and strings
		guiBkgd		:= '0x444444', tbClr := ' background0xDDDDDD '									; background colors
		ctr			:= ' 0x0200 center ', bdr := ' +border '										; center and border settings string
		cGray		:= ' c0x999999 '																; custom gray for text
		hGui		:= this.hGui, wGui := this.wGui													; gui height/width
		hPnl		:= hGui-15																		; button panel width (left side)
		hTab		:= hPnl-6, wTab := 350															; tab ctrl height/width
		hTxt		:= 28, wTxt := this.wText														; text-label height/width
		hBtn		:= 50, wBtn := 75																; launch buttons height/width
		btnWH		:= ' w' wBtn ' h' hBtn															; button height/width control string
		wLbl		:= 60, wEdit := 110, wGB := 95													; other widths
		tabX		:= wGB +15																		; x position for tab ctrl

		; create gui
		this.oGui	:= Gui(), this.oGui.BackColor := guiBkgd										; create gui, set bkgd color
		this.oGui.OnEvent('Close', this.evClose.bind(this)										)	; gui close event

		; setup controls
		this.oGui.SetFont('bold')																	; set font weight to Bold (initially)
		this.btnGB	:= this.oGui.AddGroupBox('x10 y5 w' wGB ' h' hPnl ' cGray'					)	; buttons groupbox
		txtRun		:= this.oGui.AddText(tbClr ctr 'x11 y12 w' wGB-2 ' h18', 'RUN'				)	; buttons groupbox header
		this.CVS	:= this.oGui.AddButton(btnWH bdr 'vCVS x20 y+10','Convert v1`nScript File'	)	; v2Converter button
		this.QCC	:= this.oGui.AddButton(btnWH bdr 'vQCC','Convert v1`nCode'					)	; QC code converter button
		this.QCT	:= this.oGui.AddButton(btnWH bdr 'vQCT','Run QC`nUnit Tests'				)	; QC Unit test button
		tabs		:= ['','  Gui  ', '  HK  ', '  General  ']										; Tab names
		iFile		:= A_WinDir '\system32\shell32.dll'												; file to pull icons from
		picGear		:= this.oGui.Add('Pic', tbClr ' x' tabX+15 ' y13 w16 h16 icon315',iFile		) 	; place gear icon on tab 1 (easier than the sendmessage method)
		tbXYWH		:= ' x' tabX ' y10 h' hTab ' w' wTab ' '										; tab-dimensions string
		this.T3		:= this.oGui.AddTab3(tbClr bdr 'buttons' tbXYWH ' vTab3',tabs				)	; create tab control
		this.T3.OnEvent('Change', this.evTab.bind(this) 										)	; event handler for Tab control		(pass entire obj)
		this.CVS.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for v2Converter		(pass entire obj)
		this.QCC.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for QC code convert	(pass entire obj)
		this.QCT.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for QC Unit tests	(pass entire obj)

		; save tab
		this.T3.UseTab(1)																			; target tab 1
		this.oGui.SetFont('w1 s12')																	; set font style
		txt				:= 'Converter Settings`n(see tabs for details)'								; textStr for tab 1
		this.txtSave	:= this.oGui.AddText(cGray 'center x' tabX+20 ' y+25 w' wTab-40, txt	)	; show textStr
		this.oGui.SetFont('w1 s8')																	; set font style
		this.btnSave	:= this.oGui.AddButton(bdr 'x' tabX+125 ' y+10 w100 h50 vSave', 'Save'	)	; add save button
		this.chkSave	:= this.oGui.AddCheckBox('xp+15 y+7 checked vChkSave', ' Auto Save'		)	; toggle for auto-save
		this.btnSave.OnEvent('Click', this.evSave.bind(this)									)	; event handler for save button
		this.chkSave.OnEvent('Click', this.evSave.bind(this)									)	; event handler for auto-save chkbox

		; HK Tab
		this.T3.UseTab(3)																			; target HK settings tab
		this.oGui.SetFont('w1 s20'), tabX += 20														; set enlarged font size, but normal weight
		tempMsg := 'Will allow`nhotkey filtering`n(performance)'									; temp message
		this.oGui.AddText(cGray 'center x' tabX ' y70 w310', tempMsg							)	; add temp message
		this.oGui.SetFont('s8')																		; set normal font size

		; Gui Tab
		this.T3.UseTab(2)																			; target Gui settings tab
		lblMode			:= this.oGui.AddText( 'x' tabX ' y+25 w' wlbl-25, 'Mode:'				)	; label	- Gui Conversion Mode
		this.rdoGuiOrig	:= this.oGui.AddRadio('yp vOrig', 'Orig'								)	; Radio	- Gui Conversion - Orig
		this.rdoGuiSmpl	:= this.oGui.AddRadio('yp checked vSmpl', 'Simple'						)	; Radio	- Gui Conversion - Simple
		this.rdoGuiDyn	:= this.oGui.AddRadio('yp vDyn', 'Dynamic'								)	; Radio	- Gui Conversion - Dynamic
		this.rdoGuiAuto	:= this.oGui.AddRadio('yp vAuto', 'Auto'								)	; Radio	- Gui Conversion - Auto
		lblCtrlPfx		:= this.oGui.AddText( 'x' tabX ' y+13 w' wlbl, 'Ctrl Prefix:'			)	; label	- GuiCtrl Prefix preference
		lblGuiName		:= this.oGui.AddText( 'xp+125 w' wlbl, 'Gui Name:'						)	; label	- GuiName preference
		this.edtCtrlPfx	:= this.oGui.AddEdit( 'x' tabX ' y+3 w' wEdit ' vCPfx', 'CtrlPfx'		)	; Edit	- GuiCtrl Prefix preference
		this.edtGuiName	:= this.oGui.AddEdit( 'xp+125 w' wEdit ' vGName', 'GuiName'				)	; Edit	- GuiName preference
		this.txtEx		:= this.oGui.AddText( 'cBlue x' tabX ' y+5 h45 w' wTab-40, ''			)	; label - show example of code output
		inclCap			:= 'Auto-Copy #Include file to global Library (if absent)'
		this.chkInclude	:= this.oGui.AddCheckBox('x' tabX ' y+1 checked', inclCap				)	; label - show example of code output
		this.chkInclude.Opt('+hidden +disabled')													; disable for now
		this.rdoGuiOrig.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Orig	 (pass entire obj)
		this.rdoGuiSmpl.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Simple	 (pass entire obj)
		this.rdoGuiDyn.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Dynamic	 (pass entire obj)
		this.rdoGuiAuto.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Auto	 (pass entire obj)
		this.chkInclude.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Chk   - Include	 (pass entire obj)
		this.edtGuiName.OnEvent('Change', this.evNmChg.bind(this) 								)	; event handler for Edit  - GuiName	 (pass entire obj)
		this.edtCtrlPfx.OnEvent('Change', this.evNmChg.bind(this) 								)	; event handler for Edit  - CtrlName (pass entire obj)
		this.edtGuiName.OnEvent('LoseFocus', this.evGui.bind(this) 								)	; event handler for Edit  - GuiName	 (pass entire obj)
		this.edtCtrlPfx.OnEvent('LoseFocus', this.evGui.bind(this) 								)	; event handler for Edit  - CtrlName (pass entire obj)

		; General tab
		this.T3.UseTab(4)																			; target General settings tab
		this.chkMsgs	:= this.oGui.AddCheckBox('x' tabX ' y+30 checked vChkMsg disabled'			; toggle for conversion messages/comments
						, ' Include Message Comments'											)
		this.chkMsgs.OnEvent('Click', this.evGen.bind(this)										)	; event handler for ChkBox - (pass entire obj

		; ini UI settings, set title and show gui
		this._iniUI()																				; get settings from file, ini UI
		this.oGui.Title := 'AHK V1toV2 Converter'													; set UI title
		this.oGui.Show('w' wGui ' h' hGui ' NA')													; Show UI
	}
	;############################################################################
	evClose(*) {			; also receives hidden 'this' obj										; event handler for gui close
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
		ExitApp
	}
	;############################################################################
	evGen(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on General tab
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
	}
	;############################################################################
	evGui(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on Gui tab
		saveGuiMode := this.GuiMode, newGuiMode := saveGuiMode										; track guiMode changes
		switch ctrl.name, 0 {
			case 'Orig':	newGuiMode := 0															; track guiMode changes
			case 'Smpl':	newGuiMode := 1															; track guiMode changes
			case 'Dyn':		newGuiMode := 2															; track guiMode changes
			case 'Auto':	newGuiMode := 3															; track guiMode changes
		}
		if (newGuiMode != saveGuiMode) {															; if guiMode wass changed...
			this.GuiMode := newGuiMode																; ... record that change
			this._updateGuiModeNames(this.GuiMode)													; ... update edit boxes on Gui tab
		}
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
	}
	;############################################################################
	evHK(ctrl:='', *) {		; also receives hidden 'this' obj										; event handler for controls on HK tab
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
	}
	;############################################################################
	evNmChg(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for name changes on Gui tab
		this._updateVarName(ctrl)																	; verify proper format and update example
	}
	;############################################################################
	evRun(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for handle Run buttons
		this._toolTip()																				; ensure tooltip is hidden
		switch ctrl.name {
			case 'CVS':		Run('v2Converter.ahk')													; run V2Converter for script conversions
			case 'QCC':		Run('QuickConvertorV2.ahk "QCC"')										; run QuickConverter in normal convert mode
			case 'QCT':																				; 	  QuickConverter in unit-test mode
				mode := (GetKeyState("shift")) ? '"QCTF"' : '"QCT"'									; set whether failed tests are included or not
				Run('QuickConvertorV2.ahk ' mode)													; run QuickConverter in unit-test mode
		}
	}
	;############################################################################
	evSave(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on Save tab
		this.autoSave := this.chkSave.value															; keep track of auto-save setting
		this._saveSettings()																		; save settings to disk
	}
	;############################################################################
	evTab(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for Tab clicks
		switch Trim(ctrl.Text), 0 {
			case 'gui':		this._updateExample()													; update example string when Gui tab is clicked
		}
	}
	;############################################################################
	_guiDefaults(mode) {																			; default strings to use for GuiName and CtrlPfx
		switch mode, 0 {
			case 0,1:	return {gName:'myGui', cPfx:'ogc'}											; for orig or simple guiMode
			default:	return {gName:'',	   cPfx:''	 }											; should not be used, but just in case
		}
	}
	;############################################################################
	_iniUI() {																						; reads settings from disk, initializes UI
		iniFile := this.iniFile, Section := 'Settings'
		; save tab
		this.autoSave			:= IniRead(iniFile, Section, 'AutoSave', 1)							; get setting for auto-save
		this.chkSave.value		:= this.autoSave													; keep track of auto-save setting
		; gui tab
		this.GuiMode			:= IniRead(iniFile, Section, 'GuiMode',	 1)							; get setting for guiMode
		this.chkInclude.value	:= IniRead(iniFile, Section, 'CopyIncl', 1)							; get setting for copyInclude
		this._setGuiModeButton(this.GuiMode)														; set proper mode button on gui tab
		this._updateGuiModeNames(this.GuiMode)														; update gui/ctrl names  on gui tab
		; general tab
		this.chkMsgs.value		:= IniRead(iniFile, Section, 'ConvMsgs', 1)							; get setting for conv-msgs
	}
	;############################################################################
	_saveSettings() {																				; saves settings to disk
		iniFile := this.iniFile, Section := 'Settings'
		; save tab
		IniWrite(this.autoSave, iniFile, Section, 'AutoSave')										; save setting for auto-save
		; gui tab
		IniWrite(this.GuiMode, iniFile, Section,  'GuiMode')										; save setting for guiMode
		if (this.GuiMode <= 1) {																	; if orig or simple mode...
			gn := Trim(this.edtGuiName.Text), cp := Trim(this.edtCtrlPfx.Text)						; ... get trimmed text for gui name, ctrl pfx
			gn := (this._validateGuiName(gn))	? gn : unset										; ... verify that gui name is valid
			cp := (this._validateCtrlPfx(cp))	? cp : unset										; ... verify that ctrl pfx is valid
			(IsSet(gn)) && IniWrite(gn, iniFile, Section, 'StdGuiName')								; ... if valid, save setting for gui name
			(IsSet(cp)) && IniWrite(cp, iniFile, Section, 'StdCtrlPfx')								; ... if valid, save setting for ctrl pfx
		} else if (this.GuiMode > 1) {																; if dynamic or auto mode...
			IniWrite(this.chkInclude.value, iniFile, Section, 'CopyIncl')							; ... save setting for copyInclude
		}
		; general tab
		IniWrite(this.chkMsgs.value, iniFile, Section, 'ConvMsgs')									; save setting for conv msgs
	}
	;############################################################################
	_setGuiModeButton(mode) {																		; set gui mode button on gui tab
		; deselect all radio buttons
		this.rdoGuiOrig.value:=this.rdoGuiSmpl.value:=0												; deselect orig, simple
		this.rdoGuiDyn.value:=this.rdoGuiAuto.value:=0												; deselect dynamic, auto
		; select proper radio button for mode
		switch mode {
			case 0: this.rdoGuiOrig.value	:= 1													; set orig		guiMode
			case 1: this.rdoGuiSmpl.value	:= 1													; set simple	guiMode
			case 2: this.rdoGuiDyn.value	:= 1													; set dynamic	guiMode
			case 3: this.rdoGuiAuto.value	:= 1													; set auto		guiMode
		}
	}
	;############################################################################
	_updateExample() {																				; updates example string on Gui tab
		ex := '', invalid := false																	; ini
		if (this.GuiMode <= 1) {																	; if orig or simple mode...
			gn		:= Trim(this.edtGuiName.value), cp := Trim(this.edtCtrlPfx.value)				; ... get text for gui name and ctrl pfx
			invalid := (invalid) ? invalid : !(this._validateGuiName(gn))							; ... validate gui name is valid
			invalid := (invalid) ? invalid : !(this._validateCtrlPfx(cp))							; ... validate ctrl pfx is valid
			ex 		:= 'Example:`n' cp 'ButtonButton1 := ' gn '.Add("Button",,"Button 1")'			; ... set example string
		} else if (this.GuiMode = 2) {																; if dynamic mode...
			ex := 'Example:`nmV2GC[["1","Button1"]] := mV2Gui["1"].Add("Button",,"Button 1")'		; ... set example string
		}
		fClr := ((invalid) ? 'cRed' : 'cBlue'), this.txtEx.Opt(fClr)								; set font color for example text
		this.txtEx.visible	:= !!(this.GuiMode < 3)													; set visibility for example text (hide for Auto mode)
		this.txtEx.value	:= ex																	; apply changes  to	 example text
	}
	;############################################################################
	_updateGuiModeNames(mode) {																		; gets guiName/ctrlPfx from disk, sets tab controls
		iniFile := this.iniFile, Section := 'Settings'
		; set enablement and name text based on passed gui mode
		en := (mode <= 1) ? 1 : 0																	; disable editing for dynamic and auto mode (for now)
		this.edtGuiName.enabled:=this.edtCtrlPfx.enabled:=en										; set enablement of edit boxes
		(!en) && this.edtGuiName.value := this.edtCtrlPfx.value:= ''								; remove name-text for dynamic and auto mode
		; update details related to current mode
		if (mode <= 1) {																			; if orig or simple mode...
			guiDefaults	:= this._guiDefaults(mode)													; ... get default names
			gName		:= guiDefaults.gName														; ... default gui name
			cPfx		:= guiDefaults.cPfx															; ... default ctrl pfx
			gn			:= Trim(IniRead(iniFile, Section, 'StdGuiName', gName))						; ... get gui name from file
			cp			:= Trim(IniRead(iniFile, Section, 'StdCtrlPfx',cPfx))						; ... get ctrl pfx from file
			if (!this._validateGuiName(gn))															; ... if gui name is invalid...
				gn := gName, IniWrite(gn, iniFile, Section, 'StdGuiName')							; ...	set gui name to default and save to file
			if (!this._validateCtrlPfx(cp))															; ... if ctrl pfx is invalid...
				cp := cPfx,  IniWrite(cp, iniFile, Section, 'StdCtrlPfx')							; ...	set ctrl pfx to default and save to file
			this.edtGuiName.value	:= gn, this._updateVarName(this.edtGuiName,0)					; ... set gui name text and example (do not beep)
			this.edtCtrlPfx.value	:= cp, this._updateVarName(this.edtCtrlPfx,0)					; ... set ctrl pfx text and example (do not beep)
			this.chkInclude.visible	:= false														; ... hide copyIncl chkbx
		}
		else {	; 2,3																				; if dynamic or Auto mode...
			this.chkInclude.visible	:= true															; ... show copyIncl chkbx
			this._updateExample()																	; ... update example text
		}
	}
	;############################################################################
	_updateVarName(ctrl,audio:=1,setClr:=1,updateEx:=1) {											; update gui name or ctrl pfx
		name				:= Trim(ctrl.Text)														; get text (var name) from src ctrl
		isGuiName			:= (ctrl.name='GName')													; is gui name being updated ?
		(isGuiName )		&& isValid := this._validateGuiName(name)								; validate gui name (if being updated)
		(!isGuiName)		&& isValid := this._validateCtrlPfx(name)								; validate ctrl pfx (if being updated)
		fClr				:= (isValid) ? 'cBlack' : 'cRed'										; set font color based on validity of name
		(setClr)			&& ctrl.Opt(fClr)														; update ctrl with font color
		(updateEx)			&& this._updateExample()												; update example text
		(audio && !isValid) && Soundbeep(350,25)													; play sound if invalid
	}
	;############################################################################
	_validateCtrlPfx(name) {																		; determines whether ctrl prefix is valid
	; 2026-03-18 AMB, allows empty string and unicode
		return clsVarValidation.Validate(Trim(name),1,1)
	}
	;############################################################################
	_validateGuiName(name) {																		; determines whether guiname is valid
	; 2026-03-18 AMB, UPDATED to allow unicode and dis-allow AHK reserved words
		static prevName := -1, prevResult := -1														; prevents unnecessary validation processsing
		name := Trim(name)																			; trim name of whitspace
		if (prevResult >= 0 && name = prevName)														; if name has not changed since last visit...
			return prevResult																		; ... return the previous result
		prevName	:= name																			; save name for comparison, next visit
		prevResult	:= clsVarValidation.Validate(name)												; save result of validation for next visit
		return		prevResult																		; return result of validation
	}
	;############################################################################
	OnMouseMove(*) { ;wParam, lParam, msg, hwnd) {
		MouseGetPos(,,, &hCtrl, 2)																	; get ctrl (hwnd) under mouse
		if ((hCtrl = this.QCT.hwnd))																; if ctrl under mouse is QCT button...
			this._toolTip("Shift-Click to include failing tests")									; ... show brief tooltip
		else																						; if mouse NOT over QCT button...
			this._toolTip()																			; ... clear tooltip
	}
	;############################################################################
	_toolTip(msg:='') {																				; central method for showing/clearing tooltip
		if (msg && !this.fTTActive) {																; if msg should be shown, and not already active...
			ToolTip(msg), SetTimer(() => ToolTip(), -3000)											; ... show tooltip, set it to auto-clear
			this.fTTActive := true																	; ... set  tooltip status flag as active
		} else if (!msg && this.fTTActive) {														; if tt msg should be cleared, and toolip is active...
			ToolTip(), MouseGetPos(,,, &hCtrl, 2)													; ... clear the tooltip (manual call), get ctrl under mouse
			(hCtrl != this.QCT.hwnd) && (this.fTTActive := false)									; set tt flag to false only after mouse has moved away from button
		}
	}
}
;################################################################################
class clsVarValidation
{
	Static Validate(name,emptyOK:=false,resvOK:=false) {											; main validation
		; name must be trimmed of whitespace, to be valid
		if (emptyOK && name='')																		; if empty string is allowed, and name is empty...
			return true																				; ... return VALID
		if (!this._IsValidVarSyntax(name))															; if name syntax is invalid
			return false																			; ... return INVALID
		return !(!resvOK && this._IsReserved_Fast(name))											; if resv not ok, but name is resv word, return false, otherwise true
	}
	;############################################################################
	Static _IsReserved(name) {			; 2026-03-17 magic... THANK YOU @ntepa !					; determines whether name is ahk reserved
	; 2026-03-30 - uses AHK interpreter to determine whether name is reserved word
	; 	works but VERY SLOW!
		; name must be trimmed of whitespace, to be valid
		if (name ~= '[[:^ascii:]]')																	; if name has any chars that are NOT ascii...
			return false																			; ... is not a AHK reserved word
		shell := ComObject('WScript.Shell')
		exec := shell.Exec('AutoHotkey.exe /ErrorStdOut *')											; will execute a var assignment (dynamically) and report errors
		exec.StdIn.Write(Format('FileAppend({} := 1, "*")', name))									; create dynamic var assignment, write to std in
		exec.StdIn.Close()																			; close std in stream
		return !exec.StdOut.ReadAll()																; return whether error occurred during var creation
	}
	;############################################################################
	Static _IsReserved_Fast(name) {						; 2026-03-30 AMB, ADDED						; determines whether name is ahk reserved
		; name must be trimmed of whitespace, to be valid
		if (name ~= '[[:^ascii:]]')																	; if name has any chars that are NOT ascii...
			return false																			; ... is not a AHK reserved word
		return !!(InStr(gV2ReservedWords, '|' name '|')) ; tested with no delay						; return whether name is in reserved word list
	}
	;############################################################################
	Static _IsValidVarSyntax(name) {																; must not begin with number, allows ascii/unicode chars
		; name must be trimmed of whitespace, to be valid
		return	(name ~= '(?i)^([_a-z]|([[:^ascii:]]))(\w|(?2))*$')
	}
}
