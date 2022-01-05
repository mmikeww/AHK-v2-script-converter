MsgBox % Format("You are using AutoHotkey v{1} {2}-bit.", A_AhkVersion, A_PtrSize*8)

if A_AhkVersion >= 1.0.25.07
    MsgBox % A_AhkVersion