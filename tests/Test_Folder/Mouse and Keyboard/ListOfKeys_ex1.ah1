; Requires AutoHotkey v1.1.26+, and the keyboard hook must be installed.
#InstallKeybdHook
SendSuppressedKeyUp(key) {
    DllCall("keybd_event"
        , "char", GetKeyVK(key)
        , "char", GetKeySC(key)
        , "uint", KEYEVENTF_KEYUP := 0x2
        , "uptr", KEY_BLOCK_THIS := 0xFFC3D450)
}

; Disable Alt+key shortcuts for the IME.
~LAlt::SendSuppressedKeyUp("LAlt")

; Test hotkey:
!CapsLock::MsgBox % A_ThisHotkey

; Remap CapsLock to LCtrl in a way compatible with IME.
*CapsLock::
    Send {Blind}{LCtrl DownR}
    SendSuppressedKeyUp("LCtrl")
    return
*CapsLock up::
    Send {Blind}{LCtrl Up}
    return