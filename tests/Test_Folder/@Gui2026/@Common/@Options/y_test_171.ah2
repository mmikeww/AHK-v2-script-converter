#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Opt("+AlwaysOnTop +Disabled -SysMenu +Owner")  ; +Owner avoids a taskbar button.
mV2Gui[""].Add("Text",,"Some text to display.")
mV2Gui[""].Title := "Title of Window"
mV2Gui[""].Show("NoActivate")  ; NoActivate avoids deactivating the currently active window.