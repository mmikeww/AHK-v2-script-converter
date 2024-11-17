A_MenuMaskKey := "vkFF"  ; vkFF is no mapping.
#UseHook
#Space::
!Space::
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    KeyWait("LWin")
    KeyWait("RWin")
    KeyWait("Alt")
    KeyHistory
return
} ; V1toV2: Added bracket in the end