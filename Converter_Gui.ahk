/*
	2026-01-26 AMB, ADDED
	Provides user interface supporting the following:
	 * User conversion-settings
	 * convenient launch pad for QCV2/v2Converter, after changing settings
*/

#SingleInstance force
clsSetGui()
;################################################################################
class clsSetGui {																					; Gui handling

	oGui			:= ''																			; gui object
	wGui			:= 470																			; gui width
	hGui			:= 225																			; gui height
	wText			:= this.wGui - 105																; width of text controls
	iniFile			:= 'Converter.ini'																; file to save settings
	autoSave		:= ''																			; ini auto-save setting
	;############################################################################
	__New() {
		this._makeGui()																				; create Gui
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
		wLbl		:= 60, wEdit := 180, wGB := 95													; other widths
		tabX		:= wGB +15																		; x position for tab ctrl

		; create gui
		this.oGui	:= Gui(), this.oGui.BackColor := guiBkgd										; create gui, set bkgd color
		this.oGui.OnEvent('Close', this.evClose.bind(this)										)	; gui close event

		; setup controls
		this.oGui.SetFont('bold')																	; set font weight to Bold (initially)
		this.btnGB	:= this.oGui.AddGroupBox('x10 y5 w' wGB ' h' hPnl ' cGray'					)	; buttons groupbox
		txtRun		:= this.oGui.AddText(tbClr ctr 'x11 y12 w' wGB-2 ' h18', 'RUN'				)	; buttons groupbox header
		this.QCT	:= this.oGui.AddButton(bdr 'x20 y+10' btnWH ' vQCT', 'QC`nUnit Tests'		)	; QC Unit test button
		this.QCC	:= this.oGui.AddButton(btnWH bdr 'vQCC','QC`nV1 --> V2'						)	; QC code converter button
		this.CVS	:= this.oGui.AddButton(btnWH bdr 'vCVS','Convert`nV1 Script'				)	; v2Converter button
		tabs		:= ['','  Gui  ', '  HK  ', '  General  ']										; Tab names
		iFile		:= A_WinDir '\system32\shell32.dll'												; file to pull icons from
		picGear		:= this.oGui.Add('Pic', tbClr ' x' tabX+15 ' y13 w16 h16 icon315',iFile		) 	; place gear icon on tab 1 (easier than the sendmessage method)
		tbXYWH		:= ' x' tabX ' y10 h' hTab ' w' wTab ' '										; tab-dimensions string
		this.T3		:= this.oGui.AddTab3(tbClr bdr 'buttons' tbXYWH ' vTab3',tabs				)	; create tab control
		this.T3.OnEvent('Change', this.evTab.bind(this) 										)	; event handler for Tab control		(pass entire obj)
		this.QCT.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for QC Unit tests	(pass entire obj)
		this.QCC.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for QC code convert	(pass entire obj)
		this.CVS.OnEvent('Click', this.evRun.bind(this) 										)	; event handler for v2Converter		(pass entire obj)

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
		lblMode			:= this.oGui.AddText( 'x' tabX ' y+30 w' wlbl, 'Mode:'					)	; label	- Gui Conversion Mode
		this.rdoGuiStd	:= this.oGui.AddRadio('yp checked vStd', 'Standard'						)	; Radio	- Gui Conversion - Standard
		this.rdoGuiDyn	:= this.oGui.AddRadio('yp vDyn disabled', 'Dynamic'						)	; Radio	- Gui Conversion - Dynamic
		this.rdoGuiAuto	:= this.oGui.AddRadio('yp vAuto disabled', 'Auto'						)	; Radio	- Gui Conversion - Auto
		lblGuiName		:= this.oGui.AddText( 'x' tabX ' y+15 w' wlbl, 'Gui Name:'				)	; label	- GuiName preference
		this.edtGuiName	:= this.oGui.AddEdit( 'yp w' wEdit ' vGName', 'GuiName'					)	; Edit	- GuiName preference
		lblCtrlPfx		:= this.oGui.AddText( 'x' tabX ' y+5 w' wlbl, 'Ctrl Prefix:'			)	; label	- GuiCtrl Prefix preference
		this.edtCtrlName:= this.oGui.AddEdit( 'yp w' wEdit ' vCName', 'ControlPrefix'			)	; Edit	- GuiCtrl Prefix preference
		this.txtEx		:= this.oGui.AddText( 'cBlue x' tabX ' y+5 h45 w' wTab-40, ''			)	; label - show example of code output
		this.rdoGuiStd.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Standard (pass entire obj)
		this.rdoGuiDyn.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Dynamic	 (pass entire obj)
		this.rdoGuiAuto.OnEvent('Click', this.evGui.bind(this) 									)	; event handler for Radio - Auto	 (pass entire obj)
		this.edtGuiName.OnEvent('Change', this.evNmChg.bind(this) 								)	; event handler for Edit  - GuiName	 (pass entire obj)
		this.edtCtrlName.OnEvent('Change', this.evNmChg.bind(this) 								)	; event handler for Edit  - CtrlName (pass entire obj)
		this.edtGuiName.OnEvent('LoseFocus', this.evGui.bind(this) 								)	; event handler for Edit  - GuiName	 (pass entire obj)
		this.edtCtrlName.OnEvent('LoseFocus', this.evGui.bind(this) 							)	; event handler for Edit  - CtrlName (pass entire obj)

		; General tab
		this.T3.UseTab(4)																			; target General settings tab
		this.chkMsgs	:= this.oGui.AddCheckBox('x' tabX ' y+30 checked vChkMsg disabled'			; toggle for conversion messages/comments
						, ' Include Message Comments'											)
		this.chkMsgs.OnEvent('Click', this.evGen.bind(this)										)	; event handler for ChkBox - (pass entire obj

		; update settings, set title and show gui
		this._getSettings(), this._updateSettings()													; update gui with user settings from file
		this.oGui.Title := 'AHK V1toV2 Converter'													; gui Title
		this.oGui.Show('w' wGui ' h' hGui ' NA')													; Show gui
	}
	;############################################################################
	evClose(*) {			; also receives hidden 'this' obj										; event handler for gui close
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
		ExitApp
	}
	;############################################################################
	evRun(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for handle Run buttons
		switch ctrl.name {
			case 'QCT':		Run('QuickConvertorV2.ahk "QCT"')										; run QuickConverter in unit-test mode
			case 'QCC':		Run('QuickConvertorV2.ahk "QCC"')										; run QuickConverter in normal convert mode
			case 'CVS':		Run('v2Converter.ahk')													; run V2Converter for script conversions
		}
	}
	;############################################################################
	evTab(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for Tab clicks
		switch Trim(ctrl.Text), 0 {
			case 'gui':		this._updateExample()													; update example string when Gui tab is clicked
		}
	}
	;############################################################################
	evSave(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on Save tab
		this.autoSave := this.chkSave.value															; keep track of auto-save setting
		this._saveSettings()																		; save settings to disk
	}
	;############################################################################
	evGui(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on Gui tab
		saveGuiMode := this.GuiMode, newGuiMode := saveGuiMode										; track guiMode changes
		switch ctrl.name, 0 {
			case 'Std':		newGuiMode := 1															; track guiMode changes
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
	evNmChg(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for name changes on Gui tab
		this._updateExample()																		; update example string as user types
	}
	;############################################################################
	evHK(ctrl:='', *) {		; also receives hidden 'this' obj										; event handler for controls on HK tab
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
	}
	;############################################################################
	evGen(ctrl:='', *) {	; also receives hidden 'this' obj										; event handler for controls on General tab
		(this.autoSave && this._saveSettings())														; save settings if auto-save enabled
	}
	;############################################################################
	_updateExample() {																				; updates example string on Gui tab
		g		:= this.edtGuiName.Value															; get GuiName text
		c		:= this.edtCtrlName.Value															; get CtrlPrefix text
		exStr 	:= 'Example:`n' c 'ButtonButton1 := ' g '.Add("Button",,"Button 1")'				; example string
		this.txtEx.Value := exStr																	; apply changes to example string
	}
	;############################################################################
	_guiDefaults(mode) {																			; default strings to use for GuiName and CtrlPfx
		switch mode, 0 {
			case 1:		return {gName:'myGui',cName:'ogc'}											; for standard	guiMode
			;case 2:	return {gName:'v2Gui',cName:'v2GC'}											; for dynamic	guiMode (NOT USED)
			;case 3:	return {gName:'v2Gui',cName:'v2GC'}											; for auto		guiMode (NOT USED)
		}
	}
	;############################################################################
	_getSettings() {																				; reads/gets settings from disk
		iniFile := this.iniFile, Section := 'Settings'
		; save tab
		this.autoSave		:= IniRead(iniFile, Section, 'AutoSave',	1	)						; get setting for auto-save
		; gui tab
		this.GuiMode		:= IniRead(iniFile, Section, 'GuiMode',		1	)						; get setting for guiMode
		this._updateGuiModeNames(this.GuiMode)														; update gui/ctrl names on gui tab
		; general tab
		this.chkMsgs.value	:= IniRead(iniFile, Section, 'ConvMsgs',	1	)						; get setting for conv-msgs
	}
	;############################################################################
	_saveSettings() {																				; saves settings to disk
		iniFile := this.iniFile, Section := 'Settings'
		;  save tab
		IniWrite(this.autoSave,				iniFile, Section, 'AutoSave'		)					; save setting for auto-save
		; gui tab
		IniWrite(this.GuiMode,				iniFile, Section, 'GuiMode'			)					; save setting for guiMode
		if (this.GuiMode = 1) {																		; if standard mode...
			IniWrite(this.edtGuiName.value,	iniFile, Section, 'GuiStdName'		)					; ... save setting for standard gui name
			IniWrite(this.edtCtrlName.value,iniFile, Section, 'CtrlStdName'		)					; ... save setting for standard ctrl prefix
		}
		;; NOT UTILIZED (for now)
		;else if (this.GuiMode = 2) {																; if dynamic mode...
		;	IniWrite(this.edtGuiName.value,	iniFile, Section, 'GuiDynName'		)					; ... save setting for dynamic gui name
		;	IniWrite(this.edtCtrlName.value,iniFile, Section, 'CtrlDynName'		)					; ... save setting for dynamic ctrl prefix
		;}
		; general tab
		IniWrite(this.chkMsgs.value,		iniFile, Section, 'ConvMsgs'		)					; save setting for conv msgs
	}
	;############################################################################
	_setGuiModeButtons() {																			; update controls related to guiMode
		this.rdoGuiStd.Value:=this.rdoGuiDyn.Value:=this.rdoGuiAuto.Value:=0						; unselect all radio buttons
		switch this.GuiMode {
			case 1: this.rdoGuiStd.Value	:= 1													; set standard	guiMode
			case 2: this.rdoGuiDyn.Value	:= 1													; set dynamic	guiMode
			case 3: this.rdoGuiAuto.Value	:= 1													; set auto		guiMode
		}
	}
	;############################################################################
	_updateSettings() {																				; updates controls/settings for all tabs
		this.chkSave.value := this.autoSave															; keep track of auto-save setting
		this._setGuiModeButtons()																	; update controls for gui tab
	}
	;############################################################################
	_updateGuiModeNames(mode) {																		; gets guiName/ctrlPfx from disk, sets tab controls
		iniFile := this.iniFile, Section := 'Settings'
		; set enablement and name text based on passed gui mode
		en := (mode = 1) ? 1 : 0																	; disable editing for dynamic and auto mode (for now)
		this.edtGuiName.enabled:=this.edtCtrlName.enabled:=this.txtEx.Visible:= en					; set enablement/visibility of other controls
		(!en) && this.edtGuiName.value := this.edtCtrlName.value:= ''								; remove name-text for dynamic and auto mode
		; update details related to sandard-mode, as needed
		if (mode = 1) {																				; if standard mode...
			guiDefaults				:= this._guiDefaults(mode)										; ... get default names
			gName					:= guiDefaults.gName											; ... default guiName
			cName					:= guiDefaults.cName											; ... default ctrl prefix
			this.edtGuiName.value 	:= IniRead(iniFile, Section, 'GuiStdName', gName)				; ... get current guiName
			this.edtCtrlName.value	:= IniRead(iniFile, Section, 'CtrlStdName',cName)				; ... get current ctrl prefix
			this._updateExample()																	; ... update example string
		}
		;; NOT UTILIZED (for now)
		;else if (mode = 2) {																		; if dynamic mode...
		;	this.edtGuiName.value := IniRead(iniFile, Section, 'GuiDynName', gName)					; ... get dynamic guiName
		;	this.edtCtrlName.value:= IniRead(iniFile, Section, 'CtrlDynName',cName)					; ... get dynamic ctrl prefix
		;}
	}
}