var := DllCall("Func"
     , "Str", "ABC" ; Comment
     , "Str, "123"   ; Comment
     , "Str", "DEF") ;Comment

hCtrl := DllCall("CreateWindowEx"
      , "Uint", 0x200        ; WS_EX_CLIENTEDGE
      , "str",  "HiEdit"     ; ClassName
      , "str",  ""		     ; This line causes the issue
      , "Uint", WS_CLIPCHILDREN | WS_CHILD | WS_VISIBLE | hStyle
      , "int",  X            ; Left
      , "int",  Y            ; Top
      , "int",  W            ; Width
      , "int",  H            ; Height
      , "Uint", HParent      ; hWndParent
      , "Uint", MODULEID	 ; hMenu
      , "Uint", 0            ; hInstance
      , "Uint", 0, "Uint")