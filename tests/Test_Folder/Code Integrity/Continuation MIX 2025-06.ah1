
    FileAppend,
    ( LTrim
        hWinEventHook: %hWinEventHook%
        hwnd:           %hwnd%
        idObject:       %idObject%
        idChild:        %idChild%
        dwEventThread: %dwEventThread%
        dwmsEventTime: %dwmsEventTime%`n`n
    ), test.txt

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


	HelpPage() {
	HelpPage=
	(
	{\rtf1\ansi\ansicpg1252\deff0\nouicompat\deflang1033{\fonttbl{\f0\fnil\fcharset0 Arial;}{\f1\fnil\fcharset0 Consolas;}}
	{\colortbl ;\red255\green0\blue0;\red155\green0\blue211;\red0\green77\blue187;\red0\green176\blue80;\red0\green0\blue255;}
	{\*\generator Riched20 10.0.19041}\viewkind4\uc1
	\pard\sa200\sl276\slmult1\b\fs36\lang9 H e l p _ P a g e\b0\par
	\par
	\cf1\b F1\cf0\b0  - to toggle this help page\par
	\par
	\b Basic syntax by example:\b0\par

	\pard\li720\sa200\sl276\slmult1 coexisting words/strings/patterns -unwanted\par
	for instance, \cf2\b\f1 d.*d -the and -oo \\ws\cf0\b0\f0\par
	(the 5 segments (space separated) above can go all at once, and yet, they can also be entered one by one. that's the so-called multilevel approach, instead.)\par

	\pard\sa200\sl276\slmult1\par
	\b Feature keys:\b0\par

	\pard\li720\sa200\sl276\slmult1\cf3\b Alt+a\cf0\b0  - to show assorted matches and toggle between chronological and alphabetical order.\par
	\cf3\b Ctrl+t\cf0\b0  - to put assorted matches into a treeview gui which may ease the exploration when the list is long and involved multiple groups.\par
	\cf3\b Ctrl+p\cf0\b0  - to bring up context peeking gui which provides an integrated way of reviewing the context of any lines in the shortlisted result.\par
	\cf3\b WheelDown\cf0\b0  - to find the next match (downward) from the caret position (given that, the mouse pointer is currently outside both text/edit boxes.)\par
	\cf3\b WheelUp\cf0\b0  - to find the next match (upward) from the caret position (given that, the mouse pointer is currently outside both text/edit boxes.)\par
	\cf3\b Alt+v\cf0\b0  - to paste clipboard content into the big text/edit box.\par
	\cf3\b Ctrl+o\cf0\b0  - to open a file.\par
	\cf3\b Ctrl+r\cf0\b0  - to reload the file.\par
	\cf3\b Rightclick\cf0\b0  "Back" button - to glance committed levels and select one to fall back to.\par
	\cf3\b Esc\cf0\b0  - to quit/exit/leave. same as closing the window.\par
	\cf3\b Tab\cf0\b0  - to change focus between the text/edit boxes (just try it.)\par
	\par
	these below only work when the \ul big\ulnone  text/edit box is in focus:\par

	\pard\li1440\sa200\sl276\slmult1\cf3\b f\cf0\b0  - to find the next match (downward) from the caret position.\par
	\cf3\b Shift+f\cf0\b0  - to find the next match (upward) from the caret position.\par
	\i (note: "the line" refers to the current line, that's where the caret is on.)\i0\par
	\cf3\b Doubleclick\cf0\b0  - to copy the line/selection.\par
	\cf3\b Enter\cf0\b0  - to copy the line/selection.\par
	\cf3\b Space\cf0\b0  - to page down\par
	\cf3\b Shift+Space\cf0\b0  - to page up\par
	\cf3\b s\cf0\b0  - to move the caret to the beginning/start of the line.\par
	\cf3\b e\cf0\b0  - to move the caret to the end of the line.\par
	\cf3\b t\cf0\b0  - to move the caret to the top of the text.\par
	\cf3\b b\cf0\b0  - to move the caret to the bottom of the text.\par
	\cf3\b + or =\cf0\b0  - to increase font size (same as \cf3\b Ctrl+WheelUp\cf0\b0 ).\par
	\cf3\b minus "-"\cf0\b0  - to decrease font size (same as \cf3\b Ctrl+WheelDown\cf0\b0 ).\par
	\i (side note: "caret" may be known as "cursor" to some people.)\i0\par

	\pard\sa200\sl276\slmult1\par
	\tab these below only work when the \ul small\ulnone  text/edit box is in focus:\par

	\pard\li1440\sa200\sl276\slmult1\cf3\b Enter\cf0\b0  - to commit a level (which makes the current result becoming the base/source of the next level.) same as clicking the button Go.\par

	\pard\sa200\sl276\slmult1\par

	\pard\li720\sa200\sl276\slmult1\cf3\b Backtick (``)\cf0\b0  - since users mostly use this tool to locate the specific line of text and copy it for whatever subsequent actions to be taken, which typically involves Tab and then Enter (if the first line is the one wanted), backtick is an alternative which can supersede both keys by just hit backtick twice instead.\par

	\pard\sa200\sl276\slmult1\par
	The \b improvised shorthand\b0  feature:\par

	\pard\li720\sa200\sl276\slmult1 this feature can be triggered through "\cf2\b\\/\cf0\b0 " (a \b backslash\b0  followed by a \b slash\b0 ), a "regex like" syntax style, which toggle it on or off. so, enter "\cf2\b\\/tr\cf0\b0 " will bring you those lines contained "\cf4\i the road\cf0\i0 ", "\cf4\i two roads\cf0\i0 ", as well as "\cf4\i them really\cf0\i0 " out of the poem, whereas enter "\cf2\b oo \\/a?a\cf0\b0 " or "\cf2\b\\/a?a\\/ oo\cf0\b0 " will return you these two lines "\cf4\i And looked down one as far as I could\cf0\i0 " and "\cf4\i Then took the other, as just as fair,\cf0\i0 " in which, the "\cf2\b ?\cf0\b0 " represents any valid character regex recognized it as "word" element. Besides, the space has been cared so that the toggle works across it. for instance, enter "\cf2\b\\/tr yw\cf0\b0 " or "\cf2\b\\/yw tr\cf0\b0 " will show this line "\cf4\i Two roads diverged in a yellow wood,\cf0\i0 " where the space is still a separator as always, even though the shorthand feature is toggled on.\par

	\pard\sa200\sl276\slmult1\par
	\tab three more elements of the shorthand syntax:\par
	\par

	\pard\fi-360\li1800\sa200\sl276\slmult1 1, \b extra qualifier\b0  (within a single word);\par
	2, \b escape character\b0  (between words);\par
	3, a single \b character\b0  representing any "\b non-word\b0 " one (between words).\par

	\pard\sa200\sl276\slmult1\par

	\pard\li720\sa200\sl276\slmult1 the most basic usage of improvised shorthand is to match the specific "phrase" by just entering the first letter of each word constituted it (for instance, "\cf2\b sameto\cf0\b0 " can match "\cf4\i some are more equal than others\cf0\i0 ") yet sometimes we may want to further narrow down the result. if "\cf2\b slh\cf0\b0 " brings you both "\cf4\i she likes him\cf0\i0 " and "\cf4\i she loves him\cf0\i0 ", an extra qualifier to pinpoint one may be useful. it could simply be a "v" for this example hence "\cf2\b slv/h\cf0\b0 " (in which, the "/" after the "v" tells the system that it's just an extra qualifier to the "l", not for a word starts with "v",) returns you "\cf4\i she loves him\cf0\i0 " only. likewise, you may sometimes want to tell the system exactly what the word should be ending with, for instance, if "\cf2\b ioy\cf0\b0 " brings you both "\cf4\i i owe you\cf0\i0 " and "\cf4\i i own you\cf0\i0 ", "\cf2\b ioe//y\cf0\b0 " (in which, the "//" after the "e" tells the system that it's a word ending character, that is, "oe//" represents a word starts with "o" and ends with "e") returns you "\cf4\i i owe you\cf0\i0 " only. and no matter how rare (and impractical) it may be, you may have multiple of these qualifiers for a word, such as, "\cf2\b cm/c/e//d//\cf0\b0 " can match the word "\cf4\i complicated\cf0\i0 " whereas "\cf2\b td/i/u//s//\cf0\b0 " can match the word "\cf4\i tedious\cf0\i0 ".\par
	\par
	a \b backslash\b0  "\cf2\b\\\cf0\b0 " may be used to escape a single character after it. its target should be a "word" character because you don't need to escape otherwise. for all "non-word" character, just enter them directly except "\\" itself which requires a \b double backslash\b0  "\cf2\b\\\\\cf0\b0 " for a single one. for regex syntax such as "\\s", it becomes "\\\\s" (not "\\\\\\s" you may presume.) in other words, all escaped character will only be matched barely itself. for \ul consecutive\ulnone  "word" characters that need to be escaped, enclose them in the \cf2\b\\Q\cf0\b0  \cf2\b\\E\cf0\b0  pair, similar idea as in regex. one thing to note though, escaped character may affect the word immediately after it, for instance, "\cf2\b z\\xy\cf0\b0 " may bring you "\cf4\i zebra xylophone\cf0\i0 " rather than "\cf4\i zombie x yesterday\cf0\i0 ".\par
	\par
	an \b apostrophe\b0  "\cf2\b\f1 '\cf0\b0\f0 " may be used to represent any "non-word" character. that is, same as "\\\\W" (the regex syntax "\\W" for a "non-word" character). it may be useful at the (beginning and/or ending) ends of the "phrase" if it can further narrow down the result or you simply want it to be a part of the match.\par

	\pard\sa200\sl276\slmult1\par
	The \b matches highlighting\b0  feature:\par

	\pard\li720\sa200\sl276\slmult1 the \ul default behavior\ulnone  is to highlight no more than a thousand matches (which can improve the response time when too many matches are found.) it can nonetheless be overridden by a long press of your left mouse button on one of the available gui buttons (i.e. go or refresh or back), whereas long press means press it down and hold on for \ul one second or longer\ulnone . therefore, highlighting will cover the whole thing even if the total number of matches is over \ul one thousand\ulnone . this \ul long-press-to-override\ulnone  is not a toggle, it's just an \ul one-off\ulnone  thing, so do it every time you want more than the default.\par

	\pard\sa200\sl276\slmult1\par
	End of this help page.\par
	}
	)
		Return HelpPage
	}


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

points := {Administrator       :  3
         , CEO                 :  8
         , Coordinator         :  3
         , Director            : 10
         , Europe              : 20
         , Global              : 15
         , Hiring              : 10
         , HR                  :  5
         , International       : 15
         , Manager             : 20
         , Outsourcing         :  5
         , Recruiting          : 10
         , Recruitment         : 10
         , Senior              :  5
         , "Talent Acquisition": 10}

;################################################################################

SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
   ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
   ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
   ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP

;################################################################################

/*
	ATTRIBUTES:
		already has expression equals
		has quotes within parentheses block, but not outside
	TREATMENT
		mask any quoted strings inside parentheses block (protect the string as is)
		perform other operations within the block
		unmask quoted strings within block
			convert "" to `" within quoted strings (during extraction
		leave original quoted strings in same location
		DO NOT add quotes outside parentheses block
*/

MASK CODE - MLEXPQSTR

; ini file edit.ahk - ADDS EXTRA DOUBLE-QUOTES EVERYWHERE

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


; Regex - Hotstring 02.ahk - DOES NOT TREAT AS STRING (THIS IS V2)

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


;##########################################################################


/*
	ATTRIBUTES:
		has LEGACY equals assignment
		DOES NOT have quotes yet (any quotes found should be treated as literal characters)
		could have variables inside parentheses block -> %var%
	TREATMENT
		will be converted to v2 string...
		change LEGACY equals = to expression equals := (outside of block)
		change each line to an expression string
		convert %var% to var
		add concat dots between newly quoted strings and vars
		all other characters should be treated literally...
			make sure they have proper escape chars for strings as needed
		DO NOT add quotes outside parentheses block
*/

MASK CODE - MLLEGSTR

user := "defaultuser0"
script =
(
	document.querySelector('#userId').value = '%user%'
)
MsgBox % script

;#####################################

MyVar = Test
MySection =
(
	This is a %MyVar%
)
MsgBox % MySection

;#####################################

var =
   (
   hello world
   )

;##########################################################################

/*
	ATTRIBUTES:
		Command followed by comma, followed by cont section
		has NO ASSIGNMENT leading into cont block
		has no quotes leading into cont block
		CAN HAVE %var% in cont block
		First physical line - leading HORZ WS NOT preserved
		All lines following first physical line - leading HORZ WS is preserved
		closing parenthesis may have following comma
	TREATMENT
		will be converted to v2 string...
		separate %var% from surrounding text
		surround text chunks with double-quotes (making sure to include ws before and after var)
		remove % from var [%var% to var]
		add concat dots between newly quoted strings and vars (maybe)
		all other characters should be treated literally...
			make sure they have proper escape chars for strings as needed
		DO NOT add quotes outside parentheses block
		Add command parentheses to entire block, including trailing parameters
*/

MASK CODE - MLCMDLEGSTR

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

;#####################################

; to duplicate v1 behavior
; 	1. add quote as first char just below opening parenthesis
;	2. remove leading ws from line 1 only (if blank, thats ok)
;	3. place last quote immediately  after last text char.

MsgBox,
(
		First physical line - leading HORZ WS NOT preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

MsgBox,
(
This is the 1-parameter method. Commas (,) do not need to be escaped.
With continuation section.
)

;#####################################

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

MsgBox, 1, % title,
(
%var1% World!
%var2% for now!
sorry, could not... %var3%
), 4

;#####################################

IfEqual, var, val, MsgBox, 1, title,
(
		First physical line - leading HORZ WS NOT preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

; 2nd physical line will preserve leading horz ws here
MsgBox,
(
		
		Second physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

IfEqual, var, val, MsgBox, 1, title,
(
		
		Second physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is preserved
)

;#####################################

var := 9
MsgBox,
(
%var%
line2
)

;#####################################

; Smart comma mode - requires special handling

MsgBox, 1, 22, 
(
    33
), 44, 55 ; 4-p (no timeout)



;##########################################################################

/*
	ATTRIBUTES:
		Command (usually MSGBOX) followed by [% "], followed by cont section
		has NO ASSIGNMENT leading into cont block
		HAS one double-quote leading into cont block
		HAS one double-quote following closing parenthesis
		DOES NOT HAVE %var% in cont block
		First physical line - leading HORZ WS IS preserved
		All lines following first physical line - leading HORZ WS is ALSO preserved
		closing )" may be followed by comma
	TREATMENT
		this is v1.1 multi-line quoted string
		will be converted to v2 string...
		Replace command  [ % "] with ("
		DO NOTHING inside of parentheses block
		Add closing ) to end
		DO NOT add more quotes outside parentheses block
*/

MASK CODE - MLCMDEXPSTR

MsgBox % "
(
		First physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is ALSO preserved
)"

;#####################################

; This one is using a function, but should be handled similar

MsgBox % MyFunction("
(
echo Put your commands here,
echo each one will be run,
echo and you'll get the output.
)")

;#####################################

IfEqual, var, val, MsgBox, 1, title, % "
(
		First physical line - leading HORZ WS IS preserved
	All lines following first physical line - leading HORZ WS is ALSO preserved
)", 4


;##########################################################################

/*
	ATTRIBUTES:
		Hotkey followed by cont section
		has NO ASSIGNMENT leading into cont block
		has no quotes leading into cont block
		has no %var%
	TREATMENT
		mask and do no change anything! is valid in v2
*/

MASK CODE - MLHKSTR

::text1::
(
Any text between the top and bottom parentheses is treated literally, including commas and percent signs.
By default, the hard carriage return (Enter) between the previous line and this one is also preserved.
    By default, the indentation (tab) to the left of this line is preserved.
)