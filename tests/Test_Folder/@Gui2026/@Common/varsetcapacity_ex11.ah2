; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
    mV2Gui["1"].OnEvent("Escape",GuiEscape)
}
mV2Gui["1"].Add("Text",,"Type a key name and click Convert.")
mV2GC[["1","KeyName"]] := mV2Gui["1"].Add("Edit","vKeyName w50","vk4C")
mV2GC[["1","Convert"]] := mV2Gui["1"].Add("Button","Default","Convert")
mV2GC[["1","Convert"]].OnEvent("Click",ButtonConvert.Bind("Normal"))
mV2Gui["1"].Show()
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
oSaved := mV2Gui[gCurGuiID].Submit(0)
Try KeyName := oSaved.KeyName
MsgBox("GetKeyName: " GetKeyName(KeyName)
    .  "`nGetKeyChar: " GetKeyChar(KeyName))
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
GuiEscape()
}
;##############################################
GuiEscape(*) { ; V1toV2: Lbl->Func
global
ExitApp()
}