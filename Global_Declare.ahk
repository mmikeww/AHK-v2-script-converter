; 2025-12-10 AMB ADDED - to provide organization for global definitions

; these require declaration prior to Includes
global	dbg					:= 0
global	gV2Conv				:= true								; for testing separate V1,V2 conversions
global	gFilePath			:= ''								; TEMP, for testing
global	gLineFillMsg		:= 'V1toV2_LineFill := true `; remove me after inspection'	; 2025-12-10 ADDED
global	  gmAhkKeywdsToRename,	gmAhkLoopRegKeywds
		, gAhkCmdsToRemoveV1,	gAhkCmdsToRemoveV2
		, gmAhkCmdsToConvertV1, gmAhkCmdsToConvertV2
		, gmAhkFuncsToConvert,	gmAhkMethsToConvert, gmAhkArrMethsToConvert
;################################################################################
#Include lib/ClassOrderedMap.ahk
#Include lib/dbg.ahk
#Include Interface.ahk											; 2026-01-21
#Include Convert/MaskCode.ahk									; 2024-06-26 - support for masking
#Include Convert/Scope.ahk										; 2025-11-01 - support for scope
#Include Convert/AhkLangConv.ahk								; 2025-12-24 - to organize v1 to v2 cmd/func convert funcs
#Include Convert/1Commands.ahk
#Include Convert/2Functions.ahk
#Include Convert/3Methods.ahk
#Include Convert/4ArrayMethods.ahk
#Include Convert/5Keywords.ahk
#Include Convert/Conversion_CLS.ahk								; 2025-06-12 - future support of Class version
#Include Convert/ContSections.ahk								; 2025-06-22 - support for continuation sections
#Include Convert/SplitConv/ConvV1_Funcs.ahk						; 2025-07-01 - support for separated conversion
#Include Convert/SplitConv/ConvV2_Funcs.ahk						; 2025-07-01 - support for separated conversion
#Include Convert/SplitConv/SharedCode.ahk						; 2025-07-01 - code shared for v1 or v2 conversion
#Include Convert/SplitConv/PseudoHandling.ahk					; 2025-07-01 - temp while separating dual conversion
#Include Convert/SplitConv/LabelAndFunc.ahk						; 2025-07-06
#Include Convert/SplitConv/GuiAndMenu.ahk						; 2025-07-06
;################################################################################
setGlobals() {													; for globals that are reset with each new conversion
	Global
	; func and label
	gAllFuncNames			:= ''								; 2024-07-07 - comma-deliminated string holding the names of all functions
	gAllClassNames			:= ''								; 2024-10-08 - comma-deliminated string holding the names of all classes
	gAllV1LabelNames		:= ''								; 2024-07-09 - comma-deliminated string holding the names of all v1 labels
	gmAllV2LablNames		:= Map_I()							; 2024-07-07 - map holding v1 labelNames (key) and their new v2 label/FuncName (value)
	gmList_LblsToFunc		:= Map_I()							; 2025-10-05 - replaces gaList_LblsToFuncO and gaList_LblsToFuncC
	gmList_GosubToFunc		:= Map_I()							; 2025-10-05 - tracks gosubs that need to be converted to func calls
	gmList_HKCmdToFunc		:= Map_I()							; 2025-10-12 - tracks funcs that should be called using 'hotkey' cmd
	gmByRefParamMap			:= Map_I()							; Map of FuncNames and ByRef params
	gmAltLabel				:= Map_I()							; map of labels that point to same reference
	gFuncParams				:= ''
	gmList_GotoLabel		:= Map_I()
	; gui and menu
	gMenuBarName			:= ''								; 2024-07-02 - holds the name of the main gui menubar
	gMenuList				:= '|'
	gmMenuCBChecks			:= Map_I()							; 2024-06-26 - for fix #131
	gGuiActiveFont			:= ''
	gGuiControlCount		:= 0
	gmGuiCtrlObj			:= Map_I()							; Create a map to return the object of a control
	gmGuiCtrlType			:= Map_I()							; Create a map to return the type of control
	gmGuiFuncCBChecks		:= Map_I()							; for gui funcs
	gGuiList				:= '|'
	gGuiNameDefault			:= 'myGui'
	gmGuiVList				:= Map_I()							; Used to list all variable names defined in a Gui
	gUseLastName			:= False							; Keep track of if we use the last set name in gGuiList

	;gOScriptStr			:= []								; array of all the lines (prior to being an object)
	gOScriptStr				:= Object()							; now a ScriptCode class object
	gaScriptStrsUsed		:= Array()							; Keeps an array of interesting strings used in the script
	gV1Line					:= ''								; portion of line to process, prior to processing, will not include trailing comment (2026-01-01 changed Name)
	gO_Index				:= 0								; current index of the lines
	gIndent					:= ''
	gSingleIndent			:= ''
	gfNewScope				:= 0								; 2025-12-24 - tracks scope

	gEOLComment_Cont		:= []								; 2025-05-24 - fix for #296 - comments for continuation sections
	gEOLComment_Func		:= ''								; _Funcs can use this to add comments at EOL
	gNL_Func				:= ''								; _Funcs can use this to add New Previous Line
	gfrePostFuncMatch		:= False							; _Funcs can use this to know their regex matched

	goWarnings				:= Object()							; global object [with props] to keep track of warnings to add, see FinalizeConvert()
	gaList_PseudoArr		:= Array()							; list of strings that should be converted from pseudoArray to Array
	gaList_MatchObj			:= Array()							; list of strings that should be converted from v1 Match Object to v2 Match Object

	gmOnMessageMap			:= Map_I()							; list of OnMessage listeners
	gmVarSetCapacityMap		:= Map_I()							; list of VarSetCapacity variables, with definition type
	gfLockGlbVars			:= False							; flag used to prevent global vars from being changed

	gLVNameDefault			:= 'LV'
	gTVNameDefault			:= 'TV'
	gSBNameDefault			:= 'SB'
	gaFileOpenVars			:= []								; 2025-10-12 - callection of FileOpen object names
	gaZipTagIDs				:= []								; 2025-11-30 - TagID list for line compression (Zip,Unzip)

	; reset Static vars in multiple classes						; required for Scope support and unit testing
	clsMask.Reset()												; 2025-11-01 - ADDED as part of Scope support, unit testing
	clsNodeMap.Reset()											; 2025-11-01 - ADDED as part of Scope support, unit testing
	clsSection.Reset()											; 2025-11-01 - ADDED as part of Scope support, unit testing
	clsScopeSect.Reset()										; 2025-11-01 - ADDED as part of Scope support, unit testing
}
;################################################################################
class NL {
; 2025-12-10 - dynamic newLine that includes current indent
	Static CRLF		=> ('`r`n' . (IsSet(gIndent) ? gIndent : ''))
}
;################################################################################
Class Map_I extends Map {
; 2025-11-28 - custom Map with case-sensitivity disabled by default
	caseSense		:= 0										; disable case-sensitivity by default
	KeysToString	=> Map_I._Join(this		 	)				; return list of object keys
	KeyValPairs		=> Map_I._Join(this,1		)				; return list of {key:val}	pairs
	LabelMap		=> Map_I._Join(this,1,'=>'	)				; return list of {key=>val} pairs
	;#############################################################################
	Static _Join(obj,kv:=0,d:=':',s:='') {						; 2025-11-30 - @rommmcek
	for k,v in obj
		s .= ((kv) ? k d v : k) ', '
	return (s:=Trim(s,', '))?((kv)?'{' s '}':s):''
	}
}
