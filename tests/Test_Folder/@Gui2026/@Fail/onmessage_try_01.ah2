#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#SingleInstance Force
Persistent
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
}
mV2Gui[""].Opt("+LastFound")
hWnd := WinExist()

DllCall("RegisterShellHookWindow", "UInt", WinExist())
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, ShellMessage)
return

ShellMessage( wParam,lParam, msg, hwnd )
{
try {
 pname := WinGetProcessName("ahk_id " lParam)
 title_W := WinGetTitle("ahk_id " lParam)
 class_W := WinGetClass("ahk_id " lParam)
 If ((title_W != "") && (class_W != ""))
 {
  If ( wParam = 1 ) ;  1 means HSHELL_WINDOWCREATED
  ToolTip("WINDOW CREATED:`n`"" title_W "`" ahk_class `"" class_W "`"`n" pname)
 }
}
}