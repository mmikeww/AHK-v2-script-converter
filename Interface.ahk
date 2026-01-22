/*
	2026-01-21 AMB, ADDED
	To provide a User Interface that can support:
	* Conversion progress
	* User settings/preferences
	* Debug Tool
	* More as needed...
*/
#SingleInstance force

;; FOR DESIGN MODE - UNCOMMENT THESE, then run this script
;gUIDesign := true, gUIEnable := '-disabled', gUIVisible := true									; enable and make visible
;Prog.Ulog(,'...Current  Operation')																; show UI (design mode)

;################################################################################
class Prog
{
	Static pGui			:= ''																		; UI Gui
	Static curProg		:= 0																		; (PUBLIC) progress bar value
	Static QCHide		=> (IsSet(gQCV2_Test) && !gQCV2_Test) ; see QuickConveterV2.ahk				; using QuickConverter, but not in batch test mode?
	;############################################################################
	Static Reset() {																				; reset static properties as needed
		this.curProg	:= 0
		if (this.pGui is clsProgGui) {
			try this.pGui.Reset()
			this.pGui	:= ''
		}
	}
	;############################################################################
	Static Hide() {
		this.pGui.Hide()																			; Hide UI
	}
	;############################################################################
	Static UPath(curPath) {																			; update UI with current path details
		static cPath := ''																			; keep track of current file path
		if (this.QCHide																				; if using QuickConverter, but not in batch test mode...
		||  curPath = cPath)																		; OR if filePath has not changed since last visit...
			return																					; ... do NOT show/update UI
		cPath := curPath																			; filePath has changed - save current path
		this.showGui()																				; create/show UI as needed
		SplitPath curPath, &fn, &dir																; get path details
		this.pGui.txtDir.Value	:= dir																; update UI - folder path
		this.pGui.txtFile.Value	:= fn																; update UI - file name
	}
	;############################################################################
	Static ULog(curProg?, curOp?, curFunc?, curLineNum?, curLineTxt?) {								; update UI with current conversion details
		;return																						; force NO UPDATE (debugging)
		if (this.QCHide)																			; if using QuickConverter, but not in batch test mode
			return																					; ... do NOT show/update UI
		this.showGui()																				; create/show UI as needed
		(IsSet(curProg))	&& this.curProg					:= curProg								; save progress bar value
		(IsSet(curProg))	&& this.pGui.lblProg.Value		:= round(curProg) ' %'					; update UI - progress %
		(IsSet(curProg))	&& this.pGui.progBar.Value		:= curProg								; update UI - progress bar
		if (!IsSet(gQCV2_Test)) {																	; if NOT using QuickConverter...
			(IsSet(curOp))	&& this.pGui.txtOp.Value		:= curOp								; ... update UI - current conversion operation
			return																					; ... do NOT update debug details
		}
		if (!this.pGui.debugMode)																	; if NOT using debug mode...
			return																					; ... do NOT update debug details (performance)
		(IsSet(curOp))		&& this.pGui.txtOp.Value		:= curOp								; update UI - current conversion operation
		(IsSet(curFunc))	&& this.pGui.txtFunc.Value		:= curFunc								; update UI - current conversion func
		(IsSet(curLineNum))	&& this.pGui.txtLineNum.Value	:= curLineNum							; update UI - current conversion line number
		(IsSet(curLineTxt))	&& this.pGui.txtLineVal.Value	:= curLineTxt							; update UI - current conversion line code
	}
	;############################################################################
	Static showGui() {																				; create/show UI gui as needed
		if (!(this.pGui is clsProgGui))																; if UI has not been created yet...
			this.pGui := clsProgGui()																; ... create it
		this.pGui.Show()																			; Show UI (only when hidden)
	}
}
;################################################################################
;################################################################################
class clsProgGui {																					; Gui object handling

	mGui			:= ''																			; Gui object
	; progress tab
	txtDir			:= ''																			; current folder path
	txtFile			:= ''																			; current file name
	progBar			:= ''																			; progress bar
	txtOp			:= ''																			; current conversion operation
	txtFunc			:= ''																			; current conversion function		(optional)
	txtLineNum		:= ''																			; current conversion line number	(optional)
	txtLineVal		:= ''																			; current convertion line code		(optional)
	; gui tab
	rdoGuiStd		:= ''																			; User option - GuiMode - Standard
	rdoGuiDyn		:= ''																			; User option - GuiMode - Dynamic
	rdoGuiAuto		:= ''																			; User option - GuiMode - Auto
	edtGuiName		:= ''																			; User option - default GuiName preference
	edtCtrlName		:= ''																			; User option - default GuiCtrl prefix preference
	; general tab
	chkMsgs			:= ''																			; User option - toggle conversion comments/messages
	; obj props
	debugMode		:= false																		; debug flag

	;############################################################################
	__New() {
		this._makeGui()																				; create UI Gui
	}
	;############################################################################
	Reset() {																						; Resets object properties as needed
		if (!this.mGui)
			return
		this.txtDir.Value		:= ''
		this.txtFile.Value		:= ''
		this.progBar.Value		:= 0
		this.txtOp.Value		:= ''
		this.txtFunc.Value		:= ''
		this.txtLineNum.Value	:= ''
		this.txtLineVal.Value	:= ''
		this.rdoGuiStd.Value	:= true
		this.rdoGuiDyn.Value	:= false
		this.rdoGuiAuto.Value	:= false
		this.edtGuiName			:= ''
		this.edtCtrlName		:= ''
		this.chkMsgs			:= false
	}
	;############################################################################
	_makeGui() {
		; design mode settings
		local en	:= (isSet(gUIEnable))   ? gUIEnable  : 'disabled'								; enable/disable ctrls globally
		local vis	:= ((IsSet(gUIVisible)) ? gUIVisible : false)									; enable/disable ctrl visibility globally
		local bd	:= '-border'																	; enable/disable borders globally

		; gui/ctrl dimensions
		this.mGui := Gui() ;Gui('ToolWindow -SysMenu Disabled') ; AlwaysOnTop')
		hGui := 300, hTab := hGui - 55, marg := 10													; heights,margin
		wGui := 650, wTab := wGui - 20, wTxt := wGui -110, wLbl := 60, wEdit := 120					; widths

		; Progress Tab
		tabs			:= ['Progress', 'Gui Prefs', 'HK Prefs', 'Gen Prefs', 'About']				; Tab names
		T3				:= this.mGui.AddTab3('background0xE7E7E7 h' hTab ' w' wTab, tabs		)	; Tab control
		T3.UseTab(1)																				; use Progress tab
		this.lblFolder	:= this.mGui.AddText(bd ' x20 y+30 w' wlbl, 'Folder:'					)	; label	- current folder
		this.txtDir		:= this.mGui.AddText(bd ' yp w' wTxt, '...Current Folder'				)	; display current folder
		this.lblFileName:= this.mGui.AddText(bd ' x20 y+5 w' wlbl, 'Name:'						)	; label	- current file
		this.txtFile	:= this.mGui.AddText(bd ' yp w' wTxt, '...Current File'					)	; display current file
		this.lblProg	:= this.mGui.AddText(bd ' x20 y+8 w' wlbl, '%'							)	; display progress %
		this.progBar	:= this.mGui.AddProgress(bd ' smooth xp+65 yp w' wTxt					)	; display progress bar
		this.lblOp		:= this.mGui.AddText(bd ' x20 y+8 w' wlbl, 'Operation:'					)	; label - current conversion operation
		this.txtOp		:= this.mGui.AddText(bd ' yp w' wTxt, '...Current Operation'			)	; display current conversion operation
		this.chkDebug	:= this.mGui.AddCheckBox(bd ' x14  y+5 right', 'Debug:   '				)	; toggle optional debug mode
		this.chkDebug.OnEvent('Click', this.evDebug.bind(this) 									)	; event handler for debug checkbox    (pass entire obj)
		this.lblFunc	:= this.mGui.AddText(bd ' x20 y+5 w' wlbl, 'Function:'					)	; label	- current conversion func
		this.txtFunc	:= this.mGui.AddText(bd ' yp w' wTxt, '...Current Function'				)	; display current conversion func		 (debug option)
		this.lblLineNum	:= this.mGui.AddText(bd ' x20 y+5 w' wLbl, 'Line No:'					)	; label	- current conversion line number
		this.txtLineNum	:= this.mGui.AddText(bd ' yp w' wTxt, '...Current Line Number'			)	; display current conversion line number (debug option)
		this.lblLine	:= this.mGui.AddText(bd ' x20 y+5 w' wlbl, 'Line:'						)	; label	- current conversion line code
		this.txtLineVal	:= this.mGui.AddText(bd ' yp w' wTxt, '...Current Line Text'			)	; display current conversion line code	 (debug option)

		; set initial visibilty for Progess-tab ctrls
		this.chkDebug.Visible	:= false															; ini debug checkbox as hidden
		this.chkDebug.Visible	:= (vis | (IsSet(gQCV2_Test)))										; now make it visible for QC or design mode
		this.evDebug(this.chkDebug)																	; set debug details, based on debug mode
		this.lblOp.Visible		:= (vis | !(IsSet(gQCV2_Test)))										; show/hide operation label based on current mode
		this.txtOp.Visible		:= (vis | !(IsSet(gQCV2_Test)))										; show/hide operation text  based om current mode

		; Gui Tab
		T3.UseTab(2)																				; use Gui-Conv-Preferences tab
		lblMode			:= this.mGui.AddText( en ' x20 y+30 w' wlbl-5, 'Mode:'					)	; label	- Gui Conversion Mode
		this.rdoGuiStd	:= this.mGui.AddRadio(en ' yp Checked', 'Standard'						)	; Radio	- Gui Conversion - Standard
		this.rdoGuiDyn	:= this.mGui.AddRadio(en ' yp', 'Dynamic'								)	; Radio	- Gui Conversion - Dynamic
		this.rdoGuiAuto	:= this.mGui.AddRadio(en ' yp', 'Auto'									)	; Radio	- Gui Conversion - Auto
		lblGuiName		:= this.mGui.AddText( en ' x20 y+15 w' wlbl-5, 'Gui Name:'				)	; label	- GuiName preference
		this.edtGuiName	:= this.mGui.AddEdit( en ' yp w' wEdit, 'GuiName'						)	; Edit	- GuiName preference
		lblCtrlPfx		:= this.mGui.AddText( en ' x+15 yp w' wlbl-5, 'Ctrl Prefix:'			)	; label	- GuiCtrl Prefix preference
		this.edtCtrlName:= this.mGui.AddEdit( en ' yp w' wEdit, 'ControlPrefix'					)	; Edit	- GuiCtrl Prefix preference

		; HK tab
		T3.UseTab(3)																				; use Hotkey-Preferences tab
		this.chkHKs		:= this.mGui.AddCheckBox(en ' x20 y+30 -Checked vChkHK'						; toggle including uncommon hotkeys
						, ' Include Uncommon Hotkeys (very slow performance)'					)
						this.mGui.AddText('x20 y+12'
						, 'TOO MANY HKs CAUSE POOR CONVERSION PERFORMANCE.'							; TEMP NOTE
						. '`nWILL INCLUDE LIST OF HOTKEYS TO INCLUDE, OR USER CAN EDIT'			)

		; General tab
		T3.UseTab(4)																				; use General-Conv-Preferences tab
		this.chkMsgs	:= this.mGui.AddCheckBox(en ' x20 y+30 Checked vChkMsg'						; toggle conversion messages/comments
						, ' Include Message Comments'											)

		; Start/Pause/Stop buttons - not on a Tab
		T3.UseTab(0)																				; Tab control no longer receiving controls
		this.btnStart	:= this.mGui.AddButton(en ' x' wGui-215 ' y' hGui-40 ' w100 h30'			; Conversion Start/Pause button (disabled for now)
						, 'Start'																)
		this.btnStop	:= this.mGui.AddButton(en ' x' wGui-110 ' y' hGui-40 ' w100 h30'			; Conversion Stop button (disabled for now)
						, 'Stop'																)

		; set title and show GUI
		this.mGui.Title			:= 'AHK V1toV2 Converter'											; UI Title
		this.mGui.Show('w' wGui ' h' hGui ' NA')													; Show UI
	}
	;############################################################################
	evDebug(ctrl:='', *) {		; also receives hidden 'this' obj									; set Debug-mode related for Progress tab
		this.debugMode			:= ctrl.value														; set public flag
		vis						:= ctrl.value														; visibility depends on Debug checkbox status
		this.lblOp.Visible		:= vis, this.txtOp.Visible		:= vis								; show/hide current converter operation
		this.lblFunc.Visible	:= vis, this.txtFunc.Visible	:= vis								; show/hide current converter func
		this.lblLineNum.Visible	:= vis, this.txtLineNum.Visible	:= vis								; show/hide current v1 script line number
		this.lblLine.Visible	:= vis, this.txtLineVal.Visible	:= vis								; show/hide current v1 script line details
	}
	;############################################################################
	Hide() {
		this.mGui.Hide()																			; Hide UI
	}
	;############################################################################
	Show() {																						; Show UI (only when hidden)
		Static WS_VISIBLE := 0x10000000
		If (WinGetStyle(this.mGui) & WS_VISIBLE)
			return
		this.mGui.Show('NA')
	}
}
