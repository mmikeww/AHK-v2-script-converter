Loop Files, "Yunit\*.*"
{
   FileAppend(A_LoopFilePath "`n" A_LoopFileFullPath, "*")
   break
}