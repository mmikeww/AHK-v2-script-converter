#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("DropFiles",GuiDropFiles)
}
mV2Gui[""].Opt("+AlwaysOnTop")
mV2Gui[""].SetFont("s10")
mV2GC[["","input"]] := mV2Gui[""].Add("Edit","w300 vinput")
mV2Gui[""].Title := "Convert PDF"
mV2Gui[""].Show("x100")
Return

GuiDropFiles:
GuiDropFiles()
Return

;###############  V1toV2 FUNCS  ###############
GuiDropFiles(thisGui:="", Ctrl:="", FileArray:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
for i, path in FileArray
{
SplitPath(path, , , &FileExtension)
if (FileExtension = "pdf")
 MsgBox(path)
Else
 MsgBox("not a pdf file")
}
Return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    input := ""
}
