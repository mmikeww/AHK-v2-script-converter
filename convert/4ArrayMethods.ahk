#Requires AutoHotKey v2.0-beta.1

/* a list of all renamed Array Methods, in this format:
  a method has the syntax Array.method(Par1, Par2)
    , "OrigV1Method" ,
      "ReplacementV2Method"
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
*/

global ArrayMethodsToConvertM := OrderedMap(
    "length()" ,
    "Length"
  , "HasKey(Key)" ,
    "Has({1})"
  )
