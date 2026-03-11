global editVar := ""

g := new clsGui()

class clsGui {

  __new() {
    this.makeGui("demo")
  }

  typing() { ; will need params added, or at least (*)
    SoundBeep
    Gui, Submit, NoHide
    Tooltip % editVar, 1, 1
  }

  makeGui(id) {
    Gui, %id%:New
    Gui, Add, Edit, xm w280 vEditVar, Type Something
    handler := this.typing.Bind(this)
    ; either of these will work
    ;GuiControl +g, Edit1,    % handler
    GuiControl  +g, EditVar, % handler
    Gui, Show, w300 h50, % "GuiControl +G " id
  }
}