active_title = PRIORITY
Gui, 5:Add, Text,, Press ESCAPE to cancel, or double-click a new`npriority level for the following window:`n%active_title%
Gui, 5:Add, ListBox, vMyListBox1 gMyListBox r5, Normal|High|Low|BelowNormal|AboveNormal
Gui, 5:Add, Button, default, OK
Gui, 5:Show,, Set Priority
return

MyListBox:
5ButtonOK:
msgbox hello