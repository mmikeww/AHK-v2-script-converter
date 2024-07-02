#NoEnv
#MaxMem 4095
#SingleInstance Off
SetWorkingDir %A_ScriptDir%

; __________________________________________________________________________________________________
; copy the contents of template.html to temp.html
; and then pre-populate the temp.html file with either the cmdline arg files or with our default values
; then the wb control will load temp.html
params := getArgs()

if (params[0] > 0) {     ; if command line args are passed
	SplitPath, % params[1], file1name
	SplitPath, % params[2], file2name
	srcFilePath	:= params[1]	; 2024-07-01 ADDED, AMB
	lhsvalue	:= "FileRead('" . RegExReplace(params[1], "\\", "/") . "')"
	rhsvalue	:= "FileRead('" . RegExReplace(params[2], "\\", "/") . "')"
	instructions := "&nbsp;"
} else {
	lhsvalue	:= "'the quick red fox jumped\nover the hairy dog\n\nhello world'"
	rhsvalue	:= "'the quick brown fox jumped\nover the lazy dog\n\nhello big world'"
	file1name	:= ""
	file2name	:= ""
	instructions := "First clear the boxes, then just drop a file in each side"
}
;msgbox, %file1name%`n%file2name%
;msgbox, % lhsvalue "`n" rhsvalue
FileRead, htmlcontents, template.html
;msgbox, %htmlcontents%
StringReplace, htmlcontents, htmlcontents, exo_lhsvalue_placeholder, %lhsvalue%
StringReplace, htmlcontents, htmlcontents, exo_rhsvalue_placeholder, %rhsvalue%
StringReplace, htmlcontents, htmlcontents, exo_file1name_placeholder, %file1name%
StringReplace, htmlcontents, htmlcontents, exo_file2name_placeholder, %file2name%
StringReplace, htmlcontents, htmlcontents, exo_instructions_placeholder, %instructions%
;msgbox, %htmlcontents%
FileDelete, temp.html
FileAppend, %htmlcontents%, temp.html, UTF-16


; __________________________________________________________________________________________________
; Constants
ENUM_VARIABLES=
(
A_AhkPath A_AhkVersion A_AppData A_AppDataCommon A_BatchLines A_CaretX A_CaretY
A_ComputerName A_ControlDelay A_Cursor A_DD A_DDD A_DDDD A_DefaultMouseSpeed A_Desktop
A_DesktopCommon A_DetectHiddenText A_DetectHiddenWindows A_EventInfo A_ExitReason A_FileEncoding
A_FormatFloat A_FormatInteger A_Gui A_GuiControl A_GuiControlEvent A_GuiEvent A_GuiHeight A_GuiWidth
A_GuiX A_GuiY A_Hour A_IconFile A_IconHidden A_IconNumber A_IconTip A_IPAddress1 A_IPAddress2
A_IPAddress3 A_IPAddress4 A_Is64bitOS A_IsAdmin A_IsCompiled A_IsCritical A_IsPaused A_IsSuspended
A_IsUnicode A_KeyDelay A_Language A_LastError A_MDay A_Min A_MM A_MMM A_MMMM A_Mon A_MouseDelay
A_MSec A_MyDocuments A_Now A_NowUTC A_NumBatchLines A_OSType A_OSVersion A_PriorHotkey A_PriorKey
A_ProgramFiles A_Programs A_ProgramsCommon A_PtrSize A_RegView A_ScreenDPI A_ScreenHeight
A_ScreenWidth A_ScriptDir A_ScriptFullPath A_ScriptHwnd A_ScriptName A_Sec A_Space A_StartMenu
A_StartMenuCommon A_Startup A_StartupCommon A_StringCaseSense A_Tab A_Temp A_ThisHotkey A_ThisMenu
A_ThisMenuItem A_ThisMenuItemPos A_TickCount A_TimeIdle A_TimeIdlePhysical A_TimeSincePriorHotkey
A_TimeSinceThisHotkey A_TitleMatchMode A_TitleMatchModeSpeed A_UserName A_WDay A_WinDelay A_WinDir
A_WorkingDir A_YDay A_Year A_YWeek A_YYYY ClipboardAll ComSpec ProgramFiles A_Args
)

ENUM_FUNCTIONS=
(
Abs ACos Asc ASin ATan BlockInput Ceil Chr Click ClipWait Control ControlClick ControlFocus
ControlGet ControlGetFocus ControlGetPos ControlGetText ControlMove ControlSend ControlSendRaw
ControlSetText CoordMode Cos Critical DetectHiddenText DetectHiddenWindows DllCall Drive DriveGet
DriveSpaceFree EnvGet EnvSet EnvUpdate ExitApp Exp FileAppend FileCopy FileCopyDir FileCreateDir
FileCreateShortcut FileDelete FileEncoding FileExist FileGetAttrib FileGetShortcut FileGetSize
FileGetTime FileGetVersion FileMove FileMoveDir FileOpen FileRead FileReadLine FileRecycle FileRecycleEmpty
FileRemoveDir FileSelectFile FileSelectFolder FileSetAttrib FileSetTime Floor FormatTime GetKeyName
GetKeySC GetKeyState GetKeyVK GroupActivate GroupAdd GroupClose GroupDeactivate Gui GuiControl
GuiControlGet Hotkey IL_Add IL_Create IL_Destroy ImageSearch IniDelete IniRead IniWrite Input
InputBox InStr KeyHistory KeyWait ListHotkeys Ln Log Loop LTrim LV_Add LV_Delete LV_DeleteCol
LV_GetCount LV_GetNext LV_GetText LV_Insert LV_InsertCol LV_Modify LV_ModifyCol LV_SetImageList Menu
Mod MouseClick MouseClickDrag MouseGetPos MouseMove MsgBox OnExit OnMessage OutputDebug Pause
PixelGetColor PixelSearch PostMessage Process Progress Random RegDelete RegExMatch RegExReplace
RegRead RegWrite Reload Round RTrim Run RunAs RunWait SB_SetIcon SB_SetParts SB_SetText Send
SendEvent SendInput SendLevel SendMessage SendMode SendPlay SendRaw SetBatchLines SetCapslockState
SetControlDelay SetDefaultMouseSpeed SetFormat SetKeyDelay SetMouseDelay SetNumLockState SetRegView
SetScrollLockState SetStoreCapslockMode SetTitleMatchMode SetWinDelay SetWorkingDir Shutdown Sin
Sleep Sort SoundBeep SoundGet SoundGetWaveVolume SoundPlay SoundSet SoundSetWaveVolume SplashImage
SplashTextOff SplashTextOn SplitPath Sqrt StatusBarGetText StatusBarWait StrGet StringCaseSense
StringGetPos StringLeft StringLen StringLower StringMid StringReplace StringRight StringTrimLeft
StringTrimRight StringUpper StrLen StrPut StrSplit SubStr Suspend SysGet Tan Thread ToolTip
Transform TrayTip Trim TV_Add TV_Delete TV_Get TV_GetChild TV_GetCount TV_GetNext TV_GetParent
TV_GetPrev TV_GetSelection TV_GetText TV_Modify TV_SetImageList UrlDownloadToFile WinActivate
WinActivateBottom WinActive WinClose WinExist WinGet WinGetActiveStats WinGetActiveTitle WinGetClass
WinGetPos WinGetText WinGetTitle WinHide WinKill WinMaximize WinMenuSelectItem WinMinimize
WinMinimizeAll WinMinimizeAllUndo WinMove WinRestore WinSet WinSetTitle WinShow WinWait
WinWaitActive WinWaitClose WinWaitNotActive Require
)

ENUM_NUMBER_TYPES =
(
A_ControlDelay,A_DefaultMouseSpeed,A_GuiHeight,A_GuiWidth,A_GuiX,A_GuiY,A_IconHidden,A_Is64bitOS,
A_IsAdmin,A_IsCritical,A_IsPaused,A_IsSuspended,A_KeyDelay,A_MouseDelay,A_PtrSize,A_ScreenDPI,
A_ScreenHeight,A_ScreenWidth,A_TickCount,A_TimeIdle,A_TimeIdlePhysical,A_TimeSincePriorHotkey,
A_TimeSinceThisHotkey,A_WinDelay
)

ENUM_REG_NAMES =
(
HKEY_LOCAL_MACHINE,HKLM
HKEY_USERS,HKU
HKEY_CURRENT_USER,HKCU
HKEY_CLASSES_ROOT,HKCR
HKEY_CURRENT_CONFIG,HKCC
)

BUILTIN_LABELS := "GuiClose GuiContextMenu GuiDropFiles GuiEscape GuiSize OnClipboardChange"
WIDTH	:= A_ScreenWidth - 100 ;1000
HEIGHT	:= A_ScreenHeight - 100 ;700

; __________________________________________________________________________________________________
; Global variables
global enumVariables := enum(ENUM_VARIABLES)
global enumFunctions := enum(ENUM_FUNCTIONS)
global enumNumberTypes := enum(ENUM_NUMBER_TYPES)
global enumRegNames := enum(ENUM_REG_NAMES)
global builtinLabels := enum(BUILTIN_LABELS)
global closures := {}	; a map that links a string identifier to a js native closure. Used by "trigger()"
global JS ; a JavaScript helper object. Used extensively by the API functions.
global window ; a shortcut to wb.document.parentWindow. Used by "_Require()".
global mainDir


; __________________________________________________________________________________________________
; Set working dir
;SplitPath, mainPath, mainFilename, mainDir, mainExt, mainSeed
;SetWorkingDir %mainDir%  ; From now on, all relative paths are based on the JS location
;mainDirURI := "file:///" . RegExReplace(mainDir, "\\", "/") . "/"
OnExit, LabelOnExit


; __________________________________________________________________________________________________
; Open a virtual HTML file.
; We want the latest IE documentMode, so we use "X-UA-Compatible".
; If we were to hook into the page while the page is loading, we would encounter race conditions.
; To avoid this, we need to carefully manage the document with following flow:
;					open > write > exec hook > exec main > close
; When opening the document in IE8, the documentMode is lost and so we have to write it again (thus,
; it might also work if we used "about:blank", but let's err on the safe side).
; Further reading:
; 	● http://ahkscript.org/boards/viewtopic.php?t=5714&p=33477#p33477
; 	● http://ahkscript.org/boards/viewtopic.php?f=14&t=5778
Gui, +Resize
Gui, Add, ActiveX, w%WIDTH% h%HEIGHT% x0 y0 vwb, Shell.Explorer
tempfileURI := "file:///" . RegExReplace(A_ScriptDir, "\\", "/") . "/temp.html"
;msgbox, %A_ScriptDir%`n%tempfileURI%
wb.Navigate(tempfileURI)
;wb.Navigate("about:<!DOCTYPE html><meta http-equiv='X-UA-Compatible' content='IE=edge'>")
while wb.readyState < 4
	Sleep 10
;wb.document.open() ; important
document := wb.document ; shortcut
window := document.parentWindow ; shortcut



; __________________________________________________________________________________________________
; Create a virtual helper
if (false) { ; TODO: implement the "#UseExoScope" directive
	scope := "Exo"
} else {
	scope := "window"
}
exoHelper=
(
	var __ExoHelper = {
		Object: function() {
			var obj = {};
			for (var i = 0; i < arguments.length; i += 2) {
				obj[arguments[i]] = arguments[i+1];
			}
			return obj;
		},
		Array: function() {
			return Array.prototype.slice.call(arguments);
		},


		registerFunction: function(name, func) {
			%scope%[name] = func;
		},
		registerGetter: function(name, func){
			Object.defineProperty(%scope%, name, {
				get: function() {
					return func(name);
				}
			});
		},
		registerAccessor: function(name, func){
			Object.defineProperty(%scope%, name, {
				get: function(){
					return func();
				},
				set: function(value){
					func(value);
				}
			});
		}
	};
)
; "eval" doesn't work correctly in IE8 at this point.
; If it did, we would have used an anonymous helper object and avoided polluting the global scope.
window.execScript(exoHelper)
JS := window.__ExoHelper


; __________________________________________________________________________________________________
; Register the API
getBuiltInVarReference := Func("getBuiltInVar")
for key in enumVariables {
	apiFunction := Func("_" . key)
	if (!apiFunction) { ; found no custom API function
		apiFunction := getBuiltInVarReference ; this must be a normal built-in variable
	}
	JS.registerGetter(key, apiFunction)
}
for key in enumFunctions {
	apiFunction := Func("_" . key)
	if (!apiFunction) { ; found no custom API function
		apiFunction := Func(key) ; this must be a normal built-in function
	}
	JS.registerFunction(key, apiFunction)
}
JS.registerAccessor("Clipboard", Func("_Clipboard")) ; exception: Clipboard is read-write
JS.registerAccessor("ErrorLevel", Func("_ErrorLevel")) ; exception: ErrorLevel is read-write


; __________________________________________________________________________________________________
; Evaluate the main JS.
; Note that there are 4 ways to add the main JS script:
;		1) <script src='...'></script>
;			Works ok, but errors in JS are reported as havine Line Number:0 (most of the times...)
;		2) <script>...</script>
;			Works ok, but errors in JS are reporting with a Char Number offseted by the "<script>" tag
;		3) eval(...)
;			Works ok and doesn't dirty the page source, but you have no script URL (mostly harmless).
;		4) execScript(...)
;			Same as eval, plus a bit safer for IE8. This is the chosen method.
FileRead, mainContent, %mainPath%
;window.execScript(mainContent)
document.close()	; allows the triggering of window.onload


; __________________________________________________________________________________________________
; Register any possible built-in functions equivalent to the built-in labels
for key, val in builtinLabels {
	if (window.hasOwnProperty(key) != 0) {
		closures[key] := window[key]
	}
}


; __________________________________________________________________________________________________
; Finish the Auto-execute Section
trigger("OnClipboardChange")
OnMessage(0x100, "WB_onKey", 2) ; support for key down
OnMessage(0x101, "WB_onKey", 2) ; support for key up
;Gui, Show, w%WIDTH% h%HEIGHT%, AHK v1 -> v2 Script Converter - Visual Diff
Gui, Show, x0 y0 w%WIDTH% h%HEIGHT% maximize, AHK v1 -> v2 Script Converter - Visual Diff
return


;###################################################################################################
;######################################   F U N C T I O N S   ######################################
;###################################################################################################

;ESC::
;ExitApp


/**
 *
 */
getBuiltInVar(name){
	if (enumNumberTypes.HasKey(name)) {
		return (%name%)+0
	} else {
		return (%name%)
	}
}


/**
 * Wrapper for SKAN's function (see below)
 */
getArgs(){
	CmdLine := DllCall( "GetCommandLine", "Str" )
	CmdLine := RegExReplace(CmdLine, " /ErrorStdOut", "")
	Skip    := ( A_IsCompiled ? 1 : 2 )
	argv    := Args( CmdLine, Skip )
	return argv
}


/**
 * By SKAN,  http://goo.gl/JfMNpN,  CD:23/Aug/2014 | MD:24/Aug/2014
 */
Args( CmdLine := "", Skip := 0 ) {
	Local pArgs := 0, nArgs := 0, A := []
	pArgs := DllCall( "Shell32\CommandLineToArgvW", "WStr",CmdLine, "PtrP",nArgs, "Ptr" )
	Loop % ( nArgs )
		If ( A_Index > Skip )
			A[ A_Index - Skip ] := StrGet( NumGet( ( A_Index - 1 ) * A_PtrSize + pArgs ), "UTF-16" )
	Return A,   A[0] := nArgs - Skip,   DllCall( "LocalFree", "Ptr", pArgs )
}


/**
 *
 */
trigger(key, args*){
	closure := closures[key]
	if (closure) {
		return closure.call(0,args*)
	}
}


/**
 *
 */
enum(blob){
	blob := RegExReplace(blob, "\s+", ",")
	parts := StrSplit(blob, ",")
	output := {}
	for key, val in parts {
		output[val] := 1
	}
	return output
}


/**
 * Used only for debugging. It's a lightweight JSON.stringify, but with no quotes and no escapes.
 */
trace(s){
	s := serialize(s,0)
	MsgBox, 262144,,%s% ; Always on top
}
serialize(obj,indent){
	if (IsObject(obj)) {
		prefix := ""
		Loop,%indent%
		{
			prefix .= "`t"
		}
		out := "`n"
		out .= prefix . "{`n"
		for key, val in obj {
			out .= prefix . "`t" . key . ":" . serialize(val, indent+1) . "`n"
		}
		out .= prefix . "}"
		return out
	} else {
		return obj
	}
}


/**
 *
 */
end(message){
	message .= "`nThe application will now exit."
	MsgBox % message
	ExitApp
}


;###################################################################################################
;#########################################   L A B E L S   #########################################
;###################################################################################################


/**
 * Built-in label.
 */
GuiClose:
	if (trigger("GuiClose") == 0) {
		return
	}
	ExitApp
return


/**
 * Built-in labels.
 */
GuiContextMenu:
GuiDropFiles:
GuiEscape:
OnClipboardChange:
	trigger(A_ThisLabel)
return

GuiSize:
	GuiControl,Move,wb, w%A_GuiWidth% h%A_GuiHeight%
return


/**
 * "OnExit()" redirects here.
 */
LabelOnExit:
	if (trigger("OnExit") == 0) {
		return
	}
	; 2024-07-01 ADDED, AMB - delete temp source file
	; part of fix to prevent errors when reading files with LF rather than CRLF
	if (srcFilePath~="_AHKv1v2_\d{10}\.ahk$") {
		FileDelete % srcFilePath
	}
	FileDelete, temp.html
	ExitApp
return


/**
 * "Hotkey()" redirects here.
 */
LabelHotkey:
	trigger("Hotkey" . A_ThisHotkey)
return


/**
 * "OnMessage()" redirects here. Not actually a label, but close enough.
 */
OnMessageClosure(wParam, lParam, msg, hwnd){
	trigger("OnMessage" . msg, wParam, lParam, msg, hwnd)
}


;###################################################################################################
;############################################   A P I   ############################################
;###################################################################################################
#Include %A_ScriptDir%\lib\Exo\FileObject.ahk
#Include %A_ScriptDir%\lib\Exo\WB_onKey.ahk
#Include %A_ScriptDir%\lib\Exo\API.ahk

