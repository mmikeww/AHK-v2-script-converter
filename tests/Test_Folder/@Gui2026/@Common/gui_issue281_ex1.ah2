; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("GuiName")) {
    mV2Gui["GuiName"] := NewV2Gui("GuiName")
}
mV2Gui["GuiName"].Add("Text",,"Spaces do not appear`nbetween name and method")
mV2Gui["GuiName"].Show("w200 h100")