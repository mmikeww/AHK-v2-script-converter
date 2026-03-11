; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Opt("+AlwaysOnTop +Disabled -SysMenu +Owner")  ; +Owner avoids a taskbar button.
mV2Gui["1"].Add("Text",,"Some text to display.")
mV2Gui["1"].Title := "Title of Window"
mV2Gui["1"].Show("NoActivate")  ; NoActivate avoids deactivating the currently active window.