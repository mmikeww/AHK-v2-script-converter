#HotIf MouseIsOver("ahk_class Shell_TrayWnd")
return ; V1toV2: remove if unnecessary
WheelUp::Send("{Volume_Up}")
WheelDown::Send("{Volume_Down}")

MouseIsOver(WinTitle) {
    MouseGetPos(, , &Win)
    return WinExist(WinTitle . " ahk_id " . Win)
}