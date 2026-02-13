myGui := Gui(, "Owner"), ThisHwnd := myGui.Hwnd
myGui.Show("w600 h200")

myGui1 := Gui("+Owner" . ThisHwnd, "Child 1")
myGui1.Show("w500 h150")

myGui11 := Gui("+Owner" . ThisHwnd, "Child 2")
myGui11.Show("w300 h100")