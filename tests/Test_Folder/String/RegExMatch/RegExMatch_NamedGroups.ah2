if (RegExMatch("abc|123", "^(?<Prefix>[^|]*)\|(?<Suffix>[^|]*)$", &Match))
	MsgBox(Match["Prefix"] "`n" Match["Suffix"])
if (RegExMatch("abc|123", "^(?<a1>[^|]*)\|(?<2b>[^|]*)$", &Match))
	MsgBox(Match["a1"] "`n" Match["2b"])