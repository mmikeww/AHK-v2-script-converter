MyVar := "5,3,7,9,1,13,999,-4"
MyVar := Sort(MyVar, "N D,")  ; Sort numerically, use comma as delimiter.
FileAppend(MyVar, "*")