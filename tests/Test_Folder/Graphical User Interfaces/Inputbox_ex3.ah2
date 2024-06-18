IB := InputBox("Test::", "::Test::Test"), Test := IB.Value

IB := InputBox("Provide the corrected word on the right side. You can also edit the left side if you wish.`n`nExample entry:`n::teh::the", "New Hotstring", , "::" Hotstring "::" Hotstring), Hotstring := IB.Value