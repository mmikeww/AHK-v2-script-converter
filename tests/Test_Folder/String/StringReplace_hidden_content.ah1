Str = AAA
SearchText = A
ReplaceText = Z
Options = All
StringReplace, Str, Str, %SearchText%, %ReplaceText%, %Options%
MsgBox %Str%