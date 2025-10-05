A_MenuMaskKey := "vkFF"  ; vkFF is no mapping.
#UseHook
#Space::
!Space::
{ ; V1toV2: Added opening brace for [!Space]
global ; V1toV2: Made function global
    KeyWait("LWin")
    KeyWait("RWin")
    KeyWait("Alt")
    KeyHistory
return
} ; V1toV2: Added closing brace for [!Space]