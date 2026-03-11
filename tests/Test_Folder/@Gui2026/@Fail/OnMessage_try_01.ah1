#SingleInstance Force
Gui +LastFound
hWnd := WinExist()

DllCall("RegisterShellHookWindow", UInt,WinExist())
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )
return

ShellMessage( wParam,lParam )
{
 WinGet, pname, ProcessName, ahk_id %lParam%
 WinGetTitle, title_W, ahk_id %lParam%
 WinGetClass, class_W, ahk_id %lParam%
 If ((title_W != "") && (class_W != ""))
 {
  If ( wParam = 1 ) ;  1 means HSHELL_WINDOWCREATED
  ToolTip, WINDOW CREATED:`n"%title_W%" ahk_class "%class_W%"`n%pname%
 }
}