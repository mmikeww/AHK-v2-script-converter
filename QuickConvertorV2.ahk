{ ;FILE_NAME:  QuickConverterV2.ahk - v2 - Converts AutoHotkey v1.1 to v2.0
  ; REQUIRES: AutoHotkey v2.0+
  ; Language:       English
  ; Platform:       Windows11
  ; Author:         mmikeww
  ; Function: Converts AutoHotkey v1.1 scripts to v2.0 scripts (A work in progress)
  ;
  ; Usage:  1. Run this script  Requires AHK v2+
  ;         2a. Select AHK code in another script and press XButton1 to convert it - OR -
  ;         2b. Paste AHK code into the first Edit box and press the convert button (Green arrow).
  ;
  ; NOTES: 1. When the cursor is on a function in the Edit box, press F1 to search the function in the documentation.
  ;        2. You can run and close the V1 and V2 code with the play buttons.
  ;        3. There is a "Compare VSC" button to see better compare the difference between the v1 and v2 scripts.
  ;        4. When working on ConvertFuncs.ahk, please set TestMode on in the Gui Menu Settings.
  ;             In Test Mode all the confirmed tests will be checked if the result stays the same.
  ;             You can save tests easily in Test Mode by ????
  ;        5. When you find errors or mistakes in the conversion, please open an issue here:
  ;             https://github.com/mmikeww/AHK-v2-script-converter/issues
}
{ ;CHANGES: ##### MIKE THESE ARE THE CHANGES I MADE: #####
  ; 1. I reformated the program to an easy to read foldable structure
  ; 2. I added headers to program and moved pre-main code to these headers
  ; 3. In VARIABLES: I modified the IniRead and IniWrite statements.
  ; 4. Under HOTKEYS: I added an exit script and added IniWrite statements to save current configuration on exit.
  ; 5. In MAIN PROGRAM: I added a switch case to deal with a command line option to input a file name
  ; REQUESTS:
  ; 1. I haven't found the place to add a reference to the exit function in your code.  Can you do that for me?
  ;
}
{ ;REFERENCES:  Report issues here: https://github.com/mmikeww/AHK-v2-script-converter/issues
  ;  1. The original v2 script converter by Frankie - https://www.autohotkey.com/board/topic/65333-v2-script-converter/
}
{ ;DIRECTIVES AND SETTINGS:
    #Requires AutoHotKey v2.0
    #SingleInstance Force
}
{ ;INCLUDES:
    #Include ConvertFuncs.ahk
    #Include <_GuiCtlExt>
    DirCreate(A_ScriptDir "\AutoHotKey Exe")
    if !FileExist(A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe")
        FileInstall(".\AutoHotKey Exe\AutoHotkeyV1.exe", A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe")
    if !FileExist(A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe")
        FileInstall(".\AutoHotKey Exe\AutoHotkeyV2.exe", A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe")
    ; Diffing Tool
    If !DirExist(A_ScriptDir '\diff') {
        DirCreate(A_ScriptDir "\diff\lib\Exo")
        DirCreate(A_ScriptDir "\diff\lib\mergely")
        FileInstall('diff/template.html', 'diff/template.html')
        FileInstall('diff/VisualDiff.ahk', 'diff/VisualDiff.ahk')
        FileInstall('diff/lib/Exo/API.ahk', 'diff/lib/Exo/API.ahk')
        FileInstall('diff/lib/Exo/FileObject.ahk', 'diff/lib/Exo/FileObject.ahk')
        FileInstall('diff/lib/Exo/WB_onKey.ahk', 'diff/lib/Exo/WB_onKey.ahk')
        FileInstall('diff/lib/mergely/codemirror.js', 'diff/lib/mergely/codemirror.js')
        FileInstall('diff/lib/mergely/codemirror.css', 'diff/lib/mergely/codemirror.css')
        FileInstall('diff/lib/mergely/jquery.min.js', 'diff/lib/mergely/jquery.min.js')
        FileInstall('diff/lib/mergely/mergely.js', 'diff/lib/mergely/mergely.js')
        FileInstall('diff/lib/mergely/mergely.css', 'diff/lib/mergely/mergely.css')
        FileInstall('diff/lib/mergely/searchcursor.js', 'diff/lib/mergely/searchcursor.js')
    }
}
{ ;VARIABLES:
    global icons, TestMode, TestFailing, FontSize, ViewExpectedCode, UIDarkMode, GuiIsMaximised, GuiWidth, GuiHeight

    ; Help file paths
    getHelpPath()
    ; gTreeRoot will be the root folder for the TreeView.
    ;   Note: Loading might take a long time if an entire drive such as C:\ is specified.
    global gTreeRoot, gAhkV1Exe, gAhkV2Exe
    gTreeRoot   := ((A_ScriptDir '\Tests\Test_Folder') . ((gV2Conv) ? '' : 'V1'))
    gAhkV1Exe   := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe"
    gAhkV2Exe   := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"

    ;READ INI VARIABLES WITH DEFAULTS
    IniFile := "QuickConvertorV2.ini"
    Section := "Convertor"
    FontSize            := IniRead(IniFile, Section, "FontSize", 10)
    GuiIsMaximised      := IniRead(IniFile, Section, "GuiIsMaximised", 1)
    GuiHeight           := IniRead(IniFile, Section, "GuiHeight", 500)
    GuiWidth            := IniRead(IniFile, Section, "GuiWidth", 800)
    GuiX                := IniRead(IniFile, Section, "GuiX", "")
    GuiY                := IniRead(IniFile, Section, "GuiY", "")
    TestMode            := IniRead(IniFile, Section, "TestMode", 0)
    TestFailing         := IniRead(IniFile, Section, "TestFailing", 0)
    TreeViewWidth       := IniRead(IniFile, Section, "TreeViewWidth", 280)
    ViewExpectedCode    := IniRead(IniFile, Section, "ViewExpectedCode", 0)
    UIDarkMode          := IniRead(IniFile, Section, "UIDarkMode", 0)
    ConvHotkey          := IniRead(IniFile, Section, "ConvHotkey", "F5")
    ConvHotkeyEnabled   := IniRead(IniFile, Section, "ConvHotkeyEnabled", 0)

    Hotkey(ConvHotkey, CopyAndConvert, (ConvHotkeyEnabled ? "On" : "Off"))
    OnExit(ExitFunc)
    ;WRITE BACK VARIABLES SO THAT DEFAULTS ARE SAVED TO INI (Seems like this should be moved to exit routine SEE Esc::)

}
{ ;*** MAIN PROGRAM - BEGINS HERE *****************************************************************************************


    ;USE SWITCH CASE TO DEAL WITH COMMAND LINE ARGUMENTS
    switch A_Args.Length
    {
      case 0:  ;IF NO ARGUMENTS THEN LOOK UP SOURCE FILE AND USE DEFAULT OUTPUT FILE
      {
         FileTempScript := A_IsCompiled ? A_ScriptDir "\TempScript.ah1" : A_ScriptDir "\Tests\TempScript.ah1"
      }
      case 1: ;IF ONE ARGUMENT THEN ASSUME THE ARUGMENT IS THE SOURCE FILE (FN) AND USE DEFAULT OUTPUT FILE
      {
         FileTempScript := A_Args[1]
      }
      default: ;INCORRECT NUMBER OF ARGUMENTS SUPPLIED -> ERROR
      {
        MyMsg := "ERROR: Wrong number of arguments provided.`n"
        Loop A_Args.Length
        {
          MyMsg .= "Arg[" . A_Index . "]:" . A_Args[1] . "`n"
        }
        MsgBox MyMsg
        ExitApp
      }
    }

    TempV1Script := FileExist(FileTempScript) ? FileRead(FileTempScript) : ""

;    ; Prompt to test V1 or V2
;    Result := MsgBox("Test conversion for V1.1 ONLY?`n`n`tY =`tV1.1`n`tN =`tV2","WHICH MODE?", "YNC")
;    if (result="yes") {
;        gV2Conv := false
;    }
;    else if (result="no") {
;        gV2Conv := true
;    }
;    else if (result="cancel") {
;        ExitApp
;    }

    gTreeRoot := ((A_ScriptDir '\Tests\Test_Folder') . ((gV2Conv) ? '' : 'V1'))
    GuiTest(TempV1Script)


    Return
} ; MAIN PROGRAM - ENDS HERE *******************************************************************************************
;*****************
;*** FUNCITONS ***
;*****************
AddSubFoldersToTree(Folder, DirList, ParentItemID := 0,*)
{
    if (ParentItemID="0") {
        global Number_Tests := 0
        global Number_Tests_Pass := 0
        TV.Delete()
    }
    TV.Opt("-Redraw")
    ; This function adds to the TreeView all subfolders in the specified folder
    ; and saves their paths associated with an ID into an object for later use.
    ; It also calls itself recursively to gather nested folders to any depth.
    Loop Files, Folder "\*.*", "DF"  ; Retrieve all of Folder's sub-folders.
    {
        LoadingFileName.Text := A_LoopFileName
        If InStr( FileExist(A_LoopFileFullPath ), "D" ) {
            If (!TestFailing and A_LoopFileName = "Failed conversions")
                continue ; Skip failed conversions when test mode if off
            ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.Folder)
        }
        else If InStr(A_LoopFileFullPath,".ah1") {
            FileFullPathAh2 := StrReplace(A_LoopFileFullPath, ".ah1", ".ah2")
            if FileExist(FileFullPathAh2) {
                TextSrc := StrReplace(StrReplace(FileRead(A_LoopFileFullPath), "`r`n", "`n"), "`n", "`r`n")
                TextCnv := StrReplace(StrReplace(Convert(TextSrc), "`r`n", "`n"), "`n", "`r`n")
                TextExp := StrReplace(StrReplace(FileRead(StrReplace(A_LoopFileFullPath, ".ah1", ".ah2")), "`r`n", "`n"), "`n", "`r`n")
                Number_Tests++
                if (TextExp=TextCnv){
                    ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.pass)
                    Number_Tests_Pass++
                }
                else {
                    ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.fail)
                    TV.Modify(ParentItemID, "Expand")
                    ParentItemID_ := ParentItemID
                    while (ParentItemID_ := TV.GetParent(ParentItemID_))
                        TV.Modify(ParentItemID_, "Expand")
                }

            }
            else {
                ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.blank)
            }

        }
        else{
            continue
        }
        DirList[ItemID] := A_LoopFilePath
        DirList[A_LoopFilePath] := ItemID
        DirList := AddSubFoldersToTree(A_LoopFilePath, DirList, ItemID)
    }
    TV.Opt("+Redraw")
    SB.SetText("Number of tests: " . Number_Tests . " ( " . Number_Tests - Number_Tests_Pass . " failed / " . Number_Tests_Pass . " passed)", 1)
    return DirList
}
/**
 * Function to get the paths of both version's help file
 * If it is missing it is set to run (open in browser)
*/
getHelpPath() {
    global v1HelpFile, v2HelpFile
    if !IsSet(v1HelpFile) or !IsSet(v2HelpFile) {
        command := RegRead("HKCR\AutoHotkeyScript\shell\Open\Command",, "")
        if command = "" ; Can't find ahk, default to run online docs
            v1HelpFile := "online", v2HelpFile := "online"
        else {
            SplitPath(RegExReplace(command, '"(.*?)".*', "$1"),, &AhkDir)
            AhkDir := RTrim(AhkDir, "UX")

            v1HelpFile := "", v2HelpFile := ""
            loop files AhkDir "*", "D" {
                if InStr(A_LoopFileName, "1.1")
                    v1HelpFile := VerCompare(v1HelpFile, "<" A_LoopFileName) ? A_LoopFileName : v1HelpFile
                else if RegExMatch(A_LoopFileName, "^v?2(.0|$)")
                    v2HelpFile := VerCompare(v2HelpFile, "<" A_LoopFileName) ? A_LoopFileName : v2HelpFile
            }

            v1HelpFile := AhkDir v1HelpFile "\AutoHotkey.chm"
            if !FileExist(v1HelpFile)
                v1HelpFile := "online"
            v2HelpFile := AhkDir v2HelpFile "\AutoHotkey.chm"
            if !FileExist(v2HelpFile)
                v2HelpFile := "online"
        }
    }
}
btnConvert(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &CounterBefore := 0)
    editCnv.Text := Convert(editSrc.Text)
    DllCall("QueryPerformanceCounter", "Int64*", &CounterAfter := 0)
    time := Format("{:.4f}", (CounterAfter - CounterBefore) / freq * 1000)
    SB.SetText("Conversion completed in " time "ms", 4)
    Return time
}
btnGenerateTest(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    input_script := editSrc.Text
    expected_script := editCnv.Text
    if (expected_script= "" or input_script =""){
        SB.SetText("No text was found.", 3)
        Return
    }
    if (TV.GetSelection()!=0){
        SelectedText := DirList[TV.GetSelection()]
    }
    Else{
;        SelectedText := A_ScriptDir "\tests\Test_Folder"
        SelectedText := gTreeRoot
    }

    if Instr(SelectedText,".ah1") {
        if (FileRead(SelectedText) = editSrc.text){
            msgResult := MsgBox("Do You want to overwrite the existing test?", , 308)
            if (msgResult="YES"){
                if FileExist(StrReplace(SelectedText,".ah1",".ah2")){
                    FileDelete(StrReplace(SelectedText,".ah1",".ah2"))
                }
                FileAppend(expected_script,StrReplace(SelectedText,".ah1",".ah2"))
                SB.SetText("Test is saved.", 3)
                TV.Modify(TV.GetSelection(), icons.pass)
            }
            else{
                SB.SetText("Aborted.", 3)
            }
            Return
        }
    }
    SplitPath(SelectedText, &name, &dir, &ext, &name_no_ext, &drive)
    DirNewNoExt := ext="" ? dir "\" name : dir
    IDParent := ext="" ? TV.GetSelection() : TV.GetParent(TV.GetSelection())
    SplitPath(DirNewNoExt, &nameFolder)

    Loop {
        if !FileExist(DirNewNoExt "\" nameFolder "_test" A_Index ".ah1"){
            NameSuggested := nameFolder "_test" A_Index ".ah1"
            break
        }
    }
    SelectedFile := FileSelect("S 8", DirNewNoExt "\" NameSuggested , "Save the validated test", "(*.ah1)")
    if (SelectedFile!=""){
        if !InStr(SelectedFile,".ah1"){
            SelectedFile .= ".ah1"
        }
        if FileExist(SelectedFile){
            msgResult := MsgBox("Do you want to override the existing test?", , 4132)
            if (msgResult = "No"){
                SB.SetText("Aborted saving test.", 3)
                Return
            }
            FileDelete(SelectedFile)
            if FileExist(StrReplace(SelectedFile,".ah1",".ah2")){
                FileDelete(StrReplace(SelectedFile,".ah1",".ah2"))
            }
        }

        FileAppend(input_script,SelectedFile)
        FileAppend(expected_script,StrReplace(SelectedFile,".ah1",".ah2"))
        editExp.Text := editCnv.Text
        SB.SetText("Test is saved.", 3)
        SplitPath(SelectedFile, &OutFileName, &OutDir)

        ItemID := TV.Add(OutFileName, IDParent, icons.pass)
        DirList[ItemID] := A_LoopFilePath
        DirList[A_LoopFilePath] := ItemID
    }

}
CloseSrc(*)
{
    TempAhkFile := A_MyDocuments "\testCodeSrc.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    if WinExist("testCodeSrc.ahk"){
        WinClose()
    }
    try btnCloseSrc.Opt("+Disabled")
}
CloseCnv(*)
{
    TempAhkFile := A_MyDocuments "\testCodeConv.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    if WinExist("testCodeConv.ahk"){
        WinClose()
    }
    try btnCloseCnv.Opt("+Disabled")
}
CloseExp(*)
{
    TempAhkFile := A_MyDocuments "\testCodeExp.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    try btnCloseExp.Opt("+Disabled")
}
CompCnvDif(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFileConv := A_MyDocuments "\testCodeConv.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileConv
    }
    FileAppend editCnv.text , TempAhkFileConv

    TempAhkFileSrc := A_MyDocuments "\testCodeSrc.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileSrc
    }
    FileAppend editSrc.Text, TempAhkFileSrc

    RunWait('"' A_ScriptDir '\diff\VisualDiff.ahk" "' . TempAhkFileSrc . '" "' . TempAhkFileConv . '"')

    Return
}
CompExpDif(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFileConv := A_MyDocuments "\testCodeConv.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileConv
    }
    FileAppend editCnv.text , TempAhkFileConv

    TempAhkFileExp := A_MyDocuments "\testCodeExp.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileExp
    }
    FileAppend editExp.Text, TempAhkFileExp

    RunWait('"' A_ScriptDir '\diff\VisualDiff.ahk" "' . TempAhkFileConv . '" "' . TempAhkFileExp . '"')

    Return
}
CompCnvVsc(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFileConv := A_MyDocuments "\testCodeConv.ahk"
    ;AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileConv
    }
    FileAppend editCnv.text , TempAhkFileConv

    TempAhkFileSrc := A_MyDocuments "\testCodeSrc.ahk"
    ;AhkV1Exe :=  A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileSrc
    }
    FileAppend editSrc.Text, TempAhkFileSrc
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe -d `"" TempAhkFileSrc "`" `"" TempAhkFileConv "`""
    Return
}
CompExpVsc(*)
{
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFileConv := A_MyDocuments "\testCodeConv.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileConv
    }
    FileAppend editCnv.Text , TempAhkFileConv

    TempAhkFileExp := A_MyDocuments "\testCodeExp.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileExp
    }
    FileAppend editExp.Text, TempAhkFileExp
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe -d `"" TempAhkFileConv "`" `"" TempAhkFileExp "`""
    Return
}
Edit_Change(*)
{
    GuiCtrlObj := MyGui.FocusedCtrl
    if IsObject(GuiCtrlObj){
        ; TODO: Make LF convert to CRLF in a way
        ;       where its still possible to edit
        CurrentCol := EditGetCurrentCol(GuiCtrlObj)
      CurrentLine := EditGetCurrentLine(GuiCtrlObj)
        PreText := GuiCtrlObj.Name="vCodeSrc" ? "AHK Source" : GuiCtrlObj.Name="vCodeConv" ? "AHK Converted" : GuiCtrlObj.Name="vCodeExp" ? "AHK Expected" : ""
        if (PreText !=""){
      SB.SetText(PreText ", Ln " CurrentLine ",  Col " CurrentCol , 2)
        }
    }
}
EvalSelectedTest(thisCtrl, *)
{
    global Number_Tests, Number_Tests_Pass, gTreeRoot

    selItemID := TV.GetSelection()
    parentPaths := Array()
    parentItemID := 1
    ItemID := selItemID
    while parentItemID  != 0 {
        parentItemID := TV.GetParent(ItemID)
        ItemID       := parentItemID
        if parentItemID != 0 {
            parentPaths.InsertAt(1, TV.GetText(parentItemID))
        }
    }
    if parentPaths.Length = 0 {
      return
    }
    fullParentPath := gTreeRoot
    for fd in parentPaths {
        fullParentPath .= "/" fd
    }
    FN_ah1      := TV.GetText(selItemID)
    FN_ah2      := StrReplace(FN_ah1, ".ah1", ".ah2")
    file_ah1    := fullParentPath "/" FN_ah1
    file_ah2    := fullParentPath "/" FN_ah2

    parentAttr  := FileExist(fullParentPath)
    selItemAttr := FileExist(file_ah1)
    if (not parentAttr) or InStr(selItemAttr, "D") { ; return on subfolders
        return
    }

    TV.Opt("-Redraw")
    if FileExist(file_ah1) and FileExist(file_ah2){
        TextSrc := FileRead(file_ah1)
        TextExp := FileRead(file_ah2)
        TextCnv := Convert(TextSrc)
        ; Number_Tests++
        if (TextExp=TextCnv){
            TV.Modify(selItemID, icons.pass)
            Number_Tests_Pass++
        }
        else{
            TV.Modify(selItemID, icons.fail)
        }
    }
    TV_ItemSelect(thisCtrl, selItemID)
    TV.Opt("+Redraw")
    SB.SetText("Number of tests: " . Number_Tests . " ( " . Number_Tests - Number_Tests_Pass . " failed / " . Number_Tests_Pass . " passed)", 1)
    return
}
gui_AhkHelp(SearchString,Version:="V2")
{
    if (Version="V1"){
        URLSearch := "https://www.autohotkey.com/docs/v1/search.htm?q="
    }
    else{
        URLSearch := "https://www.autohotkey.com/docs/v2/search.htm?q="
    }
    URL := URLSearch SearchString "&m=2"

    ; version is either v1 or v2
    if %Version%HelpFile != "online"
        Run(A_WinDir "\hh.exe `"mk:@MSITStore:" %Version%HelpFile "::/DOCS/search.htm#q=" SearchString "&m=2`"")
    else
        Run(URL)
}
Gui_DropFiles(GuiObj, GuiCtrlObj, FileArray, X, Y)
{
    editSrc.Text := StrReplace(StrReplace(FileRead(FileArray[1]), "`r`n", "`n"), "`n", "`r`n")
}
;################################################################################
resAdj(val)
{
; 2025-07-01 AMB, ADDED - calculates/returns compensation multiplier for screen DPI

    return round(val * (A_ScreenDPI / 96))
}
;################################################################################
getEditWidth(guiWidth)
{
; 2025-07-01 AMB, ADDED - calculates/returns edit-control width...
;   divides UI real-estate width evenly between edit controls
;   width value depends on whether expected-edit control is visible of not

    editExp.GetPos(,, &w)    ; get current width of expected-edit control
    TV.GetPos(,, &TV_W)             ; get current width of treeView control
    NumberEdits := (w > 0 && editExp.Text != '') ? 3 : 2
    return round((guiWidth-TV_W) / NumberEdits)
}
;################################################################################
Gui_Size(thisGui, MinMax, Width, Height)  ; Expand/Shrink ListView and TreeView in response to the user's resizing.
{
; 2025-07-01 AMB, UPDATED to fix GUI width when toggling expected-edit control visibility

    DllCall("LockWindowUpdate", "Uint",myGui.Hwnd)
    hHeader := 20   ; 2025-07-01
    Height  := Height - 23 ; Compensate the statusbar
    EditHeight := Height - (hHeader+30)
    btnHeight := EditHeight+3 + hHeader
    btnWidth  := 70
    if MinMax = -1  ; The window has been minimized.  No action needed.
        return
    ; Otherwise, the window has been resized or maximized. Resize the controls to match.
    TV.GetPos(,, &TV_W)
    TV.Move(,hHeader,, EditHeight)  ; -30 for StatusBar and margins.
    if !TestMode{
        TV_W := 0
        TV.Move(, , 0, )
        btnEvaluateTests.Visible := false
        btnEvalSelected.Visible  := false
        cbExp.Visible := false
    }
    else{
        btnEvaluateTests.Visible := true
        btnEvalSelected.Visible  := true
        cbExp.Visible := true
    }
    editExp.GetPos(,, &editExp_W)

    TreeViewWidth := TV_W
    EditWidth := getEditWidth(Width)

    ; 2025-07-01 AMB, ADDED header adj
    txtSrc.Move(TreeViewWidth,,EditWidth)
    txtCnv.Move(TreeViewWidth+EditWidth,,EditWidth)
    txtExp.Move(TreeViewWidth+EditWidth*2,,EditWidth)

    editSrc.Move(TreeViewWidth,hHeader,EditWidth,EditHeight)
    editCnv.Move(TreeViewWidth+EditWidth,hHeader,EditWidth,EditHeight)
    btnEvaluateTests.Move(,btnHeight)
    btnEvalSelected.Move(btnWidth+15,btnHeight)
    cbViewSymbols.Move(TreeViewWidth+EditWidth-160,EditHeight+hHeader+6)
    btnRunCodeSrc.Move(TreeViewWidth,btnHeight)
    btnCloseSrc.Move(TreeViewWidth+28,btnHeight)
    obtnConvert.Move(TreeViewWidth+EditWidth-80,btnHeight)
    btnRunCodeCnv.Move(TreeViewWidth+EditWidth,btnHeight)
    btnCloseCnv.Move(TreeViewWidth+EditWidth+28,btnHeight)
    btnCompCnvDif.Move(TreeViewWidth+EditWidth+56,btnHeight)
    btnCompCnvVsc.Move(TreeViewWidth+EditWidth+84,btnHeight)
    if (editExp_W){
        editExp.Move(TreeViewWidth+EditWidth*2,hHeader,EditWidth,EditHeight)
        btnRunCodeExp.Move(TreeViewWidth+EditWidth*2,btnHeight)
        btnCloseExp.Move(TreeViewWidth+EditWidth*2+28,btnHeight)
        btnCompExpDif.Move(TreeViewWidth+EditWidth*2+56,btnHeight)
        btnCompExpVsc.Move(TreeViewWidth+EditWidth*2+84,btnHeight)
        btnRunCodeExp.Visible := 1
        btnCloseExp.Visible := 1
        btnCompExpDif.Visible := 1
        ; 2025-07-01
        if (FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe")) {
            btnCompExpVsc.Visible := 1
        }
    }
    else{
        btnRunCodeExp.Visible := 0
        btnCloseExp.Visible := 0
        btnCompExpDif.Visible := 0
        btnCompExpVsc.Visible := 0
    }

    cbExp.Move(Width-115,EditHeight+hHeader+6)
    btnValidateConversion.Move(Width-30,btnHeight)
    DllCall("LockWindowUpdate", "Uint",0)
    thisGui.GetPos(&GuiX,&GuiY)
    thisGui.GetClientPos(,,&GuiW,&GuiH)
    GuiIsMaximised := WinGetMinMax(thisGui.title)
    IniWrite(GuiIsMaximised, IniFile, Section, "GuiIsMaximised")
    IniWrite(GuiW, IniFile, Section, "GuiWidth")
    IniWrite(GuiH, IniFile, Section, "GuiHeight")
    IniWrite(GuiX, IniFile, Section, "GuiX")
    IniWrite(GuiY, IniFile, Section, "GuiY")

}
;################################################################################
Gui_Close(thisGui){
    FileTempScript := A_IsCompiled ? A_ScriptDir "\TempScript.ah1" : A_ScriptDir "\Tests\TempScript.ah1"
    if (FileExist(FileTempScript)){
        FileDelete(FileTempScript)
    }
    FileAppend(editSrc.Text,FileTempScript)
    thisGui.GetPos(&GuiX,&GuiY)
    thisGui.GetClientPos(,,&GuiW,&GuiH)
    GuiIsMaximised := WinGetMinMax(thisGui.title)
    IniWrite(GuiIsMaximised, IniFile, Section, "GuiIsMaximised")
    IniWrite(GuiW, IniFile, Section, "GuiWidth")
    IniWrite(GuiH, IniFile, Section, "GuiHeight")
    IniWrite(GuiX, IniFile, Section, "GuiX")
    IniWrite(GuiY, IniFile, Section, "GuiY")
    ; FileTempScript := A_ScriptDir "\Tests\TempScript.ah1"
    return
}

GuiTest(strV1Script:="")
{
    global
    ListViewWidth := A_ScreenWidth/2 - TreeViewWidth - 30

    ; Create the MyGui window and display the source directory (gTreeRoot) in the title bar:
    MyGui := Gui("+Resize")  ; Allow the user to maximize or drag-resize the window.
    Mygui.SetFont('s' FontSize)
    MyGui.Title := "Quick Convertor V2"
    MyGui.MarginX := "0", MyGui.MarginY := "0"
    ; Create an ImageList and put some standard system icons into it:
    ImageListID := IL_Create(5)
    IL_Add(ImageListID,"shell32.dll",4)     ;Icon1    ;Folder
    IL_Add(ImageListID,"shell32.dll",132)   ;Icon2    ;red X
    IL_Add(ImageListID,"shell32.dll",78)    ;Icon3    ;yellow triangle with exclamation mark
    IL_Add(ImageListID,"shell32.dll",147)   ;Icon4    ;green up arrow
    IL_Add(ImageListID,"shell32.dll",135)   ;Icon5    ;two sheets of paper
    IL_Add(ImageListID,"shell32.dll",1)     ;Icon6    ;Blank
    icons := {folder: "Icon1", fail: "Icon2", issue: "Icon3", pass: "Icon4", detail: "Icon5", blank: "Icon6"}

    ; 2025-07-01 AMB, ADDED header that reflects code versions
    codeVer := (gV2Conv) ? " (V2.x)" : " (V1.1)"
    txtTV   := MyGui.Add("Text", "+border backgroundCCCCCC +center h20 w" TreeViewWidth, "Unit Tests")
    txtSrc  := MyGui.Add("Text", "+border backgroundCCCCCC +center yp h20", "Source Code (V1)")
    txtCnv  := MyGui.Add("Text", "+border backgroundCCCCCC +center yp h20", "Converted Code" codeVer)
    txtExp  := MyGui.Add("Text", "+border backgroundCCCCCC +center yp h20", "Expected Code" codeVer)

    ; Create a TreeView and a ListView side-by-side to behave like Windows Explorer:
    TV := MyGui.Add("TreeView", "x0 r20 w" TreeViewWidth " ImageList" ImageListID)
    ; LV := MyGui.Add("ListView", "r20 w" ListViewWidth " x+10", ["Name","Modified"])

    ; Create a Status Bar to give info about the number of files and their total size:
    SB := MyGui.Add("StatusBar")
    SB.SetParts(300, 300, 300)  ; Create four parts in the bar (the fourth part fills all the remaining width).

    ; Add folders and their subfolders to the tree. Display the status in case loading takes a long time:
;    LT := Gui("ToolWindow -SysMenu Disabled AlwaysOnTop", "Loading the tree..."), LT.Show("w200 h0")
    LT := Gui("ToolWindow -SysMenu Disabled", "Loading the tree...")
    LoadingFileName := LT.AddText("w200")
    LT.Show("w200")

    if TestMode{
        DirList := AddSubFoldersToTree(gTreeRoot, Map())
    }
    else{
        DirList := Map()
    }

    LT.Hide()

    ; Call TV_ItemSelect whenever a new item is selected:
    TV.OnEvent("ItemSelect", TV_ItemSelect)
    btnEvaluateTests := MyGui.Add("Button", "h24", "Eval Tests")
    btnEvaluateTests.StatusBar := "Evaluate all the tests again"
    btnEvaluateTests.OnEvent("Click", AddSubFoldersToTree.Bind(gTreeRoot, DirList,"0"))
    btnEvalSelected := MyGui.Add("Button", "h24", "Eval 1 test")
    btnEvalSelected.StatusBar := "Evaluate the one selected test again"
    btnEvalSelected.OnEvent("Click", EvalSelectedTest.Bind())
    cbViewSymbols := MyGui.Add("CheckBox", "yp x+60", "Symbols")
    cbViewSymbols.StatusBar := "Display invisible symbols like spaces, tabs and linefeeds"
    cbViewSymbols.OnEvent("Click", ViewSymbols)
    try {
        editSrc := MyGui.Add("Edit", "x280 y0 w600 vvCodeSrc +Multi +WantTab +0x100", strV1Script)  ; Add a fairly wide edit control at the top of the window.
    } catch Error as e {
        ; Failed to create control, likely because script is too large
        msgResult := MsgBox("The v1 script control could not be created`nThis is likely due to the saved script being too large.`nAdding the script after pressing Yes should work`n`nRetry without loading script?", e.Message, 0x34)
        if (msgResult = "Yes") {
            editSrc := MyGui.Add("Edit", "x280 y0 w600 vvCodeSrc +Multi +WantTab +0x100")
        } else {
            Reload
        }
    }
    editSrc.OnEvent("Change",Edit_Change)

    btnRunCodeSrc := MyGui.AddPicButton("w24 h24", "mmcndmgr.dll","icon33 h23")
    btnRunCodeSrc.StatusBar := "Run source code (V1)"
    btnRunCodeSrc.OnEvent("Click", RunCodeSrc)

    btnCloseSrc := MyGui.AddPicButton("w24 h24 x+10 yp Disabled", "mmcndmgr.dll","icon62 h23")
    btnCloseSrc.StatusBar := "Close the running source-code"
    btnCloseSrc.OnEvent("Click", CloseSrc)


    obtnConvert := MyGui.AddPicButton("w60 h24", "netshell.dll","icon98 h20")
    obtnConvert.StatusBar := "Convert source code again"
    obtnConvert.OnEvent("Click", btnConvert)
    editCnv := MyGui.Add("Edit", "x600 ym w600 vvCodeConv +Multi +WantTab +0x100", "")  ; Add a fairly wide edit control at the top of the window.
    editCnv.OnEvent("Change",Edit_Change)
    editExp := MyGui.Add("Edit", "x1000 ym w600 H100 vvCodeExp +Multi +WantTab +0x100", "")  ; Add a fairly wide edit control at the top of the window.
    editExp.OnEvent("Change",Edit_Change)


    btnRunCodeCnv := MyGui.AddPicButton("w24 h24", "mmcndmgr.dll","icon33 h23")
    btnRunCodeCnv.StatusBar := "Run converted code" codeVer
    btnRunCodeCnv.OnEvent("Click", RunCodeCnv)

    btnCloseCnv := MyGui.AddPicButton("w24 h24 x+10 yp Disabled", "mmcndmgr.dll","icon62 h23")
    btnCloseCnv.StatusBar := "Close the running converted-code"
    btnCloseCnv.OnEvent("Click", CloseCnv)

    btnCompCnvDif := MyGui.AddPicButton("w24 h24", "shell32.dll","icon239 h20")
    btnCompCnvDif.StatusBar := "Compare source and converted code"
    btnCompCnvDif.OnEvent("Click", CompCnvDif)
    btnCompCnvVsc := MyGui.Add("Button", "w100 h24 x+10 yp", "Compare VSC" )
    btnCompCnvVsc.StatusBar := "Compare source and converted code in VS Code"
    if !FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe") {
        btnCompCnvVsc.Visible := 0
    }
    btnCompCnvVsc.OnEvent("Click", CompCnvVsc)

    btnRunCodeExp := MyGui.AddPicButton("w24 h24 x+10 yp", "mmcndmgr.dll","icon33 h23")
    btnRunCodeExp.StatusBar := "Run expected code" codeVer
    btnRunCodeExp.OnEvent("Click", RunCodeExp)

    btnCloseExp := MyGui.AddPicButton("w24 h24 Disabled", "mmcndmgr.dll","icon62 h23")
    btnCloseExp.StatusBar := "Close the running expected-code"
    btnCloseExp.OnEvent("Click", CloseExp)

    btnCompExpDif := MyGui.AddPicButton("w24 h24", "shell32.dll","icon239 h20")
    btnCompExpDif.StatusBar := "Compare converted and expected code"
    btnCompExpDif.OnEvent("Click", CompExpDif)
    btnCompExpVsc := MyGui.Add("Button", "w100 h24 x+10 yp", "Compare VSC" )
    btnCompExpVsc.StatusBar := "Compare converted and expected code in VS Code"
    if !FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe") {
        btnCompExpVsc.Visible := 0
    }
    btnCompExpVsc.OnEvent("Click", CompExpVsc)
    cbExp := MyGui.Add("CheckBox", "yp x+50", "View Exp")
    cbExp.Value := ViewExpectedCode

    cbExp.StatusBar := "Display expected code if it exists"
    cbExp.OnEvent("Click", ViewExp)

    ; Save as test
    btnValidateConversion := MyGui.AddPicButton("w24 h24", "shell32.dll","icon259 h18")
    btnValidateConversion.StatusBar := "Save the converted code as valid test"
    btnValidateConversion.OnEvent("Click", btnGenerateTest)

    ; Call Gui_Size whenever the window is resized:
    MyGui.OnEvent("Size", Gui_Size)

    MyGui.OnEvent("Close", Gui_Close)
    ; MyGui.OnEvent("Escape", (*) => ExitApp())

    FileMenu := Menu()
    if !A_IsCompiled {
        FileMenu.Add "Run Yunit tests", (*) => Run('"' A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe" '" "' A_ScriptDir '\Tests\Tests.ahk"')
        FileMenu.Add "Open test folder", (*) => Run(gTreeRoot)
    } else {
        FileMenu.Add "Delete all temp files", FileDeleteTemp
    }
    FileMenu.Add()
    FileMenu.Add( "E&xit", (*) => ExitApp())
    SettingsMenu := Menu()
    SettingsMenu.Add("Testmode", MenuTestMode)
    SettingsMenu.Add("Include Failing", MenuTestFailing)
    SettingsMenu.Add()
    SettingsMenu.Add("Enable Convert Hotkey", MenuEnableConvKey)
    SettingsMenu.Add("Set Convert Hotkey", MenuSetConvKey)
    OutputMenu := Menu()
    OutputMenu.Add("Remove converter comments", MenuRemoveComments)
    OutputMenu.Add("Replace \n with \r\n", MenuFixLineEndings)
    TestMenu := Menu()
    ;TestMenu.Add("AddBracketToHotkeyTest", (*) => editCnv.Text := AddBracket(editSrc.Text))
    ;TestMenu.Add("GetAltLabelsMap", (*) => editCnv.Text := GetAltLabelsMap(editSrc.Text))
    TestMenu.Add("Performance Test", MenuPerformanceTest)
    ViewMenu := Menu()
    ViewMenu.Add("Zoom In`tCtrl+NumpadAdd", MenuZoomIn)
    ViewMenu.Add("Zoom Out`tCtrl+NumpadSub", MenuZoomOut)
    ViewMenu.Add("Show Symbols", MenuShowSymbols)
    ViewMenu.Add()
    ViewMenu.Add("View Tree",MenuViewtree)
    ViewMenu.Add("View Expected Code",MenuViewExpected)
    ViewMenu.Add("DarkMode",MenuViewDark)
    HelpMenu := Menu()
    HelpMenu.Add("Command Help`tF1",MenuCommandHelp)
    HelpMenu.Add()
    HelpMenu.Add("Online v1 docs", (*)=>Run("https://www.autohotkey.com/docs/v1/index.htm"))
    HelpMenu.Add("Online v2 docs", (*)=>Run("https://www.autohotkey.com/docs/v2/index.htm"))
    HelpMenu.Add()
    HelpMenu.Add("Report Issue", (*)=>Run("https://github.com/mmikeww/AHK-v2-script-converter/issues/new"))
    HelpMenu.Add("Open Github", (*)=>Run("https://github.com/mmikeww/AHK-v2-script-converter"))
    Menus := MenuBar()
    Menus.Add("&File", FileMenu)  ; Attach the two submenus that were created above.
    if !A_IsCompiled
        Menus.Add("&Settings", SettingsMenu)
    Menus.Add("&Output", OutputMenu)
    Menus.Add("&View", ViewMenu)
    Menus.Add( "&Reload", (*) => (Gui_Close(MyGui),Reload()))
    Menus.Add( "Test", TestMenu)
    Menus.Add( "Help", HelpMenu)
    MyGui.MenuBar := Menus

    if ViewExpectedCode{
        ViewMenu.Check("View Expected Code")
    }
    if UIDarkMode{
        ViewMenu.Check("DarkMode")
    }

    MyGui.Opt("+MinSize450x200")
    MyGui.OnEvent("DropFiles",Gui_DropFiles)
    setUIMode(MyGui, UIDarkMode)

    ; Correct coordinates to a visible position inside the screens
    GuiXOpt := (GuiX!="") ? " x" ((GuiX<0) ? 0 : (GuiX+GuiWidth>SysGet(78)) ? SysGet(78)-GuiWidth : GuiX) : ""
    GuiYOpt := (GuiY!="") ? " y" ((GuiY<0) ? 0 : (GuiY+GuiHeight>SysGet(79)) ? SysGet(79)-GuiHeight : GuiY) : ""

    ; Display the window. The OS will notify the script whenever the user performs an eligible action:
    GuiMaximise := GuiIsMaximised ? " maximize" : ""
    MyGui.Show("h" GuiHeight " w" GuiWidth GuiXOpt GuiYOpt GuiMaximise)

    ; 2024-07-02 prevent controls from being being clipped at screen edges
    ; If you experience screen clipping uncomment below
    ;iniH := A_ScreenHeight-150, iniW := A_ScreenWidth - 100
    ;MyGui.Show("h" iniH " w" iniW GuiXOpt GuiYOpt GuiMaximise)
    sleep(500)

    if TestMode {
        TestMode := !TestMode
        MenuTestMode('')
    }

    if TestFailing {
        TestFailing := !TestFailing
        MenuTestFailing('')
    }

    if (strV1Script!=""){
        btnConvert(myGui)
    }

    OnMessage(0x0200, On_WM_MOUSEMOVE)
    OnMessage(0x03, On_WM_MOVE)
    Return
}

MenuCommandHelp(*)
{
    ogcFocused := MyGui.FocusedCtrl
    Type := ogcFocused.Type
    if (Type="Edit"){

        count := EditGetCurrentLine(ogcFocused)
        text := EditGetLine(count, ogcFocused)
        count := EditGetCurrentCol(ogcFocused)

        PreString := RegExReplace(SubStr(text,1,count-1), ".*?([^,，\s\.\t`"\(\)`']*$)", "$1")
        PostString := RegExReplace(SubStr(text,count), "(^[^,，\s,\.\t`"\(\)`']*).*", "$1")
        word := PreString PostString

        if InStr(ogcFocused.Name,"Src"){
            Version := "v1"
            URLSearch := "https://www.autohotkey.com/docs/v1/search.htm?q="
        }
        else{ ; Conv
            Version := "v2"
            URLSearch := "https://www.autohotkey.com/docs/v2/search.htm?q="
        }
        URL := URLSearch word "&m=2"

        ; version is either v1 or v2
        if %Version%HelpFile != "online"
            Run(A_WinDir "\hh.exe `"mk:@MSITStore:" %Version%HelpFile "::/DOCS/search.htm#q=" word "&m=2`"")
        else
            Run(URL)
    }
}
MenuShowSymbols(*)
{
    ViewMenu.ToggleCheck("Show Symbols")
    cbViewSymbols.Value := !cbViewSymbols.Value
    ViewSymbols()
}
FileDeleteTemp(*)
{
    try DirDelete(A_ScriptDir "\AutoHotKey Exe", true)
    try FileDelete("TempScript.ah1")
    try DirDelete(A_ScriptDir "\diff", true)
    ExitApp
}
MenuTestMode(*)
{
    global
    SettingsMenu.ToggleCheck("Testmode")
    TestMode := !TestMode
    if TestMode{
        TV.Move(, , TreeViewWidth, )
        btnEvaluateTests.Visible := true
        btnEvalSelected.Visible  := true
        cbExp.Visible := true
        ViewMenu.Check("View Tree")
    }
    else {
        TV.Move(, , 0, )
        btnEvaluateTests.Visible := false
        btnEvalSelected.Visible  := false
        cbExp.Visible := false
        ViewMenu.UnCheck("View Tree")
    }
    IniWrite(TestMode, IniFile, Section, "TestMode")
    MyGui.GetPos(, , &Width, &Height)
    Gui_Size(MyGui, 0, Width-14, Height - 60)
}
MenuTestFailing(*)
{
    global
    SettingsMenu.ToggleCheck("Include Failing")
    TestFailing := !TestFailing
    IniWrite(TestFailing, IniFile, Section, "TestFailing")
}
MenuEnableConvKey(*) {
    global
    ConvHotkeyEnabled := !ConvHotkeyEnabled
    Hotkey(ConvHotkey, (ConvHotkeyEnabled ? "On" : "Off"))
    IniWrite(ConvHotkeyEnabled, IniFile, Section, "ConvHotkeyEnabled")
}
MenuSetConvKey(*) {
    global
    NewConvHotkey := InputBox("Enter new key (ahk format)", "Set conversion hotkey")
    if (NewConvHotkey.Result != "OK")
        return
    Hotkey(ConvHotkey, "Off")
    try {
        Hotkey(NewConvHotkey.Value, CopyAndConvert, (ConvHotkeyEnabled ? "On" : "Off"))
        IniWrite(NewConvHotkey.Value, IniFile, Section, "ConvHotkey")
    } catch {
        MsgBox("Invalid hotkey", "Set conversion hotkey", "Icon!")
        Hotkey(ConvHotkey, (ConvHotkeyEnabled ? "On" : "Off"))
    }
}
MenuRemoveComments(*)
{
    global
    editCnv.Value := RegExReplace(editCnv.Value, "m)^; V1toV2: [^;\n]*\n") ; for Removed X comments
    editCnv.Value := RegExReplace(editCnv.Value, "; V1toV2: [^;\n]*")
    editCnv.Value := RegExReplace(editCnv.Value, ";#{15}  V1toV2 FUNCS  #{15}\n") ; Label conversion comments
    editCnv.Value := RegExReplace(editCnv.Value, "m)^;#{46}$")
}
MenuFixLineEndings(*) {
    global
    editSrc.Value := RegExReplace(editSrc.Value, "(?<!\r)\n", "`r`n")
    editCnv.Value := RegExReplace(editCnv.Value, "(?<!\r)\n", "`r`n")
}
MenuViewDark(*)
{
    global UIDarkMode
    UIDarkMode := !UIDarkMode
    IniWrite(UIDarkMode, IniFile, Section, "UIDarkMode")
    ViewDrk()
}
MenuViewExpected(*)
{
; 2025-07-01 AMB, UPDATED to fix synchonization between menu item and checkbox
    cbExp.value := !cbExp.value     ; simulate clicking on checkbox
    ViewExp(myGui)                              ; pass handling, for consistency
}
MenuViewTree(*)
{
    ViewMenu.ToggleCheck("View Tree")
    TV.GetPos(,, &TV_W)
    if (TV_W>0){
        TV.Move(,,0,)
        btnEvaluateTests.Visible := false
        btnEvalSelected.Visible  := false
    }
    else{
        TV.Move(,,TreeViewWidth,)
        btnEvaluateTests.Visible := true
        btnEvalSelected.Visible  := true
    }
    MyGui.GetPos(,, &Width,&Height)
    Gui_Size(MyGui, 0, Width - 14, Height - 60)
}
MenuPerformanceTest(*)
{
    timeArr := []
    timeMean := 0
    Loop(250)
    {
        timeArr.Push(btnConvert())
    }
    for , time in timeArr
    {
        timeMean += time
    }
    MsgBox("Test Complete!`nDid 250 conversions in " Round(timeMean, 3) "ms`nAverage conversion was "
    Round(timeMean /= 250, 3) "ms", "Test complete!")
}
MenuZoomIn(*)
{
    global FontSize
    FontSize := FontSize +1
    if (FontSize>71){
        FontSize := 71
    }
    editSrc.SetFont("s" FontSize)
    editCnv.SetFont("s" FontSize)
    ; SB.SetText(" " (FontSize)*10 "%" , 3)
    sleep(10)
}
MenuZoomOut(*)
{
    global FontSize
    FontSize := FontSize -1
    if (FontSize=0){
        FontSize := 1
    }
    editSrc.SetFont("s" FontSize)
    editCnv.SetFont("s" FontSize)
    ; SB.SetText(" " (FontSize)*10 "%" , 3)
    sleep(10)
}
On_WM_MOUSEMOVE(wparam, lparam, msg, hwnd)
{
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd){
        Text := ""
        CurrControl := GuiCtrlFromHwnd(Hwnd)
        if CurrControl{
            StatusbarText := CurrControl.HasProp("StatusBar") ? CurrControl.StatusBar : ""
            SB.SetText(StatusbarText , 3)
        }
        PrevHwnd := Hwnd
    }
}
RunCodeSrc(*)
{
    CloseSrc(myGui)
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFile := A_MyDocuments "\testCodeSrc.ahk"
    ;AhkV1Exe :=  A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend editSrc.Text, TempAhkFile
    Run gAhkV1Exe " " Format('"{1}"', TempAhkFile)
    btnCloseSrc.Opt("-Disabled")
}
RunCodeCnv(*)
{
    CloseCnv(myGui)
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFile := A_MyDocuments "\testCodeConv.ahk"
    ;AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend oSaved.vCodeConv , TempAhkFile
    ahkExe := (gV2Conv) ? gAhkV2Exe : gAhkV1Exe
    Run ahkExe " " Format('"{1}"', TempAhkFile)
    btnCloseCnv.Opt("-Disabled")
}
RunCodeExp(*)
{
    CloseExp(myGui)
    if (cbViewSymbols.Value){
        MenuShowSymbols()
    }
    TempAhkFile := A_MyDocuments "\testCodeExp.ahk"
    ;AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend editExp.Text , TempAhkFile
    ahkExe := (gV2Conv) ? gAhkV2Exe : gAhkV1Exe
    Run ahkExe " " Format('"{1}"', TempAhkFile)
    btnCloseExp.Opt("-Disabled")
}
TV_ItemSelect(thisCtrl, Item)  ; This function is called when a new item is selected.
{
; 2025-07-01 AMB, UPDATED to fix inconsistency with UI update when toggling expected-edit control

    ; Put the files into the ListView:
    ; LV.Delete  ; Clear all rows.
    ; LV.Opt("-Redraw")  ; Improve performance by disabling redrawing during load.
    ; TotalSize := 0  ; Init prior to loop below.
    ; Loop Files, DirList[Item] "\*.*"  ; For simplicity, omit folders so that only files are shown in the ListView.
    ; {
    ;     LV.Add(, A_LoopFileName, A_LoopFileTimeModified)
    ;     TotalSize += A_LoopFileSize
    ; }
    ; LV.Opt("+Redraw")
    ;
    if InStr(DirList[Item],".ah1") {
        srcTxt := StrReplace(StrReplace(FileRead(DirList[Item]),"`r`n","`n"), "`n", "`r`n")
        editSrc.Text := srcTxt
        DllCall("QueryPerformanceFrequency", "Int64*", &freq := 0)
        DllCall("QueryPerformanceCounter", "Int64*", &CounterBefore := 0)
        editCnv.Text := Convert(srcTxt)
        DllCall("QueryPerformanceCounter", "Int64*", &CounterAfter := 0)
        SB.SetText("Conversion completed in " Format("{:.4f}", (CounterAfter - CounterBefore) / freq * 1000) "ms", 4)
        editExp.Text := StrReplace(StrReplace(FileRead(StrReplace(DirList[Item],".ah1",".ah2")), "`r`n", "`n"), "`n", "`r`n")
        cbExp.Value := true   ; make sure this is updated to reflect current setting
        ViewExp(MyGui)              ; pass UI update to here
        ; ControlSetText editSrc, editSrc
    }

    ; Update the three parts of the status bar to show info about the currently selected folder:
    ; SB.SetText( " ", 1)
    ; SB.SetText(Round(TotalSize / 1024, 1) " KB", 2)
    ; SB.SetText(DirList[Item], 3)
}
ViewSymbols(*)
{
    ViewMenu.ToggleCheck("Show Symbols")
    if (cbViewSymbols.Value){
        editSrc.Value := StrReplace(StrReplace(StrReplace(StrReplace(editSrc.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
        editCnv.Value := StrReplace(StrReplace(StrReplace(StrReplace(editCnv.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
        editExp.Value := StrReplace(StrReplace(StrReplace(StrReplace(editExp.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
    }
    else{
        editSrc.Value := StrReplace(StrReplace(StrReplace(StrReplace(editSrc.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
        editCnv.Value := StrReplace(StrReplace(StrReplace(StrReplace(editCnv.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
        editExp.Value := StrReplace(StrReplace(StrReplace(StrReplace(editExp.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
    }
}
;################################################################################
ViewExp(*)
{
; 2025-07-01 AMB, UPDATED - to fix GUI width issues when toggling expected-edit control visibility
;   and to provide consistent synchonization between checkbox and menu item

    global viewExpectedCode
    static lastEditWidth := -1, lastViewToggle := -1                ; used to avoid unnecessary UI flickering

    viewExpectedCode := cbExp.Value                           ; update global flag

    ; get current width of expected-edit control
    editExp.GetPos(,, &editExp_W)                     ; get current width of expected-edit control

    ; compare current view to last view (last func visit)
    ; if no changes, don't update GUI (prevent unnecessary flashing)
    curView  := editExp_W * viewExpectedCode
    lastView := lastEditWidth * lastViewToggle
    if (curView = lastView) {
        return  ; no changes have been made to view
    }

    ; view has changed in size and/or visibility
    ; update menu item and record new ini setting
    if (viewExpectedCode) {
        ViewMenu.Check("View Expected Code")
    } else {
        ViewMenu.UnCheck("View Expected Code")
    }
    IniWrite(cbExp.Value, IniFile, Section, "ViewExpectedCode")

    ; update expected-edit width and GUI
    MyGui.GetPos(,, &Width,&Height)                                 ; get current width and height of GUI
    editExpWidth := (viewExpectedCode) ? getEditWidth(Width) : 0    ; editWidth/3 (if visible) or 0 (if hidden)
    editExp.Move(,,editExpWidth)                                    ; resize expected-edit control
    Gui_Size(MyGui, 0, Width - 14, Height - 60)                     ; update GUI

    ; update static vars
    editExp.GetPos(,, &eeW)                                  ; get updated width for expected-edit control (no DPI compensation)
    lastEditWidth   := (eeW) ? eeW : -1
    lastViewToggle  := (viewExpectedCode) ? 1 : -1
}
;################################################################################
ViewDrk(*)
{
    ViewMenu.ToggleCheck("DarkMode")
    setUIMode(MyGui, UIDarkMode)
}

;***************
;*** HOTKEYS ***
;***************
#HotIf ((IsSet(MyGui)) && WinActive(MyGui.title))
$Esc:: OnExit(0, 0)     ;Exit application - Using either <Esc> Hotkey

CopyAndConvert(*)
{
    ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.
    A_Clipboard := ""
    Send "^c"
    if !WinExist("Quick Convertor V2"){
       GuiTest()
    }

    if !ClipWait(3){
        DebugWindow( "error`n",Clear:=0)
        return
    }

    Clipboard1 := A_Clipboard
    A_Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of A_Clipboard (not ClipboardAll).
    ClipSaved := ""  ; Free the memory in case the clipboard was very large.
    editSrc.Text := Clipboard1
    editExp.Text := ""
   btnConvert(myGui)
   WinActivate(myGui)
}
^XButton1::
{
    ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(3){
        DebugWindow( "error`n",Clear:=0)
        return
    }
    gui_AhkHelp(A_Clipboard)
    A_Clipboard := ClipSaved
}
XButton2::
{
    FileTempScript := A_IsCompiled ? A_ScriptDir "\TempScript.ah1" : A_ScriptDir "\Tests\TempScript.ah1"
    if (FileExist(FileTempScript)){
        FileDelete(FileTempScript)
    }
    FileAppend(editSrc.Text,FileTempScript)
    Reload
}
~LButton::
{
    if WinActive("testCodeConv.ahk"){
        ErrorText := WinGetText("testCodeConv.ahk")
        Line := RegexReplace(WinGetText("testCodeConv.ahk"),"s).*Error at line (\d*)\..*","$1",&RegexCount)
        if (RegexCount){
            LineCount := EditGetLineCount(editCnv)
            if (Line>LineCount){
                return ; The line number is beyond the total number of lines
            }
            else{
                FoundPos := InStr(editCnv.Text, "`n", , , Line-1)
                WinActivate myGui
                ControlFocus(editCnv)
                SendMessage(0xB1, FoundPos, FoundPos+1,,editCnv)
                Sleep(300)
                SendInput("{Right}{Left}")
            }
        }
    }

    Sleep(100)
    Edit_Change()
}

ExitFunc(ExitReason, ExitCode){
    CloseSrc(myGui) ; Close active scripts
    CloseCnv(myGui)
    CloseExp(myGui)
    IniWrite(FontSize,           IniFile, Section, "FontSize")
    IniWrite(TestMode,           IniFile, Section, "TestMode")
    IniWrite(TestFailing,        IniFile, Section, "TestFailing")
    IniWrite(TreeViewWidth,      IniFile, Section, "TreeViewWidth")
    IniWrite(ViewExpectedCode,   IniFile, Section, "ViewExpectedCode")
    IniWrite(UIDarkMode,         IniFile, Section, "UIDarkMode")
    if ConvHotkeyEnabled
        ExitApp
    else
        return
}

On_WM_MOVE(wParam, lParam, msg, hwnd){
    ; Detects the movement of a window
    try {
        thisGui := GuiFromHwnd(hwnd)
        if (thisGui.title = "Quick Convertor V2"){
            thisGui.GetPos(&GuiX,&GuiY)
            thisGui.GetClientPos(,,&GuiW,&GuiH)
            GuiIsMaximised := WinGetMinMax(thisGui.title)
            IniWrite(GuiIsMaximised, IniFile, Section, "GuiIsMaximised")
            IniWrite(GuiW, IniFile, Section, "GuiWidth")
            IniWrite(GuiH, IniFile, Section, "GuiHeight")
            IniWrite(GuiX, IniFile, Section, "GuiX")
            IniWrite(GuiY, IniFile, Section, "GuiY")
        }
    }
}
;################################################################################
setUIMode(GuiObj, DarkMode:=false)
{
; 2025-05-17 AMB, ADDED Darkmode option (partial complete)
;   some controls not updated yet, will complete them another time
;   may add option for user to adjust desired colors/shades
; borrowed from here...
;   https://www.autohotkey.com/boards/viewtopic.php?f=92&t=115952

	global DarkColors          := Map("Background", "0x353535", "Controls", "0x404040", "Font", "0xE0E0E0")
	global TextBackgroundBrush := DllCall("gdi32\CreateSolidBrush", "UInt", DarkColors["Background"], "Ptr")
	static PreferredAppMode    := Map("Default", 0, "AllowDark", 1, "ForceDark", 2, "ForceLight", 3, "Max", 4)

    if (VerCompare(A_OSVersion, "10.0.17763") >= 0)
	{
		DWMWA_USE_IMMERSIVE_DARK_MODE := 19
		if (VerCompare(A_OSVersion, "10.0.18985") >= 0)
		{
			DWMWA_USE_IMMERSIVE_DARK_MODE := 20
		}
		uxtheme := DllCall("kernel32\GetModuleHandle", "Str", "uxtheme", "Ptr")
		SetPreferredAppMode := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 135, "Ptr")
		FlushMenuThemes     := DllCall("kernel32\GetProcAddress", "Ptr", uxtheme, "Ptr", 136, "Ptr")
		switch DarkMode
		{
			case True:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", True, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["ForceDark"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := DarkColors["Background"]
                txtTV.Opt("BackgroundCCCCCC")
                TV.Opt("Background353535")
                TV.SetFont("cWhite")
                txtSrc.Opt("BackgroundCCCCCC")
                editSrc.Opt("Background353535")
                editSrc.SetFont("cWhite")
                txtCnv.Opt("BackgroundCCCCCC")
                editCnv.Opt("Background353535")
                editCnv.SetFont("cWhite")
                txtExp.Opt("BackgroundCCCCCC")
                editExp.Opt("Background353535")
                editExp.SetFont("cWhite")
                cbExp.Opt("BackgroundF0F0F0")             ; unable to change text color, so keep bkgd light
                cbViewSymbols.Opt("BackgroundF0F0F0")     ; unable to change text color, so keep bkgd light
			}
			default:
			{
				DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", GuiObj.hWnd, "Int", DWMWA_USE_IMMERSIVE_DARK_MODE, "Int*", False, "Int", 4)
				DllCall(SetPreferredAppMode, "Int", PreferredAppMode["Default"])
				DllCall(FlushMenuThemes)
				GuiObj.BackColor := "Default"
                txtTV.Opt("BackgroundFFFFFF")
                TV.Opt("BackgroundFFFFFF")
                TV.SetFont("cBlack")
                txtSrc.Opt("BackgroundFFFFFF")
                editSrc.Opt("BackgroundFFFFFF")
                editSrc.SetFont("cBlack")
                txtCnv.Opt("BackgroundFFFFFF")
                editCnv.Opt("BackgroundFFFFFF")
                editCnv.SetFont("cBlack")
                txtExp.Opt("BackgroundFFFFFF")
                editExp.Opt("BackgroundFFFFFF")
                editExp.SetFont("cBlack")
                cbExp.Opt("BackgroundF0F0F0")             ; unable to change text color, so keep bkgd light
                cbViewSymbols.Opt("BackgroundF0F0F0")     ; unable to change text color, so keep bkgd light
			}
		}
	}
}
