; This example also demonstrates one way to implement case conformity in a script.
:C:BTW::  ; Typed in all-caps.
:C:Btw::  ; Typed with only the first letter upper-case.
: :btw::  ; Typed in any other combination.
    case_conform_btw() {
        hs := A_ThisHotkey  ; For convenience and in case we're interrupted.
        if (hs == ":C:BTW")
            Send BY THE WAY
        else if (hs == ":C:Btw")
            Send By the way
        else
            Send by the way
    }