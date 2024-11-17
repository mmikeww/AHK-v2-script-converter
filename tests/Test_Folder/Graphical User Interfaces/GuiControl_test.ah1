Gui, Add, Text,vTextC, First name:
Gui, Add, Edit, vFirstName hwndtest  ; The ym option starts a new column of controls.
Gui, Add, Picture, vMyPic w20 h-1, C:\Users\Dimitri\Pictures\Save24.png

Gui, Add, CheckBox, vMyCheckBox, Option1
Gui, Add, Radio, vMyRadio, Radio
Gui, Add, Radio, , Radio2

Gui, Add, DropDownList, vMyDropDownList, Black|White|Red|Green|Blue
Gui, Add, ComboBox, vMyComboBox, Red|Green|Blue|Black|White

Gui, Add, ListBox, r5 vmyListBox, Red|Green|Blue|Black|White

Gui, Add, Link, vMyLink, This is a <a href="https://www.autohotkey.com">link</a>
Gui, Add, Hotkey, vMyHotkey
Gui, Add, DateTime, vMyDateTime,

Gui, Add, MonthCal, vMyMonthCal,
Gui, Add, Slider, vMySlider, 50
Gui, Add, Progress, w200 h20 cBlue vMyProgress, 75

Gui, Add, GroupBox, w200 h50 vMyGroupBox, Geographic Criteria
Gui, Add, Tab3,vMyTab3, General|View|Settings
Gui, Tab
Gui, Add, Button, vMyButton gEmptyTest default, Empty Test  ; The label ButtonOK (if it exists) will be run when the button is pressed.

Gui, Add, StatusBar,vMyStatusbar, Bar's starting text (omit to start off empty).
; Gui Add, ActiveX, w600 h500 vWB, Shell.Explorer  ; The final parameter is the name of the ActiveX component.
; WB.Navigate("https://www.autohotkey.com/boards/")  ; This is specific to the web browser control.
Gui, Show,, Simple Input Example
return  ; End of auto-execute section. The script is idle until the user does something.

EmptyTest:
Gui, Submit, nohide  ; Save the input from the user to each control's associated variable.
GuiControl, , TextC, test
GuiControl, , % test, test

GuiControl, , MyPic, C:\Users\Dimitri\Pictures\test.png
GuiControl, , MyCheckBox, 1
GuiControl, , MyRadio, true
GuiControl,, MyDropDownList,test
GuiControl,,myListBox,test1|test2
GuiControl,,MyComboBox,|test1|test2
GuiControl,,MyLink, test
GuiControl,,MyHotkey, ^!c
GuiControl,,MyDateTime, 20000101010101
GuiControl,,MyMonthCal, 20000101010101
GuiControl,,MySlider, +10
GuiControl,,MyProgress, +10
GuiControl,,MyGroupBox, test
GuiControl, , MyButton, test
GuiControl,,MyTab3, |Test|Test2|Test3
SB_SetText("Test")
return
GuiClose:

ExitApp