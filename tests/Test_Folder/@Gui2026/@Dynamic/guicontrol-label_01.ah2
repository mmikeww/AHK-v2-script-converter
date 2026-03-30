#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
pathToAdd := "inputPath"
fsfOutput := "outputPath"

If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2GC[["","InputFile"]] := mV2Gui[""].Add("Button","x420 y65 w90 h20 Default","Input File")
mV2GC[["","InputFile"]].OnEvent("Click",LabelInput.Bind("Normal"))
mV2GC[["","EditInput"]] := mV2Gui[""].Add("Edit","x10 y65 w400 h20 vEditInput")
mV2GC[["","EditInput"]].OnEvent("Change",Check.Bind("Normal"))
mV2Gui[""].Add("Text","x10 y120","STEP 2: Choose Output FOLDER:")
mV2GC[["","OutputFolder"]] := mV2Gui[""].Add("Button","x420 y135 w90 h20","Output Folder")
mV2GC[["","OutputFolder"]].OnEvent("Click",LabelOutput.Bind("Normal"))
mV2GC[["","EditOutDir"]] := mV2Gui[""].Add("Edit","x10 y135 w400 h20 vEditOutDir")
mV2GC[["","EditOutDir"]].OnEvent("Change",Check.Bind("Normal"))
mV2GC[["","BATCHPDFConvert"]] := mV2Gui[""].Add("Button","x10 y200 w500 h25 Disabled","BATCH PDF Convert")
mV2GC[["","BATCHPDFConvert"]].OnEvent("Click",LabelConvert.Bind("Normal"))
mV2GC[["","ProgBar"]] := mV2Gui[""].Add("Progress","c06B025 wp vProgBar Border")
mV2Gui[""].Title := "Convert PDF"
mV2Gui[""].Show()

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
Return

;###############  V1toV2 FUNCS  ###############
Check(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)
return
}
;##############################################
LabelInput(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2GC[["","EditInput"]].Value := pathToAdd
return
}
;##############################################
LabelOutput(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2GC[["","EditOutDir"]].Value := fsfOutput
mV2GC[["","BATCHPDFConvert"]].Opt("+Default") ; v1 had trailing colon
return
}
;##############################################
LabelConvert(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
mV2GC[["","InputFile"]].Opt("+Default") ; v1 had trailing colon
Return
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    EditInput := ""
    EditOutDir := ""
}