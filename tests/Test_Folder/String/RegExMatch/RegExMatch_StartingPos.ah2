Func1() {
	local Match
	StartingPos := 0
	RegExMatch("", "", &Match, (StartingPos)<1 ? (StartingPos)-1 : (StartingPos))
	RegExMatch("", "", &Match, -1)
	RegExMatch("", "", &Match, (1-1)<1 ? (1-1)-1 : (1-1))
	Return (Match&&Match[0])
}
Func1()

; these local vars should remain unchanged
Func2() {
	local NotMatch, Match0, Match1, Match2, MatchAbc, NotMatch
	MsgBox(Match)
	MsgBox(Match0)
	MsgBox(Match1)
	MsgBox(Match2)
	Return Match
}