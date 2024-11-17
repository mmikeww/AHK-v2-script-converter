BlockInput("On")
Run("notepad")
WinWaitActive("Untitled - Notepad")
Send("{F5}") ; pastes time and date
BlockInput("Off")