#SingleInstance Force

#Include ConvertFuncs.ahk
#Include <_GuiCtlExt>

global icons, TestMode, FontSize, ViewExpectedCode, GuiWidth, GuiHeight

TestMode := IniRead("QuickConvertorV2.ini", "Convertor", "TestMode", 0)
ViewExpectedCode := IniRead("QuickConvertorV2.ini", "Convertor", "ViewExpectedCode", 0)
GuiWidth := IniRead("QuickConvertorV2.ini", "Convertor", "GuiWidth", 800)
GuiHeight := IniRead("QuickConvertorV2.ini", "Convertor", "GuiHeight", 500)
FontSize := 10
IniWrite(TestMode, "QuickConvertorV2.ini", "Convertor", "TestMode")
IniWrite(ViewExpectedCode, "QuickConvertorV2.ini", "Convertor", "ViewExpectedCode")

FileTempScript := A_ScriptDir "\Tests\TempScript.ah1"
TempV1Script := FileExist(FileTempScript) ? FileRead(FileTempScript) : ""
GuiTest(TempV1Script)

Return
GuiTest(strV1Script:=""){
    global
; The following folder will be the root folder for the TreeView. Note that loading might take a long
; time if an entire drive such as C:\ is specified:
TreeRoot := A_ScriptDir "\Tests\Test_Folder"
TreeViewWidth := 280
ListViewWidth := A_ScreenWidth/2 - TreeViewWidth - 30

; Create the MyGui window and display the source directory (TreeRoot) in the title bar:
MyGui := Gui("+Resize")  ; Allow the user to maximize or drag-resize the window.
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

; Create a TreeView and a ListView side-by-side to behave like Windows Explorer:
TV := MyGui.Add("TreeView", "r20 w180 ImageList" ImageListID)
; LV := MyGui.Add("ListView", "r20 w" ListViewWidth " x+10", ["Name","Modified"])

; Create a Status Bar to give info about the number of files and their total size:
SB := MyGui.Add("StatusBar")
SB.SetParts(300, 300)  ; Create three parts in the bar (the third part fills all the remaining width).

; Add folders and their subfolders to the tree. Display the status in case loading takes a long time:
M := Gui("ToolWindow -SysMenu Disabled AlwaysOnTop", "Loading the tree..."), M.Show("w200 h0")

if TestMode{
    DirList := AddSubFoldersToTree(TreeRoot, Map())
}
else{
    DirList := Map()
}

M.Hide()

; Call TV_ItemSelect whenever a new item is selected:
TV.OnEvent("ItemSelect", TV_ItemSelect)
ButtonEvaluateTests := MyGui.Add("Button", "", "Evaluate Tests")
ButtonEvaluateTests.StatusBar := "Evaluate tests again"
ButtonEvaluateTests.OnEvent("Click", AddSubFoldersToTree.Bind(TreeRoot, DirList,"0"))
CheckBoxViewSymbols := MyGui.Add("CheckBox", "yp x+60", "Symbols")
CheckBoxViewSymbols.StatusBar := "Display invisible symbols like spaces, tabs and linefeeds"
CheckBoxViewSymbols.OnEvent("Click", ViewSymbols)
V1Edit := MyGui.Add("Edit", "x280 y0 w600 vvCodeV1 +Multi +WantTab +0x100", strV1Script)  ; Add a fairly wide edit control at the top of the window.
V1Edit.OnEvent("Change",Edit_Change)

ButtonRunV1 := MyGui.AddPicButton("w24 h24", "mmcndmgr.dll","icon33 h23")
ButtonRunV1.StatusBar := "Run the converted V2 code"
ButtonRunV1.OnEvent("Click", RunV1)

ButtonCloseV1 := MyGui.AddPicButton("w24 h24 x+10 yp", "mmcndmgr.dll","icon62 h23")
ButtonCloseV1.StatusBar := "Close the running V1 code"
ButtonCloseV1.OnEvent("Click", CloseV1)


oButtonConvert := MyGui.AddPicButton("w60 h22", "netshell.dll","icon98 h20")
oButtonConvert.StatusBar := "Convert V1 code again to V2"
oButtonConvert.OnEvent("Click", ButtonConvert)
V2Edit := MyGui.Add("Edit", "x600 ym w600 vvCodeV2 +Multi +WantTab +0x100", "")  ; Add a fairly wide edit control at the top of the window.
V2Edit.OnEvent("Change",Edit_Change)
V2ExpectedEdit := MyGui.Add("Edit", "x1000 ym w600 H100 vvCodeV2Expected +Multi +WantTab +0x100", "")  ; Add a fairly wide edit control at the top of the window.
V2ExpectedEdit.OnEvent("Change",Edit_Change)

ButtonRunV2 := MyGui.AddPicButton("w24 h24", "mmcndmgr.dll","icon33 h23")
ButtonRunV2.StatusBar := "Run this code in Autohotkey V2"
ButtonRunV2.OnEvent("Click", RunV2)

ButtonCloseV2 := MyGui.AddPicButton("w24 h24 x+10 yp", "mmcndmgr.dll","icon62 h23")
ButtonCloseV2.StatusBar := "Close the running V2 code"
ButtonCloseV2.OnEvent("Click", CloseV2)

ButtonCompDiffV2 := MyGui.AddPicButton("w24 h24", "shell32.dll","icon239 h20")
ButtonCompDiffV2.StatusBar := "Compare V1 and V2 code"
ButtonCompDiffV2.OnEvent("Click", CompDiffV2)
ButtonCompVscV2 := MyGui.Add("Button", " x+10 yp w80", "Compare VSC" )
ButtonCompVscV2.StatusBar := "Compare V1 and V2 code in VS Code"
if !FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"){
    ButtonCompVscV2.Visible := 0
}
ButtonCompVscV2.OnEvent("Click", CompVscV2)

ButtonRunV2E := MyGui.AddPicButton("w24 h24 x+10 yp", "mmcndmgr.dll","icon33 h23")
ButtonRunV2.StatusBar := "Run expected V2 code"
ButtonRunV2E.OnEvent("Click", RunV2E)

ButtonCloseV2E := MyGui.AddPicButton("w24 h24", "mmcndmgr.dll","icon62 h23")
ButtonCloseV2E.StatusBar := "Close the running expected V2 code"
ButtonCloseV2E.OnEvent("Click", CloseV2E)

ButtonCompDiffV2E := MyGui.AddPicButton("w24 h24", "shell32.dll","icon239 h20")
ButtonCompDiffV2E.StatusBar := "Compare V2 and expected V2 code"
ButtonCompDiffV2E.OnEvent("Click", CompDiffV2E)
ButtonCompVscV2E := MyGui.Add("Button", " x+10 yp w80", "Compare VSC" )
ButtonCompVscV2E.StatusBar := "Compare V2 and Expected V2 code in VS Code"
if !FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"){
    ButtonCompVscV2E.Visible := 0
}
ButtonCompVscV2E.OnEvent("Click", CompVscV2E)
CheckBoxV2E := MyGui.Add("CheckBox", "yp x+50 Checked", "Expected")
CheckBoxV2E.Value := ViewExpectedCode

CheckBoxV2E.StatusBar := "Display expected V2 code if it exists"
CheckBoxV2E.OnEvent("Click", ViewV2E)

; Save as test
ButtonValidateConversion := MyGui.AddPicButton("w24 h24", "shell32.dll","icon259 h18")
ButtonValidateConversion.StatusBar := "Save the converted code as valid test"
ButtonValidateConversion.OnEvent("Click", ButtonGenerateTest)

; Call Gui_Size whenever the window is resized:
MyGui.OnEvent("Size", Gui_Size)

; MyGui.OnEvent("Close", (*) => ExitApp())
; MyGui.OnEvent("Escape", (*) => ExitApp())

FileMenu := Menu()
FileMenu.Add "Run tests", (*) => Run('"' A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe" '" "' A_ScriptDir 'Tests\Tests.ahk"')
FileMenu.Add "Open test folder", (*) => Run(TreeRoot)
FileMenu.Add()
FileMenu.Add "E&xit", (*) => ExitApp()
SettingsMenu := Menu()
SettingsMenu.Add("Testmode", MenuTestMode)
TestMenu := Menu()
TestMenu.Add("AddBracketToHotkeyTest", (*) => V2Edit.Text := AddBracket(V1Edit.Text))
TestMenu.Add("GetAltLabelsMap", (*) => V2Edit.Text := GetAltLabelsMap(V1Edit.Text))
ViewMenu := Menu()
ViewMenu.Add("Zoom In`tCtrl+NumpadAdd", MenuZoomIn)
ViewMenu.Add("Zoom Out`tCtrl+NumpadSub", MenuZoomOut)
ViewMenu.Add("Show Symols", MenuShowSymols)
ViewMenu.Add()
ViewMenu.Add("View Tree",MenuViewtree)
ViewMenu.Add("View Expected Code",MenuViewExpected)
HelpMenu := Menu()
HelpMenu.Add("Command Help`tF1",MenuCommandHelp)
Menus := MenuBar()
Menus.Add("&File", FileMenu)  ; Attach the two submenus that were created above.
Menus.Add("&Settings", SettingsMenu)
Menus.Add("&View", ViewMenu)
Menus.Add "&Reload", (*) => Reload()
Menus.Add( "Test", TestMenu)
Menus.Add( "Help", HelpMenu)
MyGui.MenuBar := Menus

if ViewExpectedCode{
    ViewMenu.Check("View Expected Code")
}
MyGui.Opt("+MinSize450x200")
; Display the window. The OS will notify the script whenever the user performs an eligible action:
MyGui.Show("h" GuiHeight " w" GuiWidth)
sleep(500)
if TestMode {
    TestMode := !TestMode
    MenuTestMode('')
}

if (strV1Script!=""){
    ButtonConvert(myGui)
}
OnMessage(0x0200, On_WM_MOUSEMOVE)

Return

}
RunV1(*){
    CloseV1(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV1.ahk"
    AhkV1Exe :=  A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend V1Edit.Text, TempAhkFile
    Run AhkV1Exe " " TempAhkFile
    ButtonCloseV1.Opt("-Disabled")
}
CloseV1(*){
    TempAhkFile := A_MyDocuments "\testV1.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    if WinExist("testV1.ahk"){
        WinClose()
    }
    ButtonCloseV1.Opt("+Disabled")
}
RunV2(*){
    CloseV2(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV2.ahk"
    AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend oSaved.vCodeV2 , TempAhkFile
    Run AhkV2Exe " " TempAhkFile
    ButtonCloseV2.Opt("-Disabled")
}
CloseV2(*){
    TempAhkFile := A_MyDocuments "\testV2.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    if WinExist("testV2.ahk"){
        WinClose()
    }
    ButtonCloseV2.Opt("+Disabled")
}

CompVscV2(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFileV2 := A_MyDocuments "\testV2.ahk"
    AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2
    }
    FileAppend V2Edit.text , TempAhkFileV2
    
    TempAhkFileV1 := A_MyDocuments "\testV1.ahk"
    AhkV1Exe :=  A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV1.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV1
    }
    FileAppend V1Edit.Text, TempAhkFileV1
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe -d `"" TempAhkFileV1 "`" `"" TempAhkFileV2 "`""
    Return
}

CompVscV2E(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFileV2 := A_MyDocuments "\testV2.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2
    }
    FileAppend V2Edit.Text , TempAhkFileV2
    
    TempAhkFileV2E := A_MyDocuments "\testV2E.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2E
    }
    FileAppend V2ExpectedEdit.Text, TempAhkFileV2E
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe -d `"" TempAhkFileV2E "`" `"" TempAhkFileV2 "`""
    Return
}

CompDiffV2(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFileV2 := A_MyDocuments "\testV2.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2
    }
    FileAppend V2Edit.text , TempAhkFileV2
    
    TempAhkFileV1 := A_MyDocuments "\testV1.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV1
    }
    FileAppend V1Edit.Text, TempAhkFileV1

   RunWait('"' A_ScriptDir '\diff\VisualDiff.exe" "' A_ScriptDir '\diff\VisualDiff.ahk" "' . TempAhkFileV1 . '" "' . TempAhkFileV2 . '"')

    Return
}

CompDiffV2E(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFileV2 := A_MyDocuments "\testV2.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2
    }
    FileAppend V2Edit.text , TempAhkFileV2
    
    TempAhkFileV2E := A_MyDocuments "\testV2E.ahk"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2E
    }
    FileAppend V2ExpectedEdit.Text, TempAhkFileV2E

   RunWait('"' A_ScriptDir '\diff\VisualDiff.exe" "' A_ScriptDir '\diff\VisualDiff.ahk" "' . TempAhkFileV2E . '" "' . TempAhkFileV2 . '"')

    Return
}

Edit_Change(*){
    GuiCtrlObj := MyGui.FocusedCtrl
    if IsObject(GuiCtrlObj){
        CurrentCol := EditGetCurrentCol(GuiCtrlObj)
	    CurrentLine := EditGetCurrentLine(GuiCtrlObj)
        PreText := GuiCtrlObj.Name="vCodeV1" ? "Autohotkey V1" : GuiCtrlObj.Name="vCodeV2" ? "Autohotkey V2" : GuiCtrlObj.Name="vCodeV2Expected" ? "Autohotkey V2 (Expected)" : ""
        if (PreText !=""){
	    SB.SetText(PreText ", Ln " CurrentLine ",  Col " CurrentCol , 2)
        }
    }
}

RunV2E(*){
    CloseV2E(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV2E.ahk"
    AhkV2Exe := A_ScriptDir "\AutoHotKey Exe\AutoHotkeyV2.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFile
    }
    FileAppend V2ExpectedEdit.Text , TempAhkFile
    Run AhkV2Exe " " TempAhkFile
    ButtonCloseV2E.Opt("-Disabled")
}

CloseV2E(*){
    TempAhkFile := A_MyDocuments "\testV2E.ahk"
    DetectHiddenWindows(1)
    if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
        WinClose(TempAhkFile . " ahk_class AutoHotkey")
    }
    ButtonCloseV2E.Opt("+Disabled")
}
ButtonConvert(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    V2Edit.Text := Convert(V1Edit.Text)
}

MenuShowSymols(*){
    ViewMenu.ToggleCheck("Show Symols")
    CheckBoxViewSymbols.Value := !CheckBoxViewSymbols.Value
    ViewSymbols()
}

ViewSymbols(*){
    ViewMenu.ToggleCheck("Show Symols")
    if (CheckBoxViewSymbols.Value){
        V1Edit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V1Edit.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
        V2Edit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V2Edit.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
        V2ExpectedEdit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V2ExpectedEdit.Text,"`r","\r`r"),"`n","\n`n")," ","·"),"`t","→")
    }
    else{
        V1Edit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V1Edit.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
        V2Edit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V2Edit.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
        V2ExpectedEdit.Value := StrReplace(StrReplace(StrReplace(StrReplace(V2ExpectedEdit.Text,"\r`r","`r"),"\n`r`n","`n"),"·"," "),"→","`t",)
    }
}

ButtonGenerateTest(*){
    
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    input_script := V1Edit.Text
    expected_script := V2Edit.Text
    if (expected_script= "" or input_script =""){
        SB.SetText("No text was found.", 3)
        Return
    }
    if (TV.GetSelection()!=0){
        SelectedText := DirList[TV.GetSelection()]
    }
    Else{
        SelectedText := A_ScriptDir "\tests\Test_Folder"
    }
    
    if Instr(SelectedText,".ah1"){
        if (FileRead(SelectedText) = V1Edit.text){
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
        V2ExpectedEdit.Text := V2Edit.Text
        SB.SetText("Test is saved.", 3)
        SplitPath(SelectedFile, &OutFileName, &OutDir)
        
        ItemID := TV.Add(OutFileName, IDParent, icons.pass)
        DirList[ItemID] := A_LoopFilePath
        DirList[A_LoopFilePath] := ItemID
    }

}

MenuCommandHelp(*){
    ogcFocused := MyGui.FocusedCtrl
    Type := ogcFocused.Type
    if (Type="Edit"){
        
        count := EditGetCurrentLine(ogcFocused)
        text := EditGetLine(count, ogcFocused)
        count := EditGetCurrentCol(ogcFocused)

        PreString := RegExReplace(SubStr(text,1,count-1), ".*?([^,，\s\.\t`"\(\)`']*$)", "$1")
        PostString := RegExReplace(SubStr(text,count), "(^[^,，\s,\.\t`"\(\)`']*).*", "$1")
        word := PreString PostString
        
        if !isSet(Url){
            WBGui := Gui()
            WBGui.Opt("+Resize")
            WBGui.MarginX := "0", WBGui.MarginY := "0"
            global Url,WB,WBGui
            WBGui.Title := "AutoHotKey Help"
            ogcActiveXWBC := WBGui.Add("ActiveX", "xm w980 h640 vIE", "Shell.Explorer")
            WB := ogcActiveXWBC.Value
            WBGui.OnEvent("Size", WBGui_Size)
        }
        
        if InStr(ogcFocused.Name,"V1"){
            URLSearch := "https://www.autohotkey.com/docs/search.htm?q="
        }
        else{
            URLSearch := "https://lexikos.github.io/v2/docs/search.htm?q="
        }
        URL := URLSearch word "&m=2"
        
        WB.Navigate(URL)
        FuncObj := gui_KeyDown.Bind(WB)
        OnMessage(0x100, FuncObj, 2) 
        WBGui.Show()

        WBGui_Size(thisGui, MinMax, Width, Height){
            ogcActiveXWBC.Move(,,Width,Height) ; Gives an error Webbrowser has no method named move
        }
    }
}

MenuZoomIn(*){
    global FontSize
    FontSize := FontSize +1
    if (FontSize>71){
        FontSize := 71
    }
    V1Edit.SetFont("s" FontSize)
    V2Edit.SetFont("s" FontSize)
    ; SB.SetText(" " (FontSize)*10 "%" , 3)
    sleep(10)
}

MenuZoomOut(*){
    global FontSize
    FontSize := FontSize -1
    if (FontSize=0){
        FontSize := 1
    }
    V1Edit.SetFont("s" FontSize)
    V2Edit.SetFont("s" FontSize)
    ; SB.SetText(" " (FontSize)*10 "%" , 3)
    sleep(10)
}

MenuViewExpected(*){
    CheckBoxV2E.Value := !CheckBoxV2E.Value
    IniWrite(CheckBoxV2E.Value, "QuickConvertorV2.ini", "Convertor", "ViewExpectedCode")
    ViewV2E(myGui)
    MyGui.GetPos(,, &Width,&Height)
    Gui_Size(MyGui, 0, Width - 14, Height - 60)
}

ViewV2E(*){
    ViewMenu.ToggleCheck("View Expected Code")
    V2ExpectedEdit.GetPos(,, &V2ExpectedEdit_W)
    MyGui.GetPos(&X,, &Width,&Height)
    if (!CheckBoxV2E.Value){
        V2ExpectedEdit.Move(,,0,)
        WinMove(, , Width+3,,MyGui)
    }
    else{
        V2ExpectedEdit.Move(,,180,)
        WinMove(, , Width-3,,MyGui)
    }
    IniWrite(CheckBoxV2E.Value, "QuickConvertorV2.ini", "Convertor", "ViewExpectedCode")
}

MenuViewTree(*){
    ViewMenu.ToggleCheck("View Tree")
    TV.GetPos(,, &TV_W)
    if (TV_W>0){
        TV.Move(,,0,)
        ButtonEvaluateTests.Visible := false
    }
    else{
        TV.Move(,,180,)
        ButtonEvaluateTests.Visible := true
    }
    MyGui.GetPos(,, &Width,&Height)
    Gui_Size(MyGui, 0, Width - 14, Height - 60)
}

MenuTestMode(*){
    global
    SettingsMenu.ToggleCheck("Testmode")
    TestMode := !TestMode
    if TestMode{
        TV.Move(, , 180, )
        ButtonEvaluateTests.Visible := true
        CheckBoxV2E.Visible := true
        ViewMenu.Check("View Tree")
    }
    else{
        TV.Move(, , 0, )
        ButtonEvaluateTests.Visible := false
        CheckBoxV2E.Visible := false
        ViewMenu.UnCheck("View Tree")
    }
    IniWrite(TestMode, "QuickConvertorV2.ini", "Convertor", "TestMode")
    MyGui.GetPos(, , &Width, &Height)
    Gui_Size(MyGui, 0, Width-14, Height - 60)
}

AddSubFoldersToTree(Folder, DirList, ParentItemID := 0,*){
    if (ParentItemID="0"){
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
        If InStr( FileExist(A_LoopFileFullPath ), "D" ){
            ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.Folder)
        }
        else If InStr(A_LoopFileFullPath,".ah1"){
            FileFullPathV2Expected := StrReplace(A_LoopFileFullPath, ".ah1", ".ah2")
            if FileExist(FileFullPathV2Expected){
                TextV1 := FileRead(A_LoopFileFullPath)
                TextV2Expected := FileRead(StrReplace(A_LoopFileFullPath, ".ah1", ".ah2"))
                TextV2Converted := Convert(TextV1)
                Number_Tests++
                if (TextV2Expected=TextV2Converted){
                    ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.pass)
                    Number_Tests_Pass++
                }
                else{
                    ;MsgBox("[" TextV2Expected "]`n`n[" TextV2Converted "]")
                    ItemID := TV.Add(A_LoopFileName, ParentItemID, icons.fail)
                    TV.Modify(ParentItemID, "Expand")
                }
                
            }
            else{
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

TV_ItemSelect(thisCtrl, Item)  ; This function is called when a new item is selected.
{
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
    if InStr(DirList[Item],".ah1"){
        v1Text := FileRead(DirList[Item])
        V1Edit.Text := v1Text
        V2Edit.Text := Convert(v1Text)
        V2ExpectedEdit.Text := FileRead(StrReplace(DirList[Item],".ah1",".ah2"))
        MyGui.GetPos(,, &Width,&Height)
        Gui_Size(MyGui, 0, Width - 14, Height - 60)
        ; ControlSetText V1Edit, V1Edit
        ; MsgBox(v1Text)
    }
      
    ; Update the three parts of the status bar to show info about the currently selected folder:
    ; SB.SetText( " ", 1)
    ; SB.SetText(Round(TotalSize / 1024, 1) " KB", 2)
    ; SB.SetText(DirList[Item], 3)
}

Gui_Size(thisGui, MinMax, Width, Height)  ; Expand/Shrink ListView and TreeView in response to the user's resizing.
{
    DllCall("LockWindowUpdate", "Uint",myGui.Hwnd)
    Height := Height - 23 ; Compensate the statusbar
    EditHeight := Height-30
    ButtonHeight := EditHeight+3
    if MinMax = -1  ; The window has been minimized.  No action needed.
        return
    ; Otherwise, the window has been resized or maximized. Resize the controls to match.
    TV.GetPos(,, &TV_W)
    TV.Move(,,, EditHeight)  ; -30 for StatusBar and margins.
    if !TestMode{
        TV_W := 0
        TV.Move(, , 0, )
        ButtonEvaluateTests.Visible := false
        CheckBoxV2E.Visible := false
    }
    else{
        ButtonEvaluateTests.Visible := true
        CheckBoxV2E.Visible := true
    }
    V2ExpectedEdit.GetPos(,, &V2ExpectedEdit_W)
    
    TreeViewWidth := TV_W
    if (V2ExpectedEdit_W>0 and V2ExpectedEdit.Text!=""){
        NumberEdits := 3
    }
    else{
        NumberEdits := 2
    }
    EditWith := (Width-TreeViewWidth)/NumberEdits

    V1Edit.Move(TreeViewWidth,,EditWith,EditHeight)
    V2Edit.Move(TreeViewWidth+EditWith,,EditWith,EditHeight)
    ButtonEvaluateTests.Move(,ButtonHeight)
    CheckBoxViewSymbols.Move(TreeViewWidth+EditWith-140,EditHeight+6)
    ButtonRunV1.Move(TreeViewWidth,ButtonHeight)
    ButtonCloseV1.Move(TreeViewWidth+28,ButtonHeight)
    oButtonConvert.Move(TreeViewWidth+EditWith-60,ButtonHeight)
    ButtonRunV2.Move(TreeViewWidth+EditWith,ButtonHeight)
    ButtonCloseV2.Move(TreeViewWidth+EditWith+28,ButtonHeight)
    ButtonCompDiffV2.Move(TreeViewWidth+EditWith+56,ButtonHeight)
    ButtonCompVscV2.Move(TreeViewWidth+EditWith+84,ButtonHeight)
    if (V2ExpectedEdit_W){
        V2ExpectedEdit.Move(TreeViewWidth+EditWith*2,,EditWith,EditHeight)
        ButtonRunV2E.Move(TreeViewWidth+EditWith*2,ButtonHeight)
        ButtonCloseV2E.Move(TreeViewWidth+EditWith*2+28,ButtonHeight)
        ButtonCompDiffV2E.Move(TreeViewWidth+EditWith*2+56,ButtonHeight)
        ButtonCompVscV2E.Move(TreeViewWidth+EditWith*2+84,ButtonHeight)
        ButtonRunV2E.Visible := 1
        ButtonCloseV2E.Visible := 1
        ButtonCompDiffV2E.Visible := 1
        ButtonCompVscV2E.Visible := 1
    }
    else{
        ButtonRunV2E.Visible := 0
        ButtonCloseV2E.Visible := 0
        ButtonCompDiffV2E.Visible := 0
        ButtonCompVscV2E.Visible := 0
    }
    
    CheckBoxV2E.Move(Width-100,EditHeight+6)
    ButtonValidateConversion.Move(Width-30,ButtonHeight)
    DllCall("LockWindowUpdate", "Uint",0)
    IniWrite(Width, "QuickConvertorV2.ini", "Convertor", "GuiWidth")
    IniWrite(Height+22, "QuickConvertorV2.ini", "Convertor", "GuiHeight")
}

On_WM_MOUSEMOVE(wparam, lparam, msg, hwnd){
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

XButton1::
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
    V1Edit.Text := Clipboard1
    V2ExpectedEdit.Text := ""
   ButtonConvert(myGui)
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

XButton2::{
    FileTempScript := A_ScriptDir "\Tests\TempScript.ah1"
    if (FileExist(FileTempScript)){
        FileDelete(FileTempScript)
    } 
    FileAppend(V1Edit.Text,FileTempScript)
    Reload
}

~LButton::
{
    if WinActive("testV2.ahk"){
        ErrorText := WinGetText("testV2.ahk")
        Line := RegexReplace(WinGetText("testV2.ahk"),"s).*Error at line (\d*)\..*","$1",&RegexCount)
        if (RegexCount){
            LineCount := EditGetLineCount(V2Edit)
            if (Line>LineCount){
                return ; The line number is beyond the total number of lines
            }
            else{
                FoundPos := InStr(V2Edit.Text, "`n", , , Line-1)
                WinActivate myGui
                ControlFocus(V2Edit)
                SendMessage(0xB1, FoundPos, FoundPos+1,,V2Edit)
                Sleep(300)
                SendInput("{Right}{Left}")
            }
        }
    }

    Sleep(100)
    Edit_Change()
}


gui_KeyDown(wb, wParam, lParam, nMsg, hWnd) {
	; if (Chr(wParam) ~= "[BD-UW-Z]" || wParam = 0x74) ; Disable Ctrl+O/L/F/N and F5.
		; return
	WBGui.Opt("+OwnDialogs") ; For threadless callbacks which interrupt this.
	pipa := ComObjQuery(wb, "{00000117-0000-0000-C000-000000000046}")
    NumPut(
        'Ptr', hWnd, 
        'Ptr', nMsg, 
        'Ptr', wParam, 
        'Ptr', lParam, 
        'UInt', A_EventInfo,
    	kMsg := Buffer(48)
    )
    DllCall('GetCursorPos', 'Ptr', kMsg.Ptr + (4 * A_PtrSize) + 4)

	Loop 2
    ComCall(5, pipa, 'Ptr', kMsg)
    ; Loop to work around an odd tabbing issue (it's as if there
    ; is a non-existent element at the end of the tab order).
	until wParam != 9 || wb.Document.activeElement != ""
	; S_OK: the message was translated to an accelerator.
	return 0
}

gui_AhkHelp(SearchString,Version:="V2"){
    if !isSet(Url){
        WBGui := Gui()
        WBGui.Opt("+Resize")
        WBGui.MarginX := "0", WBGui.MarginY := "0"
        global Url,WB,WBGui
        WBGui.Title := "AutoHotKey Help"
        ogcActiveXWBC := WBGui.Add("ActiveX", "xm w980 h640 vIE", "Shell.Explorer")
        WB := ogcActiveXWBC.Value
        WBGui.OnEvent("Size", WBGui_Size)
    }
    
    if (Version="V1"){
        URLSearch := "https://www.autohotkey.com/docs/search.htm?q="
    }
    else{
        URLSearch := "https://lexikos.github.io/v2/docs/search.htm?q="
    }
    URL := URLSearch SearchString "&m=2"
    
    WB.Navigate(URL)
    FuncObj := gui_KeyDown.Bind(WB)
    OnMessage(0x100, FuncObj, 2) 
    WBGui.Show()

    WBGui_Size(thisGui, MinMax, Width, Height){
        ogcActiveXWBC.Move(,,Width,Height) ; Gives an error Webbrowser has no method named move
    }
}


