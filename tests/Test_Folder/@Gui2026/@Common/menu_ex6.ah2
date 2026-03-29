#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
; Menu Example #4
FileMenu := Menu()
FileMenu.Add("Script Icon", MenuHandler)
FileMenu.Add("Suspend Icon", MenuHandler)
FileMenu.Add("Pause Icon", MenuHandler)
FileMenu.SetIcon("Script Icon", A_AhkPath, 2) ; Use the 2nd icon group from the file
FileMenu.SetIcon("Suspend Icon", A_AhkPath, -206) ; Use icon with resource identifier 206
FileMenu.SetIcon("Pause Icon", A_AhkPath, -207) ; Use icon with resource identifier 207
MyMenuBar := MenuBar()
MyMenuBar.Add("&File", FileMenu)
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].MenuBar := MyMenuBar
mV2GC[["","ExitThisExample"]] := mV2Gui[""].Add("Button",,"Exit This Example")
mV2GC[["","ExitThisExample"]].OnEvent("Click",Exit.Bind("Normal"))
mV2Gui[""].Show()
return

MenuHandler:
MenuHandler()
return

Exit:
Exit()
ExitApp()

;###############  V1toV2 FUNCS  ###############
MenuHandler(A_ThisMenuItem:="", A_ThisMenuItemPos:="", MyMenu:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
return
}
;##############################################
Exit(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}