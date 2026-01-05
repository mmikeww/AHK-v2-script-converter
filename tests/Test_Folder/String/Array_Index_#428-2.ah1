
cc.Sections := []

x := 0
w := 120
cc.Sections[ 1 ] := { Header: "Section 1" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 2 ] := { Header: "Section 2" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 3 ] := { Header: "Section 3" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 4 ] := { Header: "Section 4" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 5 ] := { Header: "Section 5" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 


  While (RegExMatch(srcStr, "s)^.", char))
  {
    srcStr := StrReplace(srcStr, char, , cCnt)
    ascPos	:= asc(char)
    if (ascPos>0 && ascPos<256)
      charObj[ascPos] := {"Asc":ascPos
      ,"Char":char,"Count":cCnt}
    else
      charObj[extIdx] := {"Asc":ascPos
      ,"Char":char,"Count":cCnt}, extIdx++
    tCount += cCnt
    fCR		:= (fCR||char="`r")
    fLF		:= (fLF||char="`n")
    unique	.= char "`r"
  }