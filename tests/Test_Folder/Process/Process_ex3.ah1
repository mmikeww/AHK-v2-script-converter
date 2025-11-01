#z:: ; Win+Z hotkey
WinGet, active_pid, PID, A
WinGetTitle, active_title, A
Gui, 5:Add, Text,, Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n%active_title%
Gui, 5:Add, ListBox, vMyListBox1 gMyListBox r5, Normal|High|Low|BelowNormal|AboveNormal
Gui, 5:Add, Button, default, OK
Gui, 5:Show,, Set Priority
return

5GuiEscape:
5GuiClose:
Gui, Destroy
return

MyListBox:
if (A_GuiEvent != "DoubleClick")
    return
; else fall through to the next label:
5ButtonOK:
GuiControlGet, MyListBox1
Gui, Destroy
Process, Priority, %active_pid%, %MyListBox1%
if ErrorLevel
    MsgBox Success: Its priority was changed to "%MyListBox1%".
else
    MsgBox Error: Its priority could not be changed to "%MyListBox1%".
return