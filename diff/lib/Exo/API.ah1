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
_A_ScriptDir(){
	return %mainDir% 
}


/**
 * 
 */
_A_ScriptFullPath(){
	return %mainPath% 
}


/**
 * 
 */
_A_ScriptName(){
	SplitPath, mainPath, mainFilename
	return %mainFilename%
}


/**
 * Implementation: Normalization.
 */
_BlockInput(Mode){
	BlockInput %Mode%
}


/**
 * Implementation: Normalization.
 */
_Click(Item1="",Item2="",Item3="",Item4="",Item5="",Item6="",Item7=""){
	Click %Item1%,%Item2%,%Item3%,%Item4%,%Item5%,%Item6%,%Item7%
}


/**
 * Implementation: Identical.
 * "Clipboard" and "ErrorLevel" are the only built-in variables that allow write access.
 * Because "getBuiltInVar()" only handles getters, these 2 had to be customized.
 */
_Clipboard(a*){ ; variadic parameters, to detect the role (getter or setter)
	if (a.MaxIndex()) { ; setter
		Clipboard := a[1]
	} else { ; getter
		return Clipboard
	}
}


/**
 * Implementation: Normalization.
 */
_ClipWait(SecondsToWait="",AnyKindOfData=""){
	ClipWait %SecondsToWait%,%AnyKindOfData%
}


/**
 * Implementation: Normalization.
 */
_Control(Cmd,Value="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	Control %Cmd%,%Value%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_ControlClick(ControlorPos="",WinTitle="",WinText="",WhichButton="",ClickCount="",Options="",ExcludeTitle="",ExcludeText=""){
	ControlClick %ControlorPos%,%WinTitle%,%WinText%,%WhichButton%,%ClickCount%,%Options%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_ControlFocus(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlFocus %Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Minor change (returns Object)
 * "ControlGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Width and Height.
 */
_ControlGetPos(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlGetPos X,Y,Width,Height,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return JS.Object("X", X, "Y", Y, "Width", Width, "Height", Height)
}


/**
 * Implementation: Normalization.
 */
_ControlGet(Cmd,Value="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlGet OutputVar,%Cmd%,%Value%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_ControlGetFocus(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlGetFocus OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_ControlGetText(Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlGetText OutputVar,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_ControlMove(Control,X,Y,Width,Height,WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlMove %Control%,%X%,%Y%,%Width%,%Height%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_ControlSend(Control="",Keys="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlSend %Control%,%Keys%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_ControlSendRaw(Control="",Keys="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlSendRaw %Control%,%Keys%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_ControlSetText(Control="",NewText="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	ControlSetText %Control%,%NewText%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_CoordMode(Target,Mode=""){
	CoordMode %Target%,%Mode%
}


/**
 * Implementation: Normalization.
 */
_Critical(Value=""){
	Critical %Value%
}


/**
 * Implementation: Normalization.
 */
_DetectHiddenText(OnOff){
	DetectHiddenText %OnOff%
}


/**
 * Implementation: Normalization.
 */
_DetectHiddenWindows(OnOff){
	DetectHiddenWindows %OnOff%
}


/**
 * Implementation: Normalization.
 */
_Drive(Subcommand,Drive="",Value=""){
	Drive %Subcommand%,%Drive%,%Value%
}


/**
 * Implementation: Normalization.
 */
_DriveGet(Cmd,Value=""){
	DriveGet OutputVar,%Cmd%,%Value%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_DriveSpaceFree(Path){
	DriveSpaceFree OutputVar,%Path%
	return OutputVar+0
}


/**
 * Implementation: Normalization.
 */
_EnvGet(EnvVarName){
	EnvGet OutputVar,%EnvVarName%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_EnvSet(EnvVar,Value){
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_EnvUpdate(){
	EnvUpdate
}


/**
 * Implementation: Identical.
 * "Clipboard" and "ErrorLevel" are the only built-in variables that allow write access.
 * Because "getBuiltInVar()" only handles getters, these 2 had to be customized.
 */
_ErrorLevel(a*){ ; variadic parameters, to detect the role (getter or setter)
	if (a.MaxIndex()) { ; setter
		ErrorLevel := a[1]
	} else { ; getter
		return ErrorLevel
	}
}


/**
 * Implementation: Normalization.
 */
_ExitApp(ExitCode=""){
	ExitApp %ExitCode%
}


/**
 * Implementation: Normalization.
 */
_FileAppend(Text="",Filename="",Encoding=""){
	FileAppend %Text%,%Filename%,%Encoding%
}


/**
 * Implementation: Normalization.
 */
_FileCopy(SourcePattern,DestPattern,Flag=""){
	FileCopy %SourcePattern%,%DestPattern%,%Flag%
}


/**
 * Implementation: Normalization.
 */
_FileCopyDir(Source,Dest,Flag=""){
	FileCopyDir %Source%,%Dest%,%Flag%
}


/**
 * Implementation: Normalization.
 */
_FileCreateDir(DirName){
	FileCreateDir %DirName%
}


/**
 * Implementation: Normalization.
 */
_FileCreateShortcut(Target,LinkFile,WorkingDir="",Args="",Description="",IconFile="",ShortcutKey="",IconNumber="",RunState=""){
	FileCreateShortcut %Target%,%LinkFile%,%WorkingDir%,%Args%,%Description%,%IconFile%,%ShortcutKey%,%IconNumber%,%RunState%
}


/**
 * Implementation: Normalization.
 */
_FileDelete(FilePattern){
	FileDelete %FilePattern%
}


/**
 * Implementation: Normalization.
 */
_FileEncoding(Encoding=""){
	FileEncoding %Encoding%
}


/**
 * Implementation: Normalization.
 */
_FileGetAttrib(Filename=""){
	FileGetAttrib OutputVar,%Filename%
	return OutputVar
}


/**
 * Implementation: Minor change (returns Object)
 * "FileGetShortcut" is special because it outputs 7 variables.
 * In JS, we return an Object with 7 properties: Target, Dir, Args, Description, Icon, IconNum, RunState.
 */
_FileGetShortcut(LinkFile, Target="", Dir="", Args="", Description="", Icon="", IconNum="", RunState=""){
	FileGetShortcut, %LinkFile%, %Target%, %Dir%, %Args%, %Description%, %Icon%, %IconNum%, %RunState%
	return JS.Object("Target",Target, "Dir",Dir, "Args",Args, "Description",Description, "Icon",Icon, "IconNum",IconNum, "RunState",RunState)
}


/**
 * Implementation: Normalization.
 */
_FileGetSize(Filename="",Units=""){
	FileGetSize OutputVar,%Filename%,%Units%
	return OutputVar+0
}


/**
 * Implementation: Normalization.
 */
_FileGetTime(Filename="",WhichTime=""){
	FileGetTime OutputVar,%Filename%,%WhichTime%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileGetVersion(Filename=""){
	FileGetVersion OutputVar,%Filename%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileMove(SourcePattern,DestPattern,Flag=""){
	FileMove %SourcePattern%,%DestPattern%,%Flag%
}


/**
 * Implementation: Normalization.
 */
_FileMoveDir(Source,Dest,Flag=""){
	FileMoveDir %Source%,%Dest%,%Flag%
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
	return new FileObject(fspec, flags, encoding)
}


/**
 * Implementation: Normalization.
 */
_FileRead(Filename){
	FileRead OutputVar,%Filename%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileReadLine(Filename,LineNum){
	FileReadLine OutputVar,%Filename%,%LineNum%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileRecycle(FilePattern){
	FileRecycle %FilePattern%
}


/**
 * Implementation: Normalization.
 */
_FileRecycleEmpty(DriveLetter=""){
	FileRecycleEmpty %DriveLetter%
}


/**
 * Implementation: Normalization.
 */
_FileRemoveDir(DirName,Recurse=""){
	FileRemoveDir %DirName%,%Recurse%
}


/**
 * Implementation: Normalization.
 */
_FileSelectFile(Options="",RootDirOFilename="",Prompt="",Filter=""){
	FileSelectFile OutputVar,%Options%,%RootDirOFilename%,%Prompt%,%Filter%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileSelectFolder(StartingFolder="",Options="",Prompt=""){
	FileSelectFolder OutputVar,%StartingFolder%,%Options%,%Prompt%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_FileSetAttrib(Attributes,FilePattern="",OperateOnFolders="",Recurse=""){
	FileSetAttrib %Attributes%,%FilePattern%,%OperateOnFolders%,%Recurse%
}


/**
 * Implementation: Normalization.
 */
_FileSetTime(YYYYMMDDHH24MISS="",FilePattern="",WhichTime="",OperateOnFolders="",Recurse=""){
	FileSetTime %YYYYMMDDHH24MISS%,%FilePattern%,%WhichTime%,%OperateOnFolders%,%Recurse%
}


/**
 * Implementation: Normalization.
 */
_FormatTime(YYYYMMDDHH24MISS="",Format=""){
	FormatTime OutputVar,%YYYYMMDDHH24MISS%,%Format%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_GroupActivate(GroupName,R=""){
	GroupActivate %GroupName%,%R%
}


/**
 * Implementation: Normalization.
 */
_GroupAdd(GroupName,WinTitle="",WinText="",Label="",ExcludeTitle="",ExcludeText=""){
	GroupAdd %GroupName%,%WinTitle%,%WinText%,%Label%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_GroupClose(GroupName,Flag=""){
	GroupClose %GroupName%,%Flag%
}


/**
 * Implementation: Normalization.
 */
_GroupDeactivate(GroupName,R=""){
	GroupDeactivate %GroupName%,%R%
}


/**
 * Implementation: Normalization.
 */
_Gui(Subcommand,Param2="",Param3="",Param4=""){
	Gui %Subcommand%,%Param2%,%Param3%,%Param4%
}


/**
 * Implementation: Normalization.
 */
_GuiControl(Subcommand,ControlID,Param3=""){
	GuiControl %Subcommand%,%ControlID%,%Param3%
}


/**
 * Implementation: Normalization.
 */
_GuiControlGet(Subcommand="",ControlID="",Param4=""){
	GuiControlGet OutputVar,%Subcommand%,%ControlID%,%Param4%
	return OutputVar
}


/**
 * Implementation: Minor change (target label becomes closure).
 * "Hotkey" is special because it uses labels.
 * The migrated function uses closures instead of labels.
 * TODO: Add support for AltTab.
 */
_Hotkey(KeyName, Closure="", Options=""){
	if (KeyName == "") {
		end("Invalid KeyName!")
	}
	StringLower, Closure, Closure	; uniformity, to allow case insesitivity
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
			Hotkey %KeyName%, %operation%, %Options%
		}
	} else {
		if (Closure!="") {
			closures["Hotkey" . KeyName] := Closure
			Hotkey %KeyName%, LabelHotkey, %Options%
		} else {
			Hotkey %KeyName%,, %Options%
		}
	}
}


/**
 * Implementation: Minor change (returns Object).
 * "ImageSearch" is special because it outputs 2 variables.
 * In JS, we return an Object with 2 properties: X, Y.
 */
_ImageSearch(X1,Y1,X2,Y2,ImageFile){
	ImageSearch X,Y,%X1%,%Y1%,%X2%,%Y2%,%ImageFile%
	return JS.Object("X",X, "Y",Y)
}


/**
 * Implementation: Normalization.
 */
_IniDelete(Filename,Section,Key=""){
	IniDelete %Filename%,%Section%,%Key%
}


/**
 * Implementation: Normalization.
 */
_IniRead(Filename,Section="",Key="",Default=""){
	IniRead OutputVar,%Filename%,%Section%,%Key%,%Default%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_IniWrite(Value,Filename,Section,Key=""){
	IniWrite %Value%,%Filename%,%Section%,%Key%
}


/**
 * Implementation: Normalization.
 */
_Input(Options="",EndKeys="",MatchList=""){
	Input OutputVar,%Options%,%EndKeys%,%MatchList%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_InputBox(Title="",Prompt="",HIDE="",Width="",Height="",X="",Y="",FontBlank="",Timeout="",Default=""){
	InputBox OutputVar,%Title%,%Prompt%,%HIDE%,%Width%,%Height%,%X%,%Y%,,%Timeout%,%Default%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_KeyHistory(){
	KeyHistory 
}


/**
 * Implementation: Normalization.
 */
_KeyWait(KeyName,Options=""){
	KeyWait %KeyName%,%Options%
}


/**
 * Implementation: Normalization.
 */
_ListHotkeys(){
	ListHotkeys 
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
 */
_Loop(Param1,Param2="",Param3="",Param4=""){
	output := JS.Array()
	if (RegExMatch(Param1, "i)^parse$")) {
		end("The Parse-Loop has been superseded by StrSplit().")
	} else if (RegExMatch(Param1, "i)^read$")) {
		Loop, %Param1%, %Param2%
		{
            output.push(A_LoopReadLine)
		}
	} else {
		global regNames
		if (regNames.HasKey(Param1)) {
			Loop, %Param1%, %Param2%, %Param3%, %Param4%
			{
                output.push(JS.Object("Name", A_LoopRegName
                    ,"Type", A_LoopRegType
                    ,"Key", A_LoopRegKey
                    ,"SubKey", A_LoopRegSubKey
                    ,"TimeModified", A_LoopRegTimeModified))
			}
		} else {
			Loop, %Param1%, %Param2%, %Param3%
            {
                output.push(JS.Object("Name", A_LoopFileName
                    ,"Ext", A_LoopFileExt
                    ,"FullPath", A_LoopFileFullPath
                    ,"LongPath", A_LoopFileLongPath
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
		}
	}
	return output
}


/**
 * Implementation: Major change.
 * "LV_GetText" is special because it outputs 2 variables (a return value and a ByRef).
 * The migrated function has two modes:
 * 		1) the default mode (Advanced=0) is to return the retrieved text. Note that this behavior differs from the one in AHK.
 *		2) the advanced mode (Advanced non-empty) returns an object with 2 properties: Text, Success.
 */
_LV_GetText(RowNumber,ColumnNumber=1,Advanced=0){
	if (Advanced) {
		Success := LV_GetText(Text, RowNumber, ColumnNumber)
		return JS.Object("Text",Text, "Success",Success)
	} else {
		LV_GetText(OutputVar, RowNumber, ColumnNumber)
		return OutputVar
	}
}


/**
 * Implementation: Normalization.
 */
_Menu(MenuName,Cmd,P3="",P4="",P5=""){
	Menu %MenuName%,%Cmd%,%P3%,%P4%,%P5%
}


/**
 * Implementation: Normalization.
 */
_MouseClick(WhichButton="",X="",Y="",ClickCount="",Speed="",State="",R=""){
	MouseClick %WhichButton%,%X%,%Y%,%ClickCount%,%Speed%,%State%,%R%
}


/**
 * Implementation: Normalization.
 */
_MouseClickDrag(WhichButton,X1,Y1,X2,Y2,Speed="",R=""){
	MouseClickDrag %WhichButton%,%X1%,%Y1%,%X2%,%Y2%,%Speed%,%R%
}


/**
 * Implementation: Minor change (returns Object).
 * "MouseGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Win, Control.
 */
_MouseGetPos(Flag=""){
	MouseGetPos X, Y, Win, Control, %Flag%
	return JS.Object("X",X, "Y",Y, "Win",Win+0, "Control",Control)
}


/**
 * Implementation: Normalization.
 */
_MouseMove(X,Y,Speed="",R=""){
	MouseMove %X%,%Y%,%Speed%,%R%
}


/**
 * Implementation: Normalization.
 * Besides command->function conversion, MsgBox needed extra attention because
 * the commas separating the parameters are interperted as string.
 * Also, the case for no-parameters had to be intercepted.
 */
_MsgBox(Param1="__Undefined", Title="__Undefined", Text="", Timeout=""){
	if (Param1 == "__Undefined") {
		MsgBox
	} else if (Title == "__Undefined") {
		MsgBox, %Param1%
	} else {
		MsgBox % Param1,%Title%,%Text%,%Timeout%
	}
}


/**
 * Implementation: Minor change (target label becomes closure).
 * "OnExit" is special because it uses labels.
 * The migrated function uses instead closures.
 */
_OnExit(Closure=""){
	closures["OnExit"] := Closure
}


/**
 * Implementation: Minor change (target function becomes closure)
 * "OnMessage" is special because it uses function names.
 * In JS, the function name becomes a closure.
 */
_OnMessage(MsgNumber, Closure="__Undefined", MaxThreads=1){
    key := "OnMessage" . MsgNumber
    fn := closures[key]
    if (Closure == "__Undefined") {
        return fn
    } else if (Closure == "") {
		closures.Remove(key)
		OnMessage(MsgNumber, "", MaxThreads)
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
}


/**
 * Implementation: Normalization.
 */
_OutputDebug(Text){
	OutputDebug %Text%
}


/**
 * Implementation: Normalization.
 */
_Pause(State="",OperateOnUnderlyingThread=""){
	Pause %State%,%OperateOnUnderlyingThread%
}


/**
 * Implementation: Normalization.
 */
_PixelGetColor(X,Y,Flags=""){
	PixelGetColor OutputVar,%X%,%Y%,%Flags%
	return OutputVar
}


/**
 * Implementation: Minor change (returns Object).
 * "PixelSearch" is special because it outputs 2 variables.
 * In JS, we return an Object with 2 properties: X, Y.
 */
_PixelSearch(X1,Y1,X2,Y2,ColorID,Variation="",Flags=""){
	PixelSearch X,Y,%X1%,%Y1%,%X2%,%Y2%,%ColorID%,%Variation%,%Flags%
	return JS.Object("X",X, "Y",Y)
}


/**
 * Implementation: Normalization.
 */
_PostMessage(Msg,wParam="",lParam="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	PostMessage %Msg%,%wParam%,%lParam%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_Process(Cmd,PIDorName,Param3=""){
	Process %Cmd%,%PIDorName%,%Param3%
}


/**
 * Implementation: Normalization.
 */
_Progress(ProgressParam1,SubText="",MainText="",WinTitle="",FontName=""){
	Progress %ProgressParam1%,%SubText%,%MainText%,%WinTitle%,%FontName%
}


/**
 * Implementation: Major change.
 * "Random" is special because it accepts two modes:
 * 		1) Normal mode (with Min & Max as parameters). This is the default mode.
 *		2) Re-seeding mode (with NewSeed as parameter)
 * For the JS migration, the NewSeed mode can be activated by providing a third parameter (NewSeed),
 * in which case the first two parameters are disregarded.
 */
_Random(Min="",Max="",NewSeed=""){
	If (NewSeed) {
		Random,,%NewSeed%
	} else {
		Random OutputVar,%Min%,%Max%
		return OutputVar+0
	}
}


/**
 * Implementation: Normalization.
 */
_RegDelete(RootKey,SubKey,ValueName=""){
	RegDelete %RootKey%,%SubKey%,%ValueName%
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
_RegExMatch(Haystack, NeedleRegEx, StartingPosition=1, Advanced=0){
	if (Advanced) {
		RegExMatch(NeedleRegEx, "^\W+\)", flags)
		if (!flags) {
			NeedleRegEx := "O)" . NeedleRegEx
		} else {
			if (!InStr(flags, "O", true)) {
				NeedleRegEx := "O" . NeedleRegEx
			}
		}
		RegExMatch(Haystack, NeedleRegEx, Match, StartingPosition)
        
        Pos := JS.Array()
        Len := JS.Array()
        Value := JS.Array()
        Name := JS.Array()        
        a := ["Pos",Pos, "Len",Len, "Value",Value, "Name",Name, "Count",Match.Count(), "Mark",Match.Mark()]
		n := Match.Count() + 1
		Loop, %n%
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
		return RegExMatch(Haystack, NeedleRegEx, "", StartingPosition)
	}
}


/**
 * Implementation: Major change.
 * "RegExReplace" is special because it performs 2 roles:
 *		1) returns the replaced string. This mode is default (Advanced=0)
 *		2) fills the Count ByRef variable. This mode is triggered by non-empty values of Advanced. In this case,
 *		an Object will be returned, with 2 properties: Text, Count.
 */
_RegExReplace(Haystack, NeedleRegEx, Replacement="", Limit=-1, StartingPosition=1, Advanced=0){
	Text := RegExReplace(Haystack, NeedleRegEx, Replacement, Count, Limit, StartingPosition)
	if (Advanced) {
		return JS.Object("Text",Text, "Count",Count)
	} else {
		return Text
	}
}


/**
 * Implementation: Normalization.
 */
_RegRead(RootKey,SubKey,ValueName=""){
	RegRead OutputVar,%RootKey%,%SubKey%,%ValueName%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_RegWrite(ValueType,RootKey,SubKey,ValueName="",Value=""){
	RegWrite %ValueType%,%RootKey%,%SubKey%,%ValueName%,%Value%
}


/**
 * Implementation: Normalization.
 */
_Reload(){
	Reload 
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
    FileRead, content, %path%
    window.eval(content) ; seems to work ok in IE8 at this point
}


/**
 * Implementation: Normalization.
 */
_Run(Target, WorkingDir="", Flags=""){
	Run %Target%, %WorkingDir%, %Flags%, OutputVar
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_RunAs(User="",Password="",Domain=""){
	RunAs %User%,%Password%,%Domain%
}


/**
 * Implementation: Major change (doesn't return exit code).
 * "RunWait" is special because it sets a process ID which can be read by another thread.
 * For JS, we cannot implement this feature and therefore don't return any PID (as opposed to "Run")
 */
_RunWait(Target,WorkingDir="",Flags=""){
	RunWait %Target%, %WorkingDir%, %Flags%
}


/**
 * Implementation: Normalization.
 */
_Send(Keys){
	Send %Keys%
}


/**
 * Implementation: Normalization.
 */
_SendEvent(Keys){
	SendEvent %Keys%
}


/**
 * Implementation: Normalization.
 */
_SendInput(Keys){
	SendInput %Keys%
}


/**
 * Implementation: Normalization.
 */
_SendLevel(Level){
	SendLevel %Level%
}


/**
 * Implementation: Normalization.
 */
_SendMessage(Msg,wParam="",lParam="",Control="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText="",Timeout=""){
	SendMessage %Msg%,%wParam%,%lParam%,%Control%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%,%Timeout%
}


/**
 * Implementation: Normalization.
 */
_SendMode(Mode){
	SendMode %Mode%
}


/**
 * Implementation: Normalization.
 */
_SendPlay(Keys){
	SendPlay %Keys%
}


/**
 * Implementation: Normalization.
 */
_SendRaw(Keys){
	SendRaw %Keys%
}


/**
 * Implementation: Normalization.
 */
_SetBatchLines(IntervalOrLineCount){
	SetBatchLines %IntervalOrLineCount%
}


/**
 * Implementation: Normalization.
 */
_SetCapslockState(State=""){
	SetCapslockState %State%
}


/**
 * Implementation: Normalization.
 */
_SetControlDelay(Delay){
	SetControlDelay %Delay%
}


/**
 * Implementation: Normalization.
 */
_SetDefaultMouseSpeed(Speed){
	SetDefaultMouseSpeed %Speed%
}


/**
 * Implementation: Normalization.
 */
_SetFormat(NumberType,Format){
	SetFormat %NumberType%,%Format%
}


/**
 * Implementation: Normalization.
 */
_SetKeyDelay(Delay="",PressDuration="",Play=""){
	SetKeyDelay %Delay%,%PressDuration%,%Play%
}


/**
 * Implementation: Normalization.
 */
_SetMouseDelay(Delay,Play=""){
	SetMouseDelay %Delay%,%Play%
}


/**
 * Implementation: Normalization.
 */
_SetNumLockState(State=""){
	SetNumLockState %State%
}


/**
 * Implementation: Normalization.
 */
_SetRegView(RegView){
	SetRegView %RegView%
}


/**
 * Implementation: Normalization.
 */
_SetScrollLockState(State=""){
	SetScrollLockState %State%
}


/**
 * Implementation: Normalization.
 */
_SetStoreCapslockMode(OnOrOff){
	SetStoreCapslockMode %OnOrOff%
}


/**
 * Implementation: Normalization.
 */
_SetTitleMatchMode(Flag){
	SetTitleMatchMode %Flag%
}


/**
 * Implementation: Normalization.
 */
_SetWinDelay(Delay){
	SetWinDelay %Delay%
}


/**
 * Implementation: Normalization.
 */
_SetWorkingDir(DirName){
	SetWorkingDir %DirName%
}


/**
 * Implementation: Normalization.
 */
_Shutdown(Code){
	Shutdown %Code%
}


/**
 * Implementation: Normalization.
 */
_Sleep(DelayInMilliseconds){
	Sleep %DelayInMilliseconds%
}


/**
 * Implementation: Major change.
 * "Sort" is special because it modifies a ByRef variable.
 * For JS, we made it a return value.
 * TODO: implement the "F MyFunction" flag.
 */
_Sort(VarName,Options=""){
	Sort VarName, %Options%
	return VarName
}


/**
 * Implementation: Normalization.
 */
_SoundBeep(Frequency="",Duration=""){
	SoundBeep %Frequency%,%Duration%
}


/**
 * Implementation: Normalization.
 * "SoundGet" is special because it has multiple return types (Number or String).
 */
_SoundGet(ComponentType="",ControlType="",DeviceNumber=""){
	SoundGet OutputVar, %ComponentType%, %ControlType%, %DeviceNumber%
	static STRING_CONTROL_TYPES := {ONOFF:1, MUTE:1, MONO:1, LOUDNESS:1, STEREOENH:1, BASSBOOST:1}
	if (STRING_CONTROL_TYPES.HasKey(ControlType)) {
		return OutputVar
	} else {
		return OutputVar+0
	}
}


/**
 * Implementation: Normalization.
 */
_SoundGetWaveVolume(DeviceNumber=""){
	SoundGetWaveVolume OutputVar,%DeviceNumber%
	return OutputVar+0
}


/**
 * Implementation: Normalization.
 */
_SoundPlay(Filename,Wait=""){
	SoundPlay %Filename%,%Wait%
}


/**
 * Implementation: Normalization.
 */
_SoundSet(NewSetting,ComponentType="",ControlType="",DeviceNumber=""){
	SoundSet %NewSetting%,%ComponentType%,%ControlType%,%DeviceNumber%
}


/**
 * Implementation: Normalization.
 */
_SoundSetWaveVolume(Percent,DeviceNumber=""){
	SoundSetWaveVolume %Percent%,%DeviceNumber%
}


/**
 * Implementation: Normalization.
 */
_SplashImage(Param1,Options="",SubText="",MainText="",WinTitle="",FontName=""){
	SplashImage %Param1%,%Options%,%SubText%,%MainText%,%WinTitle%,%FontName%
}


/**
 * Implementation: Normalization.
 */
_SplashTextOff(){
	SplashTextOff 
}


/**
 * Implementation: Normalization.
 */
_SplashTextOn(Width="",Height="",Title="",Text=""){
	SplashTextOn %Width%,%Height%,%Title%,%Text%
}


/**
 * Implementation: Minor change (returns Object).
 * "SplitPath" is special because it outputs 5 variables.
 * In JS, we return an Object with 5 properties: FileName, Dir, Extension, NameNoExt, Drive
 */
_SplitPath(InputVar){
	SplitPath InputVar, FileName, Dir, Extension, NameNoExt, Drive
	return JS.Object("FileName",FileName, "Dir",Dir, "Extension",Extension, "NameNoExt",NameNoExt, "Drive",Drive)
}


/**
 * Implementation: Normalization.
 */
_StatusBarGetText(Part="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	StatusBarGetText OutputVar,%Part%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StatusBarWait(BarText="",Seconds="",Part#="",WinTitle="",WinText="",Interval="",ExcludeTitle="",ExcludeText=""){
	StatusBarWait %BarText%,%Seconds%,%Part#%,%WinTitle%,%WinText%,%Interval%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_StringCaseSense(Flag){
	StringCaseSense %Flag%
}


/**
 * Implementation: Normalization.
 */
_StringGetPos(InputVar,SearchText,LRFlag="",Offset=""){
	StringGetPos OutputVar,InputVar, %SearchText%,%LRFlag%,%Offset%
	return OutputVar+0
}


/**
 * Implementation: Normalization.
 */
_StringLeft(InputVar,Count){
	StringLeft OutputVar,InputVar,%Count%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringLen(InputVar){
	StringLen OutputVar,InputVar
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringLower(InputVar,T=""){
	StringLower OutputVar,InputVar,%T%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringMid(InputVar,StartChar,Count="",L=""){
	StringMid OutputVar,InputVar,%StartChar%,%Count%,%L%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringReplace(InputVar,SearchText,ReplaceText="",ReplaceAll=""){
	StringReplace OutputVar,InputVar,%SearchText%,%ReplaceText%,%ReplaceAll%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringRight(InputVar,Count){
	StringRight OutputVar,InputVar,%Count%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringTrimLeft(InputVar,Count){
	StringTrimLeft OutputVar,InputVar,%Count%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringTrimRight(InputVar,Count){
	StringTrimRight OutputVar,InputVar,%Count%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_StringUpper(InputVar,T=""){
	StringUpper OutputVar,InputVar,%T%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_Suspend(Mode=""){
	Suspend %Mode%
}


/**
 * Implementation: Minor change (returns Object).
 * "SysGet" is special because it has multiple return types (Number|String|Object).
 * If Subcommand="Monitor", the output will be an Object with 4 properties: Left, Top, Right, Bottom.
 * If Subcommand="MonitorName", the output will be String.
 * Otherwise, the output will be Number.
 */
_SysGet(Subcommand,Param2=""){
	SysGet v, %Subcommand%, %Param2%
	if (Subcommand == "Monitor") {
		return JS.Object("Left",vLeft, "Top",vTop, "Right",vRight, "Bottom",vBottom)
	} else if (Subcommand == "MonitorName") {
		return v
	} else {
        return v+0
    }
}


/**
 * Implementation: Normalization.
 */
_Thread(Subcommand,Param2="",Param3=""){
	Thread %Subcommand%,%Param2%,%Param3%
}


/**
 * Implementation: Normalization.
 */
_ToolTip(Text="",X="",Y="",WhichToolTip=""){
	ToolTip %Text%,%X%,%Y%,%WhichToolTip%
}


/**
 * Implementation: Normalization.
 * "Transform" is special because it has multiple return types (Number or String).
 */
_Transform(Cmd,Value1,Value2=""){
	Transform OutputVar, %Cmd%, %Value1%, %Value2%
	static STRING_COMMANDS := {Chr:1, HTML:1}
	if (STRING_COMMANDS.HasKey(Cmd)) {
		return OutputVar
	} else {
		return OutputVar+0
	}
}


/**
 * Implementation: Normalization.
 */
_TrayTip(Title="",Text="",Seconds="",Options=""){
	TrayTip %Title%,%Text%,%Seconds%,%Options%
}

/**
 * Implementation: Major change.
 * "TV_GetText" is special because it outputs 2 variables (a return value and a ByRef)
 * The migrated function has two modes:
 * 		1) the default mode (Advanced=0) is to return the retrieved text. Note that this behavior differs from the one in AHK.
 *		2) the advanced mode (Advanced non-empty) returns an object with 2 properties: Text, Success.
 */
_TV_GetText(ItemID, Advanced=0){
	if (Advanced) {
        Success := TV_GetText(OutputVar, ItemID)
		return JS.Object("Text", OutputVar, "Success",Success)
	} else {
		TV_GetText(OutputVar, ItemID)
		return OutputVar
	}
}


/**
 * Implementation: Normalization.
 */
_UrlDownloadToFile(URL,Filename){
	UrlDownloadToFile %URL%,%Filename%
}


/**
 * Implementation: Normalization.
 */
_WinActivate(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinActivate %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinActivateBottom(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinActivateBottom %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinClose(WinTitle="",WinText="",SecondsToWait="",ExcludeTitle="",ExcludeText=""){
	WinClose %WinTitle%,%WinText%,%SecondsToWait%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Minor change (returns Object).
 * "WinGet" is special because it may output an pseudo-array.
 * In JS, if Cmd=List, we return an Array of Numbers.
 * TODO: implement the List Cmd
 */
_WinGet(Cmd="",WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinGet OutputVar,%Cmd%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
    StringLower, Cmd, Cmd
    static STRING_COMMANDS := {ProcessName:1, ProcessPath:1, ControlList:1, ControlListHwnd:1, Style:1, ExStyle:1}
    if (Cmd == "list") {
        a := []
        Loop, %OutputVar%
        {
            a.Insert(OutputVar%A_Index% + 0)
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
 * "WinGetActiveStats" is special because it outputs 5 variables.
 * In JS, we return an Object with 5 properties: X, Y, Width, Height, Title.
 */
_WinGetActiveStats(){
	WinGetActiveStats Title,Width,Height,X,Y
	return JS.Object("Title",Title, "Width",Width, "Height",Height, "X",X, "Y",Y)
}


/**
 * Implementation: Normalization.
 */
_WinGetActiveTitle(){
	WinGetActiveTitle OutputVar
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_WinGetClass(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinGetClass OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Minor change (returns Object).
 * "WinGetPos" is special because it outputs 4 variables.
 * In JS, we return an Object with 4 properties: X, Y, Width, Height.
 */
_WinGetPos(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinGetPos X, Y, Width, Height, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	return JS.Object("Width",Width, "Height",Height, "X",X, "Y",Y)
}


/**
 * Implementation: Normalization.
 */
_WinGetText(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinGetText OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_WinGetTitle(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinGetTitle OutputVar,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
	return OutputVar
}


/**
 * Implementation: Normalization.
 */
_WinHide(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinHide %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinKill(WinTitle="",WinText="",SecondsToWait="",ExcludeTitle="",ExcludeText=""){
	WinKill %WinTitle%,%WinText%,%SecondsToWait%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinMaximize(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinMaximize %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinMenuSelectItem(WinTitle,WinText,Menu,SubMenu1="",SubMenu2="",SubMenu3="",SubMenu4="",SubMenu5="",SubMenu6="",ExcludeTitle="",ExcludeText=""){
	WinMenuSelectItem %WinTitle%,%WinText%,%Menu%,%SubMenu1%,%SubMenu2%,%SubMenu3%,%SubMenu4%,%SubMenu5%,%SubMenu6%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinMinimize(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinMinimize %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinMinimizeAll(){
	WinMinimizeAll 
}


/**
 * Implementation: Normalization.
 */
_WinMinimizeAllUndo(){
	WinMinimizeAllUndo 
}


/**
 * Implementation: Normalization.
 */
_WinMove(Param1,Param2,X="",Y="",Width="",Height="",ExcludeTitle="",ExcludeText=""){
	WinMove %Param1%,%Param2%,%X%,%Y%,%Width%,%Height%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinRestore(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinRestore %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinSet(Attribute,Value,WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinSet %Attribute%,%Value%,%WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinSetTitle(Param1,WinText,NewTitle,ExcludeTitle="",ExcludeText=""){
	WinSetTitle %Param1%,%WinText%,%NewTitle%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinShow(WinTitle="",WinText="",ExcludeTitle="",ExcludeText=""){
	WinShow %WinTitle%,%WinText%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinWait(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText=""){
	WinWait %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinWaitActive(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText=""){
	WinWaitActive %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinWaitClose(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText=""){
	WinWaitClose %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
}


/**
 * Implementation: Normalization.
 */
_WinWaitNotActive(WinTitle="",WinText="",Seconds="",ExcludeTitle="",ExcludeText=""){
	WinWaitNotActive %WinTitle%,%WinText%,%Seconds%,%ExcludeTitle%,%ExcludeText%
}