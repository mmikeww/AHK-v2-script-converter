if (RegExMatch("abc|123", "^(?<Prefix>[^|]*)\|(?<Suffix>[^|]*)$", Match))
	MsgBox % MatchPrefix "`n" MatchSuffix
if (RegExMatch("abc|123", "^(?<a1>[^|]*)\|(?<2b>[^|]*)$", Match))
	MsgBox % Matcha1 "`n" Match2b