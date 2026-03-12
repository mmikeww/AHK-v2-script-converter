Gui 1:Add, Button,,button 1
Gui 1:Show, x300 w250 h100

Gui 2:Add, Button,,button 2
Gui 2:Show, x650 w250 h100

Gui 1:Default
Gui add, button,,button 3

Gui, Default
Gui add, button,,button 4

guiName := "2"
Gui, %guiName%:Default
Gui add, button,,button 5