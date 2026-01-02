#Warn Unreachable, Off
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

MyListView:
MyListView()
return

GuiClose:  ; Indicate that the script should exit automatically when the window is closed.
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
MyListView(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
if (A_GuiEvent = "DoubleClick")
{
    RowText := ogcListViewNameSizeKB.GetText(Info)  ; Get the text from the row's first field.
    ToolTip("You double-clicked row number " Info ". Text: `"" RowText "`"")
}
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}