; Create the ListView with two columns, Name and Size:
myGui := Gui()
myGui.OnEvent("Close", GuiClose)
ogcListViewNameSizeKB := myGui.Add("ListView", "r20 w700", ["Name", "Size (KB)"])
ogcListViewNameSizeKB.OnEvent("DoubleClick", MyListView.Bind("DoubleClick"))

; Gather a list of file names from a folder and put them into the ListView:
Loop Files, A_MyDocuments "\*.*"
    ogcListViewNameSizeKB.Add("", A_LoopFileName, A_LoopFileSizeKB)

ogcListViewNameSizeKB.ModifyCol()  ; Auto-size each column to fit its contents.
ogcListViewNameSizeKB.ModifyCol(2, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.

; Display the window and return. The script will be notified whenever the user double clicks a row.
myGui.Show()
return

MyListView(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
if (A_GuiEvent = "DoubleClick")
{
    RowText := ogcListViewNameSizeKB.GetText(A_EventInfo)  ; Get the text from the row's first field.
    ToolTip("You double-clicked row number " A_EventInfo ". Text: `"" RowText "`"")
}
return
} ; V1toV2: Added bracket before function

GuiClose(*)  ; Indicate that the script should exit automatically when the window is closed.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()
} ; V1toV2: Added bracket in the end