; Access the registry as a 32-bit application would.
SetRegView(32)
RegWrite(123, "REG_SZ", "HKLM\SOFTWARE\Test.ahk", "Value")

; Access the registry as a 64-bit application would.
SetRegView(64)
value := RegRead("HKLM\SOFTWARE\Wow6432Node\Test.ahk", "Value")
RegDelete("HKLM\SOFTWARE\Wow6432Node\Test.ahk")

MsgBox("Read value '" value "' via Wow6432Node.")

; Restore the registry view to the default, which
; depends on whether the script is 32-bit or 64-bit.
SetRegView("Default")