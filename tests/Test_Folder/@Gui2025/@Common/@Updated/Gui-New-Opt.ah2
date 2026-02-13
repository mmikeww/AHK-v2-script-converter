myGui := Gui("Owner"), ThisHwnd := myGui.Hwnd
myGui.Show("w600 h200")

myGui2 := Gui("+Owner" . ThisHwnd, "Child 1")
myGui2.Show("w500 h150")

myGui3 := Gui("+Owner" . ThisHwnd, "Child 2")
myGui3.Show("w300 h100")