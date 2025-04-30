;########################################################################
;############################   A P I   #################################
;########################################################################
; This section migrates AHK Commands, Functions and Variables that need special attention.
; Keywords not present here are migrated directly (dynamically).
; The bulk of API functions consists of dumb Command->Function conversions.
; Whenever an API function deviates more than trivially from the AHK documentations,
; extensive comments are provided.


/**
 * Implementation: Replacement.
 * Because the command-line parameters syntax (1, 2, 3, etc.) is nonsensical in JS,
 * an alternative has been provided through the "A_Args" variable
 * (inspired by AHK v2: http://lexikos.github.io/v2/docs/Variables.htm#CommandLine ).
 */
_A_Args(){
    return JS.Array(getArgs()*) ; variadic call
}


/**
 * 
 */
_A_ScriptDir(*){
	return ''
}


/**
 * 
 */
_A_ScriptFullPath(){
	return ''
}


/**
 * 
 */
_A_ScriptName(){
	;SplitPath(mainPath, &mainFilename)
	return ''
}


/**
 * Implementation: Identical.
 * "Clipboard" and "ErrorLevel" are the only built-in variables that allow write access.
 * Because "getBuiltInVar()" only handles getters, these 2 had to be customized.
 */
Array.Prototype.DefineProp('MaxIndex', {Call:(a)=>(i:='',e:=a.__Enum(),[((*)=>e(&k,&v)&&(i:=IsSet(k)?k:i))*],i)})
_A_Clipboard(a*){ ; variadic parameters, to detect the role (getter or setter)
	if (a.MaxIndex()) { ; setter
		A_Clipboard := a[1]
	} else { ; getter
		return A_Clipboard
	}
}


/**
 * Implementation: Minor change (returns Object)
 * "ControlGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Width and Height.
 */
_ControlGetPos(Control:="",WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:=""){
	ControlGetPos(&X, &Y, &Width, &Height, Control, WinTitle, WinText, ExcludeTitle)
	return JS.Object("X", X, "Y", Y, "Width", Width, "Height", Height)
}


/**
 * Implementation: Minor change (returns Object)
 * "FileGetShortcut" is special because it outputs 7 variables.
 * In JS, we return an Object with 7 properties: Target, Dir, Args, Description, Icon, IconNum, RunState.
 * V2 Change: Removed redundent parameters
 */
_FileGetShortcut(LinkFile){
	FileGetShortcut(LinkFile, &Target, &Dir, &Args, &Description, &Icon, &IconNum, &RunState)
	return JS.Object("Target",Target, "Dir",Dir, "Args",Args, "Description",Description, "Icon",Icon, "IconNum",IconNum, "RunState",RunState)
}


/**
 * Implementation: Minor change.
 * The implementation of "FileOpen" is in fact identical to the one in AHK (thanks to Coco).
 * The only difference is in the returned file object, whose "RawRead()" cannot output 2 variables.
 * In AHK, "RawRead()" has the definition "RawRead(ByRef VarOrAddress, bytes):<Number>".
 * In JS, "RawRead()" has the definition "RawRead(bytes, Advanced=0)", with two modes:
 * 		1) the default mode (Advanced=0) is to return the retrieved data. Note that this behavior
 *          differs from the one in AHK, where the return value represents the number of bytes
 *          that were read.
 *		2) the advanced mode (Advanced!=0) returns an object with 2 properties:
 *           Count: The number of bytes that were read.
 *           Data: The data retrieved from the file.
 */
_FileOpen(fspec, flags, encoding:="CP0"){
	return FileObject(fspec, flags, encoding)
}


/**
 * Implementation: Minor change (target label becomes closure).
 * "Hotkey" is special because it uses labels.
 * The migrated function uses closures instead of labels.
 * TODO: Add support for AltTab.
 */
/*
_Hotkey(KeyName, Closure:="", Options:=""){
	if (KeyName == "") {
		end("Invalid KeyName!")
	}
	Closure := StrLower(Closure)	; uniformity, to allow case insesitivity
	operation := ""
	if (Closure == "on" || RegExMatch(Options, "i)\bOn\b")) {
		operation := "on"
	} else if (Closure == "off" || RegExMatch(Options, "i)\bOff\b")) {
		operation := "off"
	} else if (Closure == "toggle") {
		operation := "toggle"
	}
	if (operation) {
		if (!closures.HasKey("Hotkey" . KeyName)) {
			end("Nonexistent hotkey!")
		} else {
			Hotkey(KeyName, operation, Options)
		}
	} else {
		if (Closure!="") {
			closures["Hotkey" . KeyName] := Closure
			Hotkey(KeyName, LabelHotkey, Options)
		} else {
			Hotkey KeyName,, Options
		}
	}
}*/


/**
 * Implementation: Minor change (returns Object).
 * "ImageSearch" is special because it outputs 2 variables.
 * In JS, we return an Object with 2 properties: X, Y.
 */
_ImageSearch(X1,Y1,X2,Y2,ImageFile){
	ImageSearch(&X, &Y, X1, Y1, X2, Y2, ImageFile)
	return JS.Object("X",X, "Y",Y)
}


/**
 * Implementation: Major change.
 * Because an AHK Loop intermingled with JS would be nonsensical, the migration solution was to
 * output the whole Loop results as an Array of Objects. Here's how the 5 types of Loop migrated:
 * 		1) [Normal-Loop](http://ahkscript.org/docs/commands/Loop.htm): N/A (not needed)
 * 		2) [File-Loop](http://ahkscript.org/docs/commands/LoopFile.htm):
 *			Syntax: Loop(FilePattern, [IncludeFolders, Recurse])
 *			Each Object has the same properties as the special variables available inside a File-Loop:
 *			Name,Ext,FullPath,LongPath,ShortPath,Dir,TimeModified,TimeCreated,TimeAccessed,Attrib,Size,SizeKB,SizeMB
 *		3) [Parse-Loop](http://ahkscript.org/docs/commands/LoopParse.htm): N/A (superseded by StrSplit)
 *		4) [Read-Loop](http://ahkscript.org/docs/commands/LoopReadFile.htm):
 *			Syntax: Loop("Read", InputFile)
 *			The output array contains each respective A_LoopReadLine as String.
 *			The OutputFile feature cannot be implemented.
 *		5) [Registry-Loop](http://ahkscript.org/docs/commands/LoopReg.htm):
 *			Syntax: Loop("HKLM|HKYU|...", [Key, IncludeSubkeys, Recurse])
 *			Each Object has the same properties as the special variables available inside a Registry-Loop:
 *			Name,Type,Key,SubKey,TimeModified
 * V2 Change: Update output object to reflect new variable names
 */
_Loop(Param1,Param2:="",Param3:=""){
	output := JS.Array()
	if (Param1 = "i)^parse$") {
		end("The Parse-Loop has been superseded by StrSplit().")
	} else if (Param1 = "Read") {
		Loop Read, Param2
		{
            output.push(A_LoopReadLine)
		}
	} else if (Param1 = "Reg") {
		Loop Reg, Param2, Param3
		{
            output.push(JS.Object("Name", A_LoopRegName
                ,"Type", A_LoopRegType
                ,"Key", A_LoopRegKey
                ,"TimeModified", A_LoopRegTimeModified))
		}
	} else if (Param1 = "Files") {
		Loop Files, Param2, Param3
        {
	        output.push(JS.Object("Name", A_LoopFileName
                ,"Ext", A_LoopFileExt
                ,"Path", A_LoopFilePath
                ,"FullPath", A_LoopFileFullPath
                ,"ShortPath", A_LoopFileShortPath
                ,"Dir", A_LoopFileDir
                ,"TimeModified", A_LoopFileTimeModified
                ,"TimeCreated", A_LoopFileTimeCreated
                ,"TimeAccessed", A_LoopFileTimeAccessed
                ,"Attrib", A_LoopFileAttrib
                ,"Size", A_LoopFileSize+0
                ,"SizeKB", A_LoopFileSizeKB+0
                ,"SizeMB", A_LoopFileSizeMB+0))
        }
	} else { ; Error handling
		If Param1 = ""
			end("The Normal-Loop has been superseded by JavaScript's while or for loops.")
		else
			end("Unknown loop type: " Param1)
	}
	return output
}


/**
 * Implementation: Minor change (returns Object).
 * "MouseGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Win, Control.
 */
_MouseGetPos(Flag:=""){
	MouseGetPos(&X, &Y, &Win, &Control, Flag)
	return JS.Object("X",X, "Y",Y, "Win",Win+0, "Control",Control)
}


/**
 * Implementation: Normalization.
 * Besides command->function conversion, MsgBox needed extra attention because
 * the commas separating the parameters are interperted as string.
 * Also, the case for no-parameters had to be intercepted.
 */
_MsgBox(Param1:="__Undefined", Title:="__Undefined", Text:=""){
	if (Param1 == "__Undefined") {
		MsgBox
	} else if (Title == "__Undefined") {
		MsgBox(Param1)
	} else {
		MsgBox(Param1,Title,Text)
	}
}


/**
 * Implementation: Minor change (target label becomes closure).
 * "OnExit" is special because it uses labels.
 * The migrated function uses instead closures.
 */
_OnExit(Closure:=""){
	closures["OnExit"] := Closure
}


/**
 * Implementation: Minor change (target function becomes closure)
 * "OnMessage" is special because it uses function names.
 * In JS, the function name becomes a closure.
 */
/*
_OnMessage(MsgNumber, Closure:="__Undefined", MaxThreads:=1){
    key := "OnMessage" . MsgNumber
    fn := closures[key]
    if (Closure == "__Undefined") {
        return fn
    } else if (Closure == "") {
		closures.Remove(key)
		OnMessage(MsgNumber, key, 0)
        return fn
	} else {
		closures[key] := Closure
        OnMessage(MsgNumber, "OnMessageClosure", MaxThreads)
        if (fn) {
            return fn
        } else {
            return Closure
        }
	}
}*/


/**
 * Implementation: Minor change (returns Object).
 * "PixelSearch" is special because it outputs 2 variables.
 * In JS, we return an Object with 2 properties: X, Y.
 */
_PixelSearch(X1,Y1,X2,Y2,ColorID,Variation:=""){
	PixelSearch(&X, &Y, X1, Y1, X2, Y2, ColorID, Variation)
	return JS.Object("X",X, "Y",Y)
}


/**
 * Implementation: Major change.
 * Because RegExMatch performs two roles, we cannot migrate it to JS 100% unchanged. The two roles are:
 *		1) returns found position
 *		2) fills a ByRef variable
 * Therefore, in order not lose the second functionality, we introduce an extra flag called "Advanced",
 * which clarifies what role the JS function should fulfill.
 * If "Advanced=0" (default), RegExMatch behaves as before, returning the found position.
 * Otherwise, it will return a Match object (http://ahkscript.org/docs/commands/RegExMatch.htm#MatchObject), no matter
 * what the matching mode is (default, P or O).
 */
_RegExMatch(Haystack, NeedleRegEx, StartingPosition:=1, Advanced:=0){
	if (Advanced) {
		RegExMatch(Haystack, NeedleRegEx, &Match, StartingPosition)
        
        Pos := JS.Array()
        Len := JS.Array()
        Value := JS.Array()
        Name := JS.Array()        
        a := ["Pos",Pos, "Len",Len, "Value",Value, "Name",Name, "Count",Match.Count(), "Mark",Match.Mark()]
		n := Match.Count() + 1
		Loop n
		{
			index := A_Index - 1
            Pos.push(Match.Pos(index))
            Len.push(Match.Len(index))
            Value.push(Match.Value(index))
            Name.push(Match.Name(index))
            a.Insert(index)
            a.Insert(Match[index])
		}
		return JS.Object(a*)
	} else {
		return RegExMatch(Haystack, NeedleRegEx, , StartingPosition)
	}
}


/**
 * Implementation: Major change.
 * "RegExReplace" is special because it performs 2 roles:
 *		1) returns the replaced string. This mode is default (Advanced=0)
 *		2) fills the Count ByRef variable. This mode is triggered by non-empty values of Advanced. In this case,
 *		an Object will be returned, with 2 properties: Text, Count.
 */
_RegExReplace(Haystack, NeedleRegEx, Replacement:="", Limit:=-1, StartingPosition:=1, Advanced:=0){
	Text := RegExReplace(Haystack, NeedleRegEx, Replacement, &Count, Limit, StartingPosition)
	if (Advanced) {
		return JS.Object("Text",Text, "Count",Count)
	} else {
		return Text
	}
}


/**
 * Implementation: Addition.
 * "Require" is similar to "#Include", but it differs in one crucial way:
 * "Require" evaluates the script in the window scope, while "#Include"
 * evaluates the script in the local scope ("as though the specified file's
 * contents are present at this exact position").
 * Notes:
 *      ● The evaluation takes place instantly (synchronous)
 *      ● "Require" could also be written as "window.eval(FileRead(path))"
 *      ● "#Include" could also be written as "eval(FileRead(path))"
 */
_Require(path){
    content := FileRead(path)
    window.eval(content) ; seems to work ok in IE8 at this point
}


/**
 * Implementation: Major change (doesn't return exit code).
 * "RunWait" is special because it sets a process ID which can be read by another thread.
 * For JS, we cannot implement this feature and therefore don't return any PID (as opposed to "Run")
 */
_RunWait(Target,WorkingDir:="",Flags:=""){
	RunWait(Target, WorkingDir, Flags)
}


/**
 * Implementation: Major change.
 * "Sort" is special because it modifies a ByRef variable.
 * For JS, we made it a return value.
 * TODO: implement the callback param.
 */
_Sort(VarName,Options:=""){
	return Sort(VarName, Options)
}


/**
 * Implementation: Normalization.
 * "SoundGet" is special because it has multiple return types (Number or String).
 */
_SoundGet(ComponentType:="",ControlType:="",DeviceNumber:=""){
	OutputVar := SoundGet%ControlType%(ComponentType, DeviceNumber)
	static STRING_CONTROL_TYPES := {ONOFF:1, MUTE:1, MONO:1, LOUDNESS:1, STEREOENH:1, BASSBOOST:1}
	if (STRING_CONTROL_TYPES.HasKey(ControlType)) {
		return OutputVar
	} else {
		return OutputVar+0
	}
}


/**
 * Implementation: Minor change (returns Object).
 * "SplitPath" is special because it outputs 5 variables.
 * In JS, we return an Object with 5 properties: FileName, Dir, Extension, NameNoExt, Drive
 */
_SplitPath(InputVar){
	SplitPath(InputVar, &FileName, &Dir, &Extension, &NameNoExt, &Drive)
	return JS.Object("FileName",FileName, "Dir",Dir, "Extension",Extension, "NameNoExt",NameNoExt, "Drive",Drive)
}


/**
 * Implementation: Minor change (returns Object).
 * "MonitorGet" is special because it outputs 5 variables.
 * In JS, we return an Object with 5 properties: ActualN, Left, Top, Right, Bottom.
 */
_MonitorGet(N:=1) {
	ActualN := MonitorGet(N, &Left, &Top, &Right, &Bottom)
	return JS.Object("ActualN", ActualN, "Left",Left, "Top",Top, "Right",Right, "Bottom",Bottom)
}


/**
 * Implementation: Minor change (returns Object).
 * "WinGet" is special because it may output an pseudo-array.
 * In JS, if Cmd=List, we return an Array of Numbers.
 * TODO: implement the List Cmd
 * V2 TODO: Separate func for each WinGet* Func
 */
_WinGet(Cmd:="",WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:=""){
	OutputVar := WinGet%Cmd%(WinTitle,WinText,ExcludeTitle,ExcludeText)
    Cmd := StrLower(Cmd)
    static STRING_COMMANDS := {ProcessName:1, ProcessPath:1, ControlList:1, ControlListHwnd:1, Style:1, ExStyle:1}
    if (Cmd == "list") {
        a := []
        Loop OutputVar
        {
            a.Insert((OutputVar . A_Index) + 0)
        }
        return JS.Array(a*) ; variadic call
    } else if (STRING_COMMANDS.HasKey(Cmd)) {
		return OutputVar
	} else {
		return OutputVar+0
	}
}


/**
 * Implementation: Minor change (returns Object).
 * "WinGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Width, Height.
 */
_WinGetPos(WinTitle:="",WinText:="",ExcludeTitle:="",ExcludeText:=""){
	WinGetPos(&X, &Y, &Width, &Height, WinTitle, WinText, ExcludeTitle, ExcludeText)
	return JS.Object("Width",Width, "Height",Height, "X",X, "Y",Y)
}