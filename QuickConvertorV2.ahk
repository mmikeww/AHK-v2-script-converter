#SingleInstance Force

#Include ConvertFuncs.ahk
; #Include ExecScript.ahk


global icons
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
DirList := AddSubFoldersToTree(TreeRoot, Map())
M.Hide()

; Call TV_ItemSelect whenever a new item is selected:
TV.OnEvent("ItemSelect", TV_ItemSelect)
ButtonEvaluateTests := MyGui.Add("Button", "", "Evaluate Tests")
ButtonEvaluateTests.OnEvent("Click", AddSubFoldersToTree.Bind(TreeRoot, DirList,"0"))
CheckBoxViewSymbols := MyGui.Add("CheckBox", "yp x+50", "View Symbols")
CheckBoxViewSymbols.OnEvent("Click", ViewSymbols)
V1Edit := MyGui.Add("Edit", "x280 y0 w600 vvCodeV1 +Multi +WantTab", strV1Script)  ; Add a fairly wide edit control at the top of the window.
ButtonRunV1 := MyGui.Add("Button", "w60", "Run V1")
ButtonRunV1.OnEvent("Click", RunV1)
ButtonCloseV1 := MyGui.Add("Button", " x+10 yp w60 +Disabled", "Close V1")
ButtonCloseV1.OnEvent("Click", CloseV1)
oButtonConvert := MyGui.Add("Button", "default x+10 yp", "Convert =>")
oButtonConvert.OnEvent("Click", ButtonConvert)
V2Edit := MyGui.Add("Edit", "x600 ym w600 vvCodeV2 +Multi +WantTab", "")  ; Add a fairly wide edit control at the top of the window.
V2ExpectedEdit := MyGui.Add("Edit", "x1000 ym w600 H100 vvCodeV2Expected +Multi +WantTab", "")  ; Add a fairly wide edit control at the top of the window.
ButtonRunV2 := MyGui.Add("Button", "w60", "Run V2")
ButtonRunV2.OnEvent("Click", RunV2)
ButtonCloseV2 := MyGui.Add("Button", " x+10 yp w60 +Disabled", "Close V2" )
ButtonCloseV2.OnEvent("Click", CloseV2)
ButtonCompVscV2 := MyGui.Add("Button", " x+10 yp w80", "Compare VSC" )
if !FileExist("C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe"){
    ButtonCompVscV2.Visible := 0
}
ButtonCompVscV2.OnEvent("Click", CompVscV2)
ButtonRunV2E := MyGui.Add("Button", "w50", "Run V2E")
ButtonRunV2E.OnEvent("Click", RunV2E)
ButtonCloseV2E := MyGui.Add("Button", " x+10 yp w60 +Disabled", "Close V2E" )
ButtonCloseV2E.OnEvent("Click", CloseV2E)
CheckBoxV2E := MyGui.Add("CheckBox", "yp x+50 Checked", "View Expected Code")
CheckBoxV2E.OnEvent("Click", ViewV2E)

ButtonValidateConversion := MyGui.Add("Button", " x+10 yp", "Save as test")
ButtonValidateConversion.OnEvent("Click", ButtonGenerateTest)

; Call Gui_Size whenever the window is resized:
MyGui.OnEvent("Size", Gui_Size)
; MyGui.OnEvent("Close", (*) => ExitApp())
; MyGui.OnEvent("Escape", (*) => ExitApp())

FileMenu := Menu()
FileMenu.Add "Run tests", (*) => Run('"C:\Program Files\AutoHotkey V2\AutoHotkey64.exe" "' A_ScriptDir 'Tests\Tests.ahk"')
FileMenu.Add "Open test folder", (*) => Run(TreeRoot)
FileMenu.Add()
FileMenu.Add "E&xit", (*) => ExitApp()
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
Menus.Add("&View", ViewMenu)  ; Attach the two submenus that were created above.
Menus.Add "&Reload", (*) => Reload()
Menus.Add( "Test", TestMenu)
Menus.Add( "Help", HelpMenu)
MyGui.MenuBar := Menus

; Display the window. The OS will notify the script whenever the user performs an eligible action:
MyGui.Show
if (strV1Script!=""){
    ButtonConvert(myGui)
}
Return
}
RunV1(*){
    CloseV1(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV1.ahk"
    AhkV1Exe :=  "C:\Program Files\AutoHotkey\AutoHotkey.exe"
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
    ButtonCloseV1.Opt("+Disabled")
}
RunV2(*){
    CloseV2(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV2.ahk"
    AhkV2Exe := "C:\Program Files\AutoHotkey V2\AutoHotkey64.exe"
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
    ButtonCloseV2.Opt("+Disabled")
}

CompVscV2(*){
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFileV2 := A_MyDocuments "\testV2.ahk"
    AhkV2Exe := "C:\Program Files\AutoHotkey V2\AutoHotkey64.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV2
    }
    FileAppend oSaved.vCodeV2 , TempAhkFileV2
    
    TempAhkFileV1 := A_MyDocuments "\testV1.ahk"
    AhkV1Exe :=  "C:\Program Files\AutoHotkey\AutoHotkey.exe"
    oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
    try {
        FileDelete TempAhkFileV1
    }
    FileAppend V1Edit.Text, TempAhkFileV1
    Run "C:\Users\" A_UserName "\AppData\Local\Programs\Microsoft VS Code\Code.exe -d `"" TempAhkFileV1 "`" `"" TempAhkFileV2 "`""
    Return
}
RunV2E(*){
    CloseV2E(myGui)
    if (CheckBoxViewSymbols.Value){
        MenuShowSymols()
    }
    TempAhkFile := A_MyDocuments "\testV2E.ahk"
    AhkV2Exe := "C:\Program Files\AutoHotkey V2\AutoHotkey64.exe"
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
        SB.SetText("No text was found.", 1)
        Return
    }
    if (TV.GetSelection()!=0){
        SelectedText := DirList[TV.GetSelection()]
    }
    Else{
        SelectedText := A_ScriptDir "\tests"
    }
    SplitPath(SelectedText, &name, &dir, &ext, &name_no_ext, &drive)
    DirNewNoExt := ext="" ? dir "\" name : dir 
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
                SB.SetText("Aborted saving test.", 1)
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
        SB.SetText("Test is saved.", 1)
        AddSubFoldersToTree(TreeRoot, DirList,"0")
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
    ViewV2E(myGui)
    MyGui.GetPos(,, &Width,&Height)
    Gui_Size(MyGui, 0, Width, Height-54)
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
    Gui_Size(MyGui, 0, Width, Height-54)
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
        DirList := AddSubFoldersToTree(A_LoopFilePath, DirList, ItemID)
    }
    TV.Opt("+Redraw")
    SB.SetText("Number of tests: " . Number_Tests . " ( " . Number_Tests - Number_Tests_Pass . " failed / " . Number_Tests_Pass . " passed)", 2)
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
        Gui_Size(MyGui, 0, Width, Height-54)
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
    CheckBoxViewSymbols.Move(TreeViewWidth+EditWith-180,EditHeight+6)
    ButtonRunV1.Move(TreeViewWidth,ButtonHeight)
    ButtonCloseV1.Move(TreeViewWidth+62,ButtonHeight)
    oButtonConvert.Move(TreeViewWidth+EditWith-80,ButtonHeight)
    ButtonRunV2.Move(TreeViewWidth+EditWith,ButtonHeight)
    ButtonCloseV2.Move(TreeViewWidth+EditWith+62,ButtonHeight)
    ButtonCompVscV2.Move(TreeViewWidth+EditWith+124,ButtonHeight)
    if (V2ExpectedEdit_W){
        V2ExpectedEdit.Move(TreeViewWidth+EditWith*2,,EditWith,EditHeight)
        ButtonRunV2E.Move(TreeViewWidth+EditWith*2,ButtonHeight)
        ButtonCloseV2E.Move(TreeViewWidth+EditWith*2+52,ButtonHeight)
        ButtonRunV2E.Visible := 1
        ButtonCloseV2E.Visible := 1
    }
    else{
        ButtonRunV2E.Visible := 0
        ButtonCloseV2E.Visible := 0
    }

    
    CheckBoxV2E.Move(Width-220,EditHeight+6)
    ButtonValidateConversion.Move(Width-80,ButtonHeight)
    DllCall("LockWindowUpdate", "Uint",0)
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

XButton2::{
    FileTempScript := A_ScriptDir "\Tests\TempScript.ah1"
    if (FileExist(FileTempScript)){
        FileDelete(FileTempScript)
    } 
    FileAppend(V1Edit.Text,FileTempScript)
    Reload
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

