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
  , "A_BatchLines" ,
    "-1"
  , "A_NumBatchLines" ,
    "-1"
; moved to a dedicated map
;  , "A_LoopRegKey `"\`" A_LoopRegSubKey" ,
;    "A_LoopRegKey"
;  , "A_LoopRegKey . `"\`" . A_LoopRegSubKey" ,
;    "A_LoopRegKey"
;  , "%A_LoopRegKey%\%A_LoopRegSubKey%" ,
;    "%A_LoopRegKey%"
  )

; 2024-04-08, andymbody
;   Separated these from KeywordsToRenameM
;   ... so they can be treated differently
global LoopRegKeywords := OrderedMap(
    "A_LoopRegKey `"\`" A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "A_LoopRegKey . `"\`" . A_LoopRegSubKey" ,
    "A_LoopRegKey"
  , "%A_LoopRegKey%\%A_LoopRegSubKey%" ,
    "%A_LoopRegKey%"
  )
