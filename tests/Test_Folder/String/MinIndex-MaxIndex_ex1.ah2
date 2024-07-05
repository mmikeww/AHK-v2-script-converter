; MinIndex and MaxIndex test
; Please read these comments if you work on this, as they provide useful notes
; See also #178

Array1 := [1, 2, 3] ; Standard Array (both pass)

MsgBox(Array1.Length != 0 ? 1 : "") ; V1: 1	V2: 1 ; V1toV2: Not perfect fix, fails on cases like [ , "Should return 2"]
MsgBox(Array1.Length != 0 ? Array1.Length : "") ; V1: 3	V2: 3

Array2 := [ , , "A", "B", "C"] ; Array with blank starting elements (Min fails, Max passes)

MsgBox(Array2.Length != 0 ? 1 : "") ; V1: 3	V2: 1 ; V1toV2: Not perfect fix, fails on cases like [ , "Should return 2"]
MsgBox(Array2.Length != 0 ? Array2.Length : "") ; V1: 5	V2: 5

; The following array is not valid in v1, so MaxIndex does not experience the same issue as MinIndex
; Array3 := ["A", "B", "C", , ]

; Objects:

; Objects have not been converted in any way
; This is because they are too different from v1 to have a (mostly) bug-free conversion
; For an alternative fix see #178