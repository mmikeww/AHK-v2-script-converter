MyFunc() {
   global ; V1toV2: Made function global
   myGui := Gui()
   myGui.Add("Text", , "Gui")
   myGui.Show("w150")
}
MyFunc()

F1::myGui.Destroy()