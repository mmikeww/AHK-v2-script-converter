#Requires AutoHotKey v2.0-beta.1
#SingleInstance Force

; Added a mapkey to test on the fly
XButton1::
{
   ClipSaved := ClipboardAll()   ; Save the entire clipboard to a variable of your choice.
   A_Clipboard := ""
   Send "^c"

   if !ClipWait(3){
      DebugWindow( "error`n",Clear:=0)
      return
   }
   Clipboard1 := A_Clipboard
   A_Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of A_Clipboard (not ClipboardAll).
   ClipSaved := ""  ; Free the memory in case the clipboard was very large.

   ConvertedCode := Convert(Clipboard1)
   ;~ MsgBox(ConvertedCode)
   A_Clipboard := ConvertedCode
   if WinExist("Convert tester"){
      WinClose("Convert tester")
   }
   global MyGui
   MyGui := Gui(,"Convert tester")
   global FontSize := 10
   MyGui.MarginX := "0", MyGui.MarginY := "0"
   MyGui.Opt("+Resize")
   MyGui.SetFont("s" FontSize)
   V1Edit := MyGui.Add("Edit", "w600 vvCodeV1", Clipboard1)  ; Add a fairly wide edit control at the top of the window.
   ButtonRunV1 := MyGui.Add("Button", "", "Run V1")
   ButtonRunV1.OnEvent("Click", RunV1)
   ButtonCloseV1 := MyGui.Add("Button", " x+10 yp", "Close V1")
   ButtonCloseV1.OnEvent("Click", CloseV1)
   oButtonConvert := MyGui.Add("Button", "default x+10 yp", "Convert again")
   oButtonConvert.OnEvent("Click", ButtonConvert)
   V2Edit := MyGui.Add("Edit", "x600 ym w600 vvCodeV2", ConvertedCode)  ; Add a fairly wide edit control at the top of the window.
   ButtonRunV2 := MyGui.Add("Button", "", "Run V2")
   ButtonRunV2.OnEvent("Click", RunV2)
   
   ButtonCloseV2 := MyGui.Add("Button", " x+10 yp", "Close V2" )

   ButtonCloseV2.OnEvent("Click", CloseV2)
   V3Edit := MyGui.Add("Edit", "x+200 yp w100 vvTestName", "TestName")
   ButtonCopyTheTest := MyGui.Add("Button", " x+10 yp", "Copy the test")
   ButtonCopyTheTest.OnEvent("Click", ButtonGenerateTest)

   FileMenu := Menu()
   FileMenu.Add "Run tests", (*) => Run('"C:\Program Files\AutoHotkey V2\AutoHotkey64.exe" "' A_ScriptDir '\tests\Tests.ahk"')
   FileMenu.Add "&Reload", (*) => Reload()
   FileMenu.Add()
   FileMenu.Add "E&xit", (*) => ExitApp()
   HelpMenu := Menu()
   HelpMenu.Add("Command Help`tF1",MenuCommandHelp)
   HelpMenu.SetIcon("Command Help`tF1", "Shell32", "24") ; Use icon with resource identifier 207)
   ViewMenu := Menu()
   ViewMenu.Add("Zoom In`tCtrl+NumpadAdd", MenuZoomIn)
   ViewMenu.Add("Zoom Out`tCtrl+NumpadSub", MenuZoomOut)
   Menus := MenuBar()

   Menus.Add("&File", FileMenu)  ; Attach the two submenus that were created above.
   Menus.Add("&View", ViewMenu)  ; Attach the two submenus that were created above.
   Menus.Add("&Help", HelpMenu)  ; Attach the two submenus that were created above.
    
   MyGui.MenuBar := Menus
   MyGui.OnEvent("Size", Gui_Size)


   MyGui.Show

   
   return

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
         ComObjConnect(WB, Event)
         WBGui.Show()

         WBGui_Size(thisGui, MinMax, Width, Height){
            ogcActiveXWBC.Move(,,Width,Height) ; Gives an error Webbrowser has no method named move
         }
          
      }
      
   }
   RunV1(*){
      TempAhkFile := A_MyDocuments "\testV1.ahk"
      AhkV1Exe :=  "C:\Program Files\AutoHotkey\AutoHotkey.exe"
      oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
      try {
         FileDelete TempAhkFile
      }
      FileAppend oSaved.vCodeV1 , TempAhkFile
      Run AhkV1Exe " " TempAhkFile
   }
   CloseV1(*){
      TempAhkFile := A_MyDocuments "\testV1.ahk"
      DetectHiddenWindows(1)
      if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
         WinClose(TempAhkFile . " ahk_class AutoHotkey")
      }
   }
   RunV2(*){
      TempAhkFile := A_MyDocuments "\testV2.ahk"
      AhkV2Exe := "C:\Program Files\AutoHotkey V2\AutoHotkey64.exe"
      oSaved := MyGui.Submit(0)  ; Save the contents of named controls into an object.
      try {
         FileDelete TempAhkFile
      }
      FileAppend oSaved.vCodeV2 , TempAhkFile
      Run AhkV2Exe " " TempAhkFile
   }
   CloseV2(*){
      TempAhkFile := A_MyDocuments "\testV2.ahk"
      DetectHiddenWindows(1)
      if WinExist(TempAhkFile . " ahk_class AutoHotkey"){
         WinClose(TempAhkFile . " ahk_class AutoHotkey")
      }
   }
   ButtonConvert(*){

      V2Edit.Value := Convert(V1Edit.Text)
   }

   ButtonGenerateTest(*){
      oSaved := MyGui.Submit(0)
      input_script := oSaved.vCodeV1
      expected_script := oSaved.vCodeV2
      TestName := oSaved.vTestName

      NewTest := "
      (Join`r`n
{1}(){
      input_script := "
         (Join``r``n ``
{2}
         `)"
      
      expected := "
         (Join``r``n
{3}
         `)"
      
      converted := Convert(input_script)
      ;~ if (expected!=converted){
         ;~ ViewStringDiff(expected, converted)
      ;~ }
      Yunit.assert(converted = expected, "converted script != expected script")
   }
      )"
      A_Clipboard := Format(NewTest,TestName,input_script,expected_script)
      TrayTip("Convertor", "Copied test [" TestName "] to clipboard")
   }

   Gui_Size(thisGui, MinMax, Width, Height)
   {
      if MinMax = -1  ; The window has been minimized. No action needed.
         return
      ; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
      EditWith := (Width)/2

      V1Edit.Move(,,EditWith,Height-30)
      V2Edit.Move(EditWith,,EditWith,Height-30)
      ButtonRunV1.Move(,Height-30)
      ButtonCloseV1.Move(,Height-30)
      oButtonConvert.Move(,Height-30)
      ButtonRunV2.Move(EditWith,Height-30)
      ButtonCloseV2.Move(EditWith+100,Height-30)
      V3Edit.Move(EditWith+200,Height-28)
      ButtonCopyTheTest.Move(EditWith+200+105,Height-30)
      
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
}   



XButton2::{
   Reload
}

HotIfWinActive "Convert tester"
Hotkey( "Control & WheelDown", (*) => SendInput("^{NumpadAdd}"))  ; !w = Alt+W
Hotkey( "Control & WheelUp", (*) => SendInput("^{NumpadSub}"))  ; !w = Alt+W

class Event {
	DocumentComplete(wb) {
		static doc
		ComObjConnect(doc:=wb.document, Event)
	}
	OnKeyPress(doc) {
		static keys := {1:"selectall", 3:"copy", 22:"paste", 24:"cut"}
		keyCode := doc.parentWindow.event.keyCode
		if keys.HasKey(keyCode)
			Doc.ExecCommand(keys[keyCode])
	}
}

#Include ConvertFuncs.ahk

