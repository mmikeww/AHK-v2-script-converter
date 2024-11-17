Gui, Add, Text,, Gui 1`nNormal
Gui, +HWNDv1
Gui, Show, w100 h100 y0
Gui, New, +hwndv2
Gui, Add, Text,, Gui 2`nNew
Gui, Show, w100 h100 y150
Gui, g2:New, +hwndv3
Gui, g2:Add, Text,, Gui 3`nName:New
Gui, g2:Show, w100 h100 y300
Gui, g3: New, +hwndv4
Gui, g3: Add, Text,, Gui 4`nName: New
Gui, g3: Show, w100 h100 y450
Return

^l::MsgBox % v1 "`n" v2 "`n" v3 "`n" v4