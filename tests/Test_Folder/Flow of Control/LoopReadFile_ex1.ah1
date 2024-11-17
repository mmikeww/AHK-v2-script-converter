;FileDelete, C:\Docs\Family Addresses.txt

Loop, read, C:\Docs\Address List.txt, C:\Docs\Family Addresses.txt
{
    if InStr(A_LoopReadLine, "family")
        FileAppend, %A_LoopReadLine%`n
}