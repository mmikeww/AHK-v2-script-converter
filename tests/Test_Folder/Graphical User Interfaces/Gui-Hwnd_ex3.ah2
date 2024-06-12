myGui := Gui()
ListBox1 := myGui.Add("ListBox", "w300 h200")
hOutput := ListBox1.hwnd
myGui.Show()
MsgBox(hOutput)
Return