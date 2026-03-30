#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
    mV2Gui[""].OnEvent("Escape",GuiEscape)
}
mV2Gui[""].Add("Text",,"Type a key name and click Convert.")
mV2GC[["","KeyName"]] := mV2Gui[""].Add("Edit","vKeyName w50","vk4C")
mV2GC[["","Convert"]] := mV2Gui[""].Add("Button","Default","Convert")
mV2GC[["","Convert"]].OnEvent("Click",ButtonConvert.Bind("Normal"))
mV2Gui[""].Show()
return
ButtonConvert:
ButtonConvert()
return
GuiClose:
GuiClose()
return
GuiEscape:
GuiEscape()
ExitApp()

GetKeyChar(Key, WinTitle:=0)
{
    thread := WinTitle=0 ? 0
        : DllCall("GetWindowThreadProcessId", "ptr", WinExist(WinTitle), "ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")
    vk := GetKeyVK(Key), sc := GetKeySC(Key)
    state := Buffer(256, 0) ; V1toV2: if 'state' is a UTF-16 string, use 'VarSetStrCapacity(&state, 256)' and replace all instances of 'state.Ptr' with 'StrPtr(state)'
    char := Buffer(4, 0) ; V1toV2: if 'char' is a UTF-16 string, use 'VarSetStrCapacity(&char, 4)' and replace all instances of 'char.Ptr' with 'StrPtr(char)'
    n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc
, "ptr", state.Ptr, "ptr", char.Ptr, "int", 2, "uint", 0, "ptr", hkl)
    return StrGet(char.Ptr, n, "utf-16")
}

;###############  V1toV2 FUNCS  ###############
ButtonConvert(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)
MsgBox("GetKeyName: " GetKeyName(KeyName)
    .  "`nGetKeyChar: " GetKeyChar(KeyName))
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
GuiEscape()
}
;##############################################
GuiEscape(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
ExitApp()
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    KeyName := ""
}