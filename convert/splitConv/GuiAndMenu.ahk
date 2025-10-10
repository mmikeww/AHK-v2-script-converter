;################################################################################
_Gui(p) {
; 2025-06-12 AMB, UPDATED - changed some var and func names, gOScriptStr is now an object
; 2025-10-05 AMB, UPDATED - moved to GuiAndMenu.ahk, changed gaList_LblsToFuncO to gmList_LblsToFunc

	global gEarlyLine
	global gGuiNameDefault
	global gGuiControlCount
	global gLVNameDefault
	global gTVNameDefault
	global gSBNameDefault
	global gGuiList
	global gOrig_ScriptStr		; array of all the lines
	global gOScriptStr			; array of all the lines
	global gAllV1LabelNames		; all label names (comma delim str)
	global gAllFuncNames		; all func names (comma delim str)
	global gmGuiFuncCBChecks
	global gO_Index				; current index of the lines
	global gmGuiVList
	global gGuiActiveFont
	global gmGuiCtrlObj

	static HowGuiCreated := Map()
	;preliminary version

	SubCommand	:= RegExMatch(p[1], "i)^\s*[^:]*?\s*:\s*(.*)$", &newGuiName) = 0 ? Trim(p[1]) : newGuiName[1]
	GuiName		:= RegExMatch(p[1], "i)^\s*([^:]*?)\s*:\s*.*$", &newGuiName) = 0 ? "" : newGuiName[1]

	GuiLine		:= gEarlyLine
	LineResult	:= ""
	LineSuffix	:= ""
	if (RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$")) {
		ControlHwnd		:= ""
		ControlLabel	:= ""
		ControlName		:= ""
		ControlObject	:= ""
		GuiOpt			:= ""

		if (p[1] = "New" && gGuiList != "") {
			if (!InStr(gGuiList, gGuiNameDefault)) {
				GuiNameLine := gGuiNameDefault
			} else {
				loop {
					if (!InStr(gGuiList, gGuiNameDefault A_Index)) {
						GuiNameLine := gGuiNameDefault := gGuiNameDefault A_Index
						break
					}
				}
			}
			HowGuiCreated[GuiNameLine] := "New"
		} else if (RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")) {
			GuiNameLine	:= RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
			GuiLine		:= RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)
			if (GuiNameLine = "1") {
				GuiNameLine := "myGui"
			}
			gGuiNameDefault := GuiNameLine
			HowGuiCreated[GuiNameLine] := "Set"
		} else {
			GuiNameLine := gGuiNameDefault
			HowGuiCreated[GuiNameLine] := "Default"
		}
		if (RegExMatch(GuiNameLine, "^\d+$")) {
			GuiNameLine := "oGui" GuiNameLine
		}
		GuiOldName := GuiNameLine = "myGui" ? "" : GuiNameLine
		if (RegExMatch(GuiOldName, "^oGui\d+$"))
			GuiOldName := StrReplace(GuiOldName, "oGui")
		if (GuiOldName != "" and HowGuiCreated[GuiOldName] ~= "New|Default")
			GuiOldName := ""

		Var1 := RegExReplace(p[1], "i)^([^:]*):\s*(.*)$", "$2")
		Var2 := p[2]
		Var3 := p[3]
		Var4 := p[4]

		; 2024-07-09 AMB, UPDATED - needles to support all valid v1 label chars
		; 2024-09-05 f2g: UPDATED - Don't test Var3 for g-label if Var1 = "Show"
		; 2025-10-05 AMB, UPDATED - needles to prevent "+Grid" from being mistaken for gLabel
		if (RegExMatch(Var3, "i)^.*?(?<=^|\h)g([^,\h``]+).*$") && !RegExMatch(Var1, "i)show|margin|font|new")) {
			; Record and remove gLabel
			ControlLabel := RegExReplace(Var3, "i)^.*?(?<=^|\h)g([^,\h``]+).*$", "$1")		; get glabel name
			Var3 := RegExReplace(Var3, "i)^(.*?)(?<=^|\h)g([^,\h``]+)(.*)$", "$1$3")		; remove glabel
		} else if (Var2 = "Button") {
			ControlLabel := GuiOldName var2 RegExReplace(Var4, "[\s&]", "")
			if (!InStr(gAllV1LabelNames, ControlLabel) && !InStr(gAllFuncNames, ControlLabel))
			ControlLabel := ""
		}
		if (ControlLabel != "" && !InStr(gAllV1LabelNames, ControlLabel) && InStr(gAllFuncNames, ControlLabel))
			gmGuiFuncCBChecks[ControlLabel] := true

		if (RegExMatch(Var3, "i)\bv[\w]+\b") && !(Var1 ~= "i)show|margin|font|new")) {
			ControlName := RegExReplace(Var3, "i)^.*\bv([\w]+)\b.*$", "$1")

			ControlObject := InStr(ControlName, SubStr(Var2, 1, 4)) ? "ogc" ControlName : "ogc" Var2 ControlName
			gmGuiCtrlObj[ControlName] := ControlObject
			if (Var2 != "Pic" && Var2 != "Picture" && Var2 != "Text" && Var2 != "Button" && Var2 != "Link" && Var2 != "Progress"
				&& Var2 != "GroupBox" && Var2 != "Statusbar" && Var2 != "ActiveX") {		; Exclude Controls from the submit (this generates an error)
				if (gmGuiVList.Has(GuiNameLine)) {
					gmGuiVList[GuiNameLine] .= "`r`n" ControlName
				} else {
					gmGuiVList[GuiNameLine] := ControlName
				}
			}
		}
		if (RegExMatch(Var3, "i)(?<=[^\w\n]|^)\+?HWND(\w*?)(?=`"|\s|$)", &match)) {
			ControlHwnd := match[1]
			Var3 := StrReplace(Var3, match[])
			if (ControlObject = "" && Var4 != "") {
				ControlObject := InStr(ControlHwnd, SubStr(Var4, 1, 4)) ? "ogc" StrReplace(ControlHwnd, "hwnd") : "ogc" Var4 StrReplace(ControlHwnd, "hwnd")
				ControlObject := RegExReplace(ControlObject, "\W")
			} else if (ControlObject = "") {
				gGuiControlCount++
				ControlObject := Var2 gGuiControlCount
			}
			gmGuiCtrlObj["%" ControlHwnd "%"] := ControlObject
			gmGuiCtrlObj["% " ControlHwnd] := ControlObject
		} else if (RegExMatch(Var2, "i)(?<=[^\w\n]|^)\+?HWND(.*?)(?:\h|$)", &match))
				&& (RegExMatch(Var1, "i)(?<!\w)New")) {
			GuiOpt := Var2
			GuiOpt := StrReplace(GuiOpt, match[])
			LineSuffix .= ", " match[1] " := " GuiNameLine ".Hwnd"
		} else if (RegExMatch(Var1, "i)(?<!\w)New")) {
			GuiOpt := Var2
		}

		if (!InStr(gGuiList, "|" GuiNameLine "|")) {
			gGuiList .= GuiNameLine "|"
			LineResult := GuiNameLine " := Gui(" RegExReplace(ToExp(GuiOpt,1,1), '^""$') ")`r`n" gIndent

			; Add the events if they are used.
			aEventRename := []
			aEventRename.Push({oldlabel: GuiOldName "GuiClose", event: "Close", parameters: "*", NewFunctionName: GuiOldName "GuiClose"})
			aEventRename.Push({oldlabel: GuiOldName "GuiEscape", event: "Escape", parameters: "*", NewFunctionName: GuiOldName "GuiEscape"})
			aEventRename.Push({oldlabel: GuiOldName "GuiSize"
							, event: "Size", parameters: "thisGui, MinMax, A_GuiWidth, A_GuiHeight", NewFunctionName: GuiOldName "GuiSize"})
			aEventRename.Push({oldlabel: GuiOldName "GuiConTextMenu", event: "ConTextMenu", parameters: "*", NewFunctionName: GuiOldName "GuiConTextMenu"})
			aEventRename.Push({oldlabel: GuiOldName "GuiDropFiles"
							, event: "DropFiles", parameters: "thisGui, Ctrl, FileArray, *", NewFunctionName: GuiOldName "GuiDropFiles"})
			Loop aEventRename.Length {
				if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" aEventRename[A_Index].oldlabel ":\s")) {
					if (gmAltLabel.Has(aEventRename[A_Index].oldlabel)) {
						aEventRename[A_Index].NewFunctionName := gmAltLabel[aEventRename[A_Index].oldlabel]
						; Alternative label is available
					} else {
						lbl		:= aEventRename[A_Index].oldlabel
						params	:= aEventRename[A_Index].parameters
						funName	:= getV2Name(aEventRename[A_Index].NewFunctionName)
						gmList_LblsToFunc[getV2Name(lbl)] := ConvLabel('GUI', lbl, params, funName)
					}
					LineResult .= GuiNameLine ".OnEvent(`"" aEventRename[A_Index].event "`", " getV2Name(aEventRename[A_Index].NewFunctionName) ")`r`n"
				}
			}
		}

		if (RegExMatch(Var1, "i)^tab[23]?$")) {
			Return LineResult "Tab.UseTab(" Var2 ")"
		}
		if (Var1 = "Show") {
			if (Var3 != "") {
				LineResult .= GuiNameLine ".Title := " ToExp(Var3,1,1) "`r`n" gIndent
				Var3 := ""
			}
		}

		if (RegExMatch(Var2, "i)^tab[23]?$")) {
			LineResult .= "Tab := "
		}
		if (var1 = "Submit") {
			LineResult .= "oSaved := "
			if (InStr(var2, "NoHide")) {
				var2 := "0"
			}
		}

		if (var1 = "Add") {
			if (var2 = "TreeView" && ControlObject != "") {
				gTVNameDefault := ControlObject
			}
			if (var2 = "StatusBar") {
				if (ControlObject = "") {
					ControlObject := gSBNameDefault
				}
				gSBNameDefault := ControlObject
			}
			if (var2 ~= "i)(Button|ListView|TreeView)" || ControlLabel != "" || ControlObject != "") {
				if (ControlObject = "") {
					ControlObject := "ogc" var2 RegExReplace(Var4, "[^\w_]", "")
				}
				LineResult .= ControlObject " := "
				if (var2 = "ListView") {
					gLVNameDefault := ControlObject
				}
				if (var2 = "TreeView") {
					gTVNameDefault := ControlObject
				}
			}
			if (ControlObject != "") {
				gmGuiCtrlType[ControlObject] := var2	; Create a map containing the type of control
			}
		} else if (var1 = "Color") {
			Return LineResult GuiNameLine ".BackColor := " ToExp(Var2,,1)
		} else if (var1 = "Margin") {
			Return LineResult GuiNameLine ".MarginX := " ToExp(Var2,,1) ", " GuiNameLine ".MarginY := " ToExp(Var3,,1)
		} else if (var1 = "Font") {
			var1 := "SetFont"
			gGuiActiveFont := ToExp(Var2,,1) ", " ToExp(Var3,,1)
		} else if (Var1 = "Cancel") {
			Var1 := "Hide"
		} else if (var1 = "New") {
			LineResult	:= Trim(LineResult LineSuffix,"`n")
			GuiName		:=	", " ToExp(Var3,,1)
			LineResult	:= RegExReplace(LineResult, "(.*)\)(.*)", "$1" (GuiName != ', ""' ? GuiName ')' : ')') "$2")
			return		RegExReplace(LineResult, '\r\n,', ',')
		}

		LineResult .= GuiNameLine "."

		if (Var1 = "Menu") {
			; TODO: rename the output of the convert function to a global variable ( cOutput)
			; Why? output is a to general name to use as a global variable. To fragile for errors.
			; Output := StrReplace(Output, trim(Var3) ":= Menu()", trim(Var3) ":= MenuBar()")

			LineResult .= "MenuBar := " Var2
		} else {
			if (Var1 != "") {
				if (RegExMatch(Var1, "^\s*[-\+]\w*")) {
					While (RegExMatch(Var1, 'i)(?<=[^\w\n]|^)\+HWND(.*?)(?:\s|$)', &match)) {
						LineSuffix .= ", " match[1] " := " GuiNameLine ".Hwnd"
						Var1 := StrReplace(Var1, match[])
					}
					LineResult .= "Opt(" ToExp(Var1,,1)
				} Else {
					LineResult .= Var1 "("
				}
			}
			if (Var2 != "") {
				LineResult .= ToExp(Var2,,1)
			}
			if (Var3 != "") {
				LineResult .= ", " ToExp(Var3,,1)
			} else if (Var4 != "") {
				LineResult .= ", "
			}
			if (Var4 != "") {
				if (RegExMatch(Var2, "i)^tab[23]?$") || Var2 = "ListView" || Var2 = "DropDownList" || Var2 = "DDL" || Var2 = "ListBox" || Var2 = "ComboBox") {
					searchIdx := 1
					while (gOScriptStr.Has(gO_Index + searchIdx) && SubStr(gOScriptStr.GetLine(gO_Index + searchIdx), 1, 1) ~= "^(\||)$") {
						;Var4 .= contStr := gOScriptStr[gO_Index + searchIdx]
						Var4 .= contStr := gOScriptStr.GetLine(gO_Index + searchIdx)
						nlCount := (SubStr(contStr, 1, 1) = "|" ? 0 : (IsSet(nlCount) ? nlCount : 0) + 1)
						searchIdx++
					}
					if (searchIdx != 1)
						gO_Index += (searchIdx - 1 - nlCount)
						gOScriptStr.SetIndex(gO_Index)
					if (RegExMatch(Var4, "%(.*)%", &match)) {
						LineResult .= ', StrSplit(' match[1] ', "|")'
						LineSuffix .= " `; V1toV2: Check that this " Var2 " has the correct choose value"
					} else {
						ObjectValue := "["
						ChooseString := ""
						if (!InStr(Var3, "Choose") && InStr(Var4, "||")) {		; ChooseN takes priority over ||
							dPipes		:= StrSplit(var4, "||")
							selIndex 	:= 0
							for idx, str in dPipes {
								if (idx=dPipes.length)
									break
								RegExReplace(str, "\|",,&curCount)
								selIndex += curCount+1
							}
							LineResult := RegexReplace(LineResult, "`"$", " Choose" selIndex "`"")
							if (Var3 = "")
								LineResult .= "`"Choose" selIndex "`""
							Var4 := RTrim(StrReplace(Var4, "||", "|"), "|")
						} else if (InStr(Var3, "Choose")) {
							Var4 := RegexReplace(Var4, "\|+", "|")				; Replace all pipe groups, this breaks empty choices
						}
						Loop Parse Var4, "|", " "
						{
							if (RegExMatch(Var2, "i)^tab[23]?$") && A_LoopField = "") {
							ChooseString := "`" Choose" A_Index - 1 "`""
							continue
							}
							ObjectValue .= ObjectValue = "[" ? ToExp(A_LoopField,1,1) : ", " ToExp(A_LoopField,1,1)
						}
						ObjectValue .= "]"
						LineResult .= ChooseString ", " ObjectValue
					}
				} else {
					LineResult .= ", " ToExp(Var4,1,1)
				}
			}
			if (Var1 != "") {
				LineResult .= ")"
			} else if (Var1 = "" && LineSuffix != "") {
				LineResult := RegExReplace(LineResult, 'm)^.*\.Opt\(""')
				LineSuffix := LTrim(LineSuffix, ", ")
			}

			if (var1 = "Submit") {
				; This should be replaced by keeping a list of the v variables of a Gui and declare for each "vName := oSaved.vName"
				if (gmGuiVList.Has(GuiNameLine)) {
					Loop Parse, gmGuiVList[GuiNameLine], "`n", "`r"
					{
						if (gmGuiVList[GuiNameLine])
							LineResult .= "`r`n" gIndent A_LoopField " := oSaved." A_LoopField
					}
				}
			}
		}
		if (var1 = "Add" && var2 = "ActiveX" && ControlName != "") {
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
			gmList_LblsToFunc[funcName] := ConvLabel('AG', lbl, params, funcName, {NeedleRegEx: "im)^(.*?)\b\QA_EventInfo\E\b(.*+)$", Replacement: "$1Info$2"})
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

	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')		; 2025-06-12, remove exclusion
	m := [], declare := []
	for key, val in gmMenuCBChecks
	{
		nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', key)					; target specific function name
		if (pos := RegExMatch(code, nTargFunc, &m)) {
			; target function found
			nDeclare	:= '(?im)' nCommon '\))(?<trail>.*)'
			nArgs		:= '(?im)' nCommon '\K\)).*'
			if (RegExMatch(m[], nDeclare, &declare)) {										; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail
				if (instr(argList, 'A_ThisMenuItem') && instr(argList, 'A_ThisMenuItemPos') && instr(argList, 'MyMenu'))
					continue																; skip converted labels
				newArgs		:= '(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:=""' . ((m.Args='') ? ')' : ', ' SubStr(argList,2))
				addArgs		:= RegExReplace(m[],		'\Q' argList '\E', newArgs,,1)		; replace function args
				code		:= RegExReplace(code, '\Q' m[] '\E', addArgs,,, pos)			; replace function within the code
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

	Mask_T(&code, 'C&S')	; 2025-10-10 - to fix missing params
	; add menu args to callback functions
	nCommon	:= '^\h*(?<fName>[_a-z]\w*+)(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)'
	nFUNC	:= RegExReplace(gPtn_Blk_FUNC, 'i)\Q(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|\E')					; 2025-06-12, remove exclusion
	nParams := '(?i)(?:\b(?:wParam|lParam|msg|hwnd)\b(\h*,\h*)?)+'
	m := [], declare := []
	for key, funcName in gmOnMessageMap
	{
		nTargFunc := RegExReplace(nFUNC, 'i)\Q?<fName>[_a-z]\w*+\E', funcName)							; target specific function name
		If (pos := RegExMatch(code, nTargFunc, &m)) {
			; target function found
			nDeclare	:= '(?im)' nCommon '\))(?<trail>.*)'
			nArgs		:= '(?im)' nCommon '\K\)).*'
			if (RegExMatch(m[], nDeclare, &declare)) {													; get just declaration line
				argList		:= declare.fArgG, trail := declare.trail
				LWS			:= TWS := ''
				if (RegExMatch(argList, '\((\h*)(.+?)(\h*)\)', &mWS)) {									; separate lead/trail ws in params
					LWS := mWS[1], params := mWS[2], TWS := mWS[3]										; to preserve lead/trail whitespace
				}
				cleanArgs	:= RegExReplace(argList, nParams)											; remove wParam,lParam,msg,hwnd from orig list
				newArgs		:= '(' LWS 'wParam, lParam, msg, hwnd'										; place wParam,lParam,msg,hwnd at front of list
				newArgs		.= ((cleanArgs ~= '^\(\h*\)$')												; if no extra params were present originally...
							? TWS ')'																	; ... just close param list
							: ', ' LTrim(SubStr(cleanArgs,2)))											; params were already present, add them to end of list
							addArgs		:= RegExReplace(m[],  '\Q' argList '\E', newArgs,,1)			; replace function args
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

	global gEarlyLine
	global gMenuList
	global gIndent
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
			} else if (RegexMatch(gOrig_ScriptStr, "\n(\s*)" Var4 ":\s")) {
				gmList_LblsToFunc[Var4] := ConvLabel('MN', Var4, 'A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *', FunctionName)
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
