fn := StrLen
MsgBox(fn.Name "() is " (fn.IsBuiltIn ? "built-in." : "user-defined."))