#Requires AutoHotKey v2.0

/* a list of all renamed variables, in this format:
    , "OrigVar" ,
      "ReplacementVar"
    ↑ first comma is not needed for the first pair
  important: the order matters. the first 2 in the list could cause a mistake if not ordered properly
*/

global KeywordsToRenameM := OrderedMap(
    "A_LoopFileFullPath" ,
    "A_LoopFilePath"
  , "A_LoopFileLongPath" ,
    "A_LoopFileFullPath"
  , "ComSpec" ,
    "A_ComSpec"
  , "Clipboard" ,
    "A_Clipboard"
  , "ClipboardAll" ,
    "ClipboardAll()"
  , "ComObjParameter()" ,
    "ComObject()"
  , "A_isUnicode" ,
    "1"
  , "A_LoopRegKey `"\`" A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "A_LoopRegKey . `"\`" . A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "%A_LoopRegKey%\%A_LoopRegSubKey%" ,
    "%A_LoopRegKey%"
  , "A_BatchLines" , 
    "-1"
  , "A_NumBatchLines" , 
    "-1"
  )
