; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
global editVar := ""

g := clsGui()

class clsGui {

  __new() {
    this.makeGui("demo")
  }

  typing(*) { ; will need params added, or at least (*)
    SoundBeep()
    oSaved := mV2Gui[gCurGuiID].Submit(0)
    EditVar := oSaved.EditVar
    ToolTip(editVar, 1, 1)
  }

  makeGui(id) {
    mV2Gui[id] := NewV2Gui(id)
    mV2GC[[id,"EditVar"]] := mV2Gui[id].Add("Edit","xm w280 vEditVar","Type Something")
    handler := this.typing.Bind(this)
    ; either of these will work
    ;GuiControl +g, Edit1,    % handler
    ;GuiControl  +g, EditVar, % handler
    V2EH("","EditVar","",handler) ; V1toV2: Must MANUALLY ADD params or trailing * to CB func!
    mV2Gui[id].Title := "GuiControl +G " id
    mV2Gui[id].Show("w300 h50")
  }
}