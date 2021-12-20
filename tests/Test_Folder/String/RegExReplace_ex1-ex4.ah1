MsgBox % RegExReplace("abc123123", "123$", "xyz")
MsgBox % RegExReplace("abc123", "i)^ABC")
MsgBox % RegExReplace("abcXYZ123", "abc(.*)123", "aaa$1zzz")
MsgBox % RegExReplace("abc123abc456", "abc\d+", "", ReplacementCount)
MsgBox % ReplacementCount
