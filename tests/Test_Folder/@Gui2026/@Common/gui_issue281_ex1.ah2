#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("GuiName")) {
    mV2Gui["GuiName"] := NewV2Gui("GuiName")
}
mV2Gui["GuiName"].Add("Text",,"Spaces do not appear`nbetween name and method")
mV2Gui["GuiName"].Show("w200 h100")