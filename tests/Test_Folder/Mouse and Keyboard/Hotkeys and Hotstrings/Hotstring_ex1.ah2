Hotstring(":*X:]d", DatePaste)
Return

DatePaste(*)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
  Send(A_DD "-" A_MM "-" A_YYYY)
Return
} ; V1toV2: Added bracket in the end