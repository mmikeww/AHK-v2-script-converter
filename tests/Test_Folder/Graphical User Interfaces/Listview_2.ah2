myGui := Gui()
myGui.OnEvent("Close", GuiClose)
ogcListViewIconNumberDescription := myGui.Add("ListView", "h200 w180", ["Icon & Number", "Description"])  ; Create a ListView.
ImageListID := IL_Create(10)  ; Create an ImageList to hold 10 small icons.
ogcListViewIconNumberDescription.SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
Loop 10  ; Load the ImageList with a series of icons from the DLL.
    IL_Add(ImageListID, "shell32.dll", A_Index) 
Loop 10  ; Add rows to the ListView (for demonstration purposes, one for each icon).
    ogcListViewIconNumberDescription.Add("Icon" . A_Index, A_Index, "n/a")
ogcListViewIconNumberDescription.ModifyCol("Hdr")  ; Auto-adjust the column widths.
myGui.Show()
return

GuiClose(*)  ; Exit the script when the user closes the ListView's GUI window.
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()
} ; V1toV2: Added bracket in the end