ExplicitGlobalDefault() {
	global

	static static1
	static static2 := "s2"
	static static3, static4 := "s4", static5
	static static6 := "s6", static7, static8 := "s8"

	local local1
	local local2 := "l2"
	local local3, local4 := "l4", local5
	local local6 := "l6", local7, local8 := "l8"
}
ExplicitGlobalDefault()

ForceLocalAndAssumeStatic() {
	local
	static

	global global1
	global global2 := "g2"
	global global3, global4 := "g4", global5
	global global6 := "g6", global7, global8 := "g8"
}
ForceLocalAndAssumeStatic()