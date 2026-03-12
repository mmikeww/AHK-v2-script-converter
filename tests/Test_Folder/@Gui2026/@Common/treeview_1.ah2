; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
}
mV2GC[["1","@TREEVIEW1"]] := mV2Gui["1"].Add("TreeView")
P1 := mV2GC[["1","@TREEVIEW1"]].Add("First parent")
P1C1 := mV2GC[["1","@TREEVIEW1"]].Add("Parent 1's first child", P1)  ; Specify P1 to be this item's parent.
P2 := mV2GC[["1","@TREEVIEW1"]].Add("Second parent")
P2C1 := mV2GC[["1","@TREEVIEW1"]].Add("Parent 2's first child", P2)
P2C2 := mV2GC[["1","@TREEVIEW1"]].Add("Parent 2's second child", P2)
P2C2C1 := mV2GC[["1","@TREEVIEW1"]].Add("Child 2's first child", P2C2)

mV2Gui["1"].Show()  ; Show the window and its TreeView.
return

GuiClose:  ; Exit the script when the user closes the TreeView's GUI window.
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
GuiClose(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}