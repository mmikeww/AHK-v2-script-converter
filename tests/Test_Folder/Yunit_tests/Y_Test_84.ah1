if (1) {
   var = val
   if var = hello
		ToolTip, this line starts with 2 tab characters
   else {
      ifequal, var, val
         StringGetPos, pos, var, al
   }
}
FileAppend, pos=%pos%, *