{ ;FILE_NAME  My_v2converter.ahk - v2 -
; Language:       English
; Platform:       Windows11
; Author:         guest3456
; Update to v2converter.ahk (DrReflex)
; Script Function: AHK version 1 to version 2 converter
;
; Use:
;       Run the script.  Accepts arguments
;         Formats:  1. My_v2converter.ahk with parameter 1 set to "MyV1ScriptFullPath.ahk" (quotes required)
;                   2. My_v2conterter.ahk with parameter 1 set to
;       Chose the file you want to convert in the file select dialog
;       A msgbox will popup telling you the script finished converting
;       If you gave the file MyScript.ahk, the output file will be MyScript_v2new.ahk
;
; Uses format.ahk
; =============================================================================
; OTHER THINGS TO ADD:
;
}
{ ;REFERENCES:
  ; Feel free to add to this program.  Post changes here: http://www.autohotkey.com/forum/viewtopic.php?t=70266
}
{ ;DIRECTIVES AND SETTINGS
   #Requires AutoHotkey >=2.0-<2.1  ; Requires AHK v2 to run this script
   #SingleInstance Force			      ; Recommended so only one copy is runnnig at a time
   SendMode "Input"  				        ; Recommended for new scripts due to its superior speed and reliability.
   SetWorkingDir A_ScriptDir  	    ; Ensures a consistent starting directory.
}
{ ;CLASSES:
}
{ ;VARIABLES:
   global dbg:=0
}
{ ;INCLUDES:
   #Include lib/ClassOrderedMap.ahk
   #Include Convert/1Commands.ahk
   #Include Convert/2Functions.ahk
   #Include Convert/3Methods.ahk
   #Include Convert/4ArrayMethods.ahk
   #Include Convert/5Keywords.ahk
}
{ ;MAIN PROGRAM - BEGINS HERE *****************************************************************************************
;   Many changes can be made here to affect loading and processing
; =============================================================================
   MyOutExt  := "_newV2.ahk"    ;***ADDED OUTPUT EXTENSION OPTION***
   ;MyOutExt := ".c2v2.ahk"     ;***THIS IS THE OUTPUT EXTENSION OPTION THAT I USE***
   ;NOTES: 1. When I have a coverted 2 version 2 file ("FILENAME.c2v2.ahk") working, 
   ;          I change the name to "FILENAME.v2.ahk".  
   ;       2. I use the format "FILENAME.v2.ahk" for all v2 scripts and "FILNAME.v1.ahk" for all v1.1 scripts.  
   ;          This lets me distinguish the files at a glance.  
   ;       3. When I batch inserted #Requires AutoHotkey 64-bit into my v1.1 files I renamed them to ".v1.ahk" and 
   ;          when I batch inserted #Requires AutoHotkey >=2.0- <2.1 into my v2 files I renamed them to ".v2.ahk"
   ;       4. For new scripts I have SciTE4AHK abbreviations rv1=... and rv2 =... that I insert into the directives 

   FN    := ""
   FNOut := ""

   ;USE SWITCH CASE TO DEAL WITH COMMAND LINE ARGUMENTS
   switch A_Args.Length
   {
      case 0:  ;IF NO ARGUMENTS THEN LOOK UP SOURCE FILE AND USE DEFAULT OUTPUT FILE
      {
         FN := FileSelect("", A_ScriptDir, "Choose an AHK v1 file to convert to v2")
      }
      case 1: ;IF ONE ARGUMENT THEN ASSUME THE ARUGMENT IS THE SOURCE FILE (FN) AND USE DEFAULT OUTPUT FILE
      {
         FN := A_Args[1]
      }
      case 2: ;IF ONLY TWO ARGUMENTS THEN IF A_Args[1] IS NOT input THEN ERROR
      {       ;ELSE A_Args[2] IS FN
         if (A_Args[1] = "-i" || A_Args[1] = "--input")
            FN := A_Args[2]
      }
      case 4:
      {  ;IF A_Args[1] IS input AND A_Args[3] IS output
         ; THEN A_Args[2] IS FN AND A_Args[4] IS FNOut
         if ((A_Args[1] = "-i" || A_Args[1] = "--input") && (A_Args[3] = "-o" || A_Args[3] = "--output"))
         {
            FN    := A_Args[2]
            FNOut := A_Args[4]
         } else
         {
            ;IF A_Args[1] IS output AND A_Args[3] IS input
            ;   THEN A_Args[2] IS FNOut AND A_Args[4] IS FN
            if ((A_Args[1] = "-o" || A_Args[1] = "--output") && (A_Args[3] = "-i" || A_Args[3] = "--input"))
            {
               FN    := A_Args[4]
               FNOut := A_Args[2]
            }
         }
      }
   }

   FN    := Trim(FN)
   FNOut := Trim(FNOut)

   If !FN
   {
      if A_Args.Length > 0 {
         MyMgs := ""
         For args in A_Args
         {
            MyMsg .= "A_Args[" . A_Index . "]:" . A_Args[A_Index] . "`n`n"
         }
         MyMsg := "At least one of the above passed commandline parameters is invalid.`n"
         MyMsg .= "  Please make sure the parameters are correct and try again.`n"
         MyMsg .= "  Will exit due to parameter error: Error 48"
      } else {  ;IF _A_Args.Length = 0
         MyMsg := "No source file specified.`n"
         MyMsg .= "  Will exit due to lack of source file: Error AA.`n"
      }
      MsgBox MyMsg
      ExitApp
   }

   If !FNOut
   {
      FNOut := SubStr(FN, 1, StrLen(FN)-4) . MyOutExt   ;***USE OUTPUT EXTENSION OPTION***
   }

   if (!FileExist(FN))
   {
      MyMsg := "Source source file not found.`n"
      MyMsg .= "  Will exit because source file was not found. Error BB`n"
      MsgBox MyMsg
      ExitApp
   }
   inscript := FileRead(FN)
   outscript := Convert(inscript)
   outfile   := FileOpen(FNOut, "w", "utf-8")
   outfile.Write(outscript)
   outfile.Close()

   MyMsg := "Conversion complete.`n"
   MyMsg .= "  New file saved as: " . FNOut . "`n`n"
   MyMsg .= "    Would you like to see the changes made?"
   result := MsgBox(MyMsg,"", 68)
   if (result = "Yes") {
         Run("diff\VisualDiff.exe diff\VisualDiff.ahk `"" . FN . "`" `"" . FNOut . "`"")
   }
   ExitApp
} ;MAIN PROGRAM - ENDS HERE *******************************************************************************************
;######################################################################################################################
;##### FUNCTIONS(): #####
;######################################################################################################################
#include ConvertFuncs.ahk
;######################################################################################################################
;##### HOTKEYS: #####
;######################################################################################################################
; EXIT APPLICATION; EXIT APPLICATION; EXIT APPLICATION
Esc::
{ ;Exit application - Using either <Esc> Hotkey or Goto("MyExit")
   ExitApp
   Return
}
