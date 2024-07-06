#Requires AutoHotKey v2.0

/* a list of all renamed variables, in this format:
    , "OrigVar" ,
      "ReplacementVar"
    ↑ first comma is not needed for the first pair
  important: the order matters. the first 2 in the list could cause a mistake if not ordered properly
*/

; 2024-04-08, andymbody
;   Moved LoopReg keywords to a dedicated map
;   ... so they can be treated differently
global gmAhkKeywdsToRename := OrderedMap(
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
  , "A_BatchLines" ,
    "-1"
  , "A_NumBatchLines" ,
    "-1"
  , "A_IPAddress1" ,
    "SysGetIPAddresses()[1]"
  , "A_IPAddress2" ,
    "SysGetIPAddresses()[2]"
  , "A_IPAddress3" ,
    "SysGetIPAddresses()[3]"
  , "A_IPAddress4" ,
    "SysGetIPAddresses()[4]"
  )

; 2024-04-08, andymbody
;   Separated these from gmAhkKeywdsToRename
;   ... so they can be treated differently
global gmAhkLoopRegKeywds := OrderedMap(
    "A_LoopRegKey `"\`" A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "A_LoopRegKey . `"\`" . A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "%A_LoopRegKey%\%A_LoopRegSubKey%" ,
    "%A_LoopRegKey%"
  )
