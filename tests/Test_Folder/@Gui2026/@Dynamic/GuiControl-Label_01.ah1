pathToAdd = inputPath
fsfOutput = outputPath

Gui, Add, Button, x420 y65 w90 h20 gLabelInput Default, % "Input File"
Gui, Add, Edit, x10 y65 w400 h20 gCheck vEditInput
Gui, Add, Text, x10 y120, % "STEP 2: Choose Output FOLDER:"
Gui, Add, Button, x420 y135 w90 h20 gLabelOutput, % "Output Folder"
Gui, Add, Edit, x10 y135 w400 h20 gCheck vEditOutDir
Gui, Add, Button, x10 y200 w500 h25 Disabled gLabelConvert, % "BATCH PDF Convert"
Gui, Add, Progress, c06B025 wp vProgBar Border
Gui, Show,, % "Convert PDF"

Check:
Gui, Submit, NoHide
return

LabelInput:
GuiControl,, EditInput, % pathToAdd
return

LabelOutput:
GuiControl,, EditOutDir, % fsfOutput
GuiControl +Default, LabelConvert: ; v1 had trailing colon
return

LabelConvert:
GuiControl +Default, LabelInput: ; v1 had trailing colon
Return