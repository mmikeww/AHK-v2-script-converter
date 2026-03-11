Gui +AlwaysOnTop
Gui Font, s10
Gui Add, Edit, w300 vinput
Gui Show, x100, Convert PDF
Return

GuiDropFiles:
Loop, parse, A_GuiEvent, `n
{
SplitPath, A_LoopField, , , FileExtension
If FileExtension = pdf
 msgbox % A_LoopField
Else
 msgbox % "not a pdf file"
}
Return
