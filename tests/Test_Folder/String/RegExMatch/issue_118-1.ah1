if RegExMatch(uri, "^\[url=")
    RegExMatch(uri, "\G[^\]]*", uri, 6)
else
{
    MsgBox 1,, URI appears invalid:`n%uri%
    IfMsgBox Cancel
        return
}
