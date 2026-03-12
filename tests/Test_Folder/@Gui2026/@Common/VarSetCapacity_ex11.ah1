Gui Add, Text, , Type a key name and click Convert.
Gui Add, Edit, vKeyName w50, vk4C
Gui Add, Button, Default, Convert
Gui Show
return
ButtonConvert:
Gui Submit, NoHide
MsgBox % "GetKeyName: " GetKeyName(KeyName)
    .  "`nGetKeyChar: " GetKeyChar(KeyName)
return
GuiClose:
GuiEscape:
ExitApp

GetKeyChar(Key, WinTitle:=0)
{
    thread := WinTitle=0 ? 0
        : DllCall("GetWindowThreadProcessId", "ptr", WinExist(WinTitle), "ptr", 0)
    hkl := DllCall("GetKeyboardLayout", "uint", thread, "ptr")
    vk := GetKeyVK(Key), sc := GetKeySC(Key)
    VarSetCapacity(state, 256, 0)
    VarSetCapacity(char, 4, 0)
    n := DllCall("ToUnicodeEx", "uint", vk, "uint", sc
        , "ptr", &state, "ptr", &char, "int", 2, "uint", 0, "ptr", hkl)
    return StrGet(&char, n, "utf-16")
}