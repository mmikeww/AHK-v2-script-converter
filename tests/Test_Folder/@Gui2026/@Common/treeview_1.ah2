#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2GC[["","@TREEVIEW1"]] := mV2Gui[""].Add("TreeView")
P1 := mV2GC[["","@TREEVIEW1"]].Add("First parent")
P1C1 := mV2GC[["","@TREEVIEW1"]].Add("Parent 1's first child", P1)  ; Specify P1 to be this item's parent.
P2 := mV2GC[["","@TREEVIEW1"]].Add("Second parent")
P2C1 := mV2GC[["","@TREEVIEW1"]].Add("Parent 2's first child", P2)
P2C2 := mV2GC[["","@TREEVIEW1"]].Add("Parent 2's second child", P2)
P2C2C1 := mV2GC[["","@TREEVIEW1"]].Add("Child 2's first child", P2C2)

mV2Gui[""].Show()  ; Show the window and its TreeView.
return

GuiClose:  ; Exit the script when the user closes the TreeView's GUI window.
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}