; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#SingleInstance Force
Persistent
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
}
mV2Gui["1"].Opt("+LastFound")
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