Loop, Files, Yunit\*.*
{
   FileAppend, %A_LoopFileFullPath%`n%A_LoopFileLongPath%, *
   break
}