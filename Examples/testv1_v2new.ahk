
; REMOVED: #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

#SingleInstance, Force
test := "MsgBox ,  This is the 1-parameter method. `Commas (,) do not need,  to be escaped."
;~ test := "MsgBox ,  This is the 1-parameter method. Commas (,) do not need,  to be escaped."
myGui := Gui()
myGui.Add("Text", "", "Pick a file to launch from the list below.`nTo cancel, press ESCAPE or close this window.")
ogcMyListBox := myGui.Add("ListBox", "vMyListBox  w640 r10")
ogcMyListBox.OnEvent("Click", MyListBox)
ogcMyButton := myGui.Add("Button", "Default", "OK")
ogcMyButton.OnEvent("Click", ButtonOK)
Loop Files, "C:\*.*"  ; Change this folder and wildcard pattern to suit your preferences.
{
    ogcMyListBox.Value := A_LoopFilePath
}
myGui.Show()
return

MyListBox:
if (A_GuiEvent != "DoubleClick")
    return
; Otherwise, the user double-clicked a list item, so treat that the same as pressing OK.
; So fall through to the next label.
ButtonOK:
MyListBox := ogcMyListBox.Value  ; Retrieve the ListBox's current selection.
msgResult := MsgBox("Would you like to launch the file or document below?`n`n" . MyListBox, , 4)
if (msgResult = "No")
return
; Otherwise, try to launch it:
Run(MyListBox, , "UseErrorLevel")
if (ErrorLevel = "ERROR")
    msgResult := MsgBox("Could not launch the specified file. Perhaps it is not associated with anything.")
return

GuiClose:
GuiEscape:
ExitApp


msgResult := MsgBox(test)

ExitApp