#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
global editVar := ""

g := clsGui()

class clsGui {

  __new() {
    this.makeGui("demo")
  }

  typing(*) { ; will need params added, or at least (*)
    SoundBeep()
    V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)
    ToolTip(editVar, 1, 1)
  }

  makeGui(id) {
    mV2Gui[id] := NewV2Gui(id,1)
    mV2GC[["","EditVar"]] := mV2Gui[""].Add("Edit","xm w280 vEditVar","Type Something")
    handler := this.typing.Bind(this)
    ; either of these will work
    ;GuiControl +g, Edit1,    % handler
    ;GuiControl  +g, EditVar, % handler
    V2EH("","EditVar","",handler) ; V1toV2: Must MANUALLY ADD params or trailing * to CB func!
    mV2Gui[""].Title := "GuiControl +G " id
    mV2Gui[""].Show("w300 h50")
  }
}

;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    EditVar := ""
}