#Requires AutoHotKey v2.0

; 2025-12-24 AMB, MOVED Dynamic Conversion Funcs to AhkLangConv.ahk
/* a list of all renamed Array Methods, in this format:
  a method has the syntax Array.method(Par1, Par2)
    , "OrigV1Method" ,
      "ReplacementV2Method"     (see AhkLangConv.ahk)
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
*/

; 2025-10-05 AMB, UPDATED - changed source of mask chars
; 2025-11-28 AMB, UPDATED - changed to Case-Insensitive Map
; 2025-12-24 AMB, UPDATED - re-ordered Map Keys (method names) to alphabetic
global gmAhkArrMethsToConvert := Map_I()
gmAhkArrMethsToConvert := OrderedMap(
    "HasKey(Key)" ,
      "Has({1})"
  , "Insert(Keys*)" ,
      "*_InsertAt"
  , "Length()" ,
      "Length"
  , "MaxIndex()" ,
      gMXPH              ; see MaskCode.ahk
  , "MinIndex()" ,
      gMNPH              ; see MaskCode.ahk
  , "Remove(Keys*)" ,
      "*_RemoveAt"
)