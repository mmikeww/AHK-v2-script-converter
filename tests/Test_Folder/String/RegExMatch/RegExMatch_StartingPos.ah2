Func1() {
	local Match
	StartingPos := 0
	RegExMatch("", "", &Match, (StartingPos)<1 ? (StartingPos)-1 : (StartingPos))
	RegExMatch("", "", &Match, -1)
	RegExMatch("", "", &Match, (1-1)<1 ? (1-1)-1 : (1-1))
}
Func1()

Func2() {
	local NotMatch, Match, MatchAbc, NotMatch
}