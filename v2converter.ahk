; =============================================================================
; Script Converter
;    for converting scripts from v1 AutoHotkey to v2
; Use:
;    Run the script
;    Chose the file you want to convert in the file select dialog
;    A msgbox will popup telling you the script finished converting
;   If you gave the file MyScript.ahk, the output file will be MyScript_new.ahk
;   Thats it, feel free to add to it and post changes here: http://www.autohotkey.com/forum/viewtopic.php?t=70266
; Uses format.ahk
; =============================================================================


; =============================================================================
; Main Part of program
;   Many changes can be made without altering this
; =============================================================================
if (A_Args.Length() = 0)
{
   FileSelect, FN,, %A_MyDocuments%
   If !FN
      ExitApp
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"
}
else If A_Args.Length() = 1 ; Allow a command line param for the file name ex. Run Convert.ahk "MyInputFile.ahk"
{
   FN := Trim(A_Args[1])
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"
}
else if Mod(A_Args.Length(), 2) = 0 ; Parse arguments with linux like syntax, ex. Run Convert.ahk --input "Inputfile.ahk" -o "OutputFile.ahk"
{
   for i, P in A_Args
   {
      If Mod(i,2) ; Odd parameter, identifier
      {
         If (P = "-o") || (P = "--output")
            Mode := 1
         else If (P = "-i") || (P = "--input")
            Mode := 2
         else
            Mode := 0
      }
      else if Mode != 0
      {
         If Mode = 1
            FNOut := Trim(P)
         else if Mode = 2
            FN := Trim(P)
      }
   }
}


If !FN
{
   Msgbox, 48, Conversion Error, The commandline parameters passed are invalid.  Please make sure they are correct and try again.  Now exiting.
   ExitApp
}
If !FNOut
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_new.ahk"

FileRead, script, %FN%
;msgbox %script%

outscript := Convert(script)
;msgbox outscript=`n%outscript%
;msgbox, A_FileEncoding=%A_FileEncoding%

outfile := FileOpen(FNOut, "w", "utf-8")
outfile.Write(outscript)
outfile.Close()

If !A_Args.Length()
   MsgBox, Done!`nNew file saved:`n`n%FNOut%

ExitApp


#include ConvertFuncs.ahk

