#Requires AutoHotkey v2.0-beta.1
#SingleInstance Force
; =============================================================================
; Script Converter
;    for converting scripts from v1 AutoHotkey to v2
;
;    Requires AHK v2 to run this script
;
; Use:
;    Run the script
;    Chose the file you want to convert in the file select dialog
;    A msgbox will popup telling you the script finished converting
;   If you gave the file MyScript.ahk, the output file will be MyScript_v2new.ahk
;   Thats it, feel free to add to it and post changes here: http://www.autohotkey.com/forum/viewtopic.php?t=70266
; Uses format.ahk
; =============================================================================

global dbg:=0
#Include lib/ClassOrderedMap.ahk

#Include Convert/1Commands.ahk
#Include Convert/2Functions.ahk
#Include Convert/3Methods.ahk
#Include Convert/4ArrayMethods.ahk
#Include Convert/5Keywords.ahk
; =============================================================================
; Main Part of program
;   Many changes can be made without altering this
; =============================================================================
if (A_Args.Length = 0)
{
   FN := FileSelect("", A_ScriptDir, "Choose an AHK v1 file to convert to v2")
   If !FN
      ExitApp
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_v2new.ahk"
   ;msgbox, %FN%`n%FNOut%
}
else If A_Args.Length = 1 ; Allow a command line param for the file name ex. Run Convert.ahk "MyInputFile.ahk"
{
   FN := Trim(A_Args[1])
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "_v2new.ahk"
}
else if Mod(A_Args.Length, 2) = 0 ; Parse arguments with linux like syntax, ex. Run Convert.ahk --input "Inputfile.ahk" -o "OutputFile.ahk"
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
   MsgBox("The commandline parameters passed are invalid.  Please make sure they are correct and try again.  Now exiting.","Conversion Error", 48)
   ExitApp
}
If !FNOut
   FNOut := SubStr(FN, 1, StrLen(FN)-4) . "v2_new.ahk"

script := FileRead(FN)
;msgbox %script%

outscript := Convert(script)
;msgbox outscript=`n%outscript%
;msgbox, A_FileEncoding=%A_FileEncoding%

outfile := FileOpen(FNOut, "w", "utf-8")
outfile.Write(outscript)
outfile.Close()

If !A_Args.Length
{
   result := MsgBox("Conversion complete. New file saved:`n`n" FNOut "`n`nWould you like to see the changes made?", "", 68)
   if (result = "Yes")
      Run("diff\VisualDiff.exe diff\VisualDiff.ahk `"" . FN . "`" `"" . FNOut . "`"")
}
ExitApp


#include ConvertFuncs.ahk

