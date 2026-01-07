
cc.Sections := []

x := 0
w := 120
cc.Sections[ 1 ] := { Header: "Section 1" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) }  ;  V1toV2: Invalid Index errors?, try 'cc.Sections.Push(<val>)'
x += w + 3 
cc.Sections[ 2 ] := { Header: "Section 2" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) }  ;  V1toV2: Invalid Index errors?, try 'cc.Sections.Push(<val>)'
x += w + 3 
cc.Sections[ 3 ] := { Header: "Section 3" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) }  ;  V1toV2: Invalid Index errors?, try 'cc.Sections.Push(<val>)'
x += w + 3 
cc.Sections[ 4 ] := { Header: "Section 4" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) }  ;  V1toV2: Invalid Index errors?, try 'cc.Sections.Push(<val>)'
x += w + 3 
cc.Sections[ 5 ] := { Header: "Section 5" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) }  ;  V1toV2: Invalid Index errors?, try 'cc.Sections.Push(<val>)'


  While (RegExMatch(srcStr, "s)^.", &char))
  {
    srcStr := StrReplace(srcStr, (char&&char[0]), , , &cCnt)
    ascPos	:= Ord((char&&char[0]))
    if (ascPos>0 && ascPos<256)
      charObj[ascPos] := {Asc:ascPos
      ,(char&&char[0]):(char&&char[0]),Count:cCnt} ;  V1toV2: Invalid Index errors?, try 'charObj.Push(<val>)'
    else
      charObj[extIdx] := {Asc:ascPos
      ,(char&&char[0]):(char&&char[0]),Count:cCnt}, extIdx++ ;  V1toV2: Invalid Index errors?, try 'charObj.Push(<val>)'
    tCount += cCnt
    fCR		:= (fCR||(char&&char[0])="`r")
    fLF		:= (fLF||(char&&char[0])="`n")
    unique	.= (char&&char[0]) "`r"
  }