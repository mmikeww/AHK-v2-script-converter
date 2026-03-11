Company := "My Company"

Gui, Add, Text, x20 y20 w60 h20 , Date:
Gui, Add, Edit, x90 y20 w150 h20 vDate
Gui, Add, Text, x20 y50 w60 h20 , Company:
Gui, Add, Edit, x90 y50 w150 h20 vCompanyName
Gui, Add, Text, x20 y80 w60 h20 , Position:
Gui, Add, Edit, x90 y80 w150 h20 vPositionTitle

GuiControl, , CompanyName, % Company
GuiControl, , Edit3, % "My Position"

Gui, Add, Button, x130 y120 w100 h30 gAppendButton, Append
Gui, Show, , Append Data

return
AppendButton:
msgbox % "appending"