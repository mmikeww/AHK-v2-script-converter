
is_arr := { (tree): 1 }

key:={ 0 : 0 ,_0x00: "Icon", 500:"5 hundred"}

Static Views := {_0x00: "Icon", _0x01: "Report", _0x02: "IconSmall", _0x03: "List", _0x04: "Tile"}

return this.str({""_INVALID_KEYNAME: param_value}, "")		; missing object property

strangeKeynames := { (weirdkn): "weird kn", anotherone: "another", [s u p e r "s t r @ n g 3"]_INVALID_KEYNAME: "super-strange"}

;################################################################################

HelpText:=
(join`r`n
"This program allows you to load a CSV file (any delimited file)
and use various search criteria to filter the listview.
You can export the results to a new file.
The regular expression search is case sensitive and should be a
Perl-compatible regular expression (PCRE, www.pcre.org)
Note: an entire row of the CSV is searched at once and not
on a cell by cell basis to provide faster search results.

" CmdlineOpt "

Press enter: Show row data in a message box
Press ctrl-c: Copy row data to clipboard

" helpforum
)
MsgBox(HelpText, helptitle, 32)

;################################################################################

HelpText:=
(join`r`n
"Select a file and set the delimiter and press OK

If you want to change the columns that will be visible in
the listview and/or the order, enter a comma separated list:
1,4,8 will only show columns 1 4 and 8 in your listview
3,2,1 will show the columns in that order
The export function will use this order as well.
If you use columns that don't exist they show up empty.

" helpforum
)
MsgBox(HelpText, helptitle, 32)


;################################################################################

	gSite_BibleHub := {url: "https://biblehub.com/audio/chapter/{book}/{chapter}.htm", genesis: "genesis", exodus: "exodus", leviticus: "leviticus", numbers: "numbers", deuteronomy: "deuteronomy", joshua: "joshua", judges: "judges", ruth: "ruth", _1samuel: "1_samuel", _2samuel: "2_samuel", _1kings: "1_kings", _2kings: "2_kings", _1chronicles: "1_chronicles", _2chronicles: "2_chronicles", ezra: "ezra", nehemiah: "nehemiah", esther: "esther", job: "job", psalms: "psalms", proverbs: "proverbs", ecclesiastes: "ecclesiastes", songofsolomon: "songs", isaiah: "isaiah", jeremiah: "jeremiah", lamentations: "lamentations", ezekiel: "ezekiel", daniel: "daniel", hosea: "hosea", joel: "joel", amos: "amos", obadiah: "obadiah", jonah: "jonah", micah: "micah", nahum: "nahum", habakkuk: "habakkuk", zephaniah: "zephaniah", haggai: "haggai", zechariah: "zechariah", malachi: "malachi", matthew: "matthew", mark: "mark", luke: "luke", john: "john", acts: "acts", romans: "romans", _1corinthians: "1_corinthians", _2corinthians: "2_corinthians", galatians: "galatians", ephesians: "ephesians", philippians: "philippians", colossians: "colossians", _1thessalonians: "1_thessalonians", _2thessalonians: "2_thessalonians", _1timothy: "1_timothy", _2timothy: "2_timothy", titus: "titus", philemon: "philemon", hebrews: "hebrews", james: "james", _1peter: "1_peter", _2peter: "2_peter", _1john: "1_john", _2john: "2_john", _3john: "3_john", jude: "jude", revelation: "revelation"}

;################################################################################

EmptyVar :="" 	; needs empty quotes added

;################################################################################

Array := []
if ("this line has trailing open-brace...") {	
	; make array brackets above disappear! lol
	; see - "Remove [] from classes with no params" near line 774 - needles need adjusted
}

;#####################################

if (!arrayPos:=RegExMatch(srcStr, "(\[(?>[^][]+|(?1))*\])", &m))
{
	; similarly... part of needle above disappears due to trailing open-brace above
	; see - "Remove [] from classes with no params" near line 774 - needles need adjusted
}

;#####################################

; two unrelated bugs
array := []	; brackets disappear due to opening brace on next line (object declaration)
retList := {}, retList.fList := "", retList.fCount := 0	; line contents after } will disappear

;#####################################

; line contents after } will sometimes disappear, but not always

A_Args.ScrCmp := {Wait: 1},   Bytes := W*H*4,  Count := 0
Static XAlign := {C: 50, L: 0, R: 100}, YAlign := {B: 100, C: 50, T: 0}
static Problem:={S:"N",N:"S",E:"W",W:"E"},Direction:={Up:"N",Down:"S",Left:"W",Right:"E"}
WinHook.Shell.Hooks := {}, WinHook.Shell.Events := {}
EventHookTable := {}, _hHookTable := {}
emptyFolderList := {}, emptyFolderList.fList := "", emptyFolderList.fCount := 0
uCharList	:= getUniqueCharList(contents, charObj:={}, "Asc", true)	; sort by ASC in descending order
curSection := {}, pos := 0, retStr := ""

;################################################################################

key := "{pg" . ((diff<0) ? "dn " : "up ") . floor(diffVal/nPage) . "}"
key := ((diff<0) ? "{down " : "{up ") . diffVal . "}"
folderList := parentList.fList, folderCount := parentList.fCount

;################################################################################

UpdateLayeredWindow(hwnd, hdc, x:="", y:="", w:="", h:="", Alpha:=255)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"

	if ((x != "") && (y != ""))
		VarSetStrCapacity(&pt, 8), NumPut("UInt", x, pt, 0), NumPut("UInt", y, pt, 4) ; V1toV2: if 'pt' is NOT a UTF-16 string, use 'pt := Buffer(8)' and replace all instances of 'StrPtr(pt)' with 'pt.Ptr'

	if (w = "") ||(h = "")
		WinGetPos(, , &w, &h, "ahk_id " hwnd)

	return DllCall("UpdateLayeredWindow"
					, Ptr, hwnd
					, Ptr, 0
					, Ptr, ((x = "") && (y = "")) ? 0 : StrPtr(pt)
					, "int64*", w|h<<32
					, Ptr, hdc
					, "int64*", 0
					, "uint", 0
					, "UInt*", Alpha<<16|1<<24
					, "uint", 2)
}

;################################################################################

			if ( A_Index<db_NumberOfRows )															; if not the last row of database
				FileAppend(db_LeftPartOfRow "" db_CellContent "" db_RightPartOfRow "`r`n")				; save updated row and a linebreak in output file
			else																					; else (the last row of database)
				FileAppend(db_LeftPartOfRow "" db_CellContent "" db_RightPartOfRow)					; store updated row (but no linebreak) in output file

;################################################################################

	Maker(t) {
		v := this.ov, t := this.tw4sh(t), r := (this[v].Case ? "i" : "") "m`a)^(?!"
		Loop Parse, t, A_Space
			If SubStr(A_LoopField, 1, 1) = "-"
				r .= "(?!.*(" (this[v].Whole ? "\b" : "") SubStr(A_LoopField, 2) (this[v].Whole ? "\b" : "") "))"
			Else r .= "(?=.*(" (this[v].Whole ? "\b" : "") A_LoopField (this[v].Whole ? "\b" : "") "))"
		r .= ").*\R?"
		Return r
	}

;################################################################################

   EscapeStr(&Str,  Quote := True) {
      This.ErrorMsg := ""
      This.ErrorCode := 0
      This.SQL := ""
      If !(This._Handle) {
         This.ErrorMsg := "Invalid database handle!"
         Return False
      }
      if isNumber(Str)
         Return True
      OP := Buffer(16, 0) ; V1toV2: if 'OP' is a UTF-16 string, use 'VarSetStrCapacity(&OP, 16)' and replace all instances of 'OP.Ptr' with 'StrPtr(OP)'
      StrPut(Quote ? "%Q" : "%q", OP.Ptr, "UTF-8")
      This._StrToUTF8(Str, UTF8)
      Ptr := DllCall("SQLite3.dll\sqlite3_mprintf", "Ptr", OP.Ptr, "Ptr", &UTF8, "Cdecl UPtr")
      If (ErrorLevel) {
         This.ErrorMsg := "DllCall sqlite3_mprintf failed!"
         This.ErrorCode := ErrorLevel
         Return False
      }
      Str := This._UTF8ToStr(Ptr)
      DllCall("SQLite3.dll\sqlite3_free", "Ptr", "Ptr", "Cdecl")
      Return True
   }

;################################################################################


F4C_String := "testing"
F4C_String:="`"" . F4C_String . "`"" ;If needed, bracket the string in double quotes
MsgBox("[" F4C_String "]")

str := "changeVar := `n(`n`"" . "change`ntext" . "`"`n)"
MsgBox(str)


tNL			:= "`n`t"
desc		:= tNL . "`; Property Desc: "
methodName	:= tNL . "ChangeMe {"
get			:= tNL . "`tget {" . tNL . "`t`t" . "return `"`"" . tNL . "`t}"
setMsg		:= "`t`t`; dont allow change after instantiation" . tNL
			. "`t`t`; also prevents AHK from creating false local objects" . tNL
			. "`t`t`; return`t`; note: using this is equivilant to return `"`""
set			:= tNL . "`tset {" . tNL . setMsg . tNL . "`t}"
tempStr		:= desc . methodName . get . set . tNL . "}" . tNL
MsgBox(tempStr)


linkText := linkText=="" ? linkUrl : linkText
newTab := (inNewTab) ? "`" target=`"_blank" : ""
retStr := lspc(spPfx) . "<a href=`"" . linkUrl . newTab . "`">" . linkText . "</a>" . lspc(spTrl)
MsgBox(retstr)


      If (DrawStage = 0x030001) {
         UseAltCol := !(Col & 1) && (This.AltCols)
         , ColColors := This["Cells", Row, Col]
         , ColB := (ColColors.B != "") ? ColColors.B : UseAltCol ? This.ACB : This.RowB
         , ColT := (ColColors.T != "") ? ColColors.T : UseAltCol ? This.ACT : This.RowT
         , NumPut("UInt", ColT, L + OffCT), NumPut("UInt", ColB, L + OffCB)
         Return (AHKv1v2_Temp := (!This.AltCols && !This.Has(Row) && (Col > This["Cells", Row].MaxIndex())) ? 0x00 : 0x20, AHKv1v2_Temp) ; V1toV2: Wrapped Multi-statement return with parentheses
      }

;################################################################################
														   createKeyOrder(colStr)
{
	colNames := ["Row", "Size", "Type"
				,"CRC-32", "Name", "Path"
				,"Date Created", "Date Modified"
				,"Date Accessed"]
				
	colToKey := {Row: 			"kRow"
				,Size:			"kSize"
				,Type:			"kType"
				,CRC32:			"kCRC"
				,Name:			"kName"
				,Path:			"kPath"
				,DateCreated:	"kDateC"
				,DateModified:	"kDateM"
				,DateAccessed:	"kDateA"}
	return
}
;################################################################################

	Return CurrentCSV_TotalRows

	SendEvent("When you are ready, press Space")

;################################################################################

(ch == "{")
	? ( is_key := true
	  , value := {}
	  , next := object_key_or_object_closing )
; ch == "["
	: ( value := json_array ? new json_array : []
	  , next := json_value_or_array_closing )

;################################################################################

	while(pos := RegExMatch(srcStr, strNeedle, &m, (pos+1)<1 ? (pos+1)-1 : (pos+1)))
	{
		savePos := pos
		retList.push({pos:pos,val:m[1]})
		pos += StrLen(m[1])-1
		;MsgBox % "[" . line . "]`n`nm1 := " . m1 . "`n`npos := " . savePos
	}

;################################################################################

if (A == "'/'") {
	; do stuff
}
else if (nt == "'*'") {
	; do other stuff
}

;################################################################################


	_HelperClip(){
		local ClipList 
		
		
		
		ClipList := 		{ 	__New: 					" := New PopUpWindow( { AutoShow: 1 , X: 0 , Y: 0 , W: A_ScreenWidth , H: A_ScreenHeight , Options: `" -DPIScale +AlwaysOnTop `" } )"
							,	UpdateSettings:			".UpdateSettings( { X: `"`" , Y: `"`" , W: `"`" , H: `"`" } , UpdateGraphics := 0 )"
							,	ShowWindow:				".ShowWindow( Title := `"`" )"
							,	HideWindow:				".HideWindow()"
							,	UpdateWindow:			".UpdateWindow()"
							,	ClearWindow:			".ClearWindow( AutoUpdate := 0 )"
							,	DrawBitmap:				".DrawBitmap( pBitmap := `"`" , { X: 0 , Y: 0 , W: " Out ".W , H: " Out ".H } , dispose := 1 , AutoUpdate := 0 )"
							,	PaintBackground:		".PaintBackground( color := `"0xFF000000`" , AutoUpdate := 0 )  "  ";{ Color: `"0xFF000000`" , X: 2 , Y: 2 , W: " Out ".W - 4 , H: " Out ".H - 4 , Round: 10 }"
							,	DeleteWindow:			".DeleteWindow( GDIPShutdown := 0 )"
							,	AddTrigger:				".AddTrigger( { X: `"`" , Y: `"`" , W: `"`" , H: `"`" , Value: `"`" , Label: `"`" } )"	
							,	DrawTriggers:			".DrawTriggers( color := `"0xFFFF0000`" , AutoUpdate := 0 )"	
							,	CreateCachedBitmap:		".CreateCachedBitmap( pBitmap , Dispose := 0 )"	
							,	DrawCachedBitmap: 		".DrawCachedBitmap( AutoUpdate := 0 )"	
							,	DisposeCachedbitmap:	".DisposeCachedbitmap()"	}
							
		A_Clipboard := Out ClipList[ A_GuiControl ]
		
	}


;################################################################################


cc := Gui1.Listview1 := PopUpWindow( { AutoShow: 1 , X: x , Y: y , W: w * Gui1.Scale , H: h * Gui1.Scale , Options: " -DPIScale +Parent" Gui1.Hwnd } ) 

cc.Sections := []

x := 0
w := 120
cc.Sections[ 1 ] := { Header: "Section 1" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 2 ] := { Header: "Section 2" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 3 ] := { Header: "Section 3" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 4 ] := { Header: "Section 4" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 
x += w + 3 
cc.Sections[ 5 ] := { Header: "Section 5" , X: x , Y: 0 , W: w , H: 24  , MoveVector: New Vector( x + w + 1 , 0 ) } 


;################################################################################


	While (RegExMatch(srcStr, "s)^.", &char))		; get first char in string - s) targets all chars (comparable speed to StrLen(srcStr))
	{
		srcStr := StrReplace(srcStr, (char&&char[0]), , , &cCnt)	; 3 TIMES FASTER than RegexReplace() for single chars !!! ('just me' suggestion)
		;ndl		:= "\Q" char "\E"				; update needle for each char
		;srcStr	:= RegExReplace(srcStr,ndl,,cCnt)	; remove all chars found (speed boost), and...
													;	count char occurrences at same time
		; build char obj
		ascPos	:= Ord((char&&char[0]))						; array index number
		if (ascPos>0 && ascPos<256)					; if not super-extended ascii char
			charObj[ascPos] := {Asc:ascPos		; add charObj to list - char array index will be...
			,(char&&char[0]):(char&&char[0]),Count:cCnt}				;	 same as char ascii value
		else
			charObj[extIdx] := {Asc:ascPos		; push super-extended chars (or null) to end of list
			,(char&&char[0]):(char&&char[0]),Count:cCnt}, extIdx++
		tCount += cCnt								; testing/debugging
		;ToolTip % StrLen(srcStr)
		; build unique list
;		if (RegExMatch(unique, ndl)) ; not needed	; RegexMatch is about 2.5 times faster than Instr()
;			continue								; do not add dupe chars to unique list
		fCR		:= (fCR||(char&&char[0])="`r")					; determine whether CR was originally present in srcStr
		fLF		:= (fLF||(char&&char[0])="`n")					; determine whether LF was originally present in srcStr
		unique	.= (char&&char[0]) "`r"						; make list of unique chars only, use CR as delim
	}

;################################################################################


	Update_Button_State(){
		Switch {
			Case !this.Window_Title : return 1
			Case WinExist( "ahk_id" this.Window_ID ) : return 2
			Default: return 1
		}
	}

;#####################################

	SwitchToSlim() {
		v := this.ov, n := this[v].n, this[v].Needle[n] := this.Fpat(), this[v].eFlag := True
		this.GuiClose(this.id)
		this.SlimGui(this.id)
		ControlSetText(this[v].Needle[n], "Edit1", "A")
		this.RenewGui(this[v].Needle[n]), this[v].eFlag := False
		Send("{End}")
	}

;#####################################

	Switch Ship{
		case "Carrier": i:=1
		case "Battleship": i:=1
		case "Cruiser": i:=1
		case "Destroyer": i:=2
	}

;#####################################

	Switch mode
	{
;		Case 1,2:	; move := 1, copy := 2
;			; purge pending copy/cut operation within explorer (important)
;			; since we will handle the file transfer here and do not want explorer to complain
;			Clipboard := "Transferring files"		; can be set to any text
;			fileList := getOrigPaths(allPathList)	; extract original paths list
;			success := SHFileOperation(fileList, destPath, mode)
;			return (success and verifyTransfer(allPathList))
		Case 3:		; use paste method
			success := pasteFiles(allPathList, destPath)
			return success ; transfer was already verified
		Default:
			; ignore anything else
	}

;#####################################

	switch (speed)
	{
		case 0:
			return arrToStr_Fast(srcArray, delim)
		case 1:
			return arrToStr_Slow(srcArray, delim)
		case 2:
			return arrToStr_Better(srcArray, delim)
		default:
			return ""
	}


;################################################################################

strV1 := "(`"(?>[^`"\v]+|`"`")*`")"


r .= RegExMatch(A_LoopField, "\w") ? "(?=[\w'\-+]*" A_LoopField ")" : ""


return RegExReplace(srcStr, "(\h*)" commentChar "(.*)", "$1$2")


RegExEscape(str) { ; https://www.regular-expressions.info/characters.html
	return RegExReplace(str, "([\\^$.|?*+()[{])", "\$1")
}


needle		:= RegExReplace(cells[2], "^`"(.*)`"$", "$1", , 1)	; needle is specific for each reserve word (trim leading and trailing double-quotes)
repl		:= RegExReplace(cells[3], "^`"(.*)`"$", "$1", , 1)	; replacement is specific for each reserve word (trim leading and trailing double-quotes)
retStr := RegExReplace(retStr, "(?m)^((?:(?>`"[^`"\v]*`"|[^`"\v;]*)*)*)(;.*)+", "$1", &c)
		

;################################################################################

   myGui := Gui()
   myGui.MarginX := 20, myGui.MarginY := 20
   ogcButtonOrder1234 := myGui.Add("Button", "ym", "Order 1, 2, 3, 4")
   ogcButtonOrder1234.OnEvent("Click", Order123.Bind("Normal"))
   ogcButtonOrder3214 := myGui.Add("Button", "ym", "Order 3, 2, 1, 4")
   ogcButtonOrder3214.OnEvent("Click", Order321.Bind("Normal"))
   ogcButtonRemoveBkImage := myGui.Add("Button", "ym", "Remove BkImage")
   ogcButtonRemoveBkImage.OnEvent("Click", RemoveImage.Bind("Normal"))
   ogcButtonNewBkImage := myGui.Add("Button", "ym", "New BkImage")
   ogcButtonNewBkImage.OnEvent("Click", NewImage.Bind("Normal"))
   myGui.Add("Text", "xm Section h20", "First visible row:")
   myGui.Add("Text", "hp y+0", "Is row 20 visible?")
   myGui.Add("Text", "hp y+0", "Number of visible rows:")
   ogcTextFVR := myGui.Add("Text", "ys hp vFVR", "00")
   ogcTextIRV := myGui.Add("Text", "hp y+0 vIRV", "00")
   ogcTextNOVR := myGui.Add("Text", "hp y+0 vNOVR", "00")
   ogcButtonNewCheck := myGui.Add("Button", "ys", "New Check")
   ogcButtonNewCheck.OnEvent("Click", Check.Bind("Normal"))
   ogcListviewVLV := myGui.Add("Listview", "xm w500 r10  cWhite  vVLV", ["Col 1", "Col 2", "Col 3", "Icon"])
   ogcListviewVLV.OnEvent("DoubleClick", rid.Bind("DoubleClick")), HLV := ogcListviewVLV.hwnd ; add -LV0x20 on Win XP


;################################################################################

getTens(str)
{

	tens := {ten:10,twenty:20,thirty:30,forty:40,fifty:50,sixty:60,seventy:70,eighty:80,ninety:90,eleven:11
			,twelve:12,thirteen:13,fourteen:14,fifteen:15,sixteen:16,seventeen:17,eighteen:18,nineteen:19}
	return tens[str]
}

;################################################################################


frogs?"":frogs:=maxfrogs

a := ""
  , b
  ? c
  :""

a := ""
  , b ? c : ""

var ? "": "false"

(var) ? "": "false"

var1 := (var2)
	?""
	: "false"

var3 := (var4)
	? "true"
	:""

;################################################################################
	
rList.push({BPP:BPP, Width:W, Height:H, Freq:Freq, ToString:curStr})

;#####################################

obj := {keyA: "valueA", keyB : "valueB", keyC : "ValC"}
MsgBox(obj.keyA)
MsgBox(obj.keyB)
MsgBox(obj.keyC)

;################################################################################

; Send6.ahk - F3:: DISAPPEARS (THIS IS V2)

F3:: {
 MouseGetPos(&mx, &my)
 If PixelSearch(&x, &y, mx - within, my - within, mx + within, my + within, find)
  Click(x, y), SoundBeep(1500)
}


; SendKey 123298 and 123299.ahk (THIS IS V1)

; 123299
$*s::
{
	ToolTip()
	ErrorLevel := !KeyWait("LShift", "d, T0.2")		; THIS LINE HAS SPACE ISSUE
	if (ErrorLevel == 1)
		return

	StartTime := A_TickCount
	ErrorLevel := !KeyWait("c", "d, T0.25")
    ElapsedTime := A_TickCount - StartTime ; Calculate the elapsed time
	if(GetKeyState("c"))
	{
		ToolTip("here")
		if (ElapsedTime < 250)
		{
			Send("{c up}")
			Sleep(250 - ElapsedTime)
			Send("{c down}")
		}
		Send("{LShift up}{s up}{c up}")
	}
}
return


; formatComments.ahk - SEEMS TO CONVERT CORRECTLY WITH MY CHANGES

linesObj.push({code:code,comment:comment})	; should become linesObj.push({code:code,comment:comment})


; GetDisplaySettings.ahk - SEEMS TO CONVERT CORRECTLY WITH MY CHANGES

	Return {Width:w,Height:h,Qual:q,Freq:f} ;Out_1 "/" Out_2 "/" Out_3 "/" Out_4
	
	Return {W: (ErrorLevel & 0xFFFF), H: (ErrorLevel >> 16) & 0xFFFF}



; imagesearch 101814.ahk

			Click(FoundX ", " FoundY)
			
			
			
; MouseAxisLock 02b.ahk (MEMORY ERRORS AT LINE 13 OF CONVLOOPFUNC.AHK)


/*
	HAS AN ISSUE/CONFLICT WITH SOME PROCESSES...
		that try to control mouse movement at same time as script
		MOUSE AXIS LOCK WILL BE RELEASED BY ANOTHER PROCESS
	This was observed in the folowing situation...
		When axis lock is turned on and you mouse over Avast tray icon...
		The temp (green) avast notification ("you are protected") will popup...
		THE MOUSE WILL CONTINUE TO MOVE IN AXIS LOCK MODE, but...
			the lock mode will be RELEASED once the avast notification disappears

	Don't know how to fix this conflict... abandoning project for now
*/

#SingleInstance force
CoordMode("pixel", "screen")
CoordMode("mouse", "screen")
lock := false
return
;################################################################################
F11::	; lock to horz axis movement only
F12::	; lock to vert axis movement only
{
	lock :=! lock
	MouseGetPos(&mX, &mY)
	((A_ThisHotkey="F11") ? LockAxis(lock, 0, mY, A_ScreenWidth, mY) : LockAxis(lock, mX, 0, mX, A_ScreenHeight))
	return
}
;esc::ExitApp
;################################################################################
LockAxis(lock:=false, x1:=0 , y1:=0, x2:=1, y2:=1) {
	R := Buffer(16, 0),NumPut("UPtr", x1, R.Ptr+0),NumPut("UPtr", y1, R.Ptr+4),NumPut("UPtr", x2, R.Ptr+8),NumPut("UPtr", y2, R.Ptr+12) ; V1toV2: if 'R' is a UTF-16 string, use 'VarSetStrCapacity(R.Ptr, 16)' and replace all instances of 'R.Ptr' with 'StrPtr(R)'
	return (lock) ? DllCall("ClipCursor", "UInt", R.Ptr) : DllCall("ClipCursor")
}