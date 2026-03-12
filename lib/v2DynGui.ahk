/*
	2026-03-11 AMB, ADDED to V1toV2 Converter project - Provides real-time support for Dynamic GUI Handling

	  Instructions: (See docs: https://www.autohotkey.com/docs/v2/Scripts.htm#lib)

		Place v2DynGui.ahk (this file) in one of the following locations/paths:
		  FOR LOCAL SCRIPT ACCESS:
			 -->	A_ScriptDir\Lib\
		  FOR SYSTEM-WIDE SCRIPT ACCESS:
			 -->	C:\Users\USERNAME\OneDrive\Documents\AutoHotKey\Lib\
		  OR -->	C:\Users\USERNAME\Documents\AutoHotKey\Lib\
*/

global gDynMapGui	:= 'mV2Gui'
global gDynMapGC	:= 'mV2GC'
global gDynFncGC	:= 'fcV2GC'
global gDynEH		:= 'V2EH'
global gDynSubmit	:= 'V2DynSubmit'
global gDynDefGuiNm	:= (IsSet(gDynDefGuiNm)) ? gDynDefGuiNm : 'nnGui'					; public - default gui name for dynamic gui handling
global A_DefaultGui	:= '1'																; public - used by converted v2 script (BUT, holds a guiID, rather than a gui obj)
global A_Gui		:= ''																; public - used by converted v2 script (BUT, holds a guiID, rather than a gui obj)
global gCurGuiID	:= ''																; public - used by converted v2 script
global mV2Gui		:= Map_C()															; public - used by converted v2 script
						mV2Gui.DefineProp("__Item", {Set: _mapGuiSet})
						mV2Gui.DefineProp("__Item", {Get: _mapGuiGet})
global mV2GC		:= Map_C()															; public - used by converted v2 script
						mV2GC.DefineProp("__Item", {Set: _mapCtrlSet})
						mV2GC.DefineProp("__Item", {Get: _mapCtrlGet})
;################################################################################
class V1V2_UNKNOWN_GUI
{
}
class V1V2_UNKNOWN_CTRL
{
}
;################################################################################
Class Map_C extends Map {
; custom Map with case-sensitivity disabled by default, and custom outputs
	caseSense		:= 0																; disable case-sensitivity by default
	KeysToString	=> Map_C._Join(this,0)												; return list of object keys
	KeyValPairs		=> Map_C._Join(this,1)												; return list of {key:val}	pairs
	Static _Join(thisMap,kv:=0,d:=':',s:='') {											; @rommmcek (thanks!)
		for k,v in thisMap
			s .= ((kv) ? k d v : k) ', '
		return (s:=Trim(s,', '))?((kv)?'{' s '}':s):''
	}
}
;################################################################################
_mapGuiSet(thisMap, value, key) {														; allows interaction with Gui Map for SET
	local oSet := Map.Prototype.GetOwnPropDesc("__Item").Set
	key := _V1toV2_FIND_GUI_KEY(key)													; get map key associated with 'source key' [guiID]
	oSet.Call(thisMap, value, key)														; add gui obj to map using map key
	return value																		; return gui obj that was passed as src (why not?)
}
;################################################################################
_mapGuiGet(thisMap, key) {																; allows interaction with Gui Map for GET
	local oGet := Map.Prototype.GetOwnPropDesc("__Item").Get
	key := _V1toV2_FIND_GUI_KEY(key)													; get map key associated with 'source key' [guiID]
	if (thisMap.has(key))																; if map has matching key...
		return oGet.Call(thisMap, key)													; ... return the associated gui obj
	return V1V2_UNKNOWN_GUI																; unable to identify gui object
}
;################################################################################
_mapCtrlSet(thisMap, value, key) {														; allows interaction with Ctrl Map for SET
	local oSet := Map.Prototype.GetOwnPropDesc("__Item").Set
	if (Type(key) = "Array")															; if 'src key' [ctrlID] is actually an array...
		key := _V1toV2_FIND_CTRL_KEY(key[1],key[2])										; ... get map key associated with details passed in array
	oSet.Call(thisMap, value, key)														; add ctrl obj to map using map key
	return value																		; return ctrl obj that was passed as src (why not?)
}
;################################################################################
_mapCtrlGet(thisMap, key) {																; allows interaction with Ctrl Map for GET
	local oGet := Map.Prototype.GetOwnPropDesc("__Item").Get
	if (Type(key) = "Array" && key.Length) {											; if 'src key' [ctrlID] is actually an array (and not empty)...
		guiName := key[1], ctrlName := key[2]											; separate guiName and CtrlName
		ctrlKey := _V1toV2_FIND_CTRL_KEY(guiName,ctrlName)								; get map key associated with details passed in array
		if (thisMap.has(ctrlKey))														; if map has a key that matches src...
			return oGet.Call(thisMap, ctrlKey)											; ... return the associated ctrl obj
	} else {	; not an array															; if not an array...
		if (thisMap.has(key))															; ... AND map has a key that matches src...
			return oGet.Call(thisMap, key)												; ...	return the associated ctrl obj
	}
	return V1V2_UNKNOWN_CTRL															; unable to identify ctrl object
}
;################################################################################
_V1toV2_FIND_CTRL_KEY(guiID:="", ctrlID:="") {											; retrieves OR creates a ctrl key/id based on input
; TODO - MIGHT NEED BETTER DESIGN FOR KEY-GENERATION METHOD, WHEN CTRL NOT FOUND
	guiKey := (guiID) ? guiID : _V1toV2_FIND_GUI_KEY()									; get Gui identifier
	if (ctrl := _V1toV2_FIND_CTRL(guiKey,ctrlID)) {										; if able to get live ctrl object...
		ctrlKey	:= guiKey "_" ctrl.ClassNN												; ... use ClassNN to identify ctrl
	} else {																			; if ctrl object not found... (may not have been created yet)
		ctrlKey	:= (ctrlID) ? guiKey "_" ctrlID : "1"	; POOR/TEMP DESIGN				; ... create key based on input params
	}
	return ctrlKey																		; return key
}
;################################################################################
_V1toV2_FIND_CTRL(guiID:="",ctrlID:="") {												; attempts to identify/return a live ctrl object that matches input
; Performs cross-reference check to identify/return control object
; can match ctrl-attributes that change in real-time
	guiKey	:= (guiID) ? guiID : _V1toV2_FIND_GUI_KEY()									; if gui not specified, get CURRENT LIVE GUI
	guiKey	:= (guiKey = gDynDefGuiNm) ? '1' : guiKey									; make these equivilent (probably not needed)
	guiObj	:= mV2Gui[guiKey]															; use guiKey to get a matching guiObj from map (cross-ref)
	for ctrlHwnd, ctrl in guiObj {														; for each ctrl within guiObj...
		cleanText := Trim(RegExReplace(ctrl.Text, '\W+'))								; ... make sure ctrlText is formatted
		switch ctrlID, 0 {																; match ctrlID with...
			case ctrlHwnd: 		return ctrl												; matched ctrl handle
			case ctrl.ClassNN:	return ctrl												; matched ctrl ClassNN (ctrlType + seqNumber)
			case ctrl.Name:		return ctrl												; matched ctrl varName or custom name
			case ctrl.Text:		return ctrl												; matched ctrl text/caption string
			case cleanText:		return ctrl												; matched clean version of ctrl text/caption string
			;case Pic file name	; TODO if .Text does not cover this
			default: 			; MsgBox "DEFAULT: [" ctrlID "]`n[" guiKey "]"
		}
	}
	return ''																			; ctrl NOT FOUND
}
;################################################################################
_V1toV2_FIND_GUI_KEY(id:='',setCurID:=true) {											; attempts to get common gui key associated with id
	global gCurGuiID, A_Gui, A_DefaultGui
	if (id='')																			; if id was not provided...
		id := gCurGuiID																	; ... set it to current gui id
	output := id																		; ini output
	if (key := _matchGuiIDToKey(id)) {													; if guikey is found (using cross-ref check)
		output := key																	; ... [output key]
	}
	(setCurID) && (A_Gui := A_DefaultGui := gCurGuiID := id)							; update global vars if requested
	return output																		; return id or key, as appropriate
}
;################################################################################
_matchGuiIDToKey(id) {																	; provides cross-ref gui matching for src id
	for key, guiObj in mV2Gui {															; for each gui object in list...
		if (key = id || guiObj.hwnd = id)												; ... if key or hwnd matches ID...
			return key																	; ... 	return key
	}
	return false																		; no match found
}
;################################################################################
_guiExists(id) {																		; determines whether ID points to an existing (live) gui obj
	if (!obj := _clsV2Gui.GetGuiObj[id]) {												; if ID is not associated with a gui object...
		try mV2Gui.Delete(id)															; ... remove the gui ID from list
		return false																	; ... notify caller
	}
	try {
		hwnd := obj.hwnd																; try to get the hwnd for the gui
	}
	catch as e {																		; if error (hwnd does not exist)...
		_clsV2Gui.DelGui(id)															; ... remove the gui object from list
		try mV2Gui.Delete(id)															; ... remove the gui ID     from list
		return false																	; ... ID and GUI are no longer valid, notify caller
	}
	return obj																			; ID has been recorded and gui obj exists - return gui obj
}
;################################################################################
fcV2GC(guiID, ctrlID) {								; used by converted v2 script		; finds/returns ctrl obj, if possible
; provides dynamic conversion for GuiControl and GuiControlGet...
; ... when ctrlID is a ClassNN string
; guiID can be blank - will use latest (real-time) Gui object in that case
	guiID	:= (guiID = gDynDefGuiNm) ? '1' : guiID										; make these equivilent - probably not needed
	ctrl	:= _V1toV2_FIND_CTRL(guiID, ctrlID)											; get ctrl obj associated with src Gui/Ctrl ID combo
	return	ctrl
}
;################################################################################
HasV2Gui(id) {										; used by converted v2 script		; determines whether ID has already been recorded or not
	if (mV2Gui.Has(id)) {																; if ID has been recorded in gui list...
		return _guiExists(id)															; ... return the gui object if it exists
	}
	; ID has not been recorded yet, but it may be an alternate ID
	if (key := _matchGuiIDToKey(id)) {													; if ID is an alternate to existing ID...
		return _guiExists(key)															; ... return the gui object if it exists
	}
	return false																		; ID is not associated with any known object
}
;################################################################################
NewV2Gui(id, params*) {								; used by converted v2 script		; provides the ability to track gui obj creation in real-time
	new_gui	:= _clsV2Gui(id, params*)													; create a gui obj using custom class
	return	new_gui																		; return the gui obj
}
;################################################################################
V2DynSubmit(guiName,hide:=1) {						; used by converted v2 script		; allows Submit to work with dynamic vars
	global																				; func vars must be global, so script vars are updated in real-time
	badVars	:= ''																		; ini, but may not be used
	oSaved	:= guiName.Submit(hide)														; perform normal submit
	for var, val in oSaved.OwnProps() {													; for each key (var) in Submit obj...
		try {																			; ... prevent real-time errors when vars don't exist
			%var% := val																; ... assign vals to global ctrl vars (behind the scenes)
		} catch {																		; catch assignment errors
			badVars .= var ","															; ... make list of vars that do not exist (or cause errors)
		}
	}
	if (badVars := Trim(badVars, ', ')) {												; may return list to caller in the future
		;MsgBox "[" badVars "]"															; debug, if needed
	}
	return (badVars='')																	; return success or failure (why not?)
}
;################################################################################
V2EH(guiID,ctrlID,ctrlEvent,ehFunc,enable:=1) {		; used by converted v2 script		; to allow simulation of v1 [GuiControl, +/-g, ctrlID, FuncObj]
	static ehList := Map()																; allow only 1 event handler, per ctrl, at a time (simulate v1)
	ctrlID		:= Trim(RegExReplace(ctrlID, '\W+'))									; remove any non-word chars from ctrlID
	ctrl		:= _V1toV2_FIND_CTRL(guiID,ctrlID)	; guiID can be empty				; get real-time/live control OBJECT
	ctrlEvent	:= (ctrlEvent) ? ctrlEvent : _getEventName(ctrl)						; determine event name for control
	ctrlGui		:= ctrl.gui, guiKey := _matchGuiIDToKey(ctrlGui.hwnd)					; get gui key (parent)
	ctrlKey		:= _V1toV2_FIND_CTRL_KEY(guiKey,ctrlID)									; get ctrlKey
	prevEH		:= (ehList.Has(ctrlKey)) ? ehList[ctrlKey] : false						; get	  previous ev handler for cur ctrl
	(prevEH)	&& mV2GC[[guiKey,ctrlID]].OnEvent(ctrlEvent,prevEH,0)					; disable previous ev handler for cur ctrl
	param1		:= 'Normal'																; should this always be "Normal" ? (simulate v1 ?)
	if (!ehFunc)																		; if event handler was not provided...
		return																			; ... exit now (probably just wanted disable/remove all)
	ehFunc		:= ((Type(ehFunc)='BOUNDFUNC') ? ehFunc : ehFunc.Bind(param1))			; add binding as needed
	if (enable) {																		; if cur handler should be enabled...
		ehList[ctrlKey] := ehFunc														; save current event for this control
		mV2GC[[guiKey,ctrlID]].OnEvent(ctrlEvent,ehFunc)								; register/enable event handler for cur ctrl
	}
	; for -g, but might not be needed
	if (!enable) {																		; if cur event handler should be DISABLED (-g)...
		try mV2GC[[guiKey,ctrlID]].OnEvent(ctrlEvent,ehFunc,0)							; ... DISABLE cur event handler (might be redundant)
	}
}
;################################################################################
_getEventName(ctrl) {																	; TODO - MIGHT NOT BE COMPLETE
	clickCtrls	:= '(?i)BUTTON|CHECKBOX|LINK|RADIO|PIC|PICTURE|STATUSBAR|TEXT'			; controls that respond to CLICK
	ctrlType	:= RegExReplace(Type(ctrl), '(?i)^GUI\.(\w+)$', '$1')					; extract ctrl name from src ctrl
	if (ctrlType ~= clickCtrls)															; for ctrls that respond to click...
		return "Click"																	; ... click event
	return 'Change'																		; default	event
}
;################################################################################
class _clsV2Gui extends Gui {															; allows recording of details when guis are created or controls are added
	_ctrlList := []																		; list of controls for gui obj
	__new(id, p*) {																		; constructor
		super.__New(p*)																	; create gui obj
		; TODO - maybe id should only be applied if .name is empty?
		this.name := id																	; use built-in name prop for id purposes (TODO - should this be changed?)
		_clsV2Gui.AddGuiObj(id,this)													; add gui obj to static map
	}
	;############################################################################
	Add(p*) {										; used by converted v2 script		; provides a way to track ctrl creation for gui objs
		; ctrl.name is set automatically when ctrl has a variable name
		try {																			; TRY - in case ctrl was already added
			newCtrl	:= super.add(p*)													; use built-in ADD
			this._ctrlList.Push(newCtrl)												; save ctrl to array
			if (debug:=0) {																; used for debugging
				msg		:= ''
				msg		.= 'Type:`t'		newCtrl.Type
				msg		.= '`nClassNN:`t'	newCtrl.ClassNN
				msg		.= '`nGUI:`t'		newCtrl.GUI.Name
				msg		.= '`nHWND:`t'		newCtrl.HWND
				msg		.= '`nName:`t'		newCtrl.Name
				msg		.= '`nText:`t'		newCtrl.Text
				msg		.= '`nValue:`t'		newCtrl.Value
				MsgBox 	msg
			}
			return newCtrl																; return the new control object
		}
		catch as e {																	; if error...
			if (!InStr(e.message, 'control with this name already exists'))	{			; ... if UNANTICIPATED ERROR
				MsgBox "ERROR in " A_ThisFunc "`n`n" e.message							; ... notify user
				return false															; ... return fatal result
			}
			; control ALREADY EXISTS...
			ctrlName := e.Extra															; ... get ctrl name, from error obj
			if (ctrl := this._ctrlObjFromName(ctrlName))								; ... if ctrl found in list
				return 	ctrl															; ...	return that ctrl object
		}
		return false ; TODO - change output to custom error class?						; unable to create/identify control
	}
	;############################################################################
	_ctrlObjFromID(classNN) {															; identifies/returns ctrl object from ClassNN
		for idx, ctrl in this._ctrlList {												; for each ctrl in ctrl list...
			if (ctrl.ClassNN = classNN)													; ... if ctrl matches classNN...
				return ctrl																; ...	return that ctrl
		}
		return false  ; TODO - change output to custom error class?						; unknown control
	}
	;############################################################################
	_ctrlObjFromName(name) {															; identifies/returns ctrl object from name
		for idx, ctrl in this._ctrlList {												; for each ctrl in ctrl list...
			if (ctrl.Name = name)														; ... if ctrl matches name...
				return ctrl																; ...	return that ctrl
		}
		return false  ; TODO - change output to custom error class?						; unknown control
	}
	;############################################################################
	Static _v2GuiList := Map_C()														; keeps track of created Guis during script execution
	;############################################################################
	Static AddGuiObj(id, obj) {															; adds gui to gui list
		this._v2GuiList[id] := obj
	}
	;############################################################################
	Static GetGuiObj[id] {																; identifies/returns gui object that matches id
		get {
			if (this._v2GuiList.Has(id))												; if id is found in gui list
				return this._v2GuiList[id]												; return associated gui obj
			return false	; TODO - change output to custom error class?				; unknown gui
		}
	}
	;############################################################################
	Static DelGui(id) {																	; removes matching gui object from list (if present)
		try this.v2GuiList.Delete(id)
	}
}