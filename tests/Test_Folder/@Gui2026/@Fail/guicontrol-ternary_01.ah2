; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
; DragDropPdf.ahk
;Gui, new, +AlwaysOnTop ; removed because this will hide msgboxes and file dialogs
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].SetFont("s09")
mV2Gui["1"].Add("Text","x10 y10","Convert SINGLE PDF File:")
mV2Gui["1"].Add("Text","x10 y50","STEP 1: Choose PDF File (Support Drag/Drop File):")
mV2GC[["1","InputFile"]] := mV2Gui["1"].Add("Button","x420 y65 w90 h20 Default","Input File")
mV2GC[["1","InputFile"]].OnEvent("Click",LabelInput.Bind("Normal"))
mV2GC[["1","EditInput"]] := mV2Gui["1"].Add("Edit","x10 y65 w400 h20 vEditInput")
mV2GC[["1","EditInput"]].OnEvent("Change",Check.Bind("Normal"))
mV2Gui["1"].Add("Text","x10 y120","STEP 2: Choose Output FOLDER:")
mV2GC[["1","OutputFolder"]] := mV2Gui["1"].Add("Button","x420 y135 w90 h20","Output Folder")
mV2GC[["1","OutputFolder"]].OnEvent("Click",LabelOutput.Bind("Normal"))
mV2GC[["1","EditOutDir"]] := mV2Gui["1"].Add("Edit","x10 y135 w400 h20 vEditOutDir")
mV2GC[["1","EditOutDir"]].OnEvent("Change",Check.Bind("Normal"))
mV2Gui["1"].Add("Text","x10 y185","STEP 3: Convert:")
;Gui, Add, Button, w500 xm Disabled, % "BATCH Convert"
mV2GC[["1","BATCHPDFConvert"]] := mV2Gui["1"].Add("Button","x10 y200 w500 h25 Disabled","BATCH PDF Convert")
mV2GC[["1","BATCHPDFConvert"]].OnEvent("Click",LabelConvert.Bind("Normal"))
mV2GC[["1","ProgBar"]] := mV2Gui["1"].Add("Progress","c06B025 wp vProgBar Border")

mV2Gui["1"].SetFont("s06")
mV2Gui["1"].Add("Text","x460 y280","Convert PDF")
mV2Gui["1"].Title := "Convert PDF"
mV2Gui["1"].Show()


Check:
Check()
 return

LabelInput:
LabelInput()
 return

LabelOutput:
LabelOutput()
 return

LabelConvert:
LabelConvert()
 return

;###############  V1toV2 FUNCS  ###############
Check(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
 oSaved := mV2Gui[gCurGuiID].Submit(0)
 EditInput := oSaved.EditInput
 EditOutDir := oSaved.EditOutDir
 mV2GC[["1","BATCHPDFConvert"]].Enabled := (FileExist(EditInput) && FileExist(EditOutDir))
 return
}
;##############################################
LabelInput(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
 pathToAdd := "pathToAdd"
 mV2GC[["1","EditInput"]].Value := pathToAdd
 return
}
;##############################################
LabelOutput(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
 fsfOutput := "fsfOutput"
 mV2GC[["1","EditOutDir"]].Value := fsfOutput
 return
}
;##############################################
LabelConvert(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
 MsgBox("converting...")
 return
}