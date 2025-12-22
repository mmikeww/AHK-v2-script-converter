; MinIndex and MaxIndex test
; Please read these comments if you work on this, as they provide useful notes
; See also #178

Array1 := [1, 2, 3] ; Standard Array (both pass)

MsgBox(((Array1.Length) ? 1 : 0)) ; V1: 1	V2: 1 ; V1toV2: Verify V2 value matches V1 MinIndex
MsgBox(Array1.Length) ; V1: 3	V2: 3 ; V1toV2: Verify V2 Length value = V1 MaxIndex

Array2 := [ , , "A", "B", "C"] ; Array with blank starting elements (Min fails, Max passes)

MsgBox(((Array2.Length) ? 1 : 0)) ; V1: 3	V2: 1 ; V1toV2: Verify V2 value matches V1 MinIndex
MsgBox(Array2.Length) ; V1: 5	V2: 5 ; V1toV2: Verify V2 Length value = V1 MaxIndex

; The following array is not valid in v1, so MaxIndex does not experience the same issue as MinIndex
; Array3 := ["A", "B", "C", , ]

; Objects:

; Objects have not been converted in any way
; This is because they are too different from v1 to have a (mostly) bug-free conversion
; For an alternative fix see #178