myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Escape", GuiClose)
myGui.Add("Text", , "Type a key name and click Convert.")
ogcEditKeyName := myGui.Add("Edit", "vKeyName w50", "vk4C")
ogcButtonConvert := myGui.Add("Button", "Default", "Convert")
ogcButtonConvert.OnEvent("Click", ButtonConvert.Bind("Normal"))
myGui.Show()
return
ButtonConvert(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
oSaved := myGui.Submit("0")
KeyName := oSaved.KeyName
MsgBox("GetKeyName: " GetKeyName(KeyName)
    .  "`nGetKeyChar: " GetKeyChar(KeyName))
return
} ; V1toV2: Added bracket before function
GuiClose(*)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
GuiEscape:
ExitApp()
} ; V1toV2: Added bracket before function

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