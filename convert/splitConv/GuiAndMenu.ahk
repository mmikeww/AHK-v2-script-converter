class clsGui
{
; 2025-10-13 AMB, ADDED to fix #202

	guiName := ''				; gui name - used as key for smGuiList (may not match orgName)
	orgName := ''				; used to track original gui name - may not match guiName property (this provides fix for #202)
	created := ''				; how gui was created

	__new(name, created:='') {
		this.guiName := name
		this.created := created
	}
}

;################################################################################
_Gui(p) {
; 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object
; 2025-10-05 AMB, UPDATED - moved to GuiAndMenu.ahk, changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-10-13 AMB, UPDATED - to fix #202, also changed some var names and functionality
; 2025-11-01 AMB, UPDATED - as part of Scope support, and gmList_LblsToFunc key case-sensitivity

	global gEarlyLine
	global gGuiNameDefault
	global gGuiControlCount
	global gmList_LblsToFunc
	global gLVNameDefault
	global gTVNameDefault
	global gSBNameDefault
	global gGuiList
	global gOrig_ScriptStr		; array of all the lines
	global gOScriptStr			; array of all the lines
	global gmGuiFuncCBChecks
	global gO_Index				; current index of the lines
	global gmGuiVList
	global gGuiActiveFont
	global gmGuiCtrlObj

	static smGuiList := Map()	; 2025-10-13 AMB - changed var name and now holds gui object
	;preliminary version

	SubCommand	:= RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newGuiName) = 0 ? Trim(p[1]) : newGuiName[1]
	GuiName		:= RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? ""		  : newGuiName[1]

	GuiLine		:= gEarlyLine
	LineResult	:= ""
	LineSuffix	:= ""
	if (RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$")) {
		ControlHwnd		:= ""
		ControlLabel	:= ""
		ControlName		:= ""
		ControlObject	:= ""
		GuiOpt			:= ""

		if (p[1] = "New" && gGuiList != "") {																	; Gui established (NEW), has NO custom name
			if (!InStr(gGuiList, gGuiNameDefault)) {															; if default gui name not in gui list
				curGuiName := gGuiNameDefault																	; ... cur gui name := default name
			} else {
				loop {
					if (!InStr(gGuiList, gGuiNameDefault A_Index)) {
						curGuiName := gGuiNameDefault := gGuiNameDefault A_Index
						break
					}
				}
			}
			smGuiList[curGuiName] := clsGui(curGuiName, "New")													; 2025-10-13 create a gui object
		} else if (RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")) {									; Gui established (NEW), HAS CUSTOM NAME !!
			curGuiName	:= RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
			GuiLine		:= RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)
			if (curGuiName = "1") {																				; if custom name is 1...
				curGuiName := "myGui"																			; ... rename it to DEFAULT myGui
			}
			gGuiNameDefault := curGuiName
			smGuiList[curGuiName] := clsGui(curGuiName, "Set")													; 2025-10-13, create a gui object
			smGuiList[curGuiName].orgName := curGuiName															; 2025-10-13, track orig Gui name, this fixes #202
		} else {																								; triggered for anything other than NEW cmds
			curGuiName := gGuiNameDefault
			if (!smGuiList.has(curGuiName)) {
				smGuiList[curGuiName] := clsGui(curGuiName, "Default")											; no GUI() was established, do it now
			}
		}
		if (RegExMatch(curGuiName, "^\d+$")) {
			curGuiName := "oGui" curGuiName
			if (!smGuiList.has(curGuiName)) {
				smGuiList[curGuiName] := clsGui(curGuiName, "Default") ; created prop not really needed here	; no GUI() was established, do it now
			}
		}
		prevGuiName := (curGuiName = "myGui") ? "" : curGuiName													; prevGuiName and curGuiName will match most of the time
		if (RegExMatch(prevGuiName, "^oGui\d+$")) {
			prevGuiName := StrReplace(prevGuiName, "oGui")
		}
		if (prevGuiName != ""
		&& smGuiList[prevGuiName].created ~= "New|Default") {													; checking for 'Default' is unnecessary
			prevGuiName := ""
		}
		guiCmd	:= RegExReplace(p[1], "i)^([^:]*):\s*(.*)$", "$2")
		OptCtrl	:= p[2], OptList := p[3], TxtList := p[4]														; use vars for better clarity (somewhat)

		; 2024-07-09 AMB, UPDATED - needles to support all valid v1 label chars
		; 2024-09-05 f2g: UPDATED - Don't test OptList for g-label if guiCmd = "Show"
		; 2025-10-05 AMB, UPDATED - needles to prevent "+Grid" from being mistaken for gLabel
		if (RegExMatch(OptList, "i)^.*?(?<=^|\h)g([^,\h``]+).*$") && !RegExMatch(guiCmd, "i)show|margin|font|new")) {
			; Record and remove gLabel
			ControlLabel	:= RegExReplace(OptList, "i)^.*?(?<=^|\h)g([^,\h``]+).*$", "$1")					; get glabel name
			OptList			:= RegExReplace(OptList, "i)^(.*?)(?<=^|\h)g([^,\h``]+)(.*)$", "$1$3")				; remove glabel

		} else if (OptCtrl = "Button") {
			ControlLabel := smGuiList[curGuiName].orgName OptCtrl RegExReplace(TxtList, "[\s&]", "")	; 2025-10-13 - this fixes #202 (tracking of orig gui name)
			; 2025-11-01 AMB, UPDATED as part of Scope support
			if (!scriptHasLabel(ControlLabel) && !scriptHasFunc(ControlLabel)) {
				ControlLabel := ""
			}
		}
		; 2025-11-01 AMB, UPDATED as part of Scope support
		if (scriptHasFunc(ControlLabel)) {
			gmGuiFuncCBChecks[ControlLabel] := true
		}
		if (RegExMatch(OptList, "i)\bv[\w]+\b") && !(guiCmd ~= "i)show|margin|font|new")) {
			ControlName := RegExReplace(OptList, "i)^.*\bv([\w]+)\b.*$", "$1")

			ControlObject := InStr(ControlName, SubStr(OptCtrl, 1, 4)) ? "ogc" ControlName : "ogc" OptCtrl ControlName
			gmGuiCtrlObj[ControlName] := ControlObject
			if (OptCtrl != "Pic" && OptCtrl != "Picture" && OptCtrl != "Text" && OptCtrl != "Button" && OptCtrl != "Link" && OptCtrl != "Progress"
				&& OptCtrl != "GroupBox" && OptCtrl != "Statusbar" && OptCtrl != "ActiveX") {		; Exclude Controls from the submit (this generates an error)
				if (gmGuiVList.Has(curGuiName)) {
					gmGuiVList[curGuiName] .= "`r`n" ControlName
				} else {
					gmGuiVList[curGuiName] := ControlName
				}
			}
		}
		if (RegExMatch(OptList, "i)(?<=[^\w\n]|^)\+?HWND(\w*?)(?=`"|\s|$)", &match)) {
			ControlHwnd := match[1]
			OptList := StrReplace(OptList, match[])
			if (ControlObject = "" && TxtList != "") {
				ControlObject := InStr(ControlHwnd, SubStr(TxtList, 1, 4)) ? "ogc" StrReplace(ControlHwnd, "hwnd") : "ogc" TxtList StrReplace(ControlHwnd, "hwnd")
				ControlObject := RegExReplace(ControlObject, "\W")
			} else if (ControlObject = "") {
				gGuiControlCount++
				ControlObject := OptCtrl gGuiControlCount
			}
			gmGuiCtrlObj["%" ControlHwnd "%"] := ControlObject
			gmGuiCtrlObj["% " ControlHwnd] := ControlObject
		} else if (RegExMatch(OptCtrl, "i)(?<=[^\w\n]|^)\+?HWND(.*?)(?:\h|$)", &match))
				&& (RegExMatch(guiCmd, "i)(?<!\w)New")) {
			GuiOpt := OptCtrl
			GuiOpt := StrReplace(GuiOpt, match[])
			LineSuffix .= ", " match[1] " := " curGuiName ".Hwnd"
		} else if (RegExMatch(guiCmd, "i)(?<!\w)New")) {
			GuiOpt := OptCtrl
		}

		if (!InStr(gGuiList, "|" curGuiName "|")) {
			gGuiList .= curGuiName "|"
			LineResult := curGuiName " := Gui(" RegExReplace(ToExp(GuiOpt,1,1), '^""$') ")`r`n" gIndent

			; Add the events if they are used.
			aEventRename := []
			aEventRename.Push({oldlabel: prevGuiName "GuiClose", event: "Close", parameters: "*", NewFunctionName: prevGuiName "GuiClose"})
			aEventRename.Push({oldlabel: prevGuiName "GuiEscape", event: "Escape", parameters: "*", NewFunctionName: prevGuiName "GuiEscape"})
			aEventRename.Push({oldlabel: prevGuiName "GuiSize"
							, event: "Size", parameters: "thisGui, MinMax, A_GuiWidth, A_GuiHeight", NewFunctionName: prevGuiName "GuiSize"})
			aEventRename.Push({oldlabel: prevGuiName "GuiContextMenu", event: "ContextMenu", parameters: "*", NewFunctionName: prevGuiName "GuiContextMenu"})
			aEventRename.Push({oldlabel: prevGuiName "GuiDropFiles"
							, event: "DropFiles", parameters: "thisGui, Ctrl, FileArray, *", NewFunctionName: prevGuiName "GuiDropFiles"})
			Loop aEventRename.Length {
				if (scriptHasLabel(aEventRename[A_Index].oldlabel)) {
					if (gmAltLabel.Has(aEventRename[A_Index].oldlabel)) {
						aEventRename[A_Index].NewFunctionName := gmAltLabel[aEventRename[A_Index].oldlabel]
						; Alternative label is available
					} else {
						lbl		:= aEventRename[A_Index].oldlabel
						params	:= aEventRename[A_Index].parameters
						funName	:= getV2Name(aEventRename[A_Index].NewFunctionName)
						gmList_LblsToFunc[StrLower(getV2Name(lbl))] := ConvLabel('GUI', lbl, params, funName)
					}
					LineResult .= curGuiName ".OnEvent(`"" aEventRename[A_Index].event "`", " getV2Name(aEventRename[A_Index].NewFunctionName) ")`r`n"
				}
			}
		}

		if (RegExMatch(guiCmd, "i)^tab[23]?$")) {
			Return LineResult "Tab.UseTab(" OptCtrl ")"
		}
		if (guiCmd = "Show") {
			if (OptList != "") {
				LineResult .= curGuiName ".Title := " ToExp(OptList,1,1) "`r`n" gIndent
				OptList := ""
			}
		}

		if (RegExMatch(OptCtrl, "i)^tab[23]?$")) {
			LineResult .= "Tab := "
		}
		if (guiCmd = "Submit") {
			LineResult .= "oSaved := "
			if (InStr(OptCtrl, "NoHide")) {
				OptCtrl := "0"
			}
		}

		if (guiCmd = "Add") {
			if (OptCtrl = "TreeView" && ControlObject != "") {
				gTVNameDefault := ControlObject
			}
			if (OptCtrl = "StatusBar") {
				if (ControlObject = "") {
					ControlObject := gSBNameDefault
				}
				gSBNameDefault := ControlObject
			}
			if (OptCtrl ~= "i)(Button|ListView|TreeView)" || ControlLabel != "" || ControlObject != "") {
				if (ControlObject = "") {
					ControlObject := "ogc" OptCtrl RegExReplace(TxtList, "[^\w_]", "")
				}
				LineResult .= ControlObject " := "
				if (OptCtrl = "ListView") {
					gLVNameDefault := ControlObject
				}
				if (OptCtrl = "TreeView") {
					gTVNameDefault := ControlObject
				}
			}
			if (ControlObject != "") {
				gmGuiCtrlType[ControlObject] := OptCtrl	; Create a map containing the type of control
			}
		} else if (guiCmd = "Color") {
			Return LineResult curGuiName ".BackColor := " ToExp(OptCtrl,,1)
		} else if (guiCmd = "Margin") {
			Return LineResult curGuiName ".MarginX := " ToExp(OptCtrl,,1) ", " curGuiName ".MarginY := " ToExp(OptList,,1)
		} else if (guiCmd = "Font") {
			guiCmd := "SetFont"
			gGuiActiveFont := ToExp(OptCtrl,,1) ", " ToExp(OptList,,1)
		} else if (guiCmd = "Cancel") {
			guiCmd := "Hide"
		} else if (guiCmd = "New") {
			LineResult	:= Trim(LineResult LineSuffix,"`r`n")	; 2025-10-13 AMB - added CR to fix extra CR being left behind sometimes
			GuiName		:=	", " ToExp(OptList,,1)
			LineResult	:= RegExReplace(LineResult, "(.*)\)(.*)", "$1" (GuiName != ', ""' ? GuiName ')' : ')') "$2")
			return		RegExReplace(LineResult, '\r\n,', ',')
		}

		LineResult .= curGuiName "."

		if (guiCmd = "Menu") {
			; TODO: rename the output of the convert function to a global variable ( cOutput)
			; Why? output is a to general name to use as a global variable. To fragile for errors.
			; Output := StrReplace(Output, trim(OptList) ":= Menu()", trim(OptList) ":= MenuBar()")

			LineResult .= "MenuBar := " OptCtrl
		} else {
			if (guiCmd != "") {
				if (RegExMatch(guiCmd, "^\s*[-\+]\w*")) {
					While (RegExMatch(guiCmd, 'i)(?<=[^\w\n]|^)\+HWND(.*?)(?:\s|$)', &match)) {
						LineSuffix .= ", " match[1] " := " curGuiName ".Hwnd"
						guiCmd := StrReplace(guiCmd, match[])
					}
					LineResult .= "Opt(" ToExp(guiCmd,,1)
				} Else {
					LineResult .= guiCmd "("
				}
			}
			if (OptCtrl != "") {
				LineResult .= ToExp(OptCtrl,,1)
			}
			if (OptList != "") {
				LineResult .= ", " ToExp(OptList,,1)
			} else if (TxtList != "") {
				LineResult .= ", "
			}
			if (TxtList != "") {
				if (RegExMatch(OptCtrl, "i)^tab[23]?$") || OptCtrl = "ListView" || OptCtrl = "DropDownList" || OptCtrl = "DDL" || OptCtrl = "ListBox" || OptCtrl = "ComboBox") {
					searchIdx := 1
					while (gOScriptStr.Has(gO_Index + searchIdx) && SubStr(gOScriptStr.GetLine(gO_Index + searchIdx), 1, 1) ~= "^(\||)$") {
						;TxtList .= contStr := gOScriptStr[gO_Index + searchIdx]
						TxtList .= contStr := gOScriptStr.GetLine(gO_Index + searchIdx)
						nlCount := (SubStr(contStr, 1, 1) = "|" ? 0 : (IsSet(nlCount) ? nlCount : 0) + 1)
						searchIdx++
					}
					if (searchIdx != 1)
						gO_Index += (searchIdx - 1 - nlCount)
						gOScriptStr.SetIndex(gO_Index)
					if (RegExMatch(TxtList, "%(.*)%", &match)) {
						LineResult .= ', StrSplit(' match[1] ', "|")'
						LineSuffix .= " `; V1toV2: Check that this " OptCtrl " has the correct choose value"
					} else {
						ObjectValue := "["
						ChooseString := ""
						if (!InStr(OptList, "Choose") && InStr(TxtList, "||")) {		; ChooseN takes priority over ||
							dPipes		:= StrSplit(TxtList, "||")
							selIndex 	:= 0
							for idx, str in dPipes {
								if (idx=dPipes.length)
									break
								RegExReplace(str, "\|",,&curCount)
								selIndex += curCount+1
							}
							LineResult := RegexReplace(LineResult, "`"$", " Choose" selIndex "`"")
							if (OptList = "")
								LineResult .= "`"Choose" selIndex "`""
							TxtList := RTrim(StrReplace(TxtList, "||", "|"), "|")
						} else if (InStr(OptList, "Choose")) {
							TxtList := RegexReplace(TxtList, "\|+", "|")				; Replace all pipe groups, this breaks empty choices
						}
						Loop Parse TxtList, "|", " "
						{
							if (RegExMatch(OptCtrl, "i)^tab[23]?$") && A_LoopField = "") {
							ChooseString := "`" Choose" A_Index - 1 "`""
							continue
							}
							ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,1,1) : ", " ToExp(A_LoopField,1,1)
						}
						ObjectValue .= "]"
						LineResult .= ChooseString ", " ObjectValue
					}
				} else {
					LineResult .= ", " ToExp(TxtList,1,1)
				}
			}
			if (guiCmd != "") {
				LineResult .= ")"
			} else if (guiCmd = "" && LineSuffix != "") {
				LineResult := RegExReplace(LineResult, 'm)^.*\.Opt\(""')
				LineSuffix := LTrim(LineSuffix, ", ")
			}

			if (guiCmd = "Submit") {
				; This should be replaced by keeping a list of the v variables of a Gui and declare for each "vName := oSaved.vName"
				if (gmGuiVList.Has(curGuiName)) {
					Loop Parse, gmGuiVList[curGuiName], "`n", "`r"
					{
						if (gmGuiVList[curGuiName])
							LineResult .= "`r`n" gIndent A_LoopField " := oSaved." A_LoopField
					}
				}
			}
		}
		if (guiCmd = "Add" && OptCtrl = "ActiveX" && ControlName != "") {
			; Fix for ActiveX control, so functions of the ActiveX can be used
			LineResult .= "`r`n" gIndent ControlName " := " ControlObject ".Value"
		}

		if (ControlLabel != "") {
			if (gmAltLabel.Has(ControlLabel)) {
				ControlLabel := gmAltLabel[ControlLabel]
			}
			ControlEvent := "Change"

			if (gmGuiCtrlType.Has(ControlObject) && gmGuiCtrlType[ControlObject] ~= "i)(ListBox|ComboBox|ListView|TreeView)") {
				ControlEvent := "DoubleClick"
			}
			if (gmGuiCtrlType.Has(ControlObject) && gmGuiCtrlType[ControlObject] ~= "i)(Button|Checkbox|Link|Radio|Picture|Statusbar|Text)") {
				ControlEvent := "Click"
			}
			V1GuiControlEvent := ControlEvent = "Change" ? "Normal" : ControlEvent
			V1GuiControlEvent := V1GuiControlEvent = "Click" ? "Normal" : V1GuiControlEvent
			LineResult .= "`r`n" gIndent ControlObject ".OnEvent(`"" ControlEvent "`", " getV2Name(ControlLabel) ".Bind(`"" V1GuiControlEvent "`"))"
			lbl			:= ControlLabel
			params		:= 'A_GuiEvent:="", A_GuiControl:="", Info:="", *'
			funcName	:= getV2Name(ControlLabel)
			; 2025-10-07 AMB - Added regex for A_EventInfo -> Info conversion for new Gui funcs
			gmList_LblsToFunc[StrLower(funcName)] := ConvLabel('AG', lbl, params, funcName, {NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$", Replacement: "$1Info$2"})
		}
		if (ControlHwnd != "") {
			LineResult .= ", " ControlHwnd " := " ControlObject ".hwnd"
		}
	}
	DebugWindow("LineResult:" LineResult "`r`n")
	Out := format("{1}", LineResult LineSuffix)
	return Out
}
;################################################################################
_GuiControl(p) {
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk

	global gGuiNameDefault
	global gGuiActiveFont
	SubCommand		:= RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[1]) : newSubCommand[1]
	GuiName			:= RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? gGuiNameDefault : newGuiName[1]
	ControlID		:= Trim(p[2])
	Value			:= Trim(p[3])
	Out				:= ""
	ControlObject	:= gmGuiCtrlObj.Has(ControlID) ? gmGuiCtrlObj[ControlID] : "ogc" ControlID

	Type := gmGuiCtrlType.Has(ControlObject) ? gmGuiCtrlType[ControlObject] : ""

	if (SubCommand = "") {
		if (Type = "Groupbox" || Type = "Button" || Type = "Link") {
			SubCommand := "Text"
		} else if (Type = "Radio" && (Value != "0" || Value != "1" || Value != "-1" || InStr(Value, "%"))) {
			SubCommand := "Text"
		}
	}
	if (SubCommand = "") {
		; Not perfect, as this should be dependent on the type of control

		if (Type = "ListBox" || Type = "DropDownList" || Type = "ComboBox" || Type = "tab") {
			PreSelected := ""
			if (SubStr(Value, 1, 1) = "|") {
				Value := SubStr(Value, 2)
				Out .= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
			}
			ObjectValue := "["
			Loop Parse Value, "|", " "
			{
				if (A_LoopField = "" && A_Index != 1) {
					PreSelected := LoopFieldPrev
					continue
				}
				ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
				LoopFieldPrev := A_LoopField
			}
			ObjectValue .= "]"
			Out .= ControlObject ".Add(" ObjectValue ")"
			if (PreSelected != "") {
				Out .= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
			}
			Return Out
		}
		if (InStr(Value, "|")) {

			PreSelected := ""
			if (SubStr(Value, 1, 1) = "|") {
				Value	:= SubStr(Value, 2)
				Out		.= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
			}
			ObjectValue := "["
			Loop Parse Value, "|", " "
			{
				if (A_LoopField = "" && A_Index != 1) {
					PreSelected := LoopFieldPrev
					continue
				}
				ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
				LoopFieldPrev := A_LoopField
			}
			ObjectValue .= "]"
			Out .= ControlObject ".Add(" ObjectValue ")"
			if (PreSelected != "") {
				Out .= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
			}
			Return Out
		}
		if (Type = "UpDown" || Type = "Slider" || Type = "Progress") {
			if (SubStr(Value, 1, 1) = "-") {
				return ControlObject ".Value -= " ToExp(Value)
			} else if (SubStr(Value, 1, 1) = "+") {
				return ControlObject ".Value += " ToExp(Value)
			}
			return ControlObject ".Value := " ToExp(Value)
		}
		return ControlObject ".Value := " ToExp(Value)
	} else if (SubCommand = "Text") {
		if (Type = "ListBox" || Type = "DropDownList" || Type = "tab" || Type ~= "i)tab\d") {
			PreSelected := ""
			if (SubStr(Value, 1, 1) = "|") {
				Value	:= SubStr(Value, 2)
				Out		.= ControlObject ".Delete() `; V1toV2: Clean the list`r`n" gIndent
			}
			ObjectValue := "["
			Loop Parse Value, "|", " "
			{
				if (A_LoopField = "" && A_Index != 1) {
					PreSelected := LoopFieldPrev
					continue
				}
				ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,,1) : ", " ToExp(A_LoopField,,1)
				LoopFieldPrev := A_LoopField
			}
			ObjectValue	.= "]"
			Out			.= ControlObject ".Add(" ObjectValue ")"
			if (PreSelected != "") {
				Out		.= "`r`n" gIndent ControlID ".ChooseString(" ToExp(PreSelected,1,1) ")"
			}
			Return Out
		}
		Return ControlObject ".Text := " ToExp(Value)
	} else if (SubCommand = "Move" || SubCommand = "MoveDraw") {

		X := RegExMatch(Value, "i)^.*\bx`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newX) = 0 ? "" : newX[1]
		Y := RegExMatch(Value, "i)^.*\by`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newY) = 0 ? "" : newY[1]
		W := RegExMatch(Value, "i)^.*\bw`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newW) = 0 ? "" : newW[1]
		H := RegExMatch(Value, "i)^.*\bh`"\s*\.?\s*([^`"]*?)\s*\.?\s*(`".*|)$", &newH) = 0 ? "" : newH[1]

		if (X = "") {
			X := RegExMatch(Value, "i)^.*\bx([\w]*)\b.*$", &newX) = 0 ? "" : newX[1]
		}
		if (X = "") {
			X := RegExMatch(Value, "i)^.*\bx%([\w]*)\b%.*$", &newX) = 0 ? "" : newX[1]
		}
		if (Y = "") {
			Y := RegExMatch(Value, "i)^.*\bY([\w]*)\b.*$", &newY) = 0 ? "" : newY[1]
		}
		if (Y = "") {
			Y := RegExMatch(Value, "i)^.*\bY%([\w]*)\b%.*$", &newY) = 0 ? "" : newY[1]
		}
		if (W = "") {
			W := RegExMatch(Value, "i)^.*\bw([\w]*)\b.*$", &newW) = 0 ? "" : newW[1]
		}
		if (W = "") {
			W := RegExMatch(Value, "i)^.*\bw%([\w]*)\b%.*$", &newW) = 0 ? "" : newW[1]
		}
		if (H = "") {
			H := RegExMatch(Value, "i)^.*\bh([\w]*)\b.*$", &newH) = 0 ? "" : newH[1]
		}
		if (H = "") {
			H := RegExMatch(Value, "i)^.*\bh%([\w]*)\b%.*$", &newH) = 0 ? "" : newH[1]
		}

		Out := ControlObject "." SubCommand "(" X ", " Y ", " W ", " H ")"
		Out := RegExReplace(Out, "[\s\,]*\)$", ")")
		Return Out
	} else if (SubCommand = "Focus") {
		Return ControlObject ".Focus()"
	} else if (SubCommand = "Disable") {
		Return ControlObject ".Enabled := false"
	} else if (SubCommand = "Enable") {
		Return ControlObject ".Enabled := true"
	} else if (SubCommand = "Hide") {
		Return ControlObject ".Visible := false"
	} else if (SubCommand = "Show") {
		Return ControlObject ".Visible := true"
	} else if (SubCommand = "Choose") {
		Return ControlObject ".Choose(" Value ")"
	} else if (SubCommand = "ChooseString") {
		Return ControlObject ".Choose(" ToExp(Value) ")"
	} else if (SubCommand = "Font") {
		if (gGuiActiveFont != "") {
			Return ControlObject ".SetFont(" gGuiActiveFont ")"
		} else {
			Return "; V1toV2: Use " ControlObject ".SetFont(Options, FontName)"
		}
	} else if (RegExMatch(SubCommand, "^[+-].*")) {
		Return ControlObject ".Opt(" ToExp(SubCommand) ")"
	} else { ; Passed as variable, just output something that won't work
		if (RegExMatch(SubCommand, "[+-].*"))
			Return ControlObject ".Opt(" ToExp(SubCommand) ")"
		Return ControlObject ".%" ToExp(SubCommand) "%() `; V1toV2: SubCommand passed as variable, check variable contents and docs"
	}

	Return
}
;################################################################################
_GuiControlGet(p) {
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk

	; GuiControlGet, OutputVar , SubCommand, ControlID, Value
	global gGuiNameDefault
	OutputVar	:= Trim(p[1])
	SubCommand	:= RegExMatch(p[2], "i)^\s*[^:]*?\s*:\s*(.*)$", &newSubCommand) = 0 ? Trim(p[2]) : newSubCommand[1]
	GuiName		:= RegExMatch(p[2], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? gGuiNameDefault : newGuiName[1]
	ControlID	:= Trim(p[3])
	Value		:= Trim(p[4])
	if (ControlID = "") {
		ControlID := OutputVar
	}

	Out := ""
	ControlObject := gmGuiCtrlObj.Has(ControlID) ? gmGuiCtrlObj[ControlID] : "ogc" ControlID
	Type := gmGuiCtrlType.Has(ControlObject) ? gmGuiCtrlType[ControlObject] : ""

	if (SubCommand = "") {
		if (Value = "text" || Type = "ListBox") {
			Out := OutputVar " := " ControlObject ".Text"
		} else {
			Out := OutputVar " := " ControlObject ".Value"
		}
	} else if (SubCommand = "Pos") {
		Out := ControlObject ".GetPos(&" OutputVar "X, &" OutputVar "Y, &" OutputVar "W, &" OutputVar "H)"
	} else if (SubCommand = "Focus") {
		; not correct
		Out := "; " OutputVar " := ControlGetFocus() `; V1toV2: Not really the same, this returns the HWND..."
	} else if (SubCommand = "FocusV") {
		; not correct MyGui.FocusedCtrl
		Out := "; " OutputVar " := " GuiName ".FocusedCtrl `; V1toV2: Not really the same, this returns the focused gui control object..."
	} else if (SubCommand = "Enabled") {
		Out := OutputVar " := " ControlObject ".Enabled"
	} else if (SubCommand = "Visible") {
		Out := OutputVar " := " ControlObject ".Visible"
	} else if (SubCommand = "Name") {
		Out := OutputVar " := " ControlObject ".Name"
	} else if (SubCommand = "Hwnd") {
		Out := OutputVar " := " ControlObject ".Hwnd"
	}

	Return RegExReplace(Out, "[\s\,]*\)$", ")")
}
;################################################################################
addGuiCBArgs(&code) {
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk

	global gmGuiFuncCBChecks
	for key, val in gmGuiFuncCBChecks {
		code := RegExReplace(code, 'im)^(\s*' key ')\((.*?)\)(\s*\{)', '$1(A_GuiEvent:="", A_GuiControl:="", Info:="", *)$3 `; V1toV2: Handle params: $2')
		code := RegExReplace(code, 'm) `; V1toV2: Handle params: (A_GuiEvent:="", A_GuiControl:="", Info:="", \*)?$')
	}
}
;################################################################################
addMenuCBArgs(&code) {
; 2024-06-26 AMB, ADDED to fix issue #131
; 2025-06-12 AMB, UPDATED to fix interference with IF/LOOP/WHILE
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk
; 2025-10-10 AMB, UPDATED to fix missing params

	;Mask_T(&code, 'C&S')	; 2025-10-10 - now handled in FinalizeConvert()
	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')					; 2025-06-12, remove exclusion
	nDeclare:= '(?im)' nCommon '\))(?<trail>.*)'														; make needle for func declaration
	nArgs	:= '(?im)' nCommon '\K\)).*'																; make needle for func params/args
	m := [], declare := []
	for key, val in gmMenuCBChecks
	{
		nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', key)								; target specific function name
		if (pos := RegExMatch(code, nTargFunc, &m)) {
			; target function found
			if (RegExMatch(m[], nDeclare, &declare)) {													; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail
				if (instr(argList, 'A_ThisMenuItem') && instr(argList, 'A_ThisMenuItemPos') && instr(argList, 'MyMenu'))
					continue																			; skip converted labels
				newArgs		:= '(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""' . ((m.Args='') ? ')' : ', ' SubStr(argList,2))
				addArgs		:= RegExReplace(m[],		'\Q' argList '\E', newArgs,,1)					; replace function args
				code		:= RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)						; replace function within the code
			}
		}
	}
	return ; code by reference
}
;################################################################################
addOnMessageCBArgs(&code) {
; 2024-06-28 AMB, ADDED to fix issue #136
; 2025-06-12 AMB, UPDATED to fix interference with IF/LOOP/WHILE
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk
; 2025-10-10 AMB, UPDATED to fix missing params, improve WS handling
; 2025-10-12 AMB, UPDATED to better support existng params and binding

	;Mask_T(&code, 'C&S')	; 2025-10-10 - now handled in FinalizeConvert()
	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')					; 2025-06-12, remove exclusion
	nParams := '(?i)(?:\b(?:wParam|lParam|msg|hwnd)\b(\h*,\h*)?)+'
	nDeclare:= '(?im)' nCommon '\))(?<trail>.*)'														; make needle for func declaration
	nArgs	:= '(?im)' nCommon '\K\)).*'																; make needle for func params/args
	m := [], declare := []
	for key, obj in gmOnMessageMap																		; 2025-10-12 - gmOnMessageMap now holds clsOnMsg objects
	{
		funcName := obj.cbFunc																			; grab callback func
		nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', funcName)							; target specific function name
		If (pos := RegExMatch(code, nTargFunc, &m)) {													; look for the func declaration...
			; target function found
			if (RegExMatch(m[], nDeclare, &declare)) {													; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail									; extract params and trailing portion of line
				LWS			:= TWS := '', params := ''													; ini existing params details, inc lead/trail ws
				if (RegExMatch(argList, '\((\h*)(.+?)(\h*)\)', &mWS)) {									; separate lead/trail ws in params
					LWS := mWS[1], params := mWS[2], TWS := mWS[3]										; extract existing params and preserve lead/trail ws
				}
				; 2025-10-12 AMB, better support for existing params and binding
				paramsToAdd := 'wParam, lParam, msg, hwnd'												; default params required by OnMessage (will add as needed)
				if (!obj.bindStr) {																		; if OnMesssage call DOES NOT include Binding...
					checkParams := Trim(params)															; ... check exiting params (they are substitutes)
					While(checkParams) {																; remove params-to-add, if they have exiting substitutes
						checkParams := Trim(RegExReplace(checkParams, '^[^,\s]+[,\h]*'))				; [to track when all params have been processed]
						paramsToAdd := Trim(RegExReplace(paramsToAdd, '^[^,\s]+[,\h]*'))				; remove any params-to-add when they have existing substitue
					}
				}
				else {																					; OnMessage call HAS binding, so...
					params	:= Trim(RegExReplace(params, nParams), ', `t`r`n')							; remove any params-to-add from the existing list
				}
				params		.= (params && paramsToAdd) ? ', ' : ''										; add trailing comma only when needed
				newArgs		:= '(' LWS . params . paramsToAdd . TWS ')'									; preserve lead/trail ws while rebuilding params list
				addArgs		:= RegExReplace(m[],  '\Q' argList '\E', newArgs,,1)						; replace function params/args
				code		:= RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)						; replace function within the code
			}
		}
	}
	return ; code by reference
}
;################################################################################
getMenuBarName(srcStr) {
; 2024-07-02 ADDED, AMB - for detection and initialization of MenuBar...
;	when the menu is created prior to GUI official declaration
;	not perfect - requires 'gui' to be in the name of script gui control, which is common
; 2025-10-05 AMB, MOVED to GuiAndMenu.ahk

	needle := '(?im)^\h*\w*GUI\w*\b,?\h*\bMENU\b\h*,\h*(\w+)'
	if (RegExMatch(srcStr, needle, &m))
		return m[1]
	return ''
}
;################################################################################
_Menu(p) {
; 2025-10-05 AMB, UPDATED - moved to GuiAndMenu.ahk, changed gaList_LblsToFuncO to gmList_LblsToFunc
; 2025-11-01 AMB. UPDATED as part of Scope support, and gmList_LblsToFunc key case-sensitivity

	global gEarlyLine
	global gMenuList
	global gIndent
	global gmList_LblsToFunc
	MenuLine := gEarlyLine
	LineResult := ""
	menuNameLine := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
	; e.g.: Menu, Tray, Add, % func_arg3(nested_arg3a, nested_arg3b), % func_arg4(nested_arg4a, nested_arg4b), % func_arg5(nested_arg5a, nested_arg5b)
	Var2 := Trim(RegExReplace(MenuLine, "
		(
		ix)						# case insensitive, extended mode to ignore space and comments
		^\s*Menu\s*[,\s]\s*		#
		([^,]*) \s* ,	  \s*	# arg1 Tray {group $1}
		([^,]*)					# arg2 Add  {group $2}
		.*						#
		)"
		, "$2", &RegExCount2))										; =Add
	Var3 := RegExReplace(MenuLine, "
		(
		ix)						#
		^\s*Menu \s*[,\s]\s*	#
		([^,] *)	   ,   \s*	# arg1 Tray {group $1}
		([^,] *) \s* ,   \s*	# arg2 Add	{group $2}
		([^,(]*  \(?			# % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
			(?(?<=\()[^)]*\))	# nested function conditional, if matched ( then match everything up to and including the )
			[^,]*)				# group $3 end}
		.*$						#
		)"
		, "$3", &RegExCount3)										; =% func_arg3(nested_arg3a, nested_arg3b)

	Var4 := RegExReplace(MenuLine, "
		(
		ix)							#
		^\s*Menu \s*[,\s]\s*		#
		([^,] *)	   ,   \s*		# arg1 Tray {group $1}
		([^,] *) \s* ,   \s*		# arg2 Add	{group $2}
		([^,(]*  \(?				# % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
			(?(?<=\()[^)]*\))		# nested function conditional
			[^,]*)	   ,?  \s* :?	# group $3 end}
		([^;,(]*	\(?				# % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
			(?(?<=\()[^)]*\))		# nested function conditional
			[^,]*)					# group $4 end}
			.*$						#
		)"
		, "$4", &RegExCount4)										; =% func_arg4(nested_arg4a, nested_arg4b)
	Var5 := RegExReplace(MenuLine, "
		(
		ix)							#
		^\s*Menu \s*[,\s]\s*		#
		([^,] *)	   ,   \s*		# arg1 Tray {group $1}
		([^,] *) \s* ,   \s*		# arg2 Add	{group $2}
		([^,(]*  \(?				# % func_arg3(nested_arg3a, nested_arg3b) {group $3 start
			(?(?<=\()[^)]*\))		# nested function conditional
			[^,]*)	   ,?  \s* :?	# group $3 end}
		([^;,(]*	\(?				# % func_arg4(nested_arg4a, nested_arg4b) {group $4 start
			(?(?<=\()[^)]*\))		# nested function conditional
			[^,]*)\s* ,?  \s*		# group $4 end}
		([^;,(]*	\(?				# % func_arg5(nested_arg5a, nested_arg5b) {group $5 start
			(?(?<=\()[^)]*\))		# nested function conditional
			[^,] *)					# group $5 end}
		.*$							#
		)"
		, "$5", &RegExCount5)										; =% func_arg5(nested_arg5a, nested_arg5b)

	menuNameLine := Trim(menuNameLine)

	If (Var2 = "UseErrorLevel")
		return Format("; V1toV2: Removed {2} from Menu {1}", menuNameLine, Var2)

	; 2024-06-08 andymbody	fix #179
	; if systray root menu
	; (menuNameLine "->" var3) should be a unique root->child id tag (hopefully)
	;	this should distinguish between 'systray-root-menu' and 'child-menuItem/submenu'
	if (menuNameLine="Tray" && !InStr(gMenuList, "|" menuNameLine "->" var3 "|"))
	{
		; should be dealing with the root-menu (not a child menu item)
		if (Var2 = "Tip") {										; set tooltip for script sysTray root-menu
			Return LineResult .= "A_IconTip := " ToExp(Var3,,1)
		} else if (Var2 = "Icon") {								; set icon for script systray root-menu
			LineResult .= "TraySetIcon(" ToExp(Var3,,1)
			LineResult .= Var4 ? "," ToExp(Var4,,1) : ""
			LineResult .= Var5 ? "," ToExp(Var5,,1) : ""
			LineResult .= ")"
			Return LineResult
		}
	}

	; should be child menu item (not main systray-root-menu)
	if (!InStr(gMenuList, "|" menuNameLine "|"))
	{
		if (menuNameLine = "Tray") {
			LineResult .= menuNameLine ":= A_TrayMenu`r`n" gIndent		; initialize/declare systray object (only once)
		} else {
			; 2024-07-02, CHANGED, AMB - to support MenuBar detection and initialization
			global gMenuBarName										; was set prior to any conversion taking place, see Before_LineConverts() and getMenuBarName()
			lineResult		.= (menuNameLine . " := Menu") . ((menuNameLine=gMenuBarName) ? "Bar" : "") . ("()`r`n" . gIndent)
			; adj to flag that initialization has been completed (name will no longer match)
			; not setting to "" just in case verifification of a menubar's existence is desired elsewhere
			gMenuBarName	.= (menuNameLine=gMenuBarName) ? "_iniDone" : ""
		}
		gMenuList .= menuNameLine "|"								; keep track of sub-menu roots
	}

	LineResult .= menuNameLine "."

	Var2 := Trim(Var2)
	Var3 := Trim(Var3)
	Var4 := Trim(Var4)
	DebugWindow(gMenuList "`r`n")
	if (Var2 = "Default") {
		return LineResult "Default := " ToExp(Var3)
	}
	if (Var2 = "NoDefault") {
		return LineResult "Default := `"`""
	}
	if (Var2 = "Standard") {
		return LineResult "AddStandard()"
	}
	if (Var2 = "NoStandard") {
		; maybe keep track of added items, if menu is new, just Delete everything
		return LineResult "Delete() `; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning"
	}
	if (Var2 = "DeleteAll") {
		return LineResult "Delete()"
	}
	if (Var2 = "Icon") {
		Var2 := "SetIcon"											; child menuItem
	}
	if (Var2 = "Color") {
		Var2 := "SetColor"
	}
	if (Var2 = "Add" && RegExCount3 && !RegExCount4) {
		gMenuList .= menuNameLine "->" var3 "|"						; 2024-06-08 ADDED for fix #179 (unique parent->child id tag)
		Var4 := Var3
		RegExCount4 := RegExCount3
	}

	if (RegExCount2) {
		LineResult .= Var2 "("
	}
	if (RegExCount3) {
		LineResult .= ToExp(Var3,,1)
	} else if (RegExCount4) {
		LineResult .= ", "
	}
	if (RegExCount4) {
		if (Var2 = "Add") {
			if (Var4 = "")
				Var4 := Var3
			gMenuList .= menuNameLine "->" var3 "|"					; 2024-06-08 ADDED for fix #179 (unique parent->child id tag)
			FunctionName := RegExReplace(Var4, "&", "")				; Removes & from labels
			if (gmAltLabel.Has(FunctionName)) {
				FunctionName := gmAltLabel[FunctionName]
			} else if (scriptHasLabel(Var4)) {						; 2025-11-01 AMB, UPDATED
				gmList_LblsToFunc[StrLower(Var4)] := ConvLabel('MN', Var4, 'A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *', FunctionName)
			}
			if (Var4 != "") {
				; 2024-06-26 ADDED by AMB for fix #131
				; add CB func name to list - if the func exists, will add params (during final steps of conversion)
				global gmMenuCBChecks
				gmMenuCBChecks[Var4] := true
				LineResult .= ", " FunctionName
			}
		} else if (Var2 = "SetColor") {
			if (Var4 = "Single") {
				LineResult .= ", 0"
			}
		} else {
			if (Var4 != "") {
				LineResult .= ", " ToExp(Var4,,1)
			}
		}
	}
	if (RegExCount5) {
		if (Var2 = "Insert") {
			LineResult .= ", " Var5
		} else if (Var5 != "") {
			LineResult .= ", " ToExp(Var5,,1)
		} else if (Var5 = "" && p[6] != "") {
			LineResult .= ",, "
		}
	}

	if (p[6] != "") {
		if (Var5 != "") {
			LineResult .= ", "
		}
		LineResult .= p[6]
	}

	if (RegExCount1) {
		LineResult .= ")"
	}

	return LineResult
}