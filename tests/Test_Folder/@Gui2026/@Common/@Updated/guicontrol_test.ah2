; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off
If (!HasV2Gui("1")) {
    mV2Gui["1"] := NewV2Gui("1")
    mV2Gui["1"].OnEvent("Close",GuiClose)
}
mV2GC[["1","TextC"]] := mV2Gui["1"].Add("Text","vTextC","First name:")
mV2GC[["1","FirstName"]] := mV2Gui["1"].Add("Edit","vFirstName")
test := mV2GC[["1","FirstName"]].hwnd  ; The ym option starts a new column of controls.
mV2GC[["1","MyButton"]] := mV2Gui["1"].Add("Button","xp+140 vMyButton default","Click Me")
mV2GC[["1","MyButton"]].OnEvent("Click",EmptyTest.Bind("Normal"))
mV2GC[["1","MyPic"]] := mV2Gui["1"].Add("Picture","x10 vMyPic w20 h-1","C:\Windows\SysWOW64\SecurityAndMaintenance.png")
mV2GC[["1","MyCheckBox"]] := mV2Gui["1"].Add("CheckBox","x10 vMyCheckBox","Option1")
mV2GC[["1","MyRadio"]] := mV2Gui["1"].Add("Radio","xp+70 vMyRadio","Radio")
mV2Gui["1"].Add("Radio","xp+70","Radio2")

mV2GC[["1","MyDropDownList"]] := mV2Gui["1"].Add("DropDownList","x10 vMyDropDownList",["Black","White","Red","Green","Blue"])
mV2GC[["1","MyComboBox"]] := mV2Gui["1"].Add("ComboBox","vMyComboBox",["Red","Green","Blue","Black","White"])

mV2GC[["1","myListBox"]] := mV2Gui["1"].Add("ListBox","r5 vmyListBox",["Red","Green","Blue","Black","White"])

mV2GC[["1","MyLink"]] := mV2Gui["1"].Add("Link","vMyLink","This is a <a href=`"https://www.autohotkey.com`">link</a>")
mV2GC[["1","MyHotkey"]] := mV2Gui["1"].Add("Hotkey","vMyHotkey")
mV2GC[["1","MyDateTime"]] := mV2Gui["1"].Add("DateTime","vMyDateTime")

mV2GC[["1","MyMonthCal"]] := mV2Gui["1"].Add("MonthCal","vMyMonthCal")
mV2GC[["1","MySlider"]] := mV2Gui["1"].Add("Slider","vMySlider","50")
mV2GC[["1","MyProgress"]] := mV2Gui["1"].Add("Progress","w200 h20 cBlue vMyProgress","75")

mV2GC[["1","MyGroupBox"]] := mV2Gui["1"].Add("GroupBox","w200 h50 vMyGroupBox","Geographic Criteria")
mV2GC[["1","MyTab3"]] := mV2Gui["1"].Add("Tab3","h75 vMyTab3",["General","View","Settings"])
mV2GC[["1","MyTab3"]].UseTab(0)

mV2GC[["1","MyStatusbar"]] := mV2Gui["1"].Add("StatusBar","vMyStatusbar","Bar's starting text (omit to start off empty).")
; Gui Add, ActiveX, w600 h500 vWB, Shell.Explorer  ; The final parameter is the name of the ActiveX component.
; WB.Navigate("https://www.autohotkey.com/boards/")  ; This is specific to the web browser control.
mV2Gui["1"].Title := "Simple Input Example"
mV2Gui["1"].Show()
return  ; End of auto-execute section. The script is idle until the user does something.

EmptyTest:
EmptyTest()
return
GuiClose:
GuiClose()
ExitApp()

;###############  V1toV2 FUNCS  ###############
EmptyTest(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
oSaved := mV2Gui[gCurGuiID].Submit(0)
Try MyCheckBox := oSaved.MyCheckBox
Try MyComboBox := oSaved.MyComboBox
Try MyDateTime := oSaved.MyDateTime
Try MyDropDownList := oSaved.MyDropDownList
Try FirstName := oSaved.FirstName
Try MyHotkey := oSaved.MyHotkey
Try myListBox := oSaved.myListBox
Try MyMonthCal := oSaved.MyMonthCal
Try MyRadio := oSaved.MyRadio
Try MySlider := oSaved.MySlider
Try MyTab3 := oSaved.MyTab3  ; Save the input from the user to each control's associated variable.
mV2GC[["1","TextC"]].Value := "test"
mV2GC[["1","FirstName"]].Value := "test"

mV2GC[["1","MyPic"]].Value := "C:\Windows\SysWOW64\SecurityAndMaintenance_Error.png"
mV2GC[["1","MyCheckBox"]].Value := 1
mV2GC[["1","MyRadio"]].Text := "true"
mV2GC[["1","MyDropDownList"]].Add(["test"])
mV2GC[["1","myListBox"]].Add(["test1", "test2"])
mV2GC[["1","MyComboBox"]].Delete() ; V1toV2: Clean the list
mV2GC[["1","MyComboBox"]].Add(["test1", "test2"])
mV2GC[["1","MyLink"]].Text := "test"
mV2GC[["1","MyHotkey"]].Value := "^!c"
mV2GC[["1","MyDateTime"]].Value := 20000101010101
mV2GC[["1","MyMonthCal"]].Value := 20000101010101
mV2GC[["1","MySlider"]].Value += 10
mV2GC[["1","MyProgress"]].Value += 10
mV2GC[["1","MyGroupBox"]].Text := "test"
mV2GC[["1","MyButton"]].Text := "Thanks!"
mV2GC[["1","MyTab3"]].Delete() ; V1toV2: Clean the list
mV2GC[["1","MyTab3"]].Add(["Test", "Test2", "Test3"])
mV2GC[["1","MyStatusbar"]].SetText("Test")
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global

ExitApp()
}