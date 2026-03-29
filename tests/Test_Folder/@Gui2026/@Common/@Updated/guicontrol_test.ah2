#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
iniGuiCtrlVars() ; V1toV2: initialize gui ctrl vars
#Warn Unreachable, Off
If (!HasV2Gui("")) {
    mV2Gui[""] := NewV2Gui("")
    mV2Gui[""].OnEvent("Close",GuiClose)
}
mV2GC[["","TextC"]] := mV2Gui[""].Add("Text","vTextC","First name:")
mV2GC[["","FirstName"]] := mV2Gui[""].Add("Edit","vFirstName")
test := mV2GC[["","FirstName"]].hwnd  ; The ym option starts a new column of controls.
mV2GC[["","MyButton"]] := mV2Gui[""].Add("Button","xp+140 vMyButton default","Click Me")
mV2GC[["","MyButton"]].OnEvent("Click",EmptyTest.Bind("Normal"))
mV2GC[["","MyPic"]] := mV2Gui[""].Add("Picture","x10 vMyPic w20 h-1","C:\Windows\SysWOW64\SecurityAndMaintenance.png")
mV2GC[["","MyCheckBox"]] := mV2Gui[""].Add("CheckBox","x10 vMyCheckBox","Option1")
mV2GC[["","MyRadio"]] := mV2Gui[""].Add("Radio","xp+70 vMyRadio","Radio")
mV2Gui[""].Add("Radio","xp+70","Radio2")

mV2GC[["","MyDropDownList"]] := mV2Gui[""].Add("DropDownList","x10 vMyDropDownList",["Black","White","Red","Green","Blue"])
mV2GC[["","MyComboBox"]] := mV2Gui[""].Add("ComboBox","vMyComboBox",["Red","Green","Blue","Black","White"])

mV2GC[["","myListBox"]] := mV2Gui[""].Add("ListBox","r5 vmyListBox",["Red","Green","Blue","Black","White"])

mV2GC[["","MyLink"]] := mV2Gui[""].Add("Link","vMyLink","This is a <a href=`"https://www.autohotkey.com`">link</a>")
mV2GC[["","MyHotkey"]] := mV2Gui[""].Add("Hotkey","vMyHotkey")
mV2GC[["","MyDateTime"]] := mV2Gui[""].Add("DateTime","vMyDateTime")

mV2GC[["","MyMonthCal"]] := mV2Gui[""].Add("MonthCal","vMyMonthCal")
mV2GC[["","MySlider"]] := mV2Gui[""].Add("Slider","vMySlider","50")
mV2GC[["","MyProgress"]] := mV2Gui[""].Add("Progress","w200 h20 cBlue vMyProgress","75")

mV2GC[["","MyGroupBox"]] := mV2Gui[""].Add("GroupBox","w200 h50 vMyGroupBox","Geographic Criteria")
mV2GC[["","MyTab3"]] := mV2Gui[""].Add("Tab3","h75 vMyTab3",["General","View","Settings"])
mV2GC[["","MyTab3"]].UseTab(0)

mV2GC[["","MyStatusbar"]] := mV2Gui[""].Add("StatusBar","vMyStatusbar","Bar's starting text (omit to start off empty).")
; Gui Add, ActiveX, w600 h500 vWB, Shell.Explorer  ; The final parameter is the name of the ActiveX component.
; WB.Navigate("https://www.autohotkey.com/boards/")  ; This is specific to the web browser control.
mV2Gui[""].Title := "Simple Input Example"
mV2Gui[""].Show()
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
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
V2DSResult := V2DynSubmit(mV2Gui[A_DefaultGui],0)  ; Save the input from the user to each control's associated variable.
mV2GC[["","TextC"]].Value := "test"
mV2GC[["","FirstName"]].Value := "test"

mV2GC[["","MyPic"]].Value := "C:\Windows\SysWOW64\SecurityAndMaintenance_Error.png"
mV2GC[["","MyCheckBox"]].Value := 1
mV2GC[["","MyRadio"]].Text := "true"
mV2GC[["","MyDropDownList"]].Add(["test"])
mV2GC[["","myListBox"]].Add(["test1", "test2"])
mV2GC[["","MyComboBox"]].Delete() ; V1toV2: Clean the list
mV2GC[["","MyComboBox"]].Add(["test1", "test2"])
mV2GC[["","MyLink"]].Text := "test"
mV2GC[["","MyHotkey"]].Value := "^!c"
mV2GC[["","MyDateTime"]].Value := 20000101010101
mV2GC[["","MyMonthCal"]].Value := 20000101010101
mV2GC[["","MySlider"]].Value += 10
mV2GC[["","MyProgress"]].Value += 10
mV2GC[["","MyGroupBox"]].Text := "test"
mV2GC[["","MyButton"]].Text := "Thanks!"
mV2GC[["","MyTab3"]].Delete() ; V1toV2: Clean the list
mV2GC[["","MyTab3"]].Add(["Test", "Test2", "Test3"])
mV2GC[["","MyStatusbar"]].SetText("Test")
return
}
;##############################################
GuiClose(*) { ; V1toV2: Lbl->Func
global
(IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)

ExitApp()
}
;##############################################
iniGuiCtrlVars() { ; V1toV2: initializes gui control variables
    global
    FirstName := ""
    MyCheckBox := ""
    MyComboBox := ""
    MyDateTime := ""
    MyDropDownList := ""
    MyHotkey := ""
    myListBox := ""
    MyMonthCal := ""
    MyRadio := ""
    MySlider := ""
    MyTab3 := ""
}