if WinExist("Search Results") ; Sets the Last Found window to simplify the below.
{
    WinActivate()
    Send("{tab 2}!o*.txt{enter}")  ; In the Search window, enter the pattern to search for.
    Sleep(400)  ; Give the status bar time to change to "Searching".
    StatusBarWait("found", 30)
    if ErrorLevel
        MsgBox("The command timed out or there was a problem.")
    else
        MsgBox("The search successfully completed.")
}