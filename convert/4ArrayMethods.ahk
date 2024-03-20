#Requires AutoHotKey v2.0

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
  , "Insert(Keys*)",
    "*_InsertAt"
  , "Remove(Keys*)",
    "*_RemoveAt"
  )

_InsertAt(p) {
  if (p.Length = 1) {
    Return "Push(" p[1] ")"
  } else if (p.Length > 1 && IsDigit(p[1])) {
    for i, v in p {
      val .= ", " v
    }
    Return "InsertAt(" LTrim(val, ", ") ")"

  }
}

_RemoveAt(p) { ; TODO: handle Vars
  if (p.Length = 1 && p[1] = "") { ; Arr.Remove()
    Return "Pop()"
  } else if (p.Length = 1 && IsDigit(p[1])) { ; Arr.Remove(n)
    Return "RemoveAt(" p[1] ")"
  } else if (p.Length = 2 && IsDigit(p[1]) && IsDigit(p[2])) { ; Arr.Remove(n, n)
    Return "RemoveAt(" p[1] ", " p[2] " - " p[1] " + 1)"
  } else if (p.Length = 2 && IsDigit(p[1]) && p[2] = "`"`"") { ; Arr.Remove(n, "")
    Return "Delete(" p[1] ")"
  } else {
    Return "Pop()" ; TODO: Pop is placeholder, need better fix
  }
}