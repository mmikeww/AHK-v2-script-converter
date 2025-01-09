Tray:= A_TrayMenu
Tray.Delete() ; V1toV2: not 100% replacement of NoStandard, Only if NoStandard is used at the beginning
Tray.Delete()
Tray.Add(applicationname, SHOW)
Tray.Add()
Tray.Add("&Show", SHOW)
Tray.Add()
Tray.Add("&About...", ABOUT)
Tray.Add("E&xit", EXIT)
A_IconTip := applicationname
Tray.Default := applicationname