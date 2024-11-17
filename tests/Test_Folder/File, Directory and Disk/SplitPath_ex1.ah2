FullFileName := "C:\My Documents\Address List.txt"
   
; To fetch only the bare filename from the above:
SplitPath(FullFileName, &name)

; To fetch only its directory:
SplitPath(FullFileName, , &dir)

; To fetch all info:
SplitPath(FullFileName, &name, &dir, &ext, &name_no_ext, &drive)
   
; The above will set the variables as follows:
; name = Address List.txt
; dir = C:\My Documents
; ext = txt
; name_no_ext = Address List
; drive = C:
MsgBox("name:`t" Name "`ndir:`t" Dir "`next:`t" Ext "`nname_no_ext:`t" name_no_ext "`ndrive:`t" Drive)