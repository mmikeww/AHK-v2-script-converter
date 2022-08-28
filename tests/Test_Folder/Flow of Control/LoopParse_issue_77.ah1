prefix := "dyn"
dyn_dynamic = a,b

Loop, parse, dyn_dynamic, `,
    Msgbox % A_LoopField

Loop, parse, %prefix%_dynamic, `,
    Msgbox %A_LoopField%

Loop, parse, % %prefix%_dynamic, `,
    Msgbox % A_LoopField
