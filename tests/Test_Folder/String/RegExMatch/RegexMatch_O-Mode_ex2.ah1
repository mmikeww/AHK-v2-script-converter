test_string := "<RequiredPackages Count=""123"">"

RegExMatch(test_string, "O)(<RequiredPackages Count=""(\d+)"">)", match)

MsgBox, % "match.1 = " match.1 "`nmatch.2 = " match.2