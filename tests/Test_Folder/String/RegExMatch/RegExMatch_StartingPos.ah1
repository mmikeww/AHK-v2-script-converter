Func1() {
	local Match
	StartingPos := 0
	RegExMatch("", "", Match, StartingPos)
	RegExMatch("", "", Match, 0)
	RegExMatch("", "", Match, 1-1)
}
Func1()

Func2() {
	local NotMatch, Match0, Match1, Match2, MatchAbc, NotMatch
}