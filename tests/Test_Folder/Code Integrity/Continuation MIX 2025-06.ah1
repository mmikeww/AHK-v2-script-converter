
;################################################################################

; MAKE NO CHANGES TO THIS!

::text1::
(
Any text between the top and bottom parentheses is treated literally, including commas and percent signs.
By default, the hard carriage return (Enter) between the previous line and this one is also preserved.
    By default, the indentation (tab) to the left of this line is preserved.
)

;################################################################################

; MAKE NO CHANGES TO THIS BLOCK

str1 :=
(
"
[stranger_girl]
eyes=blue
hair=brown
height=5.2
weight=110

"
)
msgbox % "[" str1 "]"

;#####################################

; ONLY FIX (ESCAPE) DQs IN BLOCK

str2 :=
(
":XB0*:trigger::f(""replacement"", A_ThisHotkey, A_EndChar) ; Fixes 5 words
:XB0*:trigger::replacement ; Fixes 5 words
:*:trigger::replacement ; Fixes 5 words
::trigger::replacement
:*?:trigger::
::trigger::"
)
msgbox % "[" str2 "]"

;################################################################################


CmdlineOpt := "testing1"
helpforum := "testing2"

HelpText=
(join`r`n
%CmdlineOpt%This program allows you to load a CSV file (any delimited file)
and use various search criteria to filter the listview.
You can export the results to a new file.
The regular expression search is case sensitive and should be a
Perl-compatible regular expression (PCRE, www.pcre.org)
Note: an entire row of the "CSV" is searched at once and not
on a cell by cell basis to provide faster search results.

HelpText=%CmdlineOpt%

Press enter: Show row data in a message box
Press ctrl-c: Copy row data to clipboard

HelpText=%helpforum%
)

msgbox % HelpText

;################################################################################

var=TESTING

CmdlineOpt=
(

			%var% Command line options:
CSVQF file ["delimiter"] ["header"] ["Columns to use in CSV"]
%var% Example, opening a | delimited file:
CSVQF data.csv "|"

Use the first row as %var% header for listview: (header = 1,Y,Yes,T,True)
CSVQF data.csv "," "1"

Use \t for a tab delimited file %var%
CSVQF tabdata.txt "\t"

Only use specific columns (1 & 5):
CSVQF data.csv "," "0" "1,5" %var%

)

MsgBox % "[" CmdlineOpt "]"

;################################################################################

rawmapbg=
(
####################
##..##..##..##..#..#
#~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~#
#~~~~~~~~~~~~~~~~~~#
#::::::::::::::::::#
#::::::::::::::::::#
#_  _  _  _  _  _  #
#_  _  _  _  _  _  #
#_  _  _  _  _  _  #
#_  _  _  _  _  _  #
#                  #
#::::::::::::::::::#
#::::::::::::::::::#
####################
)

;################################################################################

theHaystack=
(
The Road Not Taken
BY ROBERT FROST
Two roads diverged in a yellow wood,
And sorry I could not travel both
And be one traveler, long I stood
And looked down one as far as I could
To where it bent in the undergrowth;
Then took the other, as just as fair,
And having perhaps the better claim,
Because it was grassy and wanted wear;
Though as for that the passing there
Had worn them really about the same,
And both that morning equally lay
In leaves no step had trodden black.
Oh, I kept the first for another day!
Yet knowing how way leads on to way,
I doubted if I should ever come back.
I shall be telling this with a sigh
Somewhere ages and ages hence:
Two roads diverged in a wood, and I
I took the one less traveled by,
And that has made all the difference.
)
msgbox %theHaystack%

;################################################################################

; FIX KEY NAMES IN OBJECT
; still have a lot more that needs to be done with object keynames
;	but this is a start

points := {Administrator  :  3
	, CEO                 :  8
	, Coordinator         :  3
	, Director            : 10
	, Europe              : 20
	, Global              : 15
	, Hiring              : 10
	, HR-Rep              :  5
	, International       : 15
	, Manager             : 20
	, Outsourcing         :  5
	, Recruiting          : 10
	, Recruitment         : 10
	, Senior VP           :  5
	, "Talent Acquisition": 10}

msgbox % points.CEO

;################################################################################

SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
   ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
   ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
   ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

;################################################################################

user := "defaultuser0"
script =
(
	document.querySelector('#userId').value = '%user%'
)
MsgBox % script

;#####################################

var =
   (
   hello world
   )

;##########################################################################

	FileAppend,
	( LTrim
		hWinEventHook: %hWinEventHook%
		hwnd:           %hwnd%
		idObject:       %idObject%
		idChild:        %idChild%
		dwEventThread: %dwEventThread%
		dwmsEventTime: %dwmsEventTime%`n`n
	), test.txt

;#####################################

var = i am a var
FileAppend,
(
A line of text.
By default, the hard carriage return (Enter) between the previous line and this one will be written to the file.
    This line is indented with a tab; by default, that tab will also be written to the file.
Variable references such as %Var% are expanded by default.
), %A_Desktop%\My File.txt


;#####################################

FileAppend,  ; The comma is required in this case.
(
open host.domain.com
username
password
binary
cd htdocs
put %VarContainingNameOfTargetFile%
delete SomeOtherFile.htm
rename OldFileName.htm NewFileName.htm
ls -l
quit
), %FTPCommandFile%

;##########################################################################

a := 1, b := 2, c := 3, d := 4
MsgBox,
(
Test
  a: %a%
  b: %b%

Test
  c: %c%
  d: %d%
)

;#####################################

title := "GREETINGS"
var1=Hello
var2=Goodbye
secs := 4
MsgBox, 1, % title,
(
%var1% World!
%var2% for now!
leaving in... %secs% secs
), %secs%

;#####################################

; 2nd physical line will preserve leading horz ws here
MsgBox,
(
		
		Second physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

MsgBox % "
(
		First physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is ALSO preserved
)"

;#####################################

MsgBox % MyFunction("
(
echo Put your commands here,
echo each one will be run,
echo and you'll get the output.
)")

;#####################################

; ENSURE PARAMS ARE ARRANGED CORRECTLY
; MAKE SURE FIRST (EMPTY) LINE IS PRESERVED IN OUTPUT
; PRESERVE BLOCK and LINE COMMENTS, FORMATTING, SPACING
; ENSURE EXTRA () DO NOT INTERFERE WITH CONTINUATION BLOCK DETECTION
; KEEP VAR SEPARATE FROM TEXT IN BLOCK
; MAKE SURE BLOCK OPTIONS WORK CORRECTLY (trim and comments)
; MAKE SURE TIMER WORKS using a variable (case insensitive)


title = complex MB
Line45=`nLine 4 and 5
TO=4
MsgBox, 1, % title ,	; comment 1 ; additional comment
/*
should support block comments OR (comment2)
*/
; line comments between command line and opening ( (comment3)
(c ltrim  ; comment 4

	Line2	; comment 5
	Line3
	%Line45%	; comment 6
	Line6
), %to%	; comment 7

;#####################################

Lines34 =		; comment 1
(c

line 3			; comment 2
line 4
)				; comment 3
msgbox,			; comment 4
(c
	Line1		; comment 5
	%Lines34%	; comment 6
)

;#####################################

IfEqual, var, val, MsgBox, 1, title,
(
		First physical line - leading HORZ WS NOT preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

IfEqual, var, val, MsgBox, 1, title,
(
		
		Second physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

IfEqual, var, val, MsgBox, 1, title, % "
(
		First physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is ALSO preserved
)", 4

