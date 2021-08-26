#Requires AutoHotKey v2.0-beta.1
#SingleInstance Force

; to do: strsplit (old command)
; requires should change the version :D

Convert(ScriptString)
{
   global ScriptStringsUsed := Array() ; Keeps an array of interesting strings used in the script
   ScriptStringsUsed.ErrorLevel := InStr(ScriptString, "ErrorLevel")
   ScriptStringsUsed.IfMsgBox := InStr(ScriptString, "IfMsgBox")

   global aListPseudoArray := Array() ; list of strings that should be converted from pseudoArray to Array
   global aListMatchObject := Array() ; list of strings that should be converted from Match Object V1 to Match Object V2
   global Orig_Line
   global Orig_Line_NoComment
   global oScriptString ; array of all the lines
   global O_Index :=0 ; current index of the lines
   global Indentation
   global GuiNameDefault
   global GuiList
   global GuiVList ; Used to list all variable names defined in a Gui
   global MenuList
   
   global ListViewNameDefault
   global TreeViewNameDefault
   global StatusBarNameDefault
   global gFunctPar

   GuiNameDefault := "myGui"
   ListViewNameDefault := "LV"
   TreeViewNameDefault := "TV"
   StatusBarNameDefault := "SB"
   GuiList := "|"
   MenuList := "|"
   GuiVList := Map()

   
   ;// Commands and How to convert them
   ;// Specification format:
   ;//          CommandName,Param1,Param2,etc | Replacement string format (see below)
   ;// Param format:
   ;//          - param names ending in "T2E" will convert a literal Text param TO an Expression
   ;//              this would be used when converting a Command to a Func or otherwise needing an expr
   ;//              such as      word -> "word"      or      %var% -> var
   ;//              Changed: empty strings will return an emty string
   ;//              like the 'value' param in those  `IfEqual, var, value`  commands
   ;//          - param names ending in "T2QE" will convert a literal Text param TO an Quoted Expression
   ;//              this would be used when converting a Command to a expr
   ;//              This is the same as T2E, but will return an "" if empty.
   ;//          - param names ending in "CBE2E" would convert parameters that 'Can Be an Expression TO an EXPR' 
   ;//              this would only be used if the conversion goes from Command to Func 
   ;//              we'd need to strip a preceeding "% " which was used to force an expr when it was unnecessary 
   ;//          - param names ending in "CBE2T" would convert parameters that 'Can Be an Expression TO literal TEXT'
   ;//              this would be used if the conversion goes from Command to Command
   ;//              because in v2, those command parameters can no longer optionally be an expression.
   ;//              these will be wrapped in %%s, so   expr+1   is now    %expr+1%
   ;//          - param names ending in "V2VR" would convert an output variable name to a v2 VarRef
   ;//              basically it will just add an & at the start. so var -> &var
   ;//          - any other param name will not be converted
   ;//              this means that the literal text of the parameter is unchanged
   ;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
   ;// Replacement format: 
   ;//          - use {1} which corresponds to Param1, etc
   ;//          - use asterisk * and a function name to call, for custom processing when the params dont directly match up
   CommandsToConvert := "
   (
      BlockInput,Option | BlockInput {1}
      DriveSpaceFree,OutputVar,PathT2E | {1} := DriveGetSpaceFree({2})
      Click,keysT2E | Click({1})
      ClipWait,Timeout,WaitForAnyData | Errorlevel := !ClipWait({1},{2})
      Control,SubCommand,ValueT2E,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | *_Control
      ControlClick,Control-or-PosCBE2E,WinTitleT2E,WinTextT2E,WhichButtonT2E,ClickCountT2E,OptionsT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlClick({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
      ControlFocus,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlFocus({1}, {2}, {3}, {4}, {5})
      ControlGet,OutputVar,SubCommand,ValueT2E,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | *_ControlGet
      ControlGetFocus,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | *_ControlGetFocus
      ControlGetPos,XV2VR,YV2VR,WidthV2VR,HeightV2VR,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlGetPos({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
      ControlGetText,OutputVar,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | {1} := ControlGetText({2}, {3}, {4}, {5}, {6})
      ControlMove,ControlCBE2E,XCBE2E,YCBE2E,WidthCBE2E,HeightT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlMove({2}, {3}, {4}, {5}, {1}, {6}, {7}, {8}, {9})
      ControlSend,ControlCBE2E,KeysT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlSend({2}, {1}, {3}, {4}, {5}, {6})
      ControlSendRaw,ControlCBE2E,KeysT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlSendText({2}, {1}, {3}, {4}, {5}, {6})
      ControlSetText,ControlCBE2E,NewTextT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | ControlSetText({2}, {1}, {3}, {4}, {5}, {6})
      CoordMode,TargetTypeT2E,RelativeToT2E | *_CoordMode
      DetectHiddenWindows,Mode | DetectHiddenWindows({1})
      Drive,SubCommand,Value1,Value2 | *_Drive
      DriveGet,OutputVar,SubCommand,ValueT2E | {1} := DriveGet{2}({3})
      EnvAdd,var,valueCBE2E,TimeUnitsT2E | *_EnvAdd
      EnvSet,EnvVarT2E,ValueT2E | EnvSet({1}, {2})
      EnvSub,var,valueCBE2E,TimeUnitsT2E | *_EnvSub
      EnvDiv,var,valueCBE2E | {1} /= {2}
      EnvGet,OutputVar,LogonServerT2E | {1} := EnvGet({2})
      EnvMult,var,valueCBE2E | {1} *= {2}
      EnvUpdate | SendMessage, `% WM_SETTINGCHANGE := 0x001A, 0, Environment,, `% "ahk_id " . HWND_BROADCAST := "0xFFFF"
      FileAppend,textT2E,fileT2E,encT2E | FileAppend({1}, {2}, {3})
      FileCopyDir,sourceT2E,destT2E,flagCBE2E | *_FileCopyDir
      FileCopy,sourceT2E,destT2E,OverwriteCBE2E | *_FileCopy
      FileCreateDir,dirT2E | DirCreate({1})
      FileDelete,dirT2E | FileDelete({1})
      FileGetSize,OutputVar,FilenameT2E,unitsT2E | {1} := FileGetSize({2}, {3})
      FileGetShortcut,LinkFileT2E,OutTargetV2VR,OutDirV2VR,OutArgsV2VR,OutDescriptionV2VR,OutIconV2VR,OutIconNumV2VR,OutRunStateV2VR | FileGetShortcut({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
      FileMoveDir,SourceT2E,DestT2E,FlagT2E | DirMove({1}, {2}, {3})
      FileRead,OutputVar,Filename | *_FileRead
      FileReadLine,OutputVar,FilenameT2E,LineNumCBE2E | *_FileReadLine
      FileRemoveDir,dirT2E,recurse | DirDelete({1}, {2})
      FileSelectFolder,var,startingdirT2E,opts,promptT2E | {1} := DirSelect({2}, {3}, {4})
      FileSelectFile,var,opts,rootdirfile,prompt,filter | *_FileSelect
      FormatTime,outVar,dateT2E,formatT2E | {1} := FormatTime({2}, {3})
      Gui,SubCommand,Value1,Value2,Value3 | *_Gui
      GuiControl,SubCommand,ControlID,Value | *_GuiControl
      GuiControlGet,OutputVar,SubCommand,ControlID,Value | *_GuiControlGet
      Gosub,Label | *_Gosub
      Goto,Label | Goto({1})
      GroupActivate,GroupNameT2E,ModeT2E | GroupActivate({1}, {2})
      GroupAdd,GroupNameT2E,WinTitleT2E,WinTextT2E,LabelT2E,ExcludeTitleT2E,ExcludeTextT2E | GroupAdd({1}, {2}, {3}, {4}, {5}, {6})
      GroupClose,GroupNameT2E,ModeT2E | GroupClose({1}, {2})
      GroupDeactivate,GroupNameT2E,ModeT2E | GroupDeactivate({1}, {2})
      Hotkey,Var1,Var2,Var3 | *_Hotkey
      KeyWait,KeyNameT2E,OptionsT2E | KeyWait({1}, {2})
      IfEqual,var,valueT2QE | if ({1} = {2})
      IfNotEqual,var,valueT2QE | if ({1} != {2})
      IfGreater,var,valueT2QE | *_IfGreater
      IfGreaterOrEqual,var,valueT2QE | *_IfGreaterOrEqual
      IfLess,var,valueT2QE | *_IfLess
      IfLessOrEqual,var,valueT2QE | *_IfLessOrEqual
      IfInString,var,valueT2E | if InStr({1}, {2})
      IfNotInString,var,valueT2E | if !InStr({1}, {2})
      IfExist,fileT2E | if FileExist({1})
      IfNotExist,fileT2E | if !FileExist({1})
      IfWinExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinExist({1}, {2}, {3}, {4})
      IfWinNotExist,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinExist({1}, {2}, {3}, {4})
      IfWinActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if WinActive({1}, {2}, {3}, {4})
      IfWinNotActive,titleT2E,textT2E,excltitleT2E,excltextT2E | if !WinActive({1}, {2}, {3}, {4})
      ImageSearch,OutputVarXV2VR,OutputVarYV2VR,X1,Y1,X2,Y2,ImageFileT2E | ErrorLevel := ImageSearch({1}, {2}, {3}, {4}, {5}, {6}, {7})
      IniRead,OutputVar,FilenameT2E,SectionT2E,KeyT2E,DefaultT2E | {1} := IniRead({2}, {3}, {4}, {5})
      IniWrite,ValueT2E,FilenameT2E,SectionT2E,KeyT2E | IniWrite({1}, {2}, {3}, {4})
      Inputbox,OutputVar,Title,Prompt,HIDE,Width,Height,X,Y,Locale,Timeout,Default | *_InputBox
      Loop,one,two,three,four | *_Loop
      Menu,MenuName,SubCommand,Value1,Value2,Value3,Value4 | *_Menu
      MsgBox,TextOrOptions,Title,Text,Timeout | *_MsgBox
      MouseGetPos,OutputVarXV2VR,OutputVarYV2VR,OutputVarWinV2VR,OutputVarControlV2VR,Flag | MouseGetPos({1}, {2}, {3}, {4}, {5})
      MouseClick,WhichButtonT2E,XT2E,YT2E,ClickCountT2E,SpeedT2E,DownOrUpT2E,RelativeT2E | MouseClick({1}, {2}, {3}, {4}, {5}, {6}, {7})
      MouseClickDrag,WhichButtonT2E,X1T2E,Y1T2E,X2T2E,Y2T2E,SpeedT2E,RelativeT2E | MouseClick({1}, {2}, {3}, {4}, {5}, {6}, {7})
      OnExit,Func,AddRemove | *_OnExit
      PixelSearch,OutputVarXV2VR,OutputVarYV2VR,X1T2E,Y1T2E,X2T2E,Y2T2E,ColorIDCBE2E,VariationT2E,ModeT2E | ErrorLevel := PixelSearch({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})
      PixelGetColor,OutputVar,XT2E,YT2E,ModeT2E | {1} := PixelGetColor({2}, {3}, {4})
      PostMessage,Msg,wParam,lParam,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | PostMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
      Process,SubCommand,PIDOrNameT2E,ValueT2E | *_Process
      RunAs,UserT2E,PasswordT2E,DomainT2E | RunAs({1}, {2}, {3})
      Run,TargetT2E,WorkingDirT2E,OptionsT2E,OutputVarPIDV2VR | Run({1}, {2}, {3}, {4})
      RunWait,TargetT2E,WorkingDirT2E,OptionsT2E,OutputVarPIDV2VR | RunWait({1}, {2}, {3}, {4})
      SetEnv,var,valueT2E | {1} := {2}
      SetTimer,LabelCBE2E,PeriodOnOffDeleteCBE2E,PriorityCBE2E | *_SetTimer
      Send,keysT2E | Send({1})
      SendText,keysT2E | SendText({1})
      SendInput,keysT2E | SendInput({1})
      SendMessage,Msg,wParamCBE2E,lParamCBE2E,ControlCBE2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E,TimeoutCBE2E | ErrorLevel := SendMessage({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9})
      SendPlay,keysT2E | SendPlay({1})
      SendEvent,keysT2E | SendEvent({1})
      Sleep,delayCBE2E | Sleep({1})
      Sort,var,optionsT2E | {1} := Sort({1}, {2})
      SoundBeep,FrequencyCBE2E,DurationCBE2E | SoundBeep({1},{2})
      SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E | *_SoundGet
      SoundPlay,FrequencyCBE2E,DurationCBE2E | SoundPlay({1},{2})
      SoundSet,NewSetting,ComponentTypeT2E,ControlType,DeviceNumberT2E | *_SoundSet
      SplashTextOn,Width,Height,TitleT2E,TextT2E | *_SplashTextOn
      SplashTextOff | SplashTextGui.Destroy
      SplitPath,varCBE2E,filenameV2VR,dirV2VR,extV2VR,name_no_extV2VR,drvV2VR | SplitPath({1}, {2}, {3}, {4}, {5}, {6})
      StringCaseSense,paramT2E | StringCaseSense({1})
      StringGetPos,OutputVar,InputVar,SearchTextT2E,SideT2E,OffsetCBE2E | *_StringGetPos
      StringLen,OutputVar,InputVar | {1} := StrLen({2})
      StringLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, {3})
      StringMid,OutputVar,InputVar,StartCharCBE2E,CountCBE2E,L_T2E | *_StringMid
      StringRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, -1*({3}))
      StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E | *_StringSplit
      StringTrimLeft,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, ({3})+1)
      StringTrimRight,OutputVar,InputVar,CountCBE2E | {1} := SubStr({2}, 1, -1*({3}))
      StringUpper,OutputVar,InputVar,TT2E| *_StringUpper
      StringLower,OutputVar,InputVar,TT2E| *_StringLower
      StringReplace,OutputVar,InputVar,SearchTxtT2E,ReplTxtT2E,ReplAll | *_StringReplace
      SysGet,OutputVar,SubCommand,ValueCBE2E | *_SysGet
      ToolTip,txtT2E,xCBE2E,yCBE2E,whichCBE2E | ToolTip({1}, {2}, {3}, {4})
      TrayTip,TitleT2E,TextT2E,Seconds,OptionsT2E | TrayTip({1}, {2}, {4})
      UrlDownloadToFile,URLT2E,FilenameT2E | Download({1},{2})
      WinActivate,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinActivate({1}, {2}, {3}, {4})
      WinActivateBottom,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinActivateBottom({1}, {2}, {3}, {4})
      WinClose,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E | WinClose({1}, {2}, {3}, {4}, {5})
      WinGet,OutputVar,SubCommand,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | *_WinGet
      WinGetActiveStats,TitleVar,WidthVar,HeightVar,XVar,YVar | *_WinGetActiveStats
      WinGetActiveTitle,OutputVar | {1} := WinGetTitle("A")
      WinGetClass,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | {1} := WinGetClass({2}, {3}, {4}, {5})
      WinGetText,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | {1} := WinGetText({2}, {3}, {4}, {5})
      WinGetTitle,OutputVar,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | {1} := WinGetTitle({2}, {3}, {4}, {5})
      WinGetPos,XV2VR,YV2VR,WidthV2VR,HeightV2VR,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinGetPos({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8})
      WinHide,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinHide({1}, {2}, {3}, {4})
      WinKill,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E | WinKill({1}, {2}, {3}, {4}, {5})
      WinMaximize,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinMaximize({1}, {2}, {3}, {4})
      WinMove,var1,var2,X,Y,Width,Height,ExcludeTitleT2E,ExcludeTextT2E | *_WinMove
      WinMinimize,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinMinimize({1}, {2}, {3}, {4})
      WinMenuSelectItem,WinTitleT2E,WinTextT2E,MenuT2E,SubMenu1T2E,SubMenu2T2E,SubMenu3T2E,SubMenu4T2E,SubMenu5T2E,SubMenu6T2E,ExcludeTitleT2E,ExcludeTextT2E | MenuSelect({1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11})
      WinSet,SubCommand,ValueT2E,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | *_WinSet
      WinSetTitle,WinTitleT2E,WinTextT2E,NewTitleT2E,ExcludeTitleT2E,ExcludeTextT2E | *_WinSetTitle
      WinShow,WinTitleT2E,WinTextT2E,ExcludeTitleT2E,ExcludeTextT2E | WinShow({1}, {2}, {3}, {4})
      WinWait,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E | *_WinWait
      WinWaitActive,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E | ErrorLevel := WinWaitActive({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
      WinWaitNotActive,WinTitleT2E,WinTextT2E,TimeoutCBE2E,ExcludeTitleT2E,ExcludeTextT2E | ErrorLevel := WinWaitNotActive({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
      WinWaitClose,WinTitleT2E,WinTextT2E,SecondsToWaitCBE2E,ExcludeTitleT2E,ExcludeTextT2E | ErrorLevel := WinWaitClose({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
      #HotkeyInterval,Milliseconds | A_HotkeyInterval := {1}
      #HotkeyModifierTimeout,Milliseconds | A_HotkeyModifierTimeout := {1}
      #If Expression | #HotIf {1}
      #IfTimeout | #HotIfTimeout {1}
      #IfWinActive,WinTitleT2E,WinTextT2E | *_HashtagIfWinActivate
      #IfWinExist,WinTitleT2E,WinTextT2E | #HotIf WinExist({1}, {2})
      #IfWinNotActive ,WinTitleT2E,WinTextT2E | #HotIf !WinActive({1}, {2})
      #IfWinNotExist,WinTitleT2E,WinTextT2E | #HotIf !WinExist({1}, {2})
      #InstallKeybdHook | InstallKeybdHook()
      #InstallMouseHook | InstallMouseHook()
      #Persistent | Persistent
      #KeyHistory,MaxEvents | KeyHistory({1})
      #MaxHotkeysPerInterval,Value | A_MaxHotkeysPerInterval := {1}
      #MenuMaskKey KeyNameT2E | A_MenuMaskKey := {1}
      #Requires AutoHotkey Version | #Requires Autohotkey v2.0-beta.1+
   )"

   ;// this is a list of all renamed functions, in this format:
   ;//          OrigV1Function | ReplacementV2Function
   ;//  Similar to commands, parameters can be added
   FunctionsToConvert := "
   (
      DllCall(DllFunction,Type1,Arg1,Type2,Arg2,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,Type,Arg,ReturnType) | *_DllCall
      Func(FunctionNameQ2T) | {1}
      RegExMatch(Haystack, NeedleRegEx , OutputVarV2VR, StartingPos) | *_RegExMatch
      RegExReplace(Haystack,NeedleRegEx,Replacement,OutputVarCountV2VR,Limit,StartingPos) | RegExReplace({1}, {2}, {3}, {4}, {5}, {6})
      StrReplace(Haystack,Needle,ReplaceText,OutputVarCountV2VR,Limit) | StrReplace({1}, {2}, {3}, , {4}, {5})
      LoadPicture(Filename,Options,ImageTypeV2VR) | LoadPicture({1},{2},{3})
      LV_Add(Options, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field) | *_LV_Add
      LV_Delete(RowNumber) | *_LV_Delete
      LV_DeleteCol(ColumnNumber) | *_LV_DeleteCol
      LV_GetCount(ColumnNumber) | *_LV_GetCount
      LV_GetText(OutputVar, RowNumber, ColumnNumber) | *_LV_GetText
      LV_GetNext(StartingRowNumber, RowType) | *_LV_GetNext
      LV_InsertCol(ColumnNumber , Options, ColumnTitle) | *_LV_InsertCol
      LV_Insert(RowNumber, Options, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field) | *_LV_Insert
      LV_Modify(RowNumber, Options, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field, Field) | *_LV_Modify
      LV_ModifyCol(ColumnNumber, Options, ColumnTitle) | *_LV_ModifyCol
      LV_SetImageList(ImageListID, IconType) | *_LV_SetImageList
      TV_Add(Name,ParentItemID,Options) | *_TV_Add
      TV_Modify(ItemID,Options,NewName) | *_TV_Modify
      TV_Delete(ItemID) | *_TV_Delete
      TV_GetSelection(ItemID) | *_TV_GetSelection
      TV_GetParent(ItemID) | *_TV_GetParent
      TV_GetPrev(ItemID) | *_TV_GetPrev
      TV_GetNext(ItemID,ItemType) | *_TV_GetNext
      TV_GetText(OutputVar,ItemID) | *_TV_GetText
      TV_GetChild(ParentItemID) | *_TV_GetChild
      TV_GetCount() | *_TV_GetCount
      TV_SetImageList(ImageListID,IconType) | *_TV_SetImageList
      SB_SetText(NewText,PartNumber,Style) | *_SB_SetText
      SB_SetParts(NewText,PartNumber,Style) | *_SB_SetParts
      SB_SetIcon(Filename,IconNumber,PartNumber) | *_SB_SetIcon
      NumPut(Number,VarOrAddress,Offset,Type) | *_NumPut
      MenuGetHandle(MenuNameQ2T) | {1}.Handle
      MenuGetName(Handle) | MenuFromHandle({1})
      OnError(FuncQ2T,AddRemove) | OnError({1},{2})
      OnClipboardChange(ClipChangedQ2T) | OnClipboardChange(ClipChanged)
      Asc(String) | Ord({1})
      VarSetCapacity(TargetVar,RequestedCapacity,FillByte) | *_VarSterCapacity
   )"
 
   ;// this is a list of all renamed Methods, in this format:
   ;// a method has the syntax object.method(Par1, Par2)
   ;//          OrigV1Method | ReplacementV2Method
   ;//  Similar to commands, parameters can be added
   MethodsToConvert := "
   (
      Count() | Count
      length() | Length
      HasKey(Key) | Has({1})
   )"

   ;// this is a list of all renamed variables , in this format:
   ;//          OrigWord | ReplacementWord
   ;//
   ;// functions should include the parentheses
   ;//
   ;// important: the order matters. the first 2 in the list could cause a mistake if not ordered properly
   KeywordsToRename := "
   (
      A_LoopFileFullPath | A_LoopFilePath
      A_LoopFileLongPath | A_LoopFileFullPath
      ComSpec | A_ComSpec
      Clipboard | A_Clipboard
      ClipboardAll | ClipboardAll()
      ComObjParameter() | ComObject()
   )"

   ;Directives := "#Warn UseUnsetLocal`r`n#Warn UseUnsetGlobal"
   ; Splashtexton and Splashtextoff is removed, but alternative gui code is available
   Remove := "
   (
      #AllowSameLineComments
      #CommentFlag
      #Delimiter
      #DerefChar
      #EscapeChar
      #LTrim
      #MaxMem
      #NoEnv
      Progress
      SetBatchLines
      SetFormat
      SoundGetWaveVolume
      SoundSetWaveVolume
      SplashImage
      A_FormatInteger
      A_FormatFloat
      AutoTrim
   )"


   ;SubStrFunction := "`r`n`r`n; This function may be removed if StartingPos is always > 0.`r`nCheckStartingPos(p) {`r`n   Return, p - (p <= 0)`r`n}`r`n`r`n"

   ScriptOutput := ""
   InCommentBlock := false
   InCont := 0
   Cont_String := 0
   oScriptString := {}
   oScriptString := StrSplit(ScriptString , "`n", "`r")

   ; parse each line of the input script
   Loop
   {
      O_Index++
      if (oScriptString.Length < O_Index){
         ; This allows the user to add or remove lines if necessary
         ; Do not forget to change the O_index if you want to remove or add the line above or lines below
         break
      }
      O_Loopfield := oScriptString[O_Index]

      Skip := false
      
      Line := O_Loopfield
      Orig_Line := Line
      RegExMatch(Line, "^(\s*)", &Indentation)
      Indentation := Indentation[1]
      ;msgbox, % "Line:`n" Line "`n`nIndentation=[" Indentation "]`nStrLen(Indentation)=" StrLen(Indentation)
      FirstChar := SubStr(Trim(Line), 1, 1)
      FirstTwo := SubStr(LTrim(Line), 1, 2)
      ;msgbox, FirstChar=%FirstChar%`nFirstTwo=%FirstTwo%
      if RegExMatch(Line, "(\s+`;.*)$", &EOLComment)
      {
         EOLComment := EOLComment[1]
         Line := RegExReplace(Line, "(\s+`;.*)$", "")
         ;msgbox, % "Line:`n" Line "`n`nEOLComment:`n" EOLComment
      }
      else
         EOLComment := ""
      
      CommandMatch := -1

      ; get PreLine of line with hotkey and hotstring definition, String will be temporary removed form the line
      ; Prelines is code that does not need to changes anymore, but coud prevent correct command conversion
      PreLine := ""

      if RegExMatch(Line, "^\s*(.+::).*$"){
         LineNoHotkey := RegExReplace(Line,"(^\s*).+::(.*$)","$1$2")
         if (LineNoHotkey!=""){
            PreLine:= RegExReplace(Line,"^\s*(.+::).*$","$1")
            Line := LineNoHotkey
            Orig_Line := RegExReplace(Line,"(^\s*).+::(.*$)","$1$2")
         }
      }
      if RegExMatch(Line, "^\s*({\s*).*$"){
         LineNoHotkey := RegExReplace(Line,"(^\s*)({\s*)(.*$)","$1$3")
         if (LineNoHotkey!=""){
            PreLine := PreLine RegExReplace(Line,"(^\s*)({\s*)(.*$)","$2")
            Line := LineNoHotkey
            Orig_Line := RegExReplace(Line,"(^\s*)({\s*)(.*$)","$1$3")
         }
      }
      if RegExMatch(Line, "i)^\s*(}?\s*(Try|Else)\s*[\s{]\s*).*$"){
         LineNoHotkey := RegExReplace(Line,"i)(^\s*)(}?\s*(Try|Else)\s*[\s{]\s*)(.*$)","$4")
         if (LineNoHotkey!=""){
            PreLine .= RegExReplace(Line,"i)(^\s*)(}?\s*(Try|Else)\s*[\s{]\s*)(.*$)","$1$2")
            Line := LineNoHotkey
            Orig_Line := RegExReplace(Line,"i)(^\s*)(}?\s*(Try|Else)\s*[\s{]\s*)(.*$)","$4")
            
         }
      }

      


      ; -------------------------------------------------------------------------------
      ;
      ; skip empty lines or comment lines
      ;
      If (Trim(Line) == "") || ( FirstChar == ";" )
      {
         ; Do nothing, but we still want to add the line to the output file
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; skip comment blocks with one statement
      ;
      else if (FirstTwo == "/*"){
         
         loop {
            O_Index++
            if (oScriptString.Length < O_Index){
               break
            }
            LineContSect := oScriptString[O_Index]
            Line .= "`r`n" . LineContSect
            FirstTwo := SubStr(LTrim(LineContSect), 1, 2)
            if (FirstTwo == "*/"){
               ; End Comment block
               break
            } 
         }
         ScriptOutput .= Line . "`r`n"
         ; Output and NewInput should become arrays, NewInput is a copy of the Input, but with empty lines added for easier comparison.
         LastLine := Line
         continue ; continue with the next line
      }

      
      ; Check for , continuation sections add them to the line
      ; https://www.autohotkey.com/docs/Scripts.htm#continuation
      loop
      {
         if (oScriptString.Length < O_Index+1){
            break
         }
         FirstNextLine := SubStr(LTrim(oScriptString[O_Index+1]), 1, 1)
         FirstTwoNextLine := SubStr(LTrim(oScriptString[O_Index+1]), 1, 1)
         TreeNextLine := SubStr(LTrim(oScriptString[O_Index+1]), 1, 1)
         if (FirstNextLine~="[,\?:\.]" or FirstTwoNextLine="||" or FirstTwoNextLine="&&" or FirstTwoNextLine="or" or TreeNextLine ="and"){
            O_Index++
            Line .= oScriptString[O_Index]
         }
         else{
            break
         } 
      }

      ; Loop the functions
      loop {
         oResult:= V1ParSplitfunctions(Line, A_Index)
         
         if (oResult.Found = 0){
            break
         }
         if (oResult.Hook_Status>0){
            ; This means that the function dit not close, probably a continuation section
            ;MsgBox("Hook_Status: " oResult.Hook_Status "line:" line)
            break
         }

         oPar := V1ParSplit(oResult.Parameters)
         gFunctPar := oResult.Parameters

         ConvertList := FunctionsToConvert
         if RegExMatch(oResult.Pre,"\.$"){
            ConvertList := MethodsToConvert
         }
         Loop Parse, ConvertList, "`n", "`r"
         {
            ListDelim := InStr(A_LoopField, "(")
            ListFunction := Trim( SubStr(A_LoopField, 1, ListDelim-1) )
            
            If (ListFunction = oResult.func){
               ;MsgBox(ListFunction)
               ListParam := SubStr(A_LoopField, ListDelim+1, InStr(A_LoopField,")") - ListDelim-1)
               oListParam := StrSplit(ListParam, "`,", " ")
               ; Fix for when ListParam is empty
               if (ListParam=""){
                  oListParam.Push("")
               }
               Part := StrSplit(A_LoopField, "|")
               Part[1]:= trim(Part[1])
               Part[2]:= trim(Part[2])
               loop oPar.Length
               {
                  ; uses a function to fromat the parameters
                  oPar[A_Index] := ParameterFormat(oListParam[A_Index],oPar[A_Index])
               }
               loop oListParam.Length
               {
                  if !oPar.Has(A_Index){
                     oPar.Push("")
                  }
               }
               
               If ( SubStr(Part[2], 1, 1) == "*" )   ; if using a special function
               {
                  FuncName := SubStr(Part[2], 2)
                  
                  FuncObj := %FuncName%  ;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
                  If FuncObj is Func
                     NewFunction := FuncObj(oPar)
               }
               Else{
                  FormatString := Trim(Part[2])
                  NewFunction := Format(FormatString,oPar*)
               }
               
               ; Remove the empty variables
               NewFunction := RegExReplace(NewFunction, "[\s\,]*\)$", ")")
               ; MsgBox("found:" A_LoopField)
               Line := oResult.Pre NewFunction oResult.Post
            }
         }
         ; msgbox("[" oResult.Pre "]`n[" oResult.func "]`n[" oResult.Parameters "]`n[" oResult.Post "]`n[" oResult.Separator "]`n")
         ; Line := oResult.Pre oResult.func "(" oResult.Parameters ")" oResult.Post
      }

      ; -------------------------------------------------------------------------------
      ;
      ; replace any renamed vars
      ; Known Error: converts also the text
      Loop Parse, KeywordsToRename, "`n"
      {
         Part := StrSplit(A_LoopField, "|")
         srchtxt := Trim(Part[1])
         rplctxt := Trim(Part[2])

         if InStr(Line, srchtxt)
         {
            Line := RegExReplace(Line, "i)([^\w]|^)" . srchtxt . "([^\w])", "$1" . rplctxt . "$2")
         }
      }

      Orig_Line_NoComment := Line

      ; -------------------------------------------------------------------------------
      ;
      ;else If InStr(Line, "SendMode") && InStr(Line, "Input")
         ;Skip := true
      
      ; -------------------------------------------------------------------------------
      ;
      ; check if this starts a continuation section
      ;
      ; no idea what that RegEx does, but it works to prevent detection of ternaries
      ; got that RegEx from Coco here: https://github.com/cocobelgica/AutoHotkey-Util/blob/master/EnumIncludes.ahk#L65
      ; and modified it slightly
      ;
      if ( FirstChar == "(" )
           && RegExMatch(Line, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$")
      {
         InCont := 1
         ;If RegExMatch(Line, "i)join(.+?)(LTrim|RTrim|Comment|`%|,|``)?", &Join)
            ;JoinBy := Join[1]
         ;else
            ;JoinBy := "``n"
         ;MsgBox, Start of continuation section`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nScriptOutput:`n[`n%ScriptOutput%`n]
         If InStr(LastLine, ':= ""')
         {
            ; if LastLine was something like:                                  var := ""
            ; that means that the line before conversion was:                  var = 
            ; and this new line is an opening ( for continuation section
            ; so remove the last quote and the newline `r`n chars so we get:   var := "
            ; and then re-add the newlines
            ScriptOutput := SubStr(ScriptOutput, 1, -3) . "`r`n"
            ;MsgBox, Output after removing one quote mark:`n[`n%ScriptOutput%`n]
            Cont_String := 1
            ;;;Output.Seek(-4, 1) ; Remove the newline characters and double quotes
         }
         else
         {
            ;;;Output.Seek(-2, 1)
            ;;;Output.Write(" `% ")
         }
         ;continue ; Don't add to the output file
      }

      else if ( FirstChar == ")" )
      {
         ;MsgBox, End Cont. Section`n`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nScriptOutput:`n[`n%ScriptOutput%`n]
         InCont := 0
         if (Cont_String = 1)
         {
            if (FirstTwo!=")`""){ ; added as an exception for quoted continuation sections
               Line := RegExReplace(Line, "\)", ")`"",, 1)
            }
            
            ScriptOutput .= Line . "`r`n"
            LastLine := Line
            continue
         }
      }

      else if InCont
      {
         ;Line := ToExp(Line . JoinBy)
         ;If InCont > 1
            ;Line := ". " . Line
         ;InCont++
         ;MsgBox, Inside Cont. Section`n`nLine:`n%Line%`n`nLastLine:`n%LastLine%`n`nScriptOutput:`n[`n%ScriptOutput%`n]
         ScriptOutput .= Line . "`r`n"
         LastLine := Line
         continue
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Replace = with := expression equivilents in "var = value" assignment lines
      ;
      ; var = 3      will be replaced with    var := "3"
      ; lexikos says var=value should always be a string, even numbers
      ; https://autohotkey.com/boards/viewtopic.php?p=118181#p118181
      ;
      else If RegExMatch(Line, "i)^([\s]*[a-z_][a-z_0-9]*[\s]*)=([^;]*)", &Equation) ; Thanks Lexikos
      {
         ; msgbox("assignment regex`norigLine: " Line "`norig_left=" Equation[1] "`norig_right=" Equation[2] "`nconv_right=" ToStringExpr(Equation[2]))
         Line := RTrim(Equation[1]) . " := " . ToStringExpr(Equation[2])   ; regex above keeps the indentation already
      }
      
      ; -------------------------------------------------------------------------------
      ;
      ; Traditional-if to Expression-if
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+(not\s+)?([a-z_][a-z_0-9]*[\s]*)(!=|=|<>|>=|<=|<|>)([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%`n6: %Equation[6]%
         ; Line := Indentation . format_v("{else}if {not}({variable} {op} {value}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , not: Equation[2]
         ;                                  , variable: RTrim(Equation[3])
         ;                                  , op: Equation[4]
         ;                                  , value: ToExp(Equation[5])
         ;                                  , otb: Equation[6] } )
         op := (Equation[4] = "<>") ? "!=" : Equation[4]
         
         ; not used, 
         ; Line := Indentation . format("{1}if {2}({3} {4} {5}){6}"
         ;                                                         , Equation[1]          ;else
         ;                                                         , Equation[2]          ;not
         ;                                                         , RTrim(Equation[3])   ;variable
         ;                                                         , op                   ;op
         ;                                                         , ToExp(Equation[5])   ;value
         ;                                                         , Equation[6] )        ;otb
         ; Preline hack for furter commands
         PreLine := Indentation PreLine . format("{1}if {2}({3} {4} {5}){6}"
                                                                 , Equation[1]          ;else
                                                                 , Equation[2]          ;not
                                                                 , RTrim(Equation[3])   ;variable
                                                                 , op                   ;op
                                                                 , ToExp(Equation[5])   ;value
                                                                 , Equation[6] )        ;otb

         Line := Equation[7]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var between
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) (\s*not\s+)?between ([^{;]*) and ([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({var} >= {val1} && {var} <= {val2}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , var: Equation[2]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , val1: ToExp(Equation[4])
         ;                                  , val2: ToExp(Equation[5])
         ;                                  , otb: Equation[6] } )
         val1 := ToExp(Equation[4])
         val2 := ToExp(Equation[5])

         if (isNumber(val1) && isNumber(val2)) || InStr(Equation[4], "%") || InStr(Equation[5], "%")
         {
            PreLine .= Indentation . format("{1}if {3}({2} >= {4} && {2} <= {5}){6}"
                                                                   , Equation[1]                 ;else
                                                                   , Equation[2]                 ;var
                                                                   , (Equation[3]) ? "!" : ""    ;not
                                                                   , val1                        ;val1
                                                                   , val2                        ;val2
                                                                   , Equation[6] )               ;otb
         }
         else  ; if not numbers or variables, then compare alphabetically with StrCompare()
         {
            ;if ((StrCompare(var, "blue") > 0) && (StrCompare(var, "red") < 0))
            PreLine .= Indentation . format("{1}if {3}((StrCompare({2}, {4}) > 0) && (StrCompare({2}, {5}) < 0)){6}"
                                                                   , Equation[1]                 ;else
                                                                   , Equation[2]                 ;var
                                                                   , (Equation[3]) ? "!" : ""    ;not
                                                                   , val1                        ;val1
                                                                   , val2                        ;val2
                                                                   , Equation[6] )               ;otb
         }
         Line := Equation[7]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; if var is type
      ;
      else If RegExMatch(Line, "i)^\s*(else\s+)?if\s+([a-z_][a-z_0-9]*) is (not\s+)?([^{;]*)(\s*{?\s*)(.*)", &Equation)
      {
         ;msgbox if regex`nLine: %Line%`n1: %Equation[1]%`n2: %Equation[2]%`n3: %Equation[3]%`n4: %Equation[4]%`n5: %Equation[5]%
         ; Line := Indentation . format_v("{else}if {not}({variable} is {type}){otb}"
         ;                                , { else: Equation[1]
         ;                                  , not: (Equation[3]) ? "!" : ""
         ;                                  , variable: Equation[2]
         ;                                  , type: ToStringExpr(Equation[4])
         ;                                  , otb: Equation[5] } )
         PreLine .= Indentation . format("{1}if {3}is{4}({2}){5}"
                                                                , Equation[1]                 ;else
                                                                , Equation[2]                 ;var
                                                                , (Equation[3]) ? "!" : ""    ;not
                                                                , StrTitle(Equation[4])       ;type
                                                                , Equation[5] )               ;otb
         Line := Equation[6]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Replace = with := in function default params
      ;
      else if RegExMatch(Line, "i)^\s*(\w+)\((.+)\)", &MatchFunc)
           && !(MatchFunc[1] ~= "i)(if|while)")         ; skip if(expr) and while(expr) when no space before paren
      ; this regex matches anything inside the parentheses () for both func definitions, and func calls :(
      {
         AllParams := MatchFunc[2]
         ;msgbox, % "function line`n`nLine:`n" Line "`n`nAllParams:`n" AllParams

         ; first replace all commas and question marks inside quoted strings with placeholders
         ;  - commas: because we will use comma as delimeter to parse each individual param
         ;  - question mark: because we will use that to determine if there is a ternary
         pos := 1, quoted_string_match := ""
         while (pos := RegExMatch(AllParams, '".*?"', &MatchObj, pos+StrLen(quoted_string_match)))  ; for each quoted string
         {
            quoted_string_match := MatchObj[0]
            ;msgbox, % "quoted_string_match=" quoted_string_match "`nlen=" StrLen(quoted_string_match) "`npos=" pos
            string_with_placeholders := StrReplace(quoted_string_match, ",", "MY_COMMª_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "?", "MY_¿¿¿_PLA¢E_HOLDER")
            string_with_placeholders := StrReplace(string_with_placeholders, "=", "MY_ÈQÜAL§_PLA¢E_HOLDER")
            ;msgbox, %string_with_placeholders%
            Line := StrReplace(Line, quoted_string_match, string_with_placeholders, "Off", &Cnt, 1)
         }
         ;msgbox, % "Line:`n" Line

         ; get all the params again, this time from our line with the placeholders
         if RegExMatch(Line, "i)^\s*\w+\((.+)\)", &MatchFunc2)
         {
            AllParams2 := MatchFunc2[1]
            pos := 1, match := ""
            Loop Parse, AllParams2, ","   ; for each individual param (separate by comma)
            {
               thisprm := A_LoopField
               ;msgbox, % "Line:`n" Line "`n`nthisparam:`n" thisprm
               if RegExMatch(A_LoopField, "i)([\s]*[a-z_][a-z_0-9]*[\s]*)=([^,\)]*)", &ParamWithEquals)
               {
                  ;msgbox, % "Line:`n" Line "`n`nParamWithEquals:`n" ParamWithEquals[0] "`n" ParamWithEquals[1] "`n" ParamWithEquals[2]
                  ; replace the = with :=
                  ;   question marks were already replaced above if they were within quotes
                  ;   so if a questionmark still exists then it must be for ternary during a func call
                  ;   which we will exclude. for example:  MyFunc((var=5) ? 5 : 0)
                  if !InStr(A_LoopField, "?")
                  {
                     TempParam := ParamWithEquals[1] . ":=" . ParamWithEquals[2]
                     ;msgbox, % "Line:`n" Line "`n`nParamWithEquals:`n" ParamWithEquals[0] "`n" TempParam
                     Line := StrReplace(Line, ParamWithEquals[0], TempParam, "Off", &Cnt, 1)
                     ;msgbox, % "Line after replacing = with :=`n" Line
                  }
               }
            }
         }

         ; deref the placeholders
         Line := StrReplace(Line, "MY_COMMª_PLA¢E_HOLDER", ",")
         Line := StrReplace(Line, "MY_¿¿¿_PLA¢E_HOLDER", "?")
         Line := StrReplace(Line, "MY_ÈQÜAL§_PLA¢E_HOLDER", "=")

      }
      ; -------------------------------------------------------------------------------
      ;
      ; Fix     return %var%        ->       return var
      ;
      ; we use the same parsing method as the next else clause below
      ;
      else if (Trim(SubStr(Line, 1, FirstDelim := RegExMatch(Line, "\w[,\s]"))) = "return")
      {
         Params := SubStr(Line, FirstDelim+2)
         if RegExMatch(Params, "^%\w+%$")       ; if the var is wrapped in %%, then remove them
         {
            Params := SubStr(Params, 2, -1)
            Line := Indentation . "return " . Params . EOLComment  ; 'return' is the only command that we won't use a comma before the 1st param
         }
      }
      
      ; Moving the if/else/While statement to the preline
      ;
      else If RegExMatch(Line, "i)(^\s*[\}]?\s*(else|while|if)[\s\(][^\{]*{\s*)(.*$)", &Equation){
            PreLine .= Equation[1]
            Line := Equation[3]
      }

      ; -------------------------------------------------------------------------------
      ;
      ; Command replacing
      ;
      if (!InCont)
      ; To add commands to be checked for, modify the list at the top of this file
      {
         CommandMatch := 0
         FirstDelim := RegExMatch(Line, "\w[,\s]") 
         if (FirstDelim > 0)
         {
            Command := Trim( SubStr(Line, 1, FirstDelim) )
            Params := SubStr(Line, FirstDelim+2)
         }
         else
         {
            Command := Trim( SubStr(Line, 1) )
            Params := ""
         }
         ; msgbox("Line=" Line "`nFirstDelim=" FirstDelim "`nCommand=" Command "`nParams=" Params)
         ; Now we format the parameters into their v2 equivilents
         Loop Parse, CommandsToConvert, "`n"
         {
            Part := StrSplit(A_LoopField, "|")
            
            ListDelim := RegExMatch(Part[1], "[,\s]")
            ListCommand := Trim( SubStr(Part[1], 1, ListDelim-1) )
            If (ListCommand = Command)
            {
               CommandMatch := 1
               same_line_action := false
               ListParams := RTrim( SubStr(Part[1], ListDelim+1) )
               
               ListParam := Array()
               Param := Array() ; Parameters in expression form
               Loop Parse, ListParams, ","
                  ListParam.Push(A_LoopField)

               oParam := V1ParSplit(Params)
               
               Loop oParam.Length
               {
                  if (A_Index <= ListParam.Length)
                     Param.Push(LTrim(oParam[A_index]))   ; trim leading spaces off each param
                  else
                     Param.Push(oParam[A_index])
               }
      
               ; Checks for continuation section
               if (oScriptString.Length > O_Index and (SubStr(Trim(oScriptString[O_Index+1]), 1, 1)="(" or RegExMatch(Trim(oScriptString[O_Index+1]), "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))){
                  
                  ContSect := oParam[oParam.Length] "`r`n"
                  
                  loop {
                     O_Index++
                     if (oScriptString.Length < O_Index){
                        break
                     }
                     LineContSect := oScriptString[O_Index]
                     FirstChar := SubStr(Trim(LineContSect), 1, 1)
                     if ((A_index=1) && (FirstChar != "(" or !RegExMatch(LineContSect, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))){
                        ; no continuation section found
                        O_Index--
                        return ""
                     }
                     if ( FirstChar == ")" ){
                        
                        ; to simplify, we just add the comments to the back
                        if RegExMatch(LineContSect, "(\s+`;.*)$", &EOLComment2)
                           {
                              EOLComment := EOLComment " " EOLComment2[1]
                              LineContSect := RegExReplace(LineContSect, "(\s+`;.*)$", "")
                           }
                           else
                              EOLComment2 := ""
                        
                        oParam2 := V1ParSplit(LineContSect)
                        Param[Param.Length] := ContSect oParam2[1]
                        
                        Loop oParam2.Length -1
                        {
                           if (oParam.Length+1 <= ListParam.Length)
                              Param.Push(LTrim(oParam2[A_index+1]))   ; trim leading spaces off each param
                           else
                              Param.Push(oParam2[A_index+1])
                        }
                        break
                     }
                     ContSect .= LineContSect "`r`n"
                  }
                  
               }

               
               ; Params := StrReplace(Params, "``,", "ESCAPED_COMMª_PLA¢E_HOLDER")     ; ugly hack
               ; Loop Parse, Params, ","
               ; {
                  ; populate array with the params
                  ; only trim preceeding spaces off each param if the param index is within the
                  ; command's number of allowable params. otherwise, dont trim the spaces
                  ; for ex:  `IfEqual, x, h, e, l, l, o`   should be   `if (x = "h, e, l, l, o")`
                  ; see ~10 lines below
               ;    if (A_Index <= ListParam.Length)
               ;       Param.Push(LTrim(A_LoopField))   ; trim leading spaces off each param
               ;    else
               ;       Param.Push(A_LoopField)
               ; }
               
               ; msgbox("Line:`n`n" Line "`n`nParam.Length=" Param.Length "`nListParam.Length=" ListParam.Length)

               ; if we detect TOO MANY PARAMS, could be for 2 reasons
               if ((param_num_diff := Param.Length - ListParam.Length) > 0)
               {
                  ; msgbox("too many params")
                  extra_params := ""
                  Loop param_num_diff
                     extra_params .= "," . Param[ListParam.Length + A_Index]
                  extra_params := SubStr(extra_params, 2)
                  extra_params := StrReplace(extra_params, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
                  ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length "`nParam[ListParam.Length]=" Param[ListParam.Length] "`nextra_params=" extra_params

                  ; 1. could be because of IfCommand with a same line action
                  ;    such as  `IfEqual, x, 1, Sleep, 1`
                  ;    in which case we need to append these extra params later
                  if_cmds_allowing_sameline_action := "IfEqual|IfNotEqual|IfGreater|IfGreaterOrEqual|"
                                                    . "IfLess|IfLessOrEqual|IfInString|IfNotInString"
                  if RegExMatch(Command, "i)^(?:" if_cmds_allowing_sameline_action ")$")
                  {
                     same_line_action := true
                  }

                  ; 2. could be this:
                  ;       "Commas that appear within the last parameter of a command do not need
                  ;        to be escaped because the program knows to treat them literally."
                  ;    from:   https://autohotkey.com/docs/commands/_EscapeChar.htm
                  else if (ListParam.Length != 0)
                  {
                     Param[ListParam.Length] .= "," extra_params
                     ;msgbox, % "Line:`n" Line "`n`nCommand=" Command "`nparam_num_diff=" param_num_diff "`nListParam.Length=" ListParam.Length "`nParam[ListParam.Length]=" Param[ListParam.Length] "`nextra_params=" extra_params
                  }
               }

               ; if we detect TOO FEW PARAMS, fill with empty strings (see Issue #5)
               if ((param_num_diff := ListParam.Length - Param.Length) > 0)
               {
                  ;msgbox, % "Line:`n`n" Line "`n`nParam.Length=" Param.Length "`nListParam.Length=" ListParam.Length "`ndiff=" param_num_diff
                  Loop param_num_diff
                     Param.Push("")
               }

               ; convert the params to expression or not
               Loop Param.Length
               {
                  this_param := Param[A_Index]
                  this_param := StrReplace(this_param, "ESCAPED_COMMª_PLA¢E_HOLDER", "``,")
                  if (A_Index > ListParam.Length)
                  {
                     Param[A_Index] := this_param
                     continue
                  }
                  ; uses a function to format the parameters
                  Param[A_Index] := ParameterFormat(ListParam[A_Index],Param[A_Index])

               }

               Part[2] := Trim(Part[2])
               If ( SubStr(Part[2], 1, 1) == "*" )   ; if using a special function
               {
                  FuncName := SubStr(Part[2], 2)
                  ;msgbox("FuncName=" FuncName)
                  FuncObj := %FuncName%  ;// https://www.autohotkey.com/boards/viewtopic.php?p=382662#p382662
                  If FuncObj is Func
                     Line := Indentation . FuncObj(Param)
               }
               else                               ; else just using the replacement defined at the top
               {
                  ; if (Command = "FileAppend")
                  ; {
                  ;    paramsstr := ""
                  ;    Loop Param.Length
                  ;       paramsstr .= "Param[" A_Index "]: " Param[A_Index] "`n"
                  ;    msgbox("in else`nLine: " Line "`nPart[2]: " Part[2] "`n`nListParam.Length: " ListParam.Length "`nParam.Length: " Param.Length "`n`n" paramsstr)
                  ; }

                  if (same_line_action)
                     Line := Indentation . format(Part[2], Param*) . "," extra_params
                  else
                     Line := Indentation . format(Part[2], Param*)

                  ; msgbox("Line after format:`n`n" Line)
                  ; if empty trailing optional params caused the line to end with extra commas, remove them
                  if SubStr(Line, -1) = ")"
                     Line := RegExReplace(Line, '(?:, "?"?)*\)$', "") . ")"
                  else
                     Line := RegExReplace(Line, "(?:,\s)*$", "")
               }
            }
         }
      }
      
      ; Remove lines we can't use
      If CommandMatch = 0 && !InCommentBlock
         Loop Parse, Remove, "`n", "`r"
         {
            If InStr(Orig_Line, A_LoopField)
            {
               ;msgbox, skip removed line`nOrig_Line=%Orig_Line%`nA_LoopField=%A_LoopField%
               Skip := true
            }
         }

      
      ; TEMPORARY
      ;If !FoundSubStr && !InCommentBlock && InStr(Line, "SubStr") 
      ;{
         ;FoundSubStr := true
         ;Line .= " `; WARNING: SubStr conversion may change in the near future"
      ;}
      
      ; Put the directives after the first non-comment line
      ;If !FoundNonComment && !InCommentBlock && A_Index != 1 && FirstChar != ";" && FirstTwo != "*/"
      ;{
         ;Output.Write(Directives . "`r`n")
         ;msgbox, directives
         ;ScriptOutput .= Directives . "`r`n"
         ;FoundNonComment := true
      ;}
      

      If Skip
      {
         ;msgbox Skipping`n%Line%
         Line := format("; REMOVED: {1}", Line)
      }

      Line := PreLine Line

      ; Correction PseudoArray to Array
      Loop aListPseudoArray.Length{
         Line := ConvertPseudoArray(Line,aListPseudoArray[A_Index])
      }

      ; Correction PseudoArray to Array
      Loop aListMatchObject.Length{
         Line := ConvertObjectMatch(Line,aListMatchObject[A_Index])
      }
       

      ScriptOutput .= Line . EOLComment . "`r`n"
      ; Output and NewInput should become arrays, NewInput is a copy of the Input, but with empty lines added for easier comparison.
      LastLine := Line
   }

   ; The following will be uncommented at a a later time
   ;If FoundSubStr
   ;   Output.Write(SubStrFunction)

   ; trim the very last newline that we add to every line (a few code lines above)
   if (SubStr(ScriptOutput, -2) = "`r`n")
      ScriptOutput := SubStr(ScriptOutput, 1, -2)

   return ScriptOutput
}


; =============================================================================
; Convert traditional statements to expressions
;    Don't pass whole commands, instead pass one parameter at a time
; =============================================================================
ToExp(Text)
{
   static qu := '"'  ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")       ; If text is empty
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox text=%text%

   if InStr(Text, "%")        ; deref   %var% -> var
   {
      ;msgbox %text%
      TOut := ""
      DeRef := 0
      ;Loop % StrLen(Text)
      Loop Parse, Text
      {
         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField
         If Symbol == "%"
         {
            If (DeRef := !DeRef) && (A_Index != 1)
               TOut .= qu . " . "
            else If (!DeRef) && (A_Index != StrLen(Text))
               TOut .= " . " . qu
         }
         else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }
      If Symbol != "%"
         TOut .= (qu) ; One double quote
   }
   else if isNumber(Text)
   {
      ;msgbox %text%
      TOut := Text+0
   }
   else      ; wrap anything else in quotes
   {
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . Text . qu
   }
   return (TOut)
}

; same as above, except numbers are excluded. 
; that is, a number will be turned into a quoted number.  3 -> "3"
ToStringExpr(Text)
{
   static qu := '"'  ; Constant for double quotes
   static bt := "``" ; Constant for backtick to escape
   Text := Trim(Text, " `t")

   If (Text = "")       ; If text is empty
      return (qu . qu)  ; Two double quotes
   else if (SubStr(Text, 1, 2) = "`% ")    ; if this param was a forced expression
      return SubStr(Text, 3)               ; then just return it without the %

   Text := StrReplace(Text, qu, bt . qu)    ; first escape literal quotes
   Text := StrReplace(Text, bt . ",", ",")  ; then remove escape char for comma
   ;msgbox("text=" text)

   if InStr(Text, "%")        ; deref   %var% -> var
   {
      TOut := ""
      DeRef := 0
      ;Loop % StrLen(Text)
      Loop Parse, Text
      {
         ;Symbol := Chr(NumGet(Text, (A_Index-1)*2, "UChar"))
         Symbol := A_LoopField
         If Symbol == "%"
         {
            If (DeRef := !DeRef) && (A_Index != 1)
               TOut .= qu . " . "
            else If (!DeRef) && (A_Index != StrLen(Text))
               TOut .= " . " . qu
         }
         else
         {
            If A_Index = 1
               TOut .= qu
            TOut .= Symbol
         }
      }

      If Symbol != "%"
         TOut .= (qu) ; One double quote
   }
   ;else if type(Text+0) != "String"
   ;{
      ;msgbox %text%
      ;TOut := Text+0
   ;}
   else      ; wrap anything else in quotes
   {
      ;msgbox text=%text%`ntout=%tout%
      TOut := qu . Text . qu
   }
   return (TOut)
}

; change   "text" -> text
RemoveSurroundingQuotes(text)
{
   if (SubStr(text, 1, 1) = "`"") && (SubStr(text, -1) = "`"")
      return SubStr(text, 2, -1)
   return text
}

; change   %text% -> text
RemoveSurroundingPercents(text)
{
   if (SubStr(text, 1, 1) = "`%") && (SubStr(text, -1) = "`%")
      return SubStr(text, 2, -1)
   return text
}

; check if a param is empty
IsEmpty(param)
{
   if (param = '') || (param = '""')   ; if its an empty string, or a string containing two double quotes
      return true
   return false
}

; =============================================================================
; Command formatting functions
;    They all accept an array of parameters and return command(s) in text form
;    These are only called in one place in the script and are called dynamicly
; =============================================================================
_Control(p){
   ; Control, SubCommand , Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText

   if (p[1]="Check"){
      p[1] := "SetChecked"
      p[2] := 1
   }
   else if (p[1]="UnCheck"){
      p[1] := "SetChecked"
      p[2] := 0
   }
   else if (p[1]="Enable"){
      p[1] := "SetEnabled"
      p[2] := 1
   }
   else if (p[1]="Disable"){
      p[1] := "SetEnabled"
      p[2] := 0
   }
   else if (p[1]="Add"){
      p[1] := "AddItem"
   }
   else if (p[1]="Delete"){
      p[1] := "DeleteItem"
   }
   else if (p[1]="Choose"){
      p[1] := "ChooseIndex"
   }
   else if (p[1]="ChooseString"){
      p[1] := "ChooseString"
   }
   else if (p[1]="EditPaste"){
      return format("EditPaste({2},{3},{4},{5},{6})", p*)
   }
   else if (p[1]="Show" || p[1]="ShowDropDown" || p[1]="HideDropDown" || p[1]="Hide"){
      return format("Control{1}({3},{4},{5},{6})", p*)
   }
   return format("Control{1}({2},{3},{4},{5},{6})", p*)
}

_ControlGet(p){
   ;ControlGet, OutputVar, SubCommand , Value, Control, WinTitle, WinText, ExcludeTitle, ExcludeText
   ; unfinished
   if (p[2]="List"){
      if (p[3]!=""){
         MsgBox("Listview, to be implemented")
      }
      p[2] := "Items"
      Out := format("o{1} := Control{2}({3}, {4}, {5}, {6}, {7}, {8})", p*) "`r`n"
      Out .= Indentation "for FileName in o " p[1] "`r`n"
      Out .= Indentation "{`r`n"
      Out .= Indentation p[1] " .= A_index=2 ? `"``r`n`" : `"`"`r`n"
      Out .= Indentation p[1] " .= A_index=1 ? FileName : Regexreplace(FileName,`"^.*\\([^\\]*)$`" ,`"$1`") `"``r``n`"`n"
      Out .= Indentation "}"
   }
   else if(p[2]="Tab" || p[2]="FindString"){
      p[2] := "Index"
   }
   if (p[2]="Checked" || p[2]="Enabled" || p[2]="Visible" || p[2]="Index" || p[2]="Choice" || p[2]="Style" || p[2]="ExStyle"){
      Out := format("{1} := Control{2}({4}, {5}, {6}, {7}, {8})", p*)
   }
   else if (p[2]="LineCount"){
      Out := format("{1} := EditGetLineCount({4}, {5}, {6}, {7}, {8})", p*)
   }
   else if (p[2]="CurrentLine"){
      Out := format("{1} := EditGetCurrentLine({4}, {5}, {6}, {7}, {8})", p*)
   }
   else if (p[2]="CurrentCol"){
      Out := format("{1} := EditGetCurrentCol({4}, {5}, {6}, {7}, {8})", p*)
   }
   else if (p[2]="Line"){
      Out := format("{1} := EditGetLine({3}, {4}, {5}, {6}, {7}, {8})", p*)
   }
   else if (p[2]="Selected"){
      Out := format("{1} := EditGetSelectedText({4}, {5}, {6}, {7}, {8})", p*)
   }
   else {
      Out := format("{1} := ControlGet{2}({3}, {4}, {5}, {6}, {7}, {8})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_ControlGetFocus(p){

   Out := format("{1} := ControlGetClassNN(ControlGetFocus({2}, {3}, {4}, {5}))", p*)
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}

_CoordMode(p){
   ; V1: CoordMode,TargetTypeT2E,RelativeToT2E | *_CoordMode
   p[2] := StrReplace(P[2], "Relative", "Window")
   Out := Format("CoordMode({1}, {2})", p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_DllCall(p){
   ParBuffer :=""
   loop p.Length
   {
      if (p[A_Index] ~= "^&"){ ; Remove the & parameter
         p[A_Index] := SubStr(p[A_Index], 2)
      }
      if (A_Index !=1 and (InStr(p[A_Index-1] ,"*`"") or InStr(p[A_Index-1] ,"*`'"))){
         p[A_Index] := "&" p[A_Index]
         if (!InStr(p[A_Index] ,":=")){
            p[A_Index] .= " := 0"
         }
      }
      ParBuffer .= A_Index=1 ? p[A_Index] : ", " p[A_Index]
   }
   Return "DllCall(" ParBuffer ")"
}

_Drive(p){
   if (p[1]="Label"){
      Out := Format("DriveSetLabel({2}, {3})", p[1],ToExp(p[2]),ToExp(p[3]))
   }
   else if (p[1]="Eject"){
      if (p[3]="0" or p[3]=""){
          Out := Format("DriveEject({2})", p*)
      }
      else{
         Out := Format("DriveRetract({2})", p*)
      }
   }
   else {
      p[2] := p[2] ="" ? "" : ToExp(p[2])
      p[3] :=  p[3] ="" ? "" : ToExp(p[3])
      Out := Format("Drive{1}({2}, {3})", p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_EnvAdd(p) {
   if !IsEmpty(p[3])
      return format("{1} := DateAdd({1}, {2}, {3})", p*)
   else
      return format("{1} += {2}", p*)
}

_EnvSub(p) {
   if !IsEmpty(p[3])
      return format("{1} := DateDiff({1}, {2}, {3})", p*)
   else
      return format("{1} -= {2}", p*)
}

_FileCopyDir(p){
   global ScriptStringsUsed
   if ScriptStringsUsed.ErrorLevel{
      Out :=  format("Try{`r`n" Indentation "   DirCopy({1}, {2}, {3})`r`n" Indentation "   ErrorLevel := 0`r`n" Indentation "} Catch {`r`n" Indentation "   ErrorLevel := 1`r`n" Indentation "}" ,p*)
   }
   Else {
      out := format("DirCopy({1}, {2}, {3})" ,p*)
      }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
_FileCopy(p){
   global ScriptStringsUsed
   ; We could check if Errorlevel is used in the next 20 lines
   if ScriptStringsUsed.ErrorLevel{
      Out :=  format("Try{`r`n" Indentation "   FileCopy({1}, {2}, {3})`r`n" Indentation "   ErrorLevel := 0`r`n" Indentation "} Catch as Err {`r`n" Indentation "   ErrorLevel := Err.Extra`r`n" Indentation "}" ,p*)
   }
   Else {
      out := format("FileCopy({1}, {2}, {3})" ,p*)
      }
   Return RegExReplace(Out, "[\s\,]*\)", ")")
}
_FileRead(p){
   ; FileRead, OutputVar, Filename
   ; OutputVar := FileRead(Filename , Options)
   if InStr(p[2],"*"){
      Options := RegExReplace(p[2], "^\s*(\*.*?)\s[^\*]*$","$1")
      Filename := RegExReplace(p[2], "^\s*\*.*?\s([^\*]*)$","$1")
      Options := StrReplace(Options, "*t","``n")
      Options := StrReplace(Options, "*")
      If InStr(options, "*P"){
         OutputDebug("Conversion FileRead has not correct.`n")
      }
      ; To do: add encoding
      Return format("{1} := Fileread({2}, {3})", p[1], ToExp(Filename) , ToExp(Options))
   }
   Return format("{1} := Fileread({2})", p[1], ToExp(p[2]))
}
_FileReadLine(p){
   ; FileReadLine, OutputVar, Filename, LineNum
   ; Not really a good alternative, inefficient but the result is the same

   Return p[1] " := StrSplit(FileRead(" p[2] "),`"``n`",`"``r`")[" P[3] "]"
}
_FileSelect(p){
   ; V1: FileSelectFile, OutputVar [, Options, RootDir\Filename, Title, Filter]
   ; V2: SelectedFile := FileSelect([Options, RootDir\Filename, Title, Filter])
   global O_Index
   global Orig_Line_NoComment
   global oScriptString ; array of all the lines
   global Indentation

   oPar := V1ParSplit(RegExReplace(Orig_Line_NoComment, "i)^\s*FileSelectFile\s*[\s,]\s*(.*)$", "$1"))
   OutputVar := oPar[1]
   Options := oPar.Has(2) ? oPar[2] : ""
   RootDirFilename := oPar.Has(3) ? oPar[3] : ""
   Title := oPar.Has(4) ? trim(oPar[4]) : ""
   Filter := oPar.Has(5) ? trim(oPar[5]) : ""

   Parameters := ""
   if (Filter!=""){
      Parameters .= ToExp(Filter)
   }
   if (Title!="" or Parameters!=""){
      Parameters := Parameters!="" ? ", " Parameters : ""
      Parameters := ToExp(Title) Parameters
   }
   if (RootDirFilename!="" or Parameters!=""){
      Parameters := Parameters!="" ? ", " Parameters : ""
      Parameters := ToExp(RootDirFilename) Parameters
   }
   if (Options!="" or Parameters!=""){
      Parameters := Parameters!="" ? ", " Parameters : ""
      Parameters := ToExp(Options) Parameters
   }

   Line := format("{1} := FileSelect({2})", OutputVar, parameters)
   if InStr(Options,"M"){
      Line := format("{1} := FileSelect({2})", "o" OutputVar, parameters) "`r`n"
      Line .= Indentation "for FileName in o " OutputVar "`r`n"
      Line .= Indentation "{`r`n"
      Line .= Indentation OutputVar " .= A_index=2 ? `"``r`n`" : `"`"`r`n"
      Line .= Indentation OutputVar " .= A_index=1 ? FileName : Regexreplace(FileName,`"^.*\\([^\\]*)$`" ,`"$1`") `"``r``n`"`n"
      Line .= Indentation "}"
   }
   return Line
}

_Gosub(p){
   ; Need to convert label into a function
   Return trim(p[1]) "()"
}

_Gui(p){

   global Orig_Line_NoComment
   global GuiNameDefault
   global ListViewNameDefault
   global TreeViewNameDefault
   global StatusbarNameDefault
   global GuiList
   global oScriptString ; array of all the lines
   global O_Index  ; current index of the lines
   global GuiVList
   ;preliminary version
   
   SubCommand := RegExMatch(p[1],"i)^\s*[^:]*?\s*:\s*(.*)$",&newGuiName) = 0 ? Trim(p[1]) : newGuiName[1]
   GuiName := RegExMatch(p[1],"i)^\s*([^:]*?)\s*:\s*.*$",&newGuiName) = 0 ? "" : newGuiName[1]

   GuiLine := Orig_Line_NoComment
   LineResult:=""
   if RegExMatch(GuiLine, "i)^\s*Gui\s*[,\s]\s*.*$"){
      ControlHwnd:=""
      ControlLabel:=""
      ControlName:=""
      ControlObject:=""

      if RegExMatch(GuiLine, "i)^\s*Gui\s*[\s,]\s*[^,\s]*:.*$")
      {
         GuiNameLine := RegExReplace(GuiLine, "i)^\s*Gui\s*[\s,]\s*([^,\s]*):.*$", "$1", &RegExCount1)
         GuiLine := RegExReplace(GuiLine, "i)^(\s*Gui\s*[\s,]\s*)([^,\s]*):(.*)$", "$1$3", &RegExCount1)   
         GuiNameDefault := GuiNameLine
      }
      else{
         GuiNameLine:= GuiNameDefault
      }
      if (RegExMatch(GuiNameLine, "^\d$")){
         GuiNameLine := "Gui" GuiNameLine
      }
      Var1 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
      Var2 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*)\s*,\s*([^,]*).*", "$2", &RegExCount2)
      Var3 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*).*$", "$3", &RegExCount3)
      Var4 := RegExReplace(GuiLine, "i)^\s*Gui\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),([^;]*).*", "$4", &RegExCount4)
      Var1 := Trim(Var1)
      Var2 := Trim(Var2)
      Var3 := Trim(Var3)
      Var4 := Trim(Var4)

      if RegExMatch(Var3, "\bg[\w]*\b"){
         ; Remove the goto option g....
         ControlLabel:= RegExReplace(Var3, "^.*\bg([\w]*)\b.*$", "$1")
         Var3:= RegExReplace(Var3, "^(.*)\bg([\w]*)\b(.*)$", "$1$3")
      }
      else if (var2="Button"){
         ControlLabel:= var2 RegExReplace(Var4, "[\s&]", "")
      }
      if RegExMatch(Var3, "\bv[\w]*\b"){
         ControlName:= RegExReplace(Var3, "^.*\bv([\w]*)\b.*$", "$1")

         ControlObject := InStr(ControlName, SubStr(Var4,1,4)) ? "ogc" ControlName : "ogc" Var2 ControlName
         
         if (GuiVList.Has(GuiNameLine)){
            GuiVList[GuiNameLine] .= "`r`n" ControlName
         }
         else {
            GuiVList[GuiNameLine] :=  ControlName
         }
      }
      if RegExMatch(Var3, "i)\bhwnd[\w]*\b"){
         ControlHwnd:= RegExReplace(Var3, "i)^.*\bhwnd([\w]*)\b.*$", "$1")
         Var3:= RegExReplace(Var3, "i)^(.*)\bhwnd([\w]*)\b(.*)$", "$1$3")
         if (ControlObject=""){
            ControlObject := InStr(ControlHwnd, SubStr(Var4,1,4)) ? "ogc" StrReplace(ControlHwnd,"hwnd") : "ogc" Var4 StrReplace(ControlHwnd,"hwnd")
         }
      }

      if !InStr(GuiList, "|" GuiNameLine "|"){
         GuiList .= GuiNameLine "|"
         LineResult := GuiNameLine " := Gui()`r`n" Indentation
      }

      if(RegExMatch(Var1, "i)^tab[23]?$")){
         Return LineResult "Tab.UseTab(" Var2 ")"

      }
      if(Var1="Show"){
         if (RegExCount3){
            LineResult.= GuiNameLine ".Title := " ToStringExpr(Var3) "`r`n" Indentation
            Var3:=""
            RegExCount3:=0
         }
      }

      if(RegExMatch(Var2, "i)^tab[23]?$")){
         LineResult.= "Tab := " 
      }
      if(var1 = "Submit"){
         LineResult.= "oSaved := " 
      }

      if(var1 = "Add"){
         if(var2="TreeView" and ControlObject!=""){
            TreeViewNameDefault := ControlObject
         }
         if(var2="StatusBar" and ControlObject!=""){
            StatusBarNameDefault := ControlObject
         }
         if(var2="Button" or var2="ListView" or ControlLabel!="" or ControlObject!=""){
            if (ControlObject=""){
               ControlObject := "ogc" var2 RegExReplace(Var4, "[^\w_]", "")
            }
            LineResult.= ControlObject " := " 
            if (var2="ListView"){
               ListViewNameDefault := ControlObject
            }
         }
      }
      if(var1 = "Color"){
         Return LineResult GuiNameLine ".BackColor := " ToStringExpr(Var2)
      }
      if(var1 = "Margin"){
         Return LineResult GuiNameLine ".MarginX := " ToStringExpr(Var2) ", " GuiNameLine ".MarginY := " ToStringExpr(Var3)
      }
      if(var1 = "Font"){
         var1 := "SetFont"
      }

      LineResult.= GuiNameLine "." 

      if (Var1="Menu"){
         ; To do: rename the output of the convert function to a global variable ( cOutput) 
         ; Why? output is a to general name to use as a global variable. To fragile for errors.
         ; Output := StrReplace(Output, trim(Var3) ":= Menu()", trim(Var3) ":= MenuBar()")

         LineResult.=  "MenuBar := " Var2
      }
      else{
         if (RegExCount1){
            if (RegExMatch(Var1, "^\s*[-\+]\w*")){
               LineResult.= "Opt(" ToStringExpr(Var1)
            }
            Else{
               LineResult.= Var1 "("
            }
         }
         if (RegExCount2){
            LineResult.= ToStringExpr(Var2)
         }
         if (RegExCount3){
            LineResult.= ", " ToStringExpr(Var3)
         }
         else if (RegExCount4){
            LineResult.= ", "
         }
         if (RegExCount4){
            if(RegExMatch(Var2, "i)^tab[23]?$") or Var2="ListView" or Var2="DropDownList" or Var2="ListBox"){
               LineResult.= ", [" 
               oVar4 :=""
               Loop Parse Var4, "|", " "
               {
                  oVar4.= oVar4="" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
               }
               LineResult.= oVar4 "]"
            }
            else{
               LineResult.= ", " ToStringExpr(Var4)
            }
         }
         if (RegExCount1){
            LineResult.= ")"
         }

         if(var1 = "Submit"){
            ; This should be replaced by keeping a list of the v variables of a Gui and declare for each "vName := oSaved.vName"
            if (GuiVList.Has(GuiNameLine)){
               Loop Parse, GuiVList[GuiNameLine],"`n","`r"
               {
                  if GuiVList[GuiNameLine]
                  LineResult.= "`r`n" Indentation A_LoopField " := oSaved." A_LoopField
               }
            }
            ; Shorter alternative, but this results in warning that variables are never assigned 
            ; LineResult.= "`r`n" Indentation "`; Hack to define variables`n`r" Indentation "for VariableName,Value in oSaved.OwnProps()`r`n" Indentation "   %VariableName% := Value"
         }

      }
      if (var1 = "Add" and var2 = "ActiveX" and ControlName!=""){
         ; Fix for ActiveX control, so functions of the ActiveX can be used  
         LineResult .= "`r`n" Indentation ControlName " := " ControlObject ".Value"
      }

      if(ControlLabel!=""){
         LineResult.= "`r`n" Indentation ControlObject ".OnEvent(`"Click`", " ControlLabel ")"
      }
      if(ControlHwnd!=""){
         LineResult.= "`r`n" Indentation ControlHwnd " := " ControlName ".hwnd"
      }
   }
   DebugWindow("LineResult:" LineResult "`r`n")
   Out := format("{1}", LineResult)
   return Out   
}

_GuiControl(p){
   global GuiNameDefault
   SubCommand := RegExMatch(p[1],"i)^\s*[^:]*?\s*:\s*(.*)$",&newSubCommand) = 0 ? Trim(p[1]) : newSubCommand[1]
   GuiName := RegExMatch(p[1],"i)^\s*([^:]*?)\s*:\s*.*$",&newGuiName) = 0 ? GuiNameDefault : newGuiName[1]
   ControlID := Trim(p[2])
   Value := Trim(p[3])
   Out := ""
   ControlObject := "ogc" ControlID ; for now, this can be improved in the future
   if (SubCommand=""){
      ; Not perfect, as this should be dependent on the type of control
      
      if InStr(Value,"|"){

         PreSelected := ""
         If (SubStr(Value,1,1)="|"){
            Value := SubStr(Value,2)
            Out .= ControlObject ".Delete() `;Clean the list`r`n" Indentation
         }
         Items := "[" 
         Loop Parse Value, "|", " "
         {
            if (A_LoopField="" and A_Index!=1){
               PreSelected := LoopFieldPrev
               continue
            }
            Items.= Items="[" ? ToStringExpr(A_LoopField) : ", " ToStringExpr(A_LoopField)
            LoopFieldPrev:= A_LoopField
         }
         Items .= "]"
         Out .= ControlObject ".Add(" Items ")"
         if (PreSelected!=""){
            Out .= "`r`n" Indentation ControlID ".ChooseString(" ToStringExpr(PreSelected) ")"
         }
         Return Out
      }
      Return ControlObject ".Value := " ToExp(Value)
   }
   else if (SubCommand="Text"){
      Return ControlObject ".Text := " ToExp(Value)
   }
   else if (SubCommand="Move" or SubCommand="MoveDraw"){
         X:= RegExMatch(Value,"i)^.*\bx`"(\s*[^`"]*)\b.*$",&newX) = 0 ? "" : newX[1]
         Y:= RegExMatch(Value,"i)^.*\by`"(\s*[^`"]*)\b.*$",&newY) = 0 ? "" : newY[1]
         W:= RegExMatch(Value,"i)^.*\bw`"(\s*[^`"]*)\b.*$",&newW) = 0 ? "" : newW[1]
         H:= RegExMatch(Value,"i)^.*\bh`"(\s*[^`"]*)\b.*$",&newH) = 0 ? "" : newH[1]
      if (X=""){
         X:= RegExMatch(Value, "i)^.*\bx([\w]*)\b.*$",&newX) = 0 ? "" : newX[1]
      }
      if (Y=""){
         Y:= RegExMatch(Value, "i)^.*\bY([\w]*)\b.*$",&newY) = 0 ? "" : newY[1]
      }
      if (W=""){
         W:= RegExMatch(Value, "i)^.*\bw([\w]*)\b.*$",&newW) = 0 ? "" : newW[1]
      }
      if (H=""){
         H:= RegExMatch(Value, "i)^.*\bh([\w]*)\b.*$",&newH) = 0 ? "" : newH[1]
      }

      Out := ControlObject "." SubCommand "(" X ", " Y ", " W ", " H ")"
      Out := RegExReplace(Out, "[\s\,]*\)$", ")")
      Return Out
   }
   else if (SubCommand="Focus"){
      Return ControlObject ".Focus()"
   }
   else if (SubCommand="Disable"){
      Return ControlObject ".Enabled := false"
   }
   else if (SubCommand="Enable"){
      Return ControlObject ".Enabled := true"
   }
   else if (SubCommand="Hide"){
      Return ControlObject ".Visible := false"
   }
   else if (SubCommand="Show"){
      Return ControlObject ".Visible := true"
   }
   else if (SubCommand="Choose"){
      Return ControlObject ".Choose(" Value ")"
   }
   else if (SubCommand="ChooseString"){
      Return ControlObject ".Choose(" ToExp(Value) ")"
   }
   else if (SubCommand="Font"){
      Return ";to be implemented"
   }
   else if (RegExMatch(SubCommand,"^[+-].*")){
      Return ControlObject ".Options(" ToExp(SubCommand) ")"
   }
   
   Return
}

_GuiControlGet(p){
   ; GuiControlGet, OutputVar , SubCommand, ControlID, Value
   global GuiNameDefault
   OutputVar := Trim(p[1])
   SubCommand := RegExMatch(p[2],"i)^\s*[^:]*?\s*:\s*(.*)$",&newSubCommand) = 0 ? Trim(p[2]) : newSubCommand[1]
   GuiName := RegExMatch(p[2],"i)^\s*([^:]*?)\s*:\s*.*$",&newGuiName) = 0 ? GuiNameDefault : newGuiName[1]
   ControlID := Trim(p[3])
   Value := Trim(p[4])
   If (ControlID=""){
      ControlID := OutputVar
   }

   Out := ""
   ControlObject := "ogc" ControlID ; for now, this can be improved in the future
   if (SubCommand=""){
      if (Value="text"){
         Out := OutputVar " := " ControlObject ".Text"
      }
      else{
       Out := OutputVar " := " ControlObject ".Value"
      }
   }
   else if (SubCommand="Pos"){
      Out := ControlObject ".GetPos(&" OutputVar "X, &" OutputVar "Y, &" OutputVar "W, &" OutputVar "H)" 
   }
   else if (SubCommand="Focus"){
      ; not correct
      Out := "; " OutputVar " := ControlGetFocus() `; Not really the same, this returns the HWND..." 
   }
   else if (SubCommand="FocusV"){
      ; not correct MyGui.FocusedCtrl
      Out := "; " OutputVar " := " GuiName ".FocusedCtrl `; Not really the same, this returns the focused gui control object..." 
   }
   else if (SubCommand="Enabled"){
      Out :=  OutputVar " := " ControlObject ".Enabled" 
   }
   else if (SubCommand="Visible"){
      Out :=  OutputVar " := " ControlObject ".Visible" 
   }
   else if (SubCommand="Name"){
      Out :=  OutputVar " := " ControlObject ".Name" 
   }
   else if (SubCommand="Hwnd"){
      Out :=  OutputVar " := " ControlObject ".Hwnd" 
   }

   
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_Hotkey(p){
   if(p[1]="IfWinActive"){
         p[2] := p[2] ="" ? "" : ToExp(p[2])
         p[3] :=  p[3] ="" ? "" : ToExp(p[3])
         Out := Format("HotIfWinActive({2}, {3})",p*)
   }
   else if(p[1]="IfWinNotActive"){
         p[2] := p[2] ="" ? "" : ToExp(p[2])
         p[3] :=  p[3] ="" ? "" : ToExp(p[3])
         Out := Format("HotIfWinNotActive({2}, {3})",p*)
   }
   else if(p[1]="IfWinExist"){
         p[2] := p[2] ="" ? "" : ToExp(p[2])
         p[3] :=  p[3] ="" ? "" : ToExp(p[3])
         Out := Format("HotIfWinExist({2}, {3})",p*)
   }
   else if(p[1]="IfWinNotExist"){
         p[2] := p[2] ="" ? "" : ToExp(p[2])
         p[3] :=  p[3] ="" ? "" : ToExp(p[3])
         Out := Format("HotIfWinNotExist({2}, {3})",p*)
   }
   else{
      p[1] :=  p[1] ="" ? "" : ToExp(p[1])
      if (P[2]= "on" or P[2]= "off" or P[2]= "Toggle" or P[2]~= "^AltTab" or P[2]~= "^ShiftAltTab"){
         p[2] := p[2] ="" ? "" : ToExp(p[2])
      }
      p[3] :=  p[3] ="" ? "" : ToExp(p[3])
      Out := Format("Hotkey({1}, {2}, {3})",p*)
   }
   Out := RegExReplace(Out, "\s*`"`"\s*\)$", ")")
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_IfGreater(p){
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) > 0)", p*)
}

_IfGreaterOrEqual(p){
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} > {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) >= 0)", p*)
}

_IfLess(p){
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) < 0)", p*)
}

_IfLessOrEqual(p){
   ; msgbox(p[2])
   if isNumber(p[2]) || InStr(p[2], "%")
      return format("if ({1} < {2})", p*)
   else
      return format("if (StrCompare({1}, {2}) <= 0)", p*)
}

_InputBox(oPar){
   ; V1: InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default]
   ; V2: Obj := InputBox(Prompt, Title, Options, Default)
   global O_Index
   global ScriptStringsUsed
   
   global oScriptString ; array of all the lines
   options :=""
  
   OutputVar := oPar[1]
   Title := oPar.Has(2) ? oPar[2] : ""
   Prompt := oPar.Has(3) ? oPar[3] : ""
   Hide := oPar.Has(4) ? trim(oPar[4]) : ""
   Width := oPar.Has(5) ? trim(oPar[5]) : ""
   Height := oPar.Has(6) ? trim(oPar[6]) : ""
   X := oPar.Has(7) ? trim(oPar[7]) : ""
   Y := oPar.Has(8) ? trim(oPar[8]) : ""
   Locale := oPar.Has(9) ? trim(oPar[9]) : ""
   Timeout := oPar.Has(10) ? trim(oPar[10]) : ""
   Default := oPar.Has(11) ? trim(oPar[11]) : ""

   Parameters := ToExp(Prompt) ", " ToExp(Title)
   if (Hide="hide"){
      Options .= "Password"
   }
   if (Width!=""){
      Options .= Options != "" ? " " : ""
      Options .=  "w" 
      Options .=  IsNumber(Width) ? Width :  "`" " Width " `""
   }
   if (Height!=""){
      Options .= Options != "" ? " " : ""
      Options .= "h"
      Options .=  IsNumber(Height) ? Height :  "`" " Height " `""
   }
   if (x!=""){
      Options .= Options != "" ? " " : ""
      Options .= "h"
      Options .=  IsNumber(x) ? x :  "`" " x " `""
   }
   if (y!=""){
      Options .= Options != "" ? " " : ""
      Options .= "h"
      Options .=  IsNumber(y) ? y :  "`" " y " `""
   }
   if (Options!=""){
      Parameters .= ", `"" Options "`""
   }
   if ScriptStringsUsed.ErrorLevel{
      Line := format("IB := InputBox({1}), {2} := IB.Value , ErrorLevel := IB.Result=`"OK`" ? 0 : IB.Result=`"CANCEL`" ? 1 : IB.Result=`"Timeout`" ? 2 : `"ERROR`"", parameters ,OutputVar)
   }
   else{
      Line := format("IB := InputBox({1}), {2} := IB.Value", parameters ,OutputVar)
   }

   return Line
}

_Loop(p){
   
   line := ""
   if (InStr(p[1],"*") and InStr(p[1],"\")){ ; Automatically switching to Files loop
      IncludeFolders := p[2]
      Recurse := p[3]
      p[3] := ""
      if (IncludeFolders=1){
         p[3] .= "FD"
      }
      else if (IncludeFolders=2){
         p[3] .= "D"
      }
      if (Recurse=1){
         p[3] .= "R"
      }
      p[2] := p[1]
      p[1] := "Files"
   }
   if (p[1] = "Parse")
   {
      Line := p.Has(4) ? Trim(ToExp(p[4])) : ""
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(3) ? Trim(ToExp(p[3])) Line : "" Line
      Line := Line != "" ? ", " Line : ""
      if (Substr(Trim(p[2]),1,1)="%"){
         p[2] := "ParseVar := " Substr(Trim(p[2]),2)
      }
      Line := ", " Trim(p[2]) Line
      Line := "Loop Parse" Line
      ; Line := format("Loop {1}, {2}, {3}, {4}",p[1], p[2], ToExp(p[3]), ToExp(p[4]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "") ; remove trailing ,\s and ,\s""
      return Line
   }
   else if (p[1] = "Files")
   {
      
      Line := format("Loop {1}, {2}, {3}","Files", ToExp(p[2]), ToExp(p[3]))
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "") ; remove trailing ,\s and ,\s""
      return Line
   }
   else if (p[1] = "Read" || p[1] = "Reg")
   {
      Line := p.Has(3) ? Trim(ToExp(p[3])) : "" 
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(2) ? Trim(ToExp(p[2])) Line : "" Line
      Line := Line != "" ? ", " Line : ""
      Line := p.Has(1) ? Trim(p[1]) Line : "" Line
      Line := "Loop " Line
      Line := RegExReplace(Line, "(?:,\s(?:`"`")?)*$", "") ; remove trailing ,\s and ,\s""
      return Line
   }
   else{
      Line := "Loop " Trim(ToExp(p[1]))
      return Line
   }
   ; Else no changes need to be made

}


_LV_Add(p){
   global ListviewNameDefault
   Return format("{1}.Add({2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17})", ListviewNameDefault, p*)
}
_LV_Delete(p){
   global ListviewNameDefault
   Return format("{1}.Delete({2})", ListviewNameDefault, p*)
}
_LV_DeleteCol(p){
   global ListviewNameDefault
   Return format("{1}.DeleteCol({2})", ListviewNameDefault, p*)
}
_LV_GetCount(p){
   global ListviewNameDefault
   Return format("{1}.GetCount({2})", ListviewNameDefault, p*)
}
_LV_GetText(p){
   global ListviewNameDefault
   Return format("{2} := {1}.GetText({3})", ListviewNameDefault, p*)
}
_LV_GetNext(p){
   global ListviewNameDefault
   Return format("{1}.GetNext({2},{3})", ListviewNameDefault, p*)
}
_LV_InsertCol(p){
   global ListviewNameDefault
   Return format("{1}.InsertCol({2}, {3}, {4})", ListviewNameDefault, p*)
}
_LV_Insert(p){
   global ListviewNameDefault
   Return format("{1}.Insert({2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17})", ListviewNameDefault, p*)
}
_LV_Modify(p){
   global ListviewNameDefault
   Return format("{1}.Modify({2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16}, {17})", ListviewNameDefault, p*)
}
_LV_ModifyCol(p){
   global ListviewNameDefault
   Return format("{1}.ModifyCol({2}, {3}, {4})", ListviewNameDefault, p*)
}
_LV_SetImageList(p){
   global ListviewNameDefault
   Return format("{1}.SetImageList({2}, {3})", ListviewNameDefault, p*)
}

_MsgBox(p){
   global O_Index
   global Orig_Line_NoComment
   global oScriptString ; array of all the lines
   global ScriptStringsUsed
   ; v1
   ; MsgBox, Text (1-parameter method)
   ; MsgBox [, Options, Title, Text, Timeout]
   ; v2
   ; Result := MsgBox(Text, Title, Options)
   Check_IfMsgBox()
   if RegExMatch(p[1], "i)^\dx?\d*\s*"){
      text:=""
      title:=""
      options:=p[1]
      if (p[3]=""){
         ContSection := Convert_GetContSect()
         if (ContSection!=""){
            LastParIndex := p.Length
            text :=  "`"`r`n" RegExReplace(ContSection,"s)^(.*\n\s*\))[^\n]*$", "$1") "`"`r`n"
            Timeout := RegExReplace(ContSection,"s)^.*\n\s*\)\s*,\s*(\d*)\s*$", "$1", &RegExCount)
            ; delete the empty parameter
            if (RegExCount){
               options.= " T" Timeout
            }
            title:= ToExp(p[2])

         }
      }
      else if (isNumber(p[p.Length]) and p.Length>3){
         text := ToExp(RegExReplace(Orig_Line_NoComment, "i)MsgBox\s*,?[^,]*,[^,]*,(.*),.*?$", "$1"))
         options.= " T" p[p.Length]
         title:= ToExp(p[2])
      }
      else{
         text := ToExp(RegExReplace(Orig_Line_NoComment, "i)MsgBox\s*,?[^,]*,[^,]*,(.*)$", "$1"))
      }
      Out := format("MsgBox({1}, {2}, {3})",  text , title, ToExp(options) )
      if ScriptStringsUsed.IfMsgBox{
         Out := "msgResult := " Out 
      }
      return Out
   }
   else if RegExMatch(p[1], "i)^\s*.*"){
      Out :=  format("MsgBox({1})",  ToExp(p[1]))
      if ScriptStringsUsed.IfMsgBox{
         Out := "msgResult := " Out 
      }
      return Out
   }
}

_Menu(p){
   global Orig_Line_NoComment
   global MenuList
   MenuLine := Orig_Line_NoComment
   LineResult:=""
   menuNameLine := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*).*$", "$1", &RegExCount1)
   Var2 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*)\s*,\s*([^,]*).*", "$2", &RegExCount2)
   Var3 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*).*$", "$3", &RegExCount3)
   Var4 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),\s*:?([^;,]*).*", "$4", &RegExCount4)
   Var5 := RegExReplace(MenuLine, "i)^\s*Menu\s*[,\s]\s*([^,]*),\s*([^,]*)\s*,\s*([^,]*),\s*:?([^;,]*)\s*,\s*([^,]*).*", "$5", &RegExCount5)
   menuNameLine := Trim(menuNameLine)
   Var2 := Trim(Var2)
   Var3 := Trim(Var3)
   Var4 := Trim(Var4)
   DebugWindow(menuList "`r`n")
   if (Var2="Add" and RegExCount3 and !RegExCount4){
      Var4 := Var3
      RegExCount4 := RegExCount3
   }
   if (Var2="Icon"){
      Var2 := "SetIcon"
   }
   if !InStr(menuList, "|" menuNameLine "|"){
      menuList.= menuNameLine "|"

      if (menuNameLine="Tray"){
         LineResult.= menuNameLine ":= A_TrayMenu`r`n"
      }
      else{
         LineResult.= menuNameLine " := Menu()`r`n"
      }
   }

   LineResult.= menuNameLine "." 

   if (RegExCount2){
      LineResult.= Var2 "("
   }
   if (RegExCount3){
      LineResult.= ToStringExpr(Var3)
   }
   else if (RegExCount4){
      LineResult.= ", "
   }
   if (RegExCount4){
      if (Var2="Add"){
         LineResult.= ", " Var4
      }
      else{
         LineResult.= ", " ToStringExpr(Var4)
      }
   }
   if (RegExCount5){
      LineResult.= ", " ToStringExpr(Var5)
   }
   if (RegExCount1){
      LineResult.= ")"
   }
   Out := format("{1}", LineResult)
   return Out  
}

_NumPut(p){
   ;V1 NumPut(Number,VarOrAddress,Offset,Type)
   ;V2 NumPut Type, Number, Type2, Number2, ... Target , Offset
   ; This should work to unwind the NumPut labyrinth
   p[1] := StrReplace(StrReplace(p[1],"`r"),"`n")
   p[2] := StrReplace(StrReplace(p[2],"`r"),"`n")
   p[3] := StrReplace(StrReplace(p[3],"`r"),"`n")
   p[4] := StrReplace(StrReplace(p[4],"`r"),"`n")
   if InStr(p[2], "Numput("){
      ParBuffer := ""
      loop {
            p[1] := Trim(p[1])
            p[2] := Trim(p[2])
            p[3] := Trim(p[3])
            p[4] := Trim(p[4])
            Number := p[1]
            VarOrAddress := p[2]
            if (p[4]="" ){
               if (P[3]=""){
                  OffSet := ""
                  Type := "`"UPtr`""
               }
               else if (IsInteger(p[3])){
                  OffSet := p[3]
                  Type := "`"UPtr`""
               }
               else{
                  OffSet := ""
                  Type := p[3]
               }
            }
            else{ ; 
                  OffSet := p[3]
                  Type := p[4]
            }
         NextParameters := RegExReplace(VarOrAddress,"is)^\s*Numput\((.*)\)\s*$","$1",&OutputVarCount)
         if (OutputVarCount=0){
            break
         }
         
         ParBuffer := Type ", " Number ", `r`n" Indentation "   " ParBuffer
         
         p := V1ParSplit(NextParameters)
         loop 4-p.Length {
            p.Push("")
         }
      }
      Out := "NumPut(" ParBuffer VarOrAddress ", " OffSet ")"
   }
   else{
      p[1] := Trim(p[1])
      p[2] := Trim(p[2])
      p[3] := Trim(p[3])
      p[4] := Trim(p[4])
      Number := p[1]
      VarOrAddress := p[2]
      if (p[4]="" ){
         if (P[3]=""){
            OffSet := ""
            Type := "`"UPtr`""
         }
         else if (IsInteger(p[3])){
            OffSet := p[3]
            Type := "`"UPtr`""
         }
         else{
            OffSet := ""
            Type := p[3]
         }
      }
      else{ ; 
            OffSet := p[3]
            Type := p[4]
      }
      Out := "NumPut(" Type ", " Number ", " VarOrAddress ", " OffSet ")"
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_OnExit(p){
   ;V1 OnExit,Func,AddRemove
   ConvertLabel2Funct(p[1])
   Return Format("OnExit({1}, {2})",p*)
}

_Process(p){
   ; V1: Process,SubCommand,PIDOrName,Value

   if (p[1]="Priority"){
      Out:= Format("ProcessSetPriority({1}, {2})", p[3], p[2])
   }
   else if (p[1]="Exist"){
      if ScriptStringsUsed.ErrorLevel{
         Out:= Format("ErrorLevel := Process{1}({2}, {3})", p*)
      }
      else{
         Out:= Format("Process{1}({2}, {3})", p*)
      }
   }
   else{
      Out:= Format("Process{1}({2}, {3})", p*)
   }
   
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_RegExMatch(p){
  global aListPseudoArray
  ; V1: FoundPos := RegExMatch(Haystack, NeedleRegEx , OutputVar, StartingPos := 1)
  ; V2: FoundPos := RegExMatch(Haystack, NeedleRegEx , &OutputVar, StartingPos := 1)
   
  if (p[3]!=""){
      OutputVar := SubStr(Trim(p[3]), 2) ; Remove the &
      if RegexMatch(P[2],"^[^(]*O[^(]*\)"){
         ; Object Match
         aListMatchObject.Push(OutputVar)
         
         P[2] := RegExReplace(P[2],"(^[^(]*)O([^(]*\).*$)","$1$2") ; Remove the "O from the options"
      }
      else if RegexMatch(P[2],"^\(.*\)"){
         aListPseudoArray.Push(OutputVar)
      }
      else {
         
         ; beneath the line, we sould write : Indentation OutputVar " := " OutputVar "[]"
         aListPseudoArray.Push(OutputVar)

      }
  }
  Out := Format("RegExMatch({1}, {2}, {3}, {4})",p*)
  Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SB_SetText(p){
   global StatusBarNameDefault
   Return format("{1}.SetText({2}, {3}, {4})", StatusBarNameDefault)
}
_SB_SetParts(p){
   global StatusBarNameDefault,gFunctPar
   Return format("{1}.SetParts({2})", StatusBarNameDefault,gFunctPar)
}
_SB_SetIcon(p){
   global StatusBarNameDefault,gFunctPar
   Return format("{1}.SetIcon({2})", StatusBarNameDefault,gFunctPar)
}

_SetTimer(p){
   if (p[2]="Off"){
      Out := format("SetTimer({1},0)",p*)
   }
   else{
      Out := format("SetTimer({1},{2},{3})",p*)
   }
   
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SoundGet(p){
   ; SoundGet,OutputVar,ComponentTypeT2E,ControlType,DeviceNumberT2E
   OutputVar := p[1]
   ComponentType := p[2]
   ControlType := p[3]
   DeviceNumber := p[4]
   if (ComponentType="" and ControlType="Mute"){
      out := Format("{1} := SoundGetMute({2}, {4})",p*)
   }
   else if (ComponentType="Volume" || ComponentType="Vol" || ComponentType="" ){
      out := Format("{1} := SoundGetVolume({2}, {4})",p*)
   }
   else if (ComponentType="mute" ){
      out := Format("{1} := SoundGetMute({2}, {4})",p*)
   }
   else{
      out := Format(";REMOVED CV2 {1} := SoundGet{3}({2}, {4})",p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SoundSet(p){
   ; SoundSet,NewSetting,ComponentTypeT2E,ControlType,DeviceNumberT2E
   NewSetting := p[1]
   ComponentType := p[2]
   ControlType := p[3]
   DeviceNumber := p[4]
   if (ControlType="mute" ){
      out := Format("SoundSetMute({1}, {2}, {4})",p*)
   }
   else if (ComponentType="Volume" || ComponentType="Vol" || ComponentType="" ){
      p[1] := InStr(p[1], "+") ? "`"" p[1] "`"" : p[1]
      out := Format("SoundSetVolume({1}, {2}, {4})",p*)
   }
   else{
      out := Format(";REMOVED CV2 Soundset{3}({1}, {2}, {4})",p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SplashTextOn(p){
   ;V1 : SplashTextOn,Width,Height,TitleT2E,TextT2E 
   ;V2 : Removed
   P[1] := P[1]="" ? 200 : P[1]
   P[2] := P[2]="" ? 0 : P[2]
   Return "SplashTextGui := Gui(`"ToolWindow -Sysmenu Disabled`", " p[3] "), SplashTextGui.Add(`"Text`",, " p[4] "), SplashTextGui.Show(`"w" p[1] " h" p[2] "`")"
}

_StringLower(p){
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrLower({2})", p*)
}
_StringUpper(p){
   if (p[3] = '"T"')
      return format("{1} := StrTitle({2})", p*)
   else
      return format("{1} := StrUpper({2})", p*)
}
_StringGetPos(p){
   global Indentation
   
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format("{1} := InStr({2}, {3}) - 1", p*)

   ; modelled off of:
   ; https://github.com/Lexikos/AutoHotkey_L/blob/9a88309957128d1cc701ca83f1fc5cca06317325/source/script.cpp#L14732
   else
   {
      p[5] := p[5] ? p[5] : 0   ; 5th param is 'Offset' aka starting position. set default value if none specified

      p4FirstChar := SubStr(p[4], 1, 1)
      p4LastChar := SubStr(p[4], -1)
      ; msgbox(p[4] "`np4FirstChar=" p4FirstChar "`np4LastChar=" p4LastChar)
      if (p4FirstChar = "`"") && (p4LastChar = "`"")   ; remove start/end quotes, would be nice if a non-expr was passed in
      {
         ; the text param was already conveted to expr based on the SideT2E param definition
         ; so this block handles cases such as "L2" or "R1" etc
         p4noquotes := SubStr(p[4], 2, -1)
         p4char1 := SubStr(p4noquotes, 1, 1)
         occurences := SubStr(p4noquotes, 2)
         ;msgbox, % p[4]
         ; p[4] := occurences ? occurences : 1

         if (StrUpper(p4char1) = "R")
         {
            ; only add occurrences param to InStr func if occurrences > 1
            if isInteger(occurences) && (occurences > 1)
               return format("{1} := InStr({2}, {3},, -1*(({5})+1), -" . occurences . ") - 1", p*)
            else
               return format("{1} := InStr({2}, {3},, -1*(({5})+1)) - 1", p*)
         }
         else
         {
            if isInteger(occurences) && (occurences > 1)
               return format("{1} := InStr({2}, {3},, ({5})+1, " . occurences . ") - 1", p*)
            else
               return format("{1} := InStr({2}, {3},, ({5})+1) - 1", p*)
         }
      }
      else if (p[4] = 1)
      {
         ; in v1 if occurrences param = "R" or "1" conduct search right to left
         ; "1" sounds weird but its in the v1 source, see link above
         return format("{1} := InStr({2}, {3},, -1*(({5})+1)) - 1", p*)
      }
      else if (p[4] = "")
      {
         return format("{1} := InStr({2}, {3},, ({5})+1) - 1", p*)
      }
      else
      {
         ; msgbox( p.Length "`n" p[1] "`n" p[2] "`n" p[3] "`n[" p[4] "]`n[" p[5] "]")
         ; else then a variable was passed (containing the "L#|R#" string),
         ;      or literal text converted to expr, something like:   "L" . A_Index
         ; output something anyway even though it won't work, so that they can see something to fix
         return format("{1} := InStr({2}, {3},, ({5})+1, {4}) - 1", p*)
      }
   }
}
_StringMid(p){
   if IsEmpty(p[4]) && IsEmpty(p[5])
      return format("{1} := SubStr({2}, {3})", p*)
   else if IsEmpty(p[5])
      return format("{1} := SubStr({2}, {3}, {4})", p*)
   else
   {
      ;msgbox, % p[5] "`n" SubStr(p[5], 1, 2)
      ; any string that starts with 'L' is accepted
      if (StrUpper(SubStr(p[5], 2, 1) = "L"))
         return format("{1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*)
      else
      {
         out := format("if (SubStr({5}, 1, 1) = `"L`")", p*) . "`r`n"
         out .= format("    {1} := SubStr(SubStr({2}, 1, {3}), -{4})", p*) . "`r`n"
         out .= format("else", p) . "`r`n"
         out .= format("    {1} := SubStr({2}, {3}, {4})", p*)
         return out
      }
   }
}
_StringReplace(p){
   ; v1
   ; StringReplace, OutputVar, InputVar, SearchText [, ReplaceText, ReplaceAll?]
   ; v2
   ; ReplacedStr := StrReplace(Haystack, Needle [, ReplaceText, CaseSense, OutputVarCount, Limit])
   global Indentation
   comment := "; StrReplace() is not case sensitive`r`n" Indentation "; check for StringCaseSense in v1 source script`r`n"
   comment .= Indentation "; and change the CaseSense param in StrReplace() if necessary`r`n"

   if IsEmpty(p[4]) && IsEmpty(p[5])
      return comment Indentation . format("{1} := StrReplace({2}, {3},,,, 1)", p*)
   else if IsEmpty(p[5])
      return comment Indentation . format("{1} := StrReplace({2}, {3}, {4},,, 1)", p*)
   else
   {
      p5char1 := SubStr(p[5], 1, 1)
      ; MsgBox(p[5] "`n" p5char1)

      if (p[5] = "UseErrorLevel")    ; UseErrorLevel also implies ReplaceAll
         return comment Indentation . format("{1} := StrReplace({2}, {3}, {4},, &ErrorLevel)", p*)
      else if (p5char1 = "1") || (StrUpper(p5char1) = "A")
         ; if the first char of the ReplaceAll param starts with '1' or 'A'
         ; then all of those imply 'replace all'
         ; https://github.com/Lexikos/AutoHotkey_L/blob/master/source/script2.cpp#L7033
         return comment Indentation . format("{1} := StrReplace({2}, {3}, {4})", p*)
   }
}
_StringSplit(p){
   ;V1 StringSplit,OutputArray,InputVar,DelimitersT2E,OmitCharsT2E
   ; Output should be checked to replace OutputArray\d to OutputArray[\d]
   global aListPseudoArray
   aListPseudoArray.Push(Trim(p[1]))
   Out := Format("{1} := StrSplit({2},{3},{4})",p*)
   Return RegExReplace(Out, "[\s\,]*\)$", ")")
}

_SysGet(p){
   ; SysGet,OutputVar,SubCommand,Value
   if (p[2]="MonitorCount"){
      Return Format("{1} := MonitorGetCount()", p*)
   }
   else if (p[2]="MonitorPrimary"){
      Return Format("{1} := MonitorGetPrimary()", p*)
   }
   else if (p[2]="Monitor"){
      Return Format("MonitorGet({3}, {1}Left, {1}Top, {1}Right, {1}Bottom)", p*)
   }
   else if (p[2]="MonitorWorkArea"){
      Return Format("MonitorGetWorkArea({3}, {1}Left, {1}Top, {1}Right, {1}Bottom)", p*)
   }
   else if (p[2]="MonitorName "){
      Return Format("{1} := MonitorGetName({3})", p*)
   }
   Return Format("{1} := SysGet({2})", p*)
}

_TV_Add(p){
   global TreeViewNameDefault
   Return format("{1}.Add({2}, {3}, {4})", TreeViewNameDefault, p*)
}
_TV_Modify(p){
   global TreeViewNameDefault
   Return format("{1}.Modify({2}, {3}, {4})", TreeViewNameDefault, p*)
}
_TV_Delete(p){
   global TreeViewNameDefault
   Return format("{1}.Delete({2})", TreeViewNameDefault, p*)
}
_TV_GetSelection(p){
   global TreeViewNameDefault
   Return format("{1}.GetSelection({2})", TreeViewNameDefault, p*)
}
_TV_GetParent(p){
   global TreeViewNameDefault
   Return format("{1}.GetParent({2})", TreeViewNameDefault, p*)
}
_TV_GetChild(p){
   global TreeViewNameDefault
   Return format("{1}.GetChild({2})", TreeViewNameDefault, p*)
}
_TV_GetPrev(p){
   global TreeViewNameDefault
   Return format("{1}.GetPrev({2})", TreeViewNameDefault, p*)
}
_TV_GetNext(p){
   global TreeViewNameDefault
   Return format("{1}.GetNext({2}, {3})", TreeViewNameDefault, p*)
}
_TV_GetText(p){
   global TreeViewNameDefault
   Return format("{2} := {1}.GetText({3})", TreeViewNameDefault, p*)
}
_TV_GetCount(p){
   global TreeViewNameDefault
   Return format("{1}.GetCount()", TreeViewNameDefault)
}
_TV_SetImageList(p){
   global TreeViewNameDefault
   Return format("{2} := {1}.SetImageList({3})", TreeViewNameDefault)
}

_VarSterCapacity(p){
   if (p[3]=""){
      Return Format("VarSetStrCapacity(&{1}, {2})",p*)
   }
   Return Format("{1} := Buffer({2}, {3})",p*)
}

_WinGetActiveStats(p) {
   Out := format("{1} := WinGetTitle(`"A`")", p*) . "`r`n"
   Out .= format("WinGetPos(&{4}, &{5}, &{2}, &{3}, `"A`")", p*)
   return Out   
}

_WinGet(p) {
   global Indentation
   p[2]:= p[2]="ControlList" ? "Controls" : p[2]
   
   Out := format("{1} := WinGet{2}({3},{4},{5},{6})", p*)
   if (P[2]="Class" || P[2]="List" || P[2]="Controls" || P[2]="ControlsHwnd" ||  P[2]="ControlsHwnd"){
      Out := format("o{1} := WinGet{2}({3},{4},{5},{6})", p*) "`r`n"
      Out .= Indentation "For v in o" P[1] "`r`n"
      Out .= Indentation "{`r`n"
      Out .= Indentation "   " P[1] " .= A_index=1 ? v : `"``r``n`" v`r`n"
      Out .= Indentation "}"
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")")  
}

_WinMove(p){
   ;V1 : WinMove, WinTitle, WinText, X, Y , Width, Height, ExcludeTitle, ExcludeText
   ;V1 : WinMove, X, Y
   ;V2 : WinMove X, Y , Width, Height, WinTitle, WinText, ExcludeTitle, ExcludeText
   if (p[3]="" and p[4]=""){
      
      Out := Format("WinMove({1}, {2})",p*)
   }
   else{
      p[1] := ToExp(p[1])
      p[2] := ToExp(p[2])
      Out := Format("WinMove({3}, {4}, {5}, {6}, {1}, {2}, {7}, {8})",p*)
   }
   Return RegExReplace(Out, "[\s\,]*\)$", ")") 
}

_WinSet(p) {
   if (p[1]="AlwaysOnTop"){
         p[2] := p[2]="on" ? 1 : p[2]="off" ? 0 : p[2]="toggle" ? -1 : p[2]  
   }
   if (p[1]="Region" or p[1]="Style" or p[1]="ExStyle"){
      p[2] :=  ToExp(p[2])
   }
   if (p[1]="Bottom"){
      Out := format("WinMoveBottom({2}, {3}, {4}, {5}, {6})", p*)
   }
   else if (p[1]="Top"){
      Out := format("WinMoveTop({2}, {3}, {4}, {5}, {6})", p*)
   }
   else if (p[1]="Disable"){
      Out := format("WinSetEnabled(0, {3}, {4}, {5}, {6})", p*)
   }
   else if (p[1]="Enable"){
      Out := format("WinSetEnabled(1, {3}, {4}, {5}, {6})", p*)
   }
   else if (p[1]="Redraw"){
      Out := format("WinRedraw({3}, {4}, {5}, {6})", p*)
   } 
   else{
      Out := format("WinSet{1}({2}, {3}, {4}, {5}, {6})", p*)
   }
   Out := RegExReplace(Out, "[\s\,]*\)$", ")")
   return Out   
}

_WinSetTitle(p){
   ; V1: WinSetTitle, NewTitle
   ; V1 (alternative): WinSetTitle, WinTitle, WinText, NewTitle , ExcludeTitle, ExcludeText
   ; V2: WinSetTitle NewTitle , WinTitle, WinText, ExcludeTitle, ExcludeText
   if (P[3]=""){
         Out := format("WinSetTitle({1})", p*)
   }
   else{
      Out := format("WinSetTitle({3}, {1}, {2}, {4}, {5})", p*)
   }
   Out := RegExReplace(Out, "[\s\,]*\)$", ")")
   return Out  
}

_WinWait(p){
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel{
      out := Format("ErrorLevel := WinWait({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0",p*)
      out := RegExReplace(Out, "[\s\,]*\)\s,\sErrorLevel", ") , ErrorLevel")
   }
   else{
      out := Format("WinWait({1}, {2}, {3}, {4}, {5})",p*)
      out := RegExReplace(Out, "[\s\,]*\)", ")")
   }
   Return out
}
_WinWaitActive(p){
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel{
      out := Format("ErrorLevel := WinWaitActive({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0",p*)
      out := RegExReplace(Out, "[\s\,]*\)\s,\sErrorLevel", ") , ErrorLevel")
   }
   else{
      out := Format("WinWaitActive({1}, {2}, {3}, {4}, {5})",p*)
      out := RegExReplace(Out, "[\s\,]*\)", ")")
   }
   Return out
}
_WinWaitNotActive(p){
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel{
      out := Format("ErrorLevel := WinWaitNotActive({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0",p*)
      out := RegExReplace(Out, "[\s\,]*\)\s,\sErrorLevel", ") , ErrorLevel")
   }
   else{
      out := Format("WinWaitNotActive({1}, {2}, {3}, {4}, {5})",p*)
      out := RegExReplace(Out, "[\s\,]*\)", ")")
   }
   Return out
}
_WinWaitClose(p){
   ; Created because else there where empty parameters.
   if ScriptStringsUsed.ErrorLevel{
      out := Format("ErrorLevel := WinWaitClose({1}, {2}, {3}, {4}, {5}) , ErrorLevel := ErrorLevel = 0 ? 1 : 0",p*)
      out := RegExReplace(Out, "[\s\,]*\)\s,\sErrorLevel", ") , ErrorLevel")
   }
   else{
      out := Format("WinWaitClose({1}, {2}, {3}, {4}, {5})",p*)
      out := RegExReplace(Out, "[\s\,]*\)", ")")
   }
   Return out
}

_HashtagIfWinActivate(p){
   if (p[1]="" and p[2]=""){
       Return "#HotIf"
   }
   Return format("#HotIf WinActive({1}, {2})",p*)
}

; =============================================================================

Convert_GetContSect(){
   ; Go further in the lines to get the next continuation section
   global oScriptString ; array of all the lines
   global O_Index  ; current index of the lines

   result:= ""

   loop {
      O_Index++
      if (oScriptString.Length < O_Index){
         break
      }
      LineContSect := oScriptString[O_Index]
      FirstChar := SubStr(Trim(LineContSect), 1, 1)
      if ((A_index=1) && (FirstChar != "(" or !RegExMatch(LineContSect, "i)^\s*\((?:\s*(?(?<=\s)(?!;)|(?<=\())(\bJoin\S*|[^\s)]+))*(?<!:)(?:\s+;.*)?$"))){
         ; no continuation section found
         O_Index--
         return ""
      }
      if ( FirstChar == ")" ){
         result .= LineContSect
         break
      }
      result .= LineContSect "`r`n"
   }
   DebugWindow("contsect:" result "`r`n",Clear:=0)

   return "`r`n" result
}

Check_IfMsgBox(){
   ; Go further in the lines to get the next continuation section
   global oScriptString ; array of all the lines
   global O_Index  ; current index of the lines
   global Indentation
   ; get Temporary index
   T_Index := O_Index
   result:= ""

   loop {
      T_Index++
      if (oScriptString.Length < T_Index or A_Index=40){ ; check the next 40 lines
         break
      }
      LineContSect := oScriptString[T_Index]
      FirstChar := SubStr(Trim(LineContSect), 1, 1)
      if (RegExMatch(LineContSect, "i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)(.*)")){
         if RegExMatch(LineContSect,"i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)\s*,\s*([^\s{]*)$"){
            oScriptString[T_Index] := RegExReplace(LineContSect, "i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)\s*,\s*([^\s{]*)$","$1if (msgResult = " ToExp("$2") "){`r`n" Indentation "   $3`r`n" Indentation "}" )
         }
         else{
            oScriptString[T_Index] := RegExReplace(LineContSect, "i)^(.*?)\bifMsgBox\s*[,\s]\s*(\w*)(.*)","$1if (msgResult = " ToExp("$2") ")$3" )
         }
      }
   }
   return 
}

; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and separate the variables
; Input:
;   String - The string to parse.
; Output:
;   RETURN - array of the parsed commands.
; --------------------------------------------------------------------
V1ParSplit(String){
   ; Created by Ahk_user
   ; Tries to split the parameters better because sometimes the , is part of a quote, function or object
   ; spinn-off from DeathByNukes from https://autohotkey.com/board/topic/35663-functions-to-get-the-original-command-line-and-parse-it/
   ; I choose not to trim the values as spaces can be valuable too
   oResult:= Array() ; Array to store result
   oIndex:=1 ; index of array
   InArray := 0
   InApostrophe := false
   InFunction := 0
   InObject := 0
   InQuote := false

   ; Checks if an even number was found, not bulletproof, fixes 50%
   StrReplace(String, '"',,, &NumberQuotes)
   CheckQuotes := Mod(NumberQuotes+1,2)

   StrReplace(String, "'",,, &NumberApostrophes)
   CheckApostrophes := Mod(NumberApostrophes+1,2)

   oString := StrSplit(String)
   oResult.Push("")
   Loop oString.Length
   {
      Char := oString[A_Index]
      if ( !InQuote && !InObject && !InArray && !InApostrophe && !InFunction){
         if (Char="," && (A_Index=1 || oString[A_Index-1] !="``")){
            oIndex++
            oResult.Push("")
            Continue
         }
      }
      
      if ( Char = "`"" && !InApostrophe && CheckQuotes){
         if (!InQuote){
            if (A_Index=1 || Instr("( ,",oString[A_Index-1])){
               InQuote := 1
            }
            else{
               CheckQuotes := 0
            }
         }
         else{
            if (A_Index=oString.Length || Instr(") ,",oString[A_Index+1])){
               InQuote := 0
            }
            else{
               CheckQuotes := 0
            }
         }
         
      }
      else if ( Char = "`'" && !InQuote && CheckApostrophes){
         if (!InApostrophe){
            if (A_Index!=1 || Instr("( ,",oString[A_Index-1])){
               CheckApostrophes := 0
            }
            else{
               InApostrophe := 1
            }
         }
         else{
            if (A_Index!=oString.Length || Instr(") ,",oString[A_Index+1])){
               CheckApostrophes := 0
            }
            else{
               InApostrophe := 0
            }
         }
      }
      else if (!InQuote && !InApostrophe){
         if ( Char = "{"){
            InObject++
         }
         else if ( Char = "}" && InObject){
            InObject--
         }
         else if ( Char = "[" ){
            InArray--
         }
         else if ( Char = "]" && InArray){
            InArray++
         }
         else if ( Char = "("){
            InFunction++
         }
         else if ( Char = ")" && InFunction){
            InFunction--
         }
      }
      oResult[oIndex] := oResult[oIndex] Char
   }
   return oResult
}

; --------------------------------------------------------------------
; Purpose: Read a ahk v1 command line and return the function, parameters, post and pre text
; Input:
;     String - The string to parse.
;     FuctionTaget - The number of the function that you want to target
; Output:
;   oResult - array
;       oResult.pre           text before the function
;       oResult.function      function name
;       oResult.parameters    parameters of the function
;       oResult.post          text afther the function
;       oResult.separator     character before the function
; --------------------------------------------------------------------
V1ParSplitFunctions(String, FunctionTarget := 1){
	; Will try to extract the function of the given line
	; Created by Ahk_user
	oResult:= Array() ; Array to store result Pre func params post
	oIndex:=1 ; index of array
	InArray := 0
	InApostrophe := false
	InQuote := false
	Hook_Status:=0
	
	FunctionNumber:=0
	Searchstatus:=0
	HE_Index:=0
	oString := StrSplit(String)
	oResult.Push("")
	
	Loop oString.Length
	{
		Char := oString[A_Index]
		
		if (Char = "'" && !InQuote){
			InApostrophe := !InApostrophe
		}
		else if (Char = "`"" && !InApostrophe){
			InQuote := !InQuote
		}
		if (Searchstatus=0){
			
			if (Char="(" and !InQuote and !InApostrophe){
				FunctionNumber++
				if (FunctionNumber=FunctionTarget){
					H_Index := A_Index
					; loop to find function
					loop H_Index-1 {
						if (!IsNumber(oString[H_Index - A_Index]) and !IsAlpha(oString[H_Index - A_Index]) And !InStr("#_@$", oString[H_Index - A_Index])){
							F_Index := H_Index - A_Index+1
							Searchstatus:=1
							break
						}
                  else if (H_Index - A_Index=1){
                     F_Index := 1
                     Searchstatus:=1
							break
                  }
					}
				}
			}
		}
		if (Searchstatus=1){
			if (oString[A_Index]="(" and !InQuote and !InApostrophe){
				Hook_Status++
			}
			else if (oString[A_Index]=")" and !InQuote and !InApostrophe){
				Hook_Status--
			}
			if (Hook_Status=0){
				HE_Index:= A_Index
				break
			}
		}
		oResult[oIndex] := oResult[oIndex] Char
	}
	if (Searchstatus=0){
		oResult.Pre:= String
		oResult.Func:= ""
		oResult.Parameters:= ""
		oResult.Post:= ""
		oResult.Separator:=""
      oResult.Found := 0
      
	}
	else{
		oResult.Pre:= SubStr(String, 1 , F_Index-1)
		oResult.Func:= SubStr(String, F_Index,H_Index - F_Index)
		oResult.Parameters:= SubStr(String, H_Index+1,HE_Index - H_Index-1 )
		oResult.Post:= SubStr(String, HE_Index+1 )
		oResult.Separator:= SubStr(String, F_Index-1,1)
      oResult.Found := 1
	}
   oResult.Hook_Status := Hook_Status
	return oResult
}

; Function to debug
DebugWindow(Text,Clear:=0,LineBreak:=0,Sleep:=0,AutoHide:=0){
   if WinExist("AHK Studio"){
      x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
      x.DebugWindow(Text,Clear,LineBreak,Sleep,AutoHide)
   }
   else{
      OutputDebug Text
   }
   return
}

Format2(FormatStr , Values*){
   ; Removes empty values
   return Format(FormatStr , Values*)
}

; Future function to convert a label to a function
; Most troublesome part will be to define the end...
ConvertLabel2Funct(label,Parameters:=""){
   ; to make: convert the defined label to a function : label => label(parameters){ .... }
   return
}

  ;// Param format:
   ;//          - param names ending in "T2E" will convert a literal Text param TO an Expression
   ;//              this would be used when converting a Command to a Func or otherwise needing an expr
   ;//              such as      word -> "word"      or      %var% -> var
   ;//              Changed: empty strings will return an emty string
   ;//              like the 'value' param in those  `IfEqual, var, value`  commands
   ;//          - param names ending in "T2QE" will convert a literal Text param TO an Quoted Expression
   ;//              this would be used when converting a Command to a expr
   ;//              This is the same as T2E, but will return an "" if empty.
   ;//          - param names ending in "CBE2E" would convert parameters that 'Can Be an Expression TO an EXPR' 
   ;//              this would only be used if the conversion goes from Command to Func 
   ;//              we'd need to strip a preceeding "% " which was used to force an expr when it was unnecessary 
   ;//          - param names ending in "CBE2T" would convert parameters that 'Can Be an Expression TO literal TEXT'
   ;//              this would be used if the conversion goes from Command to Command
   ;//              because in v2, those command parameters can no longer optionally be an expression.
   ;//              these will be wrapped in %%s, so   expr+1   is now    %expr+1%
   ;//          - param names ending in "Q2T" would convert parameters that 'Can Be an quoted TO literal TEXT'
   ;//               "var" => var 
   ;//               'var' => var 
   ;//                var => var 
   ;//          - param names ending in "V2VR" would convert an output variable name to a v2 VarRef
   ;//              basically it will just add an & at the start. so var -> &var
   ;//          - any other param name will not be converted
   ;//              this means that the literal text of the parameter is unchanged
   ;//              this would be used for InputVar/OutputVar params, or whenever you want the literal text preserved
ParameterFormat(ParName,ParValue){
   ParValue := Trim(ParValue)
   if (ParName ~= "V2VR$"){
      if (ParValue != "")
         ParValue := "&" . ParValue
   }
   else if (ParName ~= "CBE2E$")    ; 'Can Be an Expression TO an Expression'
   {
      if (SubStr(ParValue, 1, 2) = "% ")            ; if this param expression was forced
         ParValue := SubStr(ParValue, 3)       ; remove the forcing
      else
         ParValue := RemoveSurroundingPercents(ParValue)
   }
   else if (ParName ~= "CBE2T$")    ; 'Can Be an Expression TO literal Text'
   {
      if isInteger(ParValue)                                               ; if this param is int
      || (SubStr(ParValue, 1, 2) = "% ")                                      ; or the expression was forced
      || ((SubStr(ParValue, 1, 1) = "%") && (SubStr(ParValue, -1) = "%"))  ; or var already wrapped in %%s
         ParValue := ParValue                  ; dont do any conversion
      else
         ParValue := "%" . ParValue . "%"    ; wrap in percent signs to evaluate the expr
   }
   else if (ParName ~= "Q2T$")    ; 'Can Be an quote TO literal Text'
   {
      if ((SubStr(ParValue, 1, 1) = "`"") && (SubStr(ParValue, -1) = "`""))  ;  var already wrapped in Quotes
         || ((SubStr(ParValue, 1, 1) = "`'") && (SubStr(ParValue, -1) = "`'")) ;  var already wrapped in Quotes
               ParValue := SubStr(ParValue, 2, StrLen(ParValue)-2)
   }
   if (ParName ~= "T2E$")           ; 'Text TO Expression'
   {
      ParValue := ParValue!="" ? ToExp(ParValue) : ""
   }
   else if (ParName ~= "T2QE$")           ; 'Text TO Quote Expression'
   {
      ParValue := ToExp(ParValue)
   }

   Return ParValue
}

;// Converts PseudoArray to Array
;//  Example array123 => array[123]
;//  Example array%A_index% => array[A_index]
ConvertPseudoArray(ScriptStringInput,ArrayName){
    if InStr(ScriptStringInput,ArrayName){ ; InStr is faster than only Regex
      Loop { ; arrayName0 = arrayName.Length
         ScriptStringInput := RegExReplace(ScriptStringInput, "is)(^(|.*[^\w])" ArrayName ")0(([^\w].*|)$)", "$1.Length$4",&OutputVarCount)   
      } Until OutputVarCount = 0
      Loop {
         ScriptStringInput := RegExReplace(ScriptStringInput, "is)(^(|.*[^\w])" ArrayName ")(%(\w+)%|(\d+))(([^\w].*|)$)", "$1[$4$5]$6",&OutputVarCount)   
      } Until OutputVarCount = 0
    }
    Return ScriptStringInput
}

;// Converts Object Match V1 to Object Match V2
;//  Example ObjectMatch.Value(N) => ObjectMatch[N]
;//  Example ObjectMatch.Len(N) => ObjectMatch.Len[N]
;//  Example ObjectMatch.Mark() => ObjectMatch.Mark

ConvertObjectMatch(ScriptStringInput,ObjectMatchName){
    if InStr(ScriptStringInput,ObjectMatchName){ ; InStr is faster than only Regex
      Loop { ; arrayName0 = arrayName.Length
         ScriptStringInput := RegExReplace(ScriptStringInput, "is)(^(|.*[^\w])" ObjectMatchName ").Value\((.*?)\)(([^\w].*|)$)", "$1[$3]$4",&OutputVarCount)   
      } Until OutputVarCount = 0
      Loop { ; arrayName0 = arrayName.Length
         ScriptStringInput := RegExReplace(ScriptStringInput, "is)(^(|.*[^\w])" ObjectMatchName ").(Mark|Count)\(\)(([^\w].*|)$)", "$1.$3$4",&OutputVarCount)   
      } Until OutputVarCount = 0
    }
    Return ScriptStringInput
}