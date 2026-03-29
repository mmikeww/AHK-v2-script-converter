#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2GC[["","@LISTVIEW1"]] := mV2Gui[""].Add("ListView","h200 w180",["Icon & Number","Description"])
global gV2CurLV := mV2GC[["","@LISTVIEW1"]]  ; Create a ListView.
ImageListID := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
gV2CurLV.SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
Loop 10  ; Load the ImageList with a series of icons from the DLL.
    IL_Add(ImageListID, "shell32.dll", A_Index) 
Loop 10  ; Add rows to the ListView (for demonstration purposes, one for each icon).
    gV2CurLV.Add("Icon" . A_Index, A_Index, "n/a")
gV2CurLV.Opt("Hdr")  ; Auto-adjust the column widths.
mV2Gui[""].Show()
return

GuiClose:  ; Exit the script when the user closes the ListView's GUI window.
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}