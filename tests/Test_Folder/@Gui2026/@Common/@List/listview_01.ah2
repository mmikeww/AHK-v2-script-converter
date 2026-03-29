#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
; Create the ListView with two columns, Name and Size:
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2GC[["","@LISTVIEW1"]] := mV2Gui[""].Add("ListView","r20 w700",["Name","Size (KB)"])
mV2GC[["","@LISTVIEW1"]].OnEvent("DoubleClick",MyListView.Bind("DoubleClick"))
;mV2GC[["","@LISTVIEW1"]].OnEvent("Click",MyListView.Bind("Click")) ; V1toV2: enable as needed
;mV2GC[["","@LISTVIEW1"]].OnEvent("ItemSelect",MyListView.Bind("Select")) ; V1toV2: enable as needed
global gV2CurLV := mV2GC[["","@LISTVIEW1"]]

; Gather a list of file names from a folder and put them into the ListView:
Loop Files, A_MyDocuments "\*.*"
    gV2CurLV.Add("", A_LoopFileName, A_LoopFileSizeKB)

gV2CurLV.ModifyCol()  ; Auto-size each column to fit its contents.
gV2CurLV.ModifyCol(2, "Integer")  ; For sorting purposes, indicate that column 2 is an integer.

; Display the window and return. The script will be notified whenever the user double clicks a row.
mV2Gui[""].Show()
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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
if (A_GuiEvent = "DoubleClick")
{
    RowText := gV2CurLV.GetText(Info)  ; Get the text from the row's first field.
    ToolTip("You double-clicked row number " Info ". Text: `"" RowText "`"")
}
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}