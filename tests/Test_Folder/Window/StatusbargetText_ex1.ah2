RetrievedText := StatusBarGetText(1, "Search Results")
if InStr(RetrievedText, "found")
    MsgBox("Search results have been found.")