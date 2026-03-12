; DragDropPdf.ahk
;Gui, new, +AlwaysOnTop ; removed because this will hide msgboxes and file dialogs
Gui, Font,s09
Gui, Add, Text, x10 y10, % "Convert SINGLE PDF File:"
Gui, Add, Text, x10 y50, % "STEP 1: Choose PDF File (Support Drag/Drop File):"
Gui, Add, Button, x420 y65 w90 h20 gLabelInput Default, % "Input File"
Gui, Add, Edit, x10 y65 w400 h20 gCheck vEditInput
Gui, Add, Text, x10 y120, % "STEP 2: Choose Output FOLDER:"
Gui, Add, Button, x420 y135 w90 h20 gLabelOutput, % "Output Folder"
Gui, Add, Edit, x10 y135 w400 h20 gCheck vEditOutDir
Gui, Add, Text, x10 y185, % "STEP 3: Convert:"
;Gui, Add, Button, w500 xm Disabled, % "BATCH Convert"
Gui, Add, Button, x10 y200 w500 h25 Disabled gLabelConvert,	% "BATCH PDF Convert"
Gui, Add, Progress, c06B025 wp vProgBar Border

Gui, Font, s06
Gui, Add, Text, x460 y280, % "Convert PDF"
Gui, Show,,% "Convert PDF"


Check:
 Gui, Submit, NoHide
 GuiControl, % FileExist(EditInput) && FileExist(EditOutDir) ? "Enable" : "Disable", % "BATCH PDF Convert"
 return

LabelInput:
 pathToAdd := "pathToAdd"
 GuiControl,, EditInput, % pathToAdd
 return

LabelOutput:
 fsfOutput := "fsfOutput"
 GuiControl,, EditOutDir, % fsfOutput
 return

LabelConvert:
 msgbox converting...
 return