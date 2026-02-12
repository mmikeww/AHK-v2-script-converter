Gui, Add, DDL,, A|B

  |C|D ; this comment will be removed

  /*
           block comment between fragments
  */

  |E||F ; removed also

MsgBox, Line 1

Gui, Add, DDL,, A|B
; line comment before fragments
|C|D
; line comment between fragments
|E|F||
; line comment after fragments

MsgBox, Line 2

Gui, Show