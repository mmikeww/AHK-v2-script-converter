file2 := FileSelect(32, "", "Pick a shortcut to analyze.", "Shortcuts (*.lnk)")
if (file2 = "")
    return
FileGetShortcut(file2, &OutTarget, &OutDir, &OutArgs, &OutDesc, &OutIcon, &OutIconNum, &OutRunState)
MsgBox(OutTarget "`n" OutDir "`n" OutArgs "`n" OutDesc "`n" OutIcon "`n" OutIconNum "`n" OutRunState)