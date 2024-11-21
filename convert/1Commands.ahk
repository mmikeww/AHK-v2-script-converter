#Requires AutoHotKey v2.0

/* Commands and How to convert them
  Specification format:
    , "CommandName,Param1,Param2,etc",
      "Replacement string format" (see below)
    ↑ first comma is not needed for the first pair
  Param format:
    - param names ending in "T2E" will convert a literal Text param TO an Expression
        this would be used when converting a Command to a Func or otherwise needing an expr
        such as      word -> "word"      or      %var% -> var
        Changed: empty strings will return an emty string
        like the 'value' param in those  `IfEqual, var, value`  commands
    - param names ending in "T2QE" will convert a literal Text param TO an Quoted Expression
        this would be used when converting a Command to a expr
        This is the same as T2E, but will return an "" if empty.
    - param names ending in "Q2T" will convert a Quoted Text param TO text
        this would be used when converting a function variable that holds a label or function
        "WM_LBUTTONDOWN" => WM_LBUTTONDOWN
    - param names ending in "CBE2E" would convert parameters that 'Can Be an Expression TO an EXPR'
        this would only be used if the conversion goes from Command to Func
        we'd need to strip a preceeding "% " which was used to force an expr when it was unnecessary
    - param names ending in "CBE2T" would convert parameters that 'Can Be an Expression TO literal TEXT'
        this would be used if the conversion goes from Command to Command
        because in v2, those command parameters can no longer optionally be an expression.
        these will be wrapped in %%s, so   expr+1   is now    %expr+1%
    - param names ending in "V2VR" would convert an output variable name to a v2 VarRef
        basically it will just add an & at the start. so var -> &var
    - param names ending in "V2VRM" would convert an output variable name to a v2 VarRef
        same as V2VR but adds a placeholder name if blank, only use if its mandatory param in v2
    - param names ending in "On2True" would convert an OnOff Parameter name to a Mode
        On  => True
        Off => False
    - param names ending in "*" means there could be an unlimited amount of params after
        more common in functions, prevents program from warning extra params
        DllCall will have different params, compared to the dll's function
    - any other param name will not be converted
        this means that the literal text of the parameter is unchanged
        this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
  Replacement format:
    - use {1} which corresponds to Param1, etc
    - use asterisk * and a function name to call, for custom processing when the params dont directly match up
*/

; SplashTextOn and SplashTextOff are removed, but alternative gui code is available
global gAhkCmdsToRemove := "
   (
      #AllowSameLineComments
      #CommentFlag
      #Delimiter
      #DerefChar
      #EscapeChar
      #LTrim
      #MaxMem
      #NoEnv
      SetBatchLines
      SetFormat
      SoundGetWaveVolume
      SoundSetWaveVolume
      SplashImage
      A_FormatInteger
      A_FormatFloat
      AutoTrim
   )"

global gmAhkCmdsToConvert := OrderedMap(
    "BlockInput,OptionT2E" ,
    "BlockInput({1})"
  , "DriveSpaceFree,OutputVar,PathT2E" ,
    "{1} := DriveGetSpaceFree({2})"
  , "Click,keysT2E" ,
    "Click({1})"
  , "ClipWait,Timeout,WaitForAnyData" ,
    "Errorlevel := !ClipWait({1}, {2})"
  , "Control,SubCommand,ValueT2E,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_Control"
  , "ControlClick,Control-or-PosT2E,WinTitleT2E,WinTextT2E,WhichButtonT2E,ClickCountT2E,OptionsT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlClick({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})"
  , "ControlFocus,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlFocus({1}, {2}, {3}, {4}, {5})"
  , "ControlGet,OutputVar,SubCommand,ValueT2E,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_ControlGet"
  , "ControlGetFocus,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_ControlGetFocus"
  , "ControlGetPos,XV2VR,YV2VR,WidthV2VR,HeightV2VR,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlGetPos({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})"
  , "ControlGetText,OutputVar,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "{1} := ControlGetText({2}, {3}, {4}, {5}, {6})"
  , "ControlMove,ControlT2E,XCBE2E,YCBE2E,WidthCBE2E,HeightT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlMove({2}, {3}, {4}, {5}, {1}, {6}, {7}, {8}, {9})"
  , "ControlSend,ControlT2E,KeysT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlSend({2}, {1}, {3}, {4}, {5}, {6})"
  , "ControlSendRaw,ControlT2E,KeysT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlSendText({2}, {1}, {3}, {4}, {5}, {6})"
  , "ControlSetText,ControlT2E,NewTextT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "ControlSetText({2}, {1}, {3}, {4}, {5}, {6})"
  , "CoordMode,TargetTypeT2E,RelativeToT2E" ,
    "*_CoordMode"
  , "Critical,OnOffNumericT2E" ,
    "Critical({1})" ; The use of On2True is discouraged and unnecessary.
  , "DetectHiddenText,ModeOn2True" ,
    "DetectHiddenText({1})"
  , "DetectHiddenWindows,ModeOn2True" ,
    "DetectHiddenWindows({1})"
  , "Drive,SubCommand,Value1,Value2" ,
    "*_Drive"
  , "DriveGet,OutputVar,SubCommand,ValueT2E" ,
    "{1} := DriveGet{2}({3})"
  , "Edit" ,
    "Edit()"
  , "EnvAdd,var,valueCBE2E,TimeUnitsT2E" ,
    "*_EnvAdd"
  , "EnvSet,EnvVarT2E,ValueT2E" ,
    "EnvSet({1}, {2})"
  , "EnvSub,var,valueCBE2E,TimeUnitsT2E" ,
    "*_EnvSub"
  , "EnvDiv,var,valueCBE2E" ,
    "{1} /= {2}"
  , "EnvGet,OutputVar,EnvVarNameT2E" ,
    "{1} := EnvGet({2})"
  , "EnvMult,var,valueCBE2E" ,
    "{1} *= {2}"
  , "EnvUpdate" ,
    'SendMessage, `% WM_SETTINGCHANGE := 0x001A, 0, Environment,, `% "ahk_id " . HWND_BROADCAST := "0xFFFF"'
  , "Exit,ExitCode" ,
    "Exit({1})"
  , "ExitApp,ExitCode" ,
    "ExitApp({1})"
  , "FileAppend,textT2E,fileT2E,encT2E" ,
    "FileAppend({1}, {2}, {3})"
  , "FileCopyDir,sourceT2E,destT2E,flagCBE2E" ,
    "*_FileCopyDir"
  , "FileCopy,sourceT2E,destT2E,OverwriteCBE2E" ,
    "*_FileCopy"
  , "FileCreateDir,dirT2E" ,
    "DirCreate({1})"
  , "FileCreateShortcut,TargetT2E,LinkFileT2E,WorkingDirT2E,ArgsT2E,DescriptionT2E,IconFileT2E,ShortcutKeyT2E,IconNumberT2E,RunStateT2E" ,
    "FileCreateShortcut({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})"
  , "FileDelete,dirT2E" ,
    "FileDelete({1})"
  , "FileEncoding,FilePatternT2E" ,
    "FileEncoding({1})"
  , "FileGetAttrib,OutputVar,FilenameT2E" ,
    "{1} := FileGetAttrib({2})"
  , "FileGetSize,OutputVar,FilenameT2E,unitsT2E" ,
    "{1} := FileGetSize({2}, {3})"
  , "FileGetTime,OutputVar,FilenameT2E,WhichTimeT2E" ,
    "{1} := FileGetTime({2}, {3})"
  , "FileGetVersion,OutputVar,FilenameT2E" ,
    "{1} := FileGetVersion({2})"
  , "FileGetShortcut,LinkFileT2E,OutTargetV2VR,OutDirV2VR,OutArgsV2VR,OutDescriptionV2VR,OutIconV2VR,OutIconNumV2VR,OutRunStateV2VR" ,
    "FileGetShortcut({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})"
  , "FileInstall,SourceT2E,DestT2E,OverwriteT2E" ,
    "FileInstall({1}, {2}, {3})"
  , "FileMove,SourceT2E,DestPatternT2E,OverwriteT2E" ,
    "*_FileMove"
  , "FileMoveDir,SourceT2E,DestT2E,FlagT2E" ,
    "DirMove({1}, {2}, {3})"
  , "FileRead,OutputVar,Filename" ,
    "*_FileRead"
  , "FileReadLine,OutputVar,FilenameT2E,LineNumCBE2E" ,
    "*_FileReadLine"
  , "FileRecycle,FilePatternT2E" ,
    "FileRecycle({1})"
  , "FileRecycleEmpty,FilePatternT2E" ,
    "FileRecycleEmpty({1})"
  , "FileRemoveDir,dirT2E,recurse" ,
    "DirDelete({1}, {2})"
  , "FileSelectFile,var,opts,rootdirfile,prompt,filter" ,
    "*_FileSelect"
  , "FileSelectFolder,var,startingdirT2E,opts,promptT2E" ,
    "{1} := DirSelect({2}, {3}, {4})"
  , "FileSetAttrib,AttributesT2E,FilePatternT2E,OperateOnFolders,Recurse" ,
    "*_FileSetAttrib"
  , "FileSetTime,YYYYMMDDHH24MISST2E,FilePatternT2E,WhichTimeT2E,OperateOnFolders,Recurse" ,
    "*_FileSetTime"
  , "FormatTime,outVar,dateT2E,formatT2E" ,
    "{1} := FormatTime({2}, {3})"
  , "GetKeyState,OutputVar,KeyNameT2E,ModeT2E" ,
    '{1} := GetKeyState({2}, {3}) ? "D" : "U"'
  , "Gui,SubCommand,Value1,Value2,Value3" ,
    "*_Gui"
  , "GuiControl,SubCommand,ControlID,Value" ,
    "*_GuiControl"
  , "GuiControlGet,OutputVar,SubCommand,ControlID,Value" ,
    "*_GuiControlGet"
  , "Gosub,Label" ,
    "*_Gosub"
  , "Goto,LabelT2E" ,
    "Goto({1})"
  , "GroupActivate,GroupNameT2E,ModeT2E" ,
    "GroupActivate({1}, {2})"
  , "GroupAdd,GroupNameT2E,WinTitleT2E,WinTextT2E,LabelT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "GroupAdd({1}, {2}, {3}, {4}, {5}, {6})"
  , "GroupClose,GroupNameT2E,ModeT2E" ,
    "GroupClose({1}, {2})"
  , "GroupDeactivate,GroupNameT2E,ModeT2E" ,
    "GroupDeactivate({1}, {2})"
  , "Hotkey,Var1,Var2CBE2E,Var3" ,
    "*_Hotkey"
  , "KeyWait,KeyNameT2E,OptionsT2E" ,
    "*_KeyWait"
  , "IfEqual,var,valueT2QE" ,
    "if ({1} = {2})"
  , "IfNotEqual,var,valueT2QE" ,
    "if ({1} != {2})"
  , "IfGreater,var,valueT2QE" ,
    "*_IfGreater"
  , "IfGreaterOrEqual,var,valueT2QE" ,
    "*_IfGreaterOrEqual"
  , "IfLess,var,valueT2QE" ,
    "*_IfLess"
  , "IfLessOrEqual,var,valueT2QE" ,
    "*_IfLessOrEqual"
  , "IfInString,var,valueT2E" ,
    "if InStr({1}, {2})"
  , "IfMsgBox,ButtonNameT2E" ,
    "if (msgResult = {1})"
  , "IfNotInString,var,valueT2E" ,
    "if !InStr({1}, {2})"
  , "IfExist,fileT2E" ,
    "if FileExist({1})"
  , "IfNotExist,fileT2E" ,
    "if !FileExist({1})"
  , "IfWinExist,titleT2E,textT2E,excltitleT2E,excltextT2E" ,
    "if WinExist({1}, {2}, {3}, {4})"
  , "IfWinNotExist,titleT2E,textT2E,excltitleT2E,excltextT2E" ,
    "if !WinExist({1}, {2}, {3}, {4})"
  , "IfWinActive,titleT2E,textT2E,excltitleT2E,excltextT2E" ,
    "if WinActive({1}, {2}, {3}, {4})"
  , "IfWinNotActive,titleT2E,textT2E,excltitleT2E,excltextT2E" ,
    "if !WinActive({1}, {2}, {3}, {4})"
  , "ImageSearch,OutputVarXV2VRM,OutputVarYV2VRM,X1CBE2E,Y1CBE2E,X2CBE2E,Y2CBE2E,ImageFileT2E" ,
    "ErrorLevel := !ImageSearch({1}, {2}, {3}, {4}, {5}, {6}, {7})"
  , "IniDelete,FilenameT2E,SectionT2E,KeyT2E" ,
    "IniDelete({1}, {2}, {3})"
  , "IniRead,OutputVar,FilenameT2E,SectionT2E,KeyT2E,DefaultT2E" ,
    "{1} := IniRead({2}, {3}, {4}, {5})"
  , "IniWrite,ValueT2E,FilenameT2E,SectionT2E,KeyT2E" ,
    "IniWrite({1}, {2}, {3}, {4})"
  , "Input,OutputVar,OptionsT2E,EndKeysT2E,MatchListT2E" ,
    "*_input"
  , "Inputbox,OutputVar,Title,Prompt,HIDE,WidthCBE2E,HeightCBE2E,XCBE2E,YCBE2E,Locale,TimeoutCBE2E,Default" ,
    "*_InputBox"
  , "ListHotkeys" ,
    "ListHotkeys()"
  , "ListLines, ModeOn2True" ,
    "ListLines({1})"
  , "ListVars" ,
    "ListVars()"
  , "Loop,one,two,three,four" ,
    "*_Loop"
  , "Menu,MenuName,SubCommand,Value1,Value2,Value3,Value4" ,
    "*_Menu"
  , "MsgBox,TextOrOptions,Title,Text,Timeout" ,
    "*_MsgBox"
  , "MouseGetPos,OutputVarXV2VR,OutputVarYV2VR,OutputVarWinV2VR,OutputVarControlV2VR,Flag"       , "MouseGetPos({1}, {2}, {3}, {4}, {5})"
  , "MouseClick,WhichButtonT2E,XCBE2E,YCBE2E,ClickCountCBE2E,SpeedCBE2E,DownOrUpT2E,RelativeT2E" ,
    "MouseClick({1}, {2}, {3}, {4}, {5}, {6}, {7})"
  , "MouseClickDrag,WhichButtonT2E,X1CBE2E,Y1CBE2E,X2CBE2E,Y2CBE2E,SpeedCBE2E,RelativeT2E"       , "MouseClickDrag({1}, {2}, {3}, {4}, {5}, {6}, {7})"
  , "MouseMove,XCBE2E,YCBE2E,SpeedCBE2E,RelativeT2E" ,
    "MouseMove({1}, {2}, {3}, {4})"
  , "OnExit,Func,AddRemove" ,
    "*_OnExit"
  , "OutputDebug,TextT2E" ,
    "OutputDebug({1})"
  , "Pause,OnOffToggleOn2True,OperateOnUnderlyingThread " ,
    "*_Pause"
  , "PixelGetColor,OutputVar,XCBE2E,YCBE2E,ModeT2E" ,
    "*_PixelGetColor"
  , "PixelSearch,OutputVarXV2VRM,OutputVarYV2VRM,X1CBE2E,Y1CBE2E,X2CBE2E,Y2CBE2E,ColorIDCBE2E,VariationCBE2E,ModeT2E" ,
    "*_PixelSearch"
  , "PostMessage,MsgCBE2E,wParamCBE2E,lParamCBE2E,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "PostMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})"
  , "Process,SubCommand,PIDOrNameT2E,ValueT2E" ,
    "*_Process"
  , "Progress, ProgressParam1,SubTextT2E,MainTextT2E,WinTitleT2E,FontNameT2E" ,
    "*_Progress"
  , "Random,OutputVar,MinCBE2E,MaxCBE2E" ,
    "*_Random"
  , "RegRead,OutputVar,KeyName,ValueName,var4" ,
    "*_RegRead"
  , "RegWrite,ValueTypeT2E,KeyNameT2E,var3T2E,var4T2E,var5T2E" ,
    "*_RegWrite"
  , "RegDelete,var1,var2,var3" ,
    "*_RegDelete"
  , "Reload" ,
    "Reload()"
  , "RunAs,UserT2E,PasswordT2E,DomainT2E" ,
    "RunAs({1}, {2}, {3})"
  , "Run,TargetT2E,WorkingDirT2E,OptionsT2E,OutputVarPIDV2VR" ,
    "*_Run"
  , "RunWait,TargetT2E,WorkingDirT2E,OptionsT2E,OutputVarPIDV2VR" ,
    "RunWait({1}, {2}, {3}, {4})"
  , "SetCapsLockState, StateT2E" ,
    "SetCapsLockState({1})"
  , "SetControlDelay,DelayCBE2E" ,
    "SetControlDelay({1})"
  , "SetEnv,var,valueT2E" ,
    "{1} := {2}"
  , "SetNumLockState, StateT2E" ,
    "SetNumLockState({1})"
  , "SetKeyDelay,DelayCBE2E,PressDurationCBE2E,PlayT2E" ,
    "SetKeyDelay({1}, {2}, {3})"
  , "SetMouseDelay,DelayCBE2E,PlayT2E" ,
    "SetMouseDelay({1}, {2})"
  , "SetRegView, RegViewT2E" ,
    "SetRegView({1})"
  , "SetScrollLockState, StateT2E" ,
    "SetScrollLockState({1})"
  , "SetStoreCapsLockMode,OnOffOn2True" ,
    "SetStoreCapsLockMode({1})"
  , "SetTimer,LabelCBE2E,PeriodOnOffDeleteCBE2E,PriorityCBE2E" ,
    "*_SetTimer"
  , "SetTitleMatchMode,MatchModeT2E" ,
    "SetTitleMatchMode({1})"
  , "SetWinDelay,DelayCBE2E" ,
    "SetWinDelay({1})"
  , "SetWorkingDir,DirNameT2E" ,
    "SetWorkingDir({1})"
  , "Send,keysT2E" ,
    "Send({1})"
  , "SendText,keysT2E" ,
    "SendText({1})"
  , "SendMode,ModeT2E" ,
    "SendMode({1})"
  , "SendMessage,MsgCBE2E,wParamCBE2E,lParamCBE2E,ControlT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E,TimeoutCBE2E" ,
    "*_SendMessage"
  , "SendInput,keysT2E" ,
    "SendInput({1})"
  , "SendLevel,LevelT2E" ,
    "SendLevel({1})"
  , "SendRaw,keys" ,
    "*_SendRaw"
  , "SetDefaultMouseSpeed, LevelT2E" ,
    "SetDefaultMouseSpeed({1})"
  , "SendPlay,keysT2E" ,
    "SendPlay({1})"
  , "SendEvent,keysT2E" ,
    "SendEvent({1})"
  , "SendEvent,keysT2E" ,
    "SendEvent({1})"
  , "Shutdown, FlagCBE2E" ,
    "Shutdown({1})"
  , "Sleep,delayCBE2E" ,
    "Sleep({1})"
  , "Sort,var,optionsT2E" ,
    "*_Sort"
  , "SoundBeep,FrequencyCBE2E,DurationCBE2E" ,
    "SoundBeep({1}, {2})"
  , "SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E" ,
    "*_SoundGet"
  , "SoundPlay,FrequencyT2E,DurationCBE2E" ,
    "SoundPlay({1}, {2})"
  , "SoundSet,NewSetting,ComponentTypeT2E,ControlType,DeviceNumberT2E" ,
    "*_SoundSet"
  , "SplashTextOn,Width,Height,TitleT2E,TextT2E" ,
    "*_SplashTextOn"
  , "SplashTextOff" ,
    "SplashTextGui.Destroy"
  , "SplashImage,ImageFileT2E,Options,SubTextT2E,MainTextT2E,WinTitleT2E,FontNameT2E" ,
    "*_SplashImage"
  , "SplitPath,varCBE2E,filenameV2VR,dirV2VR,extV2VR,name_no_extV2VR,drvV2VR" ,
    "SplitPath({1}, {2}, {3}, {4}, {5}, {6})"
  , "StatusBarGetText,Part,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "{1} := StatusBarGetText({2}, {3}, {4}, {5})"
  , "StatusBarWait,BarTextT2E,Timeout,Part,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    " StatusBarWait({1}, {2}, {3}, {4}, {5}, {6})"
  , "StringCaseSense,param" ,
    ";REMOVED StringCaseSense, {1}"
  , "StringGetPos,OutputVar,InputVar,SearchTextT2E,SideT2E,OffsetCBE2E" ,
    "*_StringGetPos"
  , "StringLen,OutputVar,InputVar" ,
    "{1} := StrLen({2})"
  , "StringLeft,OutputVar,InputVar,CountCBE2E" ,
    "{1} := SubStr({2}, 1, {3})"
  , "StringMid,OutputVar,InputVar,StartCharCBE2E,CountCBE2E,L_T2E" ,
    "*_StringMid"
  , "StringRight,OutputVar,InputVar,CountCBE2E" ,
    "{1} := SubStr({2}, -1*({3}))"
  , "StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E" ,
    "*_StringSplit"
  , "StringTrimLeft,OutputVar,InputVar,CountCBE2E" ,
    "{1} := SubStr({2}, ({3})+1)"
  , "StringTrimRight,OutputVar,InputVar,CountCBE2E" ,
    "{1} := SubStr({2}, 1, -1*({3}))"
  , "StringUpper,OutputVar,InputVar,TT2E" ,
    "*_StringUpper"
  , "StringLower,OutputVar,InputVar,TT2E" ,
    "*_StringLower"
  , "StringReplace,OutputVar,InputVar,SearchTxtT2E,ReplTxtT2E,ReplAll" ,
    "*_StringReplace"
  , "Suspend,ModeOn2True" ,
    "*_SuspendV2"
  , "SysGet,OutputVar,SubCommand,ValueCBE2E" ,
    "*_SysGet"
  , "Thread,SubCommandT2E,Value1CBE2E,Value2CBE2E" ,
    "Thread({1}, {2}, {3})"
  , "ToolTip,txtT2E,xCBE2E,yCBE2E,whichCBE2E" ,
    "ToolTip({1}, {2}, {3}, {4})"
  , "TrayTip,TitleT2E,TextT2E,Seconds,OptionsT2E" ,
    "TrayTip({1}, {2}, {4})"
  , "Transform,OutputVar,SubCommand,Value1T2E,Value2T2E" ,
    " *_Transform"
  , "UrlDownloadToFile,URLT2E,FilenameT2E" ,
    "Download({1},{2})"
  , "WinActivate,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinActivate({1}, {2}, {3}, {4})"
  , "WinActivateBottom,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinActivateBottom({1}, {2}, {3}, {4})"
  , "WinClose,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinClose({1}, {2}, {3}, {4}, {5})"
  , "WinGet,OutputVar,SubCommand,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinGet"
  , "WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar" ,
    "*_WinGetActiveStats"
  , "WinGetActiveTitle,OutputVar" ,
    '{1} := WinGetTitle("A")'
  , "WinGetClass,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "{1} := WinGetClass({2}, {3}, {4}, {5})"
  , "WinGetText,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "{1} := WinGetText({2}, {3}, {4}, {5})"
  , "WinGetTitle,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "{1} := WinGetTitle({2}, {3}, {4}, {5})"
  , "WinGetPos,XV2VR,YV2VR,WidthV2VR,HeightV2VR,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinGetPos({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})"
  , "WinHide,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinHide({1}, {2}, {3}, {4})"
  , "WinKill,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinKill({1}, {2}, {3}, {4}, {5})"
  , "WinMaximize,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinMaximize({1}, {2}, {3}, {4})"
  , "WinMinimize,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinMinimize({1}, {2}, {3}, {4})"
  , "WinMove,val1,val2,XCBE2E,YCBE2E,WidthCBE2E,HeightCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinMove"
  , "WinMenuSelectItem,WinTitleT2E,WinTextT2E,MenuT2E,SubMenu1T2E,SubMenu2T2E,SubMenu3T2E,SubMenu4T2E,SubMenu5T2E,SubMenu6T2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "MenuSelect({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})"
  , "WinSet,SubCommand,ValueT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinSet"
  , "WinSetTitle,WinTitleT2E,WinTextT2E,NewTitleT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinSetTitle"
  , "WinRestore,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinRestore({1}, {2}, {3}, {4})"
  , "WinShow,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "WinShow({1}, {2}, {3}, {4})"
  , "WinWait,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinWait"
  , "WinWaitActive,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinWaitActive"
  , "WinWaitNotActive,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinWaitNotActive"
  , "WinWaitClose,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E" ,
    "*_WinWaitClose"
  , "#ClipboardTimeout, MillisecondsCBE2E" ,
    "#ClipboardTimeout {1}"
  , "#ErrorStdOut,EncodingCBE2E" ,
    "#ErrorStdOut {1}"
  , "#HotkeyInterval,MillisecondsCBE2E" ,
    "A_HotkeyInterval := {1}"
  , "#HotkeyModifierTimeout,MillisecondsCBE2E" ,
    "A_HotkeyModifierTimeout := {1}"
  , "#HotString,ExpressionCBE2E" ,
    "#HotString {1}"
  , "#If,ExpressionCBE2E" ,
    "#HotIf {1}"
  , "#IfTimeout,ExpressionCBE2E" ,
    "#HotIfTimeout {1}"
  , "#Include,FileOrDirName" ,
    "#Include `"{1}`""
  , "#IncludeAgain,FileOrDirName" ,
    "#IncludeAgain `"{1}`""
  , "#InputLevel,LevelCBE2E" ,
    "#InputLevel {1}"
  , "#IfWinActive,WinTitleT2E,WinTextT2E" ,
    "*_HashtagIfWinActivate"
  , "#IfWinExist,WinTitleT2E,WinTextT2E" ,
    "#HotIf WinExist({1}, {2})"
  , "#IfWinNotActive,WinTitleT2E,WinTextT2E" ,
    "#HotIf !WinActive({1}, {2})"
  , "#IfWinNotExist,WinTitleT2E,WinTextT2E" ,
    "#HotIf !WinExist({1}, {2})"
  , "#InputLevel,LevelCBE2E" ,
    "#InputLevel {1}"
  , "#InstallKeybdHook" ,
    "InstallKeybdHook()"
  , "#InstallMouseHook" ,
    "InstallMouseHook()"
  , "#KeyHistory,MaxEventsCBE2E" ,
    "KeyHistory({1})"
  , "#MaxHotkeysPerInterval,ValueCBE2E" ,
    "A_MaxHotkeysPerInterval := {1}"
  , "#MaxThreads,ValueCBE2E" ,
    "#MaxThreads {1}"
  , "#MaxThreadsBuffer,OnOffOn2True" ,
    "#MaxThreadsBuffer {1}"
  , "#MaxThreadsPerHotkey,ValueCBE2E" ,
    "#MaxThreadsPerHotkey {1}"
  , "#MenuMaskKey,KeyNameT2E" ,
    "A_MenuMaskKey := {1}"
  , "#Persistent" ,
    "Persistent"
  , "#Requires,AutoHotkey Version" ,
    "#Requires Autohotkey v2.0"
  , "#SingleInstance, ForceIgnorePromptOff" ,
    "#SingleInstance {1}"
  , "#UseHook,OnOffOn2True" ,
    "#UseHook {1}"
  , "#Warn,WarningType,WarningMode" ,
    "*_HashtagWarn"
  )
;################################################################################
FindCommandDefinitions(Command, &v1:=unset, &v2:=unset) {
    for v1_, v2_ in gmAhkCmdsToConvert {
      if (v1_ ~= "i)^\s*\Q" Command "\E\s*(,|$)") {
        v1 := v1_
        v2 := v2_
        return true
      }
    }
    return false
  }