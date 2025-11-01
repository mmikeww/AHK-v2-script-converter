Persistent
Tray:= A_TrayMenu
Tray.Add("Test", Test)

Test(A_ThisMenuItem:="", A_ThisMenuItemPos:="", A_ThisMenu:="") {
  Tray.Add("Test", Test)
}

