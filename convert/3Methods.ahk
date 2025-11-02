#Requires AutoHotKey v2.0

/* a list of all renamed Methods, in this format:
  a method has the syntax object.method(Par1, Par2)
    , "OrigV1Method" ,
      "ReplacementV2Method"
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
  !!! we split the lists of Arrays and objects, as Count needs only to be replaced for maps
*/

; 2025-11-02 AMB, UPDATED - disabled case-sensitivity for map key
global gmAhkMethsToConvert := Map()
gmAhkMethsToConvert.CaseSense := 0
gmAhkMethsToConvert := OrderedMap(
    "Count()" ,
    "Count"
  , "HasKey(Key)" ,
    "Has({1})"
  , "length()" ,
    "Length"
  )
