myGui := Gui()
myGui.OnEvent("Close", GuiClose)
ogcTextC := myGui.Add("Text", "vTextC", "First name:")
ogcEditFirstName := myGui.Add("Edit", "vFirstName")
test := ogcEditFirstName.hwnd  ; The ym option starts a new column of controls.
ogcPictureMyPic := myGui.Add("Picture", "vMyPic w20 h-1", "C:\Users\Dimitri\Pictures\Save24.png")

ogcMyCheckBox := myGui.Add("CheckBox", "vMyCheckBox", "Option1")
ogcMyRadio := myGui.Add("Radio", "vMyRadio", "Radio")
myGui.Add("Radio", , "Radio2")

ogcMyDropDownList := myGui.Add("DropDownList", "vMyDropDownList", ["Black", "White", "Red", "Green", "Blue"])
ogcMyComboBox := myGui.Add("ComboBox", "vMyComboBox", ["Red", "Green", "Blue", "Black", "White"])

ogcmyListBox := myGui.Add("ListBox", "r5 vmyListBox", ["Red", "Green", "Blue", "Black", "White"])

ogcMyLink := myGui.Add("Link", "vMyLink", "This is a <a href=`"https://www.autohotkey.com`">link</a>")
ogcMyHotkey := myGui.Add("Hotkey", "vMyHotkey")
ogcMyDateTime := myGui.Add("DateTime", "vMyDateTime")

ogcMyMonthCal := myGui.Add("MonthCal", "vMyMonthCal")
ogcMySlider := myGui.Add("Slider", "vMySlider", "50")
ogcMyProgress := myGui.Add("Progress", "w200 h20 cBlue vMyProgress", "75")

ogcMyGroupBox := myGui.Add("GroupBox", "w200 h50 vMyGroupBox", "Geographic Criteria")
Tab := ogcMyTab3 := myGui.Add("Tab3", "vMyTab3", ["General", "View", "Settings"])
Tab.UseTab()
ogcMyButton := myGui.Add("Button", "vMyButton  default", "Empty Test")
ogcMyButton.OnEvent("Click", EmptyTest.Bind("Normal"))  ; The label ButtonOK (if it exists) will be run when the button is pressed.

ogcMyStatusbar := myGui.Add("StatusBar", "vMyStatusbar", "Bar's starting text (omit to start off empty).")
; Gui Add, ActiveX, w600 h500 vWB, Shell.Explorer  ; The final parameter is the name of the ActiveX component.
; WB.Navigate("https://www.autohotkey.com/boards/")  ; This is specific to the web browser control.
myGui.Title := "Simple Input Example"
myGui.Show()
return  ; End of auto-execute section. The script is idle until the user does something.

EmptyTest(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
oSaved := myGui.Submit("0")
FirstName := oSaved.FirstName
MyCheckBox := oSaved.MyCheckBox
MyRadio := oSaved.MyRadio
MyDropDownList := oSaved.MyDropDownList
MyComboBox := oSaved.MyComboBox
myListBox := oSaved.myListBox
MyHotkey := oSaved.MyHotkey
MyDateTime := oSaved.MyDateTime
MyMonthCal := oSaved.MyMonthCal
MySlider := oSaved.MySlider
MyTab3 := oSaved.MyTab3  ; Save the input from the user to each control's associated variable.
ogcTextC.Value := "test"
ogcEditFirstName.Value := "test"

ogcPictureMyPic.Value := "C:\Users\Dimitri\Pictures\test.png"
ogcMyCheckBox.Value := 1
ogcMyRadio.Text := "true"
ogcMyDropDownList.Add(["test"])
ogcmyListBox.Add(["test1", "test2"])
ogcMyComboBox.Delete() ; V1toV2: Clean the list
ogcMyComboBox.Add(["test1", "test2"])
ogcMyLink.Text := "test"
ogcMyHotkey.Value := "^!c"
ogcMyDateTime.Value := 20000101010101
ogcMyMonthCal.Value := 20000101010101
ogcMySlider.Value += 10
ogcMyProgress.Value += 10
ogcMyGroupBox.Text := "test"
ogcMyButton.Text := "test"
ogcMyTab3.Delete() ; V1toV2: Clean the list
ogcMyTab3.Add(["Test", "Test2", "Test3"])
ogcMyStatusbar.SetText("Test")
return
} ; V1toV2: Added bracket before function
GuiClose(*)

{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()
} ; V1toV2: Added bracket in the end