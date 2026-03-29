/*
	2026-03-11 AMB, ADDED to V1toV2 Converter project - Provides real-time support for Dynamic GUI Handling
	2026-03-29 AMB, UPDATED:
					to allow dynamic creation of guis that have no id in v2 script
					to provide better [real-time] tracking of guis/ctrls between threads and func calls
					to provide support for dynamic Submit
					to provide support Destroy-commands that do not specify gui name/num


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
global A_DefaultGui	:= '1'																; public - can be used by converted v2 script
global A_Gui		:= ''																; public - can be used by converted v2 script
global mV2Gui		:= Map_C()															; public - used by converted v2 script - as Gui variables
						mV2Gui.DefineProp("__Item", {Set: _mapGuiSet})
						mV2Gui.DefineProp("__Item", {Get: _mapGuiGet})
global mV2GC		:= Map_C()															; public - used by converted v2 script - as Ctrl variables
						mV2GC.DefineProp("__Item", {Set: _mapCtrlSet})
						mV2GC.DefineProp("__Item", {Get: _mapCtrlGet})


;################################################################################
DestroyGui(guiID) {									; used by converted v2 script		; destroys specified gui, if possible
	Try mV2Gui[guiID].Destroy()
}
;################################################################################
fcV2GC(guiID, ctrlID) {								; used by converted v2 script		; finds/returns ctrl obj, if possible
; provides dynamic conversion for GuiControl and GuiControlGet...
; ... when ctrlID is a ClassNN string
; guiID can be blank - will use latest (real-time) Gui object in that case
	guiID	:= (guiID = gDynDefGuiNm) ? '1' : guiID										; make these equivilent - probably not needed
	ctrl	:= _V1toV2_FIND_CTRL(guiID, ctrlID)											; get ctrl obj associated with src Gui/Ctrl ID combo
	return	ctrl																		; return ctrl obj
}
;################################################################################
HasV2Gui(id) {										; used by converted v2 script		; determines whether ID has already been recorded or not
	if (mV2Gui.Has(id))																	; if ID has been recorded in gui list...
		return _guiExists(id)															; ... return the gui object if it exists
	; ID has not been recorded yet, but it may be an alternate ID
	if (key := _matchGuiIDToKey(id))													; if ID is an alternate to existing ID...
		return _guiExists(key)															; ... return the gui object if it exists
	return false																		; ID is not associated with any known object
}
;################################################################################
NewV2Gui(id,SetDefault:=false,params*) {			; used by converted v2 script		; creates new gui obj in real-time
	newGui := _clsV2Gui(id, params*)													; create a gui obj using custom class
	(SetDefault) && SetDefaultGui(newGui)												; set this new gui as default, if requested
	return newGui																		; return the gui obj
}
;################################################################################
SetDefaultGui(src) {								; used by converted v2 script		; sets passed gui as default gui
; 2026-03-29 AMB, ADDED
; Sets A_Gui and A_DefaultGui is real-time
; Also allows passing gui/ctrl obj details via func calls, or between threads
; src can be in many forms [obj, string, number, name, etc]
	; convert src to a guiName [and other details]
	_getSrcDetails(src, &guiObj:='', &guiName:='', &ctrlObj:='', &ctrlType:='')			; extract details from src
	; push gui name to global variables
	global A_Gui := guiName																; set A_Gui even when guiName is empty
	if (guiName) {																		; if guiName is NOT empty...
		global A_DefaultGui	:= guiName													; ... set only when guiName is NOT empty
	}
}
;################################################################################
V2DynSubmit(guiName,hide:=1) {						; used by converted v2 script		; allows Submit to work with dynamic vars
	global																				; must be global, so %var%s can be updated globally...
	local goodVars, badVars, oSaved, val												; ... but UNDO global for these
	goodVars := badVars	:= ''															; ini, but may not be used
	oSaved	:= guiName.Submit(hide)														; perform normal submit for passed gui
	for var, val in oSaved.OwnProps() {													; for each key (var) in Submit obj...
		try {																			; ... prevent real-time errors when vars don't exist
			%var% := val																; ... assign vals to global ctrl vars (behind the scenes)
			goodVars .= var ','															; ... debug purposes
		} catch {																		; catch assignment errors
			badVars .= var ','															; ... make list of vars that do not exist (or cause errors)
		}
	}
	goodVars := Trim(goodVars, ', '), badVars := Trim(badVars,  ', ')					; trim debug strings
	;MsgBox "Updated:`n[" goodVars "]`n`nRejected:`n[" badVars "]"						; debug
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
		ehList[ctrlKey] := ehFunc														; ... save current event for this control
		mV2GC[[guiKey,ctrlID]].OnEvent(ctrlEvent,ehFunc)								; ... register/enable event handler for cur ctrl
	}
	; for -g, but might not be needed
	if (!enable) {																		; if cur event handler should be DISABLED (-g)...
		try mV2GC[[guiKey,ctrlID]].OnEvent(ctrlEvent,ehFunc,0)							; ... DISABLE cur event handler (might be redundant)
	}
}

;################################################################################
;#############################  INTERNAL USE ONLY  ##############################
;################################################################################
class V1V2_UNKNOWN_GUI
{
}
class V1V2_UNKNOWN_CTRL
{
}
;################################################################################
Class Map_C extends Map {
; WARNING: MAPS DO NOT CONSIDER NUMERIC STRINGS IDENTICAL TO NUMBER VALUES
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
; WARNING: MAPS DO NOT CONSIDER NUMERIC STRINGS IDENTICAL TO NUMBER VALUES
	local oSet := Map.Prototype.GetOwnPropDesc("__Item").Set
	try key	:= string(key)																; ensure key is a string
	key		:= (key = '' && Type(value) = '_clsV2Gui') ? string(value.name) : key		; if key has no value, set it to the guiName being passed
	key		:= _V1toV2_FIND_GUI_KEY(key)												; get map key associated with key, if possible
	;(!key)	&& MsgBox A_ThisFunc "`nSETTING GUI, BUT KEY HAS NO VALUE"					; debug popup
	oSet.Call(thisMap, value, key)														; set gui obj (value) for key (key may be hwnd)
	return value	; gui obj															; return gui obj that was passed
}
;################################################################################
_mapGuiGet(thisMap, key) {																; allows interaction with Gui Map for GET
; WARNING: MAPS DO NOT CONSIDER NUMERIC STRINGS IDENTICAL TO NUMBER VALUES
	local oGet := Map.Prototype.GetOwnPropDesc("__Item").Get
	try key	:= string(key)																; ensure key is a string
	key		:= _V1toV2_FIND_GUI_KEY(key)												; get map key associated with key, if possible
	if (thisMap.has(key))																; if map has matching key...
		return oGet.Call(thisMap, key)													; ... return the associated gui obj
	; not found in this map, check external map
	if (guiObj := _guiExists(key)) {													; if key is listed in external map list...
		mV2Gui[key] := guiObj															; ... save it to this map (indirectly, using set)
		return guiObj																	; ... return the associated gui obj
	}
	return V1V2_UNKNOWN_GUI																; unable to identify gui object
}
;################################################################################
_mapCtrlSet(thisMap, value, key) {														; allows interaction with Ctrl Map for SET
; WARNING: MAPS DO NOT CONSIDER NUMERIC STRINGS IDENTICAL TO NUMBER VALUES
	local oSet := Map.Prototype.GetOwnPropDesc("__Item").Set
	try key := string(key)																; ensure key is a string
	if (Type(key) = "Array" && key.Length) {											; if key is actually an array...
		guiName := key[1], ctrlName := key[2]											; separate guiName and CtrlName
		key := _V1toV2_FIND_CTRL_KEY(guiName,ctrlName)									; ... get map key associated with details passed in array
	}
	oSet.Call(thisMap, value, key)														; add ctrl obj to map using map key
	return value	; ctrl obj															; return ctrl obj that was passed
}
;################################################################################
_mapCtrlGet(thisMap, key) {																; allows interaction with Ctrl Map for GET
; WARNING: MAPS DO NOT CONSIDER NUMERIC STRINGS IDENTICAL TO NUMBER VALUES
	local oGet := Map.Prototype.GetOwnPropDesc("__Item").Get
	try key := string(key)																; ensure key is a string
	if (Type(key) = "Array" && key.Length) {											; if key is actually an array (and not empty)...
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
_getEventName(ctrl) {																	; TODO - MIGHT NOT BE COMPLETE
	clickCtrls	:= '(?i)BUTTON|CHECKBOX|LINK|RADIO|PIC|PICTURE|STATUSBAR|TEXT'			; controls that respond to CLICK
	ctrlType	:= RegExReplace(Type(ctrl), '(?i)^GUI\.(\w+)$', '$1')					; extract ctrl name from src ctrl
	if (ctrlType ~= clickCtrls)															; for ctrls that respond to click...
		return "Click"																	; ... click event
	return 'Change'																		; default	event
}
;################################################################################
_getSrcDetails(src,&guiObj:='',&guiName:='',&ctrlObj:='',&ctrlType:='')
{
; 2026-03-29 AMB, ADDED to support SetDefaultGui() and A_DefaultGui update
	srcType := Type(src), guiName := ''													; ini
	if (IsObject(src)) {																; if src is an object...
		if (srcType = '_clsV2Gui') {													; if src is gui created by this file...
			gn := string(src.name), guiName := gn										; ... update guiName
		} else if (RegExMatch(srcType, '(?i)^GUI\.(.+)$', &m)) {						; if src is a ctrl obj
			ctrlType := m[1], guiObj := src.Gui, gn := string(guiObj.name)				; ... get ctrlType, guiObj, guiName
			if (mV2Gui.Has(gn)) {														; ... if gui is found in map...
				guiName := gn															; ...	 update guiName
			} else {																	; ... not found in map...
				msg := A_ThisFunc
				msg .= '`nDefault Gui is OBJECT but NOT found in map list'
				msg .= '`nsrcType := ' srcType '`nguiName := ' gn
				MsgBox msg																; ... debug popup
			}
		}
	} else if (IsNumber(src) || srcType = 'integer') {									; if src is a number
		if (src > 0 && src <= 99) {														; if 1-99, is a gui name
			src := string(src), guiName := src											; ... update guiName
		} else { ; larger than 99														; should be hwnd
			src := string(src), guiName := src											; ... update guiName
			;MsgBox "Default Gui is a NUMBER and may be an HWND`n" src					; ... debug
		}
	} else if (!IsNumber(src) && srcType = 'string') {									; if src is string, and NOT empty...
		guiName := src																	; ... update guiName
	} else {																			; if src type is unknown...
		MsgBox A_ThisFunc "`nUNKNOWN DATA TYPE [" srcType "]"							; ... debug popup
	}
}
;################################################################################
_guiExists(id) {																		; determines whether ID points to an existing (live) gui obj
	if (!obj := _clsV2Gui.GetGuiObj[id])												; if ID is not associated with a gui object...
		return false																	; ... notify caller
	try {
		hwnd := obj.hwnd																; try to get the hwnd for the gui
	}
	catch as e {																		; if error (hwnd does not exist)...
		_clsV2Gui.DelGui(id)															; ... remove the gui object from list
		return false																	; ... ID and GUI are no longer valid, notify caller
	}
	return obj																			; ID has been recorded and gui obj exists - return gui obj
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
	guiKey	:= (guiID) ? guiID : _V1toV2_FIND_GUI_KEY()									; if gui NOT specified, get CURRENT LIVE GUI
	guiKey	:= (guiKey = gDynDefGuiNm) ? '1' : guiKey									; make these equivilent (probably not needed)
	guiObj	:= mV2Gui[guiKey]															; use guiKey to get a matching guiObj from map (cross-ref)
	for ctrlHwnd, ctrl in guiObj {														; for each ctrl within guiObj...
		cleanText := Trim(RegExReplace(ctrl.Text, '\W+'))								; ... make sure ctrlText is formatted
		switch ctrlID, 0 {																; ... match ctrlID with...
			case ctrlHwnd: 		return ctrl												; ... matched ctrl handle
			case ctrl.ClassNN:	return ctrl												; ... matched ctrl ClassNN (ctrlType + seqNumber)
			case ctrl.Name:		return ctrl												; ... matched ctrl varName or custom name
			case ctrl.Text:		return ctrl												; ... matched ctrl text/caption string
			case cleanText:		return ctrl												; ... matched clean version of ctrl text/caption string
			;case Pic file name	; TODO if .Text does not cover this
			default: 			; MsgBox "DEFAULT: [" ctrlID "]`n[" guiKey "]"
		}
	}
	return ''																			; ctrl NOT FOUND
}
;################################################################################
_V1toV2_FIND_GUI_KEY(id:='') {															; attempts to get common gui key associated with id
	(id='') && (id := A_DefaultGui)														; if id empty, set it to current default gui id
	output := id																		; ini output
	if (key := _matchGuiIDToKey(id))													; if guikey is found (using cross-ref check)
		output := key																	; ... set output to matching key
	return output																		; return id or key, as appropriate
}
;################################################################################
class _clsV2Gui extends Gui {															; allows recording of details when guis are created or controls are added
	_ctrlList := []																		; list of controls for gui obj
	__new(id, p*) {																		; constructor
		super.__New(p*)																	; create gui obj using super Gui()
		; TODO - maybe id should only be applied if .name is empty?
		if (!id)																		; if id is not specified...
			id := (!_clsV2Gui.HasDefaultGui()) ? string('1') : this.hwnd				; ... set id to special default 1, or the gui hwnd
		this.name := id																	; use built-in name prop for id purposes
		_clsV2Gui.AddGuiObj(id,this)													; add gui obj to static map
	}
	;############################################################################
	Add(p*) {										; used by converted v2 script		; provides a way to track ctrl creation for gui objs
		; ctrl.name is set automatically when ctrl has a variable name
		try {																			; TRY - in case ctrl was already added
			newCtrl	:= super.add(p*)													; use super ADD
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
				MsgBox 	msg																; debug popup
			}
			return newCtrl																; return the new ctrl obj
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
	Static HasDefaultGui() {															; returns whether a special default gui 1 has been created/recorded
		return this._v2GuiList.Has(string('1'))											; ensure string data type
	}
	;############################################################################
	Static AddGuiObj(id, obj) {															; adds gui to gui list
		this._v2GuiList[String(id)] := obj												; ensure string data type
	}
	;############################################################################
	Static GetGuiObj[id] {																; identifies/returns gui object that matches id
		get {
			id := string(id)															; ensure string data type
			if (this._v2GuiList.Has(id))												; if id is found in gui list
				return this._v2GuiList[id]												; ... return associated gui obj
			return false	; TODO - change output to custom error class?				; unknown gui
		}
	}
	;############################################################################
	Static DelGui(id) {																	; removes matching gui object from list (if present)
		try this.v2GuiList.Delete(id)
	}
}