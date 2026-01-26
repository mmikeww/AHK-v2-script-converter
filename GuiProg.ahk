/*
	2026-01-24 AMB, ADDED
	Provides the following:
	 * Conversion Progress details
	 * Works with QCV2 and V2Converter
	 * Debug Tool - limited (for now) to QCV2 unit-test mode
*/

;; FOR DESIGN MODE - UNCOMMENT THESE, then run this script
;#SingleInstance force
;gUIDesign := true, gUIEnable := '-disabled', gUIVisible := true									; enable and make visible
;Prog.Ulog(,'...Current  Operation')																; show gui (design mode)

;################################################################################
class Prog
{
	Static pGui			:= ''																		; progress-gui
	Static curProg		:= 0																		; (PUBLIC) progress bar value
	Static QCHide		=> (IsSet(gQCV2_Test) && !gQCV2_Test) ; see QuickConveterV2.ahk				; using QuickConverter, but not in batch test mode?
	Static WrapLen		=> (this.pGui is clsProgGui) ? (this.pGui.WrapLen) : 60						; max chars per line for file folder ctrl (wrapping)
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
		this.pGui.Hide()																			; Hide gui
	}
	;############################################################################
	Static UPath(curPath) {																			; update gui with current path details
		static cPath := ''																			; keep track of current file path
		if (this.QCHide																				; if using QuickConverter, but not in batch test mode...
		||  curPath = cPath)																		; OR if filePath has not changed since last visit...
			return																					; ... do NOT show/update gui
		cPath := curPath																			; filePath has changed - save current path
		this.showGui()																				; create/show gui as needed
		SplitPath curPath, &fn, &dir																; get path details
		this.pGui.txtDir.Value	:= this.wrapPath(dir)												; update gui - folder path
		this.pGui.txtFile.Value	:= fn																; update gui - file name
	}
	;############################################################################
	Static ULog(curProg?, curOp?, curFunc?, curLineNum?, curLineTxt?) {								; update gui with current conversion details
		;return																						; force NO UPDATE (debugging)
		if (this.QCHide)																			; if using QuickConverter, but not in batch test mode
			return																					; ... do NOT show/update gui
		this.showGui()																				; create/show gui as needed
		(IsSet(curProg))	&& this.curProg					:= curProg								; save progress bar value
		(IsSet(curProg))	&& this.pGui.lblProg.Value		:= round(curProg) ' %'					; update gui - progress %
		(IsSet(curProg))	&& this.pGui.progBar.Value		:= curProg								; update gui - progress bar
		if (!IsSet(gQCV2_Test)) {																	; if NOT using QuickConverter...
			(IsSet(curOp))	&& this.pGui.txtOp.Value		:= curOp								; ... update gui - current conversion operation
			return																					; ... do NOT update debug details
		}
		if (!this.pGui.debugMode)																	; if NOT using debug mode...
			return																					; ... do NOT update debug details (performance)
		(IsSet(curOp))		&& this.pGui.txtOp.Value		:= curOp								; update gui - current conversion operation
		(IsSet(curFunc))	&& this.pGui.txtFunc.Value		:= curFunc								; update gui - current conversion func
		(IsSet(curLineNum))	&& this.pGui.txtLineNum.Value	:= curLineNum							; update gui - current conversion line number
		(IsSet(curLineTxt))	&& this.pGui.txtLineVal.Value	:= curLineTxt							; update gui - current conversion line code
	}
	;############################################################################
	Static showGui() {																				; create/show gui gui as needed
		if (!(this.pGui is clsProgGui))																; if gui has not been created yet...
			this.pGui := clsProgGui()																; ... create it
		this.pGui.Show()																			; Show gui (only when hidden)
	}
	;############################################################################
	Static wrapPath(srcStr) {																		; provides custom wrapping for file path
		dirs	:= StrSplit(srcStr, '\')															; extract folders
		curStr	:= outStr := ''																		; ini
		for idx, dir in dirs {																		; for each folder in path...
			if (StrLen(curStr '\' dir) >= this.WrapLen)												; ... if current chunk exceeds max char length...
				outStr .= ('`n' . curStr), curStr := ''												; ...	add linefeed
			curStr .= '\' dir																		; ... add current dir to current chunk (in any case)
		}
		outStr .= ('`n' . curStr)																	; ensure final chunk is added to output str
		return Trim(outStr, ' `n\')																	; cleanup final str and return it
	}
}
;################################################################################
;################################################################################
class clsProgGui {																					; Gui object handling

	oGui			:= ''																			; gui object
	txtDir			:= ''																			; current folder path
	txtFile			:= ''																			; current file name
	progBar			:= ''																			; progress bar
	txtOp			:= ''																			; current conversion operation
	txtFunc			:= ''																			; current conversion function		(optional)
	txtLineNum		:= ''																			; current conversion line number	(optional)
	txtLineVal		:= ''																			; current convertion line code		(optional)
	debugMode		:= false																		; debug flag
	wGui			:= 450																			; gui width
	hGui			:= (IsSet(gQCV2_Test) || IsSet(gUIDesign)) ? 130 : 110							; gui height (initial)
	wText			:= this.wGui - 105																; width of text controls
	WrapLen			:= (this.wText // 6)															; max char length per line for text controls
	;############################################################################
	__New() {
		this._makeGui()																				; create Gui
	}
	;############################################################################
	Reset() {																						; Resets object properties as needed
		if (!this.oGui)
			return
		this.txtDir.Value		:= ''
		this.txtFile.Value		:= ''
		this.progBar.Value		:= 0
		this.txtOp.Value		:= ''
		this.txtFunc.Value		:= ''
		this.txtLineNum.Value	:= ''
		this.txtLineVal.Value	:= ''
	}
	;############################################################################
	_makeGui() {
		; design mode settings
		local vis	:= ((IsSet(gUIVisible)) ? gUIVisible : false)									; enable/disable ctrl visibility globally
		local bd	:= ((IsSet(gUIVisible)) ? '+border'	: '-border')								; enable/disable borders globally
		local dirTxt:= '12345678-1\12345678-2\12345678-3\12345678-4\12345678-5'						; text to test wrapping of file path
					.  '\12345678-6\12345678-7\12345678-8\12345678-9\1234567890-10'
		dirTxt		:= Prog.wrapPath(dirTxt)														; format wrapped path (for testing)

		; gui/ctrl dimensions
		hGui		:= this.hGui, hTxt := 28														; heights
		wGui		:= this.wGui, wTxt := this.wText, wLbl := 60, wEdit := 120						; widths
		tClr		:= ' cGray'																		; dim text color

		; create gui
		this.oGui	:= Gui()																		; gui
		this._disableClose()																		; disable close, but allow minimize

		; set controls
		this.lblFileName:= this.oGui.AddText(bd tClr ' x20 y+15 w' wlbl, 'FileName:'			)	; label	- current file
		this.txtFile	:= this.oGui.AddText(bd tClr ' yp w' wTxt, '...CurFile'					)	; display current file
		this.lblFolder	:= this.oGui.AddText(bd tClr ' x20 y+5 w' wlbl, 'FileFolder:'			)	; label	- current folder
		this.txtDir		:= this.oGui.AddText(bd tClr ' yp w' wTxt ' h' hTxt, '...CurFolder'		)	; display current folder
		this.lblProg	:= this.oGui.AddText(bd ' center x20 y+5 w' wlbl, '%'					)	; display progress %
		this.progBar	:= this.oGui.AddProgress(bd ' smooth xp+65 yp w' wTxt					)	; display progress bar
		this.lblOp		:= this.oGui.AddText(bd ' x20 y+3 w' wlbl, ''							)	; label - current conversion operation
		this.txtOp		:= this.oGui.AddText(bd ' yp w' wTxt, '...Current Operation'			)	; display current conversion operation
		this.chkDebug	:= this.oGui.AddCheckBox(bd tClr ' x14  y+5 right', 'Debug:   '			)	; toggle optional debug mode
		this.chkDebug.OnEvent('Click', this.evDebug.bind(this) 									)	; event handler for debug checkbox    (pass entire obj)
		this.lblFunc	:= this.oGui.AddText(bd tClr ' x20 y+5 w' wlbl, 'Function:'				)	; label	- current conversion func
		this.txtFunc	:= this.oGui.AddText(bd tClr ' yp w' wTxt, '...Current Function'		)	; display current conversion func		 (debug option)
		this.lblLineNum	:= this.oGui.AddText(bd tClr ' x20 y+5 w' wLbl, 'Line No:'				)	; label	- current conversion line number
		this.txtLineNum	:= this.oGui.AddText(bd tClr ' yp w' wTxt, '...Line Number'				)	; display current conversion line number (debug option)
		this.lblLine	:= this.oGui.AddText(bd tClr ' x20 y+5 w' wlbl, 'Line:'					)	; label	- current conversion line code
		this.txtLineVal	:= this.oGui.AddText(bd tClr ' yp w' wTxt ' h' hTxt, '...Line Text'		)	; display current conversion line code	 (debug option)

		; for testing muti-line
		if (IsSet(gUIDesign)) {
			this.txtDir.Value		:= dirTxt														; display current conversion line code	 (debug option)
			this.txtLineVal.Value	:= dirTxt														; display current conversion line code	 (debug option)
		}

		; set initial visibilty for ctrls
		this.chkDebug.Visible	:= false															; ini debug checkbox as hidden
		this.chkDebug.Visible	:= (vis | (IsSet(gQCV2_Test)))										; now make it visible for QC or design mode
		this.evDebug(this.chkDebug)																	; set debug details, based on debug mode
		this.txtOp.Visible		:= (vis | !(IsSet(gQCV2_Test)))										; show/hide operation text  based om current mode

		; set title and show gui
		this.oGui.Title := 'AHK V1toV2 Conversion Progress'											; gui Title
		this.oGui.Show('w' wGui ' h' hGui ' NA')													; Show gui
	}
	;############################################################################
	evDebug(ctrl:='', *) {		; also receives hidden 'this' obj									; set Debug-mode related for Progress tab
		this.debugMode			:= ctrl.value														; set public flag
		vis						:= ctrl.value														; visibility depends on Debug checkbox status
		this.lblOp.Visible		:= vis, this.txtOp.Visible		:= vis								; show/hide current converter operation
		this.lblFunc.Visible	:= vis, this.txtFunc.Visible	:= vis								; show/hide current converter func
		this.lblLineNum.Visible	:= vis, this.txtLineNum.Visible	:= vis								; show/hide current v1 script line number
		this.lblLine.Visible	:= vis, this.txtLineVal.Visible	:= vis								; show/hide current v1 script line details
		this.oGui.Show('h' ((this.debugMode) ? 200 : this.hGui))									; update gui height based on debug mode
	}
	;############################################################################
	_disableClose() {
		hMenu := DllCall("GetSystemMenu", "Ptr", this.oGui.Hwnd, "Int", False, "Ptr")				; get handle fo sysmenu
		DllCall("DeleteMenu", "Ptr", hMenu, "UInt", 0xF060, "UInt", 0x8)							; delete sysMenu - 0x8 is MF_BYPOSITION (or MF_BYCOMMAND 0xF060)
		this.oGui.OnEvent("Close", (*) => 1)														; prevent close
	}
	;############################################################################
	Hide() {
		this.oGui.Hide()																			; Hide gui
	}
	;############################################################################
	Show() {																						; Show gui (only when hidden)
		Static WS_VISIBLE := 0x10000000																; logic flag for Visible
		If (WinGetStyle(this.oGui) & WS_VISIBLE)													; if already visible...
			return																					; ... don't update gui
		this.oGui.Show('NA')																		; is hidden, show
	}
}