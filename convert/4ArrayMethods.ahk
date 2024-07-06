#Requires AutoHotKey v2.0

/* a list of all renamed Array Methods, in this format:
  a method has the syntax Array.method(Par1, Par2)
    , "OrigV1Method" ,
      "ReplacementV2Method"
    ↑ first comma is not needed for the first pair
  Similar to commands, parameters can be added
*/

global gmAhkArrMethsToConvert := OrderedMap(
    "length()" ,
    "Length"
  , "HasKey(Key)" ,
    "Has({1})"
  , "Insert(Keys*)",
    "*_InsertAt"
  , "Remove(Keys*)",
    "*_RemoveAt"
  , "MaxIndex()" ,
    Chr(1000) "MaxIndex(placeholder)" Chr(1000)
  , "MinIndex()" ,
    Chr(1000) "MinIndex(placeholder)" Chr(1000)
  )

_InsertAt(p) {
  if (p.Length = 1) {
    Return "Push(" p[1] ")"
  } else if (p.Length > 1 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"'))) {
    for i, v in p {
      val .= ", " v
    }
    Return "InsertAt(" LTrim(val, ", ") ")"

  }
}

_RemoveAt(p) {
  if (p.Length = 1 && p[1] = "") { ; Arr.Remove()
    Return "Pop()"
  } else if (p.Length = 1 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"'))) { ; Arr.Remove(n)
    Return "RemoveAt(" p[1] ")"
  } else if (p.Length = 2 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"')) && (IsDigit(p[2]) || p[2] = Trim(p[2], '"'))) { ; Arr.Remove(n, n)
    Return "RemoveAt(" p[1] ", " p[2] " - " p[1] " + 1)"
  } else if (p.Length = 2 && (IsDigit(p[1]) || p[1] = Trim(p[1], '"')) && p[2] = "`"`"") { ; Arr.Remove(n, "")
    Return "Delete(" p[1] ")"
  } else {
    params := ""
    for , param in p
      params .= param ", "
    Return "Delete(" RTrim(params, ", ") ") `; V1toV2: Check Object.Remove in v1 docs to see which one matches"
  }
}