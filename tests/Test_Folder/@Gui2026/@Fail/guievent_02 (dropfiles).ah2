; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("DropFiles",GuiDropFiles)
}
mV2Gui["1"].Opt("+AlwaysOnTop")
mV2Gui["1"].SetFont("s10")
mV2GC[["1","input"]] := mV2Gui["1"].Add("Edit","w300 vinput")
mV2Gui["1"].Title := "Convert PDF"
mV2Gui["1"].Show("x100")
Return

GuiDropFiles:
GuiDropFiles()
Return

;###############  V1toV2 FUNCS  ###############
GuiDropFiles(thisGui:="", Ctrl:="", FileArray:="", *) { ; V1toV2: Lbl->Func
global
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
