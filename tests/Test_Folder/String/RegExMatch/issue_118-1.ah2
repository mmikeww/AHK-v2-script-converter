if RegExMatch(uri, "^\[url=")
    RegExMatch(uri, "\G[^\]]*", &uri, 6)
else
{
    msgResult := MsgBox("URI appears invalid:`n" (uri && uri[0]), "", 1)
    if (msgResult = "Cancel")
        return
}
