; https://github.com/mmikeww/AHK-v2-script-converter/issues/479
myGui := Gui()
myGui.SetFont("bold")
myGui.Add("Text", , "Bold Text")
myGui.SetFont("norm") ; v2 requires "norm"
myGui.Add("Text", , "Normal Text")
myGui.Title := "Norm Font"
myGui.Show("w250 h100")