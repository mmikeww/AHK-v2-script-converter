; Turn off CapsLock
return ; V1toV2: remove if unnecessary
CapsLock::SetCapsLockState("AlwaysOff")

; Turn on CapsLock
CapsLock & Tab::SetCapsLockState("AlwaysOn")