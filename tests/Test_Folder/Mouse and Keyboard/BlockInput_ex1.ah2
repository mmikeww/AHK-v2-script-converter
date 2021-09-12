BlockInput("On")
Run("notepad")
ErrorLevel := WinWaitActive("Untitled - Notepad", , , , ) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
Send("{F5}") ; pastes time and date
BlockInput("Off")