; 2026-06-26 ADDED by andymbody to support code block masking
; currently supports nested classes and functions (as wells as block/line comments and quoted strings for v1 or v2)
; will add more support for other code blocks, AHK funcs, etc as needed
; all regex needles were designed to support masking tags. Feel free to contact me on AHK forum if I can assist with edits


; The FORMAT of this file was CREATED WITH TABS OF 4.
;	Please do NOT change this to spaces or a different number of chars... Thanks!


global	  gTagChar		:= chr(0x2605)
		, gFuncPtn		:= buildPtn_FUNC(), gClassPtn := buildPtn_CLS()
		, gLCPtn		:= '(*UCP)(?m)(?<=\s|);[^\v]*'															; line comment (allows lead ws to be consumed already)
		, gBCPtn		:= '(*UCP)(?m)^\h*(/\*((?>[^*/]+|\*[^/]|/[^*])*)(?>(?-2)(?-1))*(?:\*/|\Z))'				; block comments
		, gQSPtn		:= '(*UCP)(?m)(?:`'`'|`'(?>[^`'\v]+(?:(?<=``)`')?)+`'|""|"(?>[^"\v]+(?:(?<=``)")?)+")'	; quoted string	(UPDATED 2024-06-17)
		, gMQSPtn		:= buildPtn_MStr()																		; v1 multiline string (non expression)
;		, gBracePtn		:= '(\{(?>[^}{]+|(?-1))*\})'															; nested brace blocks (for future support)

;################################################################################
class NodeMap
{
	name					:= ''		; name of block
;	taggedCode				:= ''		; (no longer used)
	BlockCode				:= ''		; orig block code - used to determine whether code was converted
	ConvCode				:= ''		; converted code
	cType					:= ''		; CLS, FUNC, etc
	tagId					:= ''		; tagId
	parentPos				:= -1		; -1 is root
	pos						:= -1		; block start position within code, ALSO use as unique key for MapList
	len						:= 0		; block entire length
	ParentList				:= ''		; list of parent ids (immediate parent will be listed first)
	ChildList				:= map()	; list of child nodes

	; acts as constructor for a node object
	__New(name, cType, blkCode, pos, len)
	{
		this.name			:= name
		this.cType			:= cType
		this.blockCode		:= blkCode
		this.pos			:= pos
		this.len			:= len
	}

	; PRIVATE - returns the nested path depth of the node
	_depth() {
		StrReplace(this.PathVal, "\",,, &count)
		return count
	}

;	; PRIVATE - custom sort for path depth
;	_depthSort(a1,a2,*)
;	{
;		RegExMatch(a1, "(\d+):(\d+):", &m1)
;		RegExMatch(a2, "(\d+):(\d+):", &m2)
;		return ((m2[2] > m1[2]) ? 1 : ((m2[2] < m1[2]) ? -1 : ((m2[1] > m1[1]) ? 1 : ((m2[1] < m1[1]) ? -1 : 0))))
;	}

	; PUBLIC - convenience - returns string list of ChildList map()
	GetChildren() {
		cList := ""
		for key, childNode in this.ChildList {
			cList .= ((cList="") ? "" : ";") . ("[" key "]" . childNode.name)
		}
		return cList
	}

	EndPos					=> this.pos + this.len
	ParentName				=> (this.parentPos > 0)	 ? NodeMap.mapList[this.parentPos].name : "Root"
	Path					=> ((this.parentPos > 0) ? NodeMap.mapList[this.parentPos].Path : "") . ("\" this.name)
	PathVal					=> ((this.parentPos > 0) ? NodeMap.mapList[this.parentPos].PathVal : "") . ("\" this.pos)
	AddChild(id)			=> this.ChildList[id]	:= NodeMap.mapList[id]	; add node object
	hasChildren				=> this.ChildList.Count
	hasChanged				=> (this.ConvCode && (this.ConvCode = this.BlockCode))

	;################################################################################

	static mapList			:= map()
	static idIndex			:= 0
	static nextIdx			=> ++NodeMap.IdIndex
	static getNode(id)		=> NodeMap.mapList(id)
	static getName(id)		=> NodeMap.mapList(id).name

	; PRIVATE - adds a node to maplist
	static _add(node) {
		NodeMap.mapList[node.pos] := node
		return
	}

	; PUBLIC - provides details of all nodes in maplist
	; used for debugging, etc.
	static Report() {
		reportStr := ""
		for key, nm in NodeMap.MapList {
			reportStr	.= "`nname:`t[" nm.cType "] " nm.name "`nstart:`t" nm.pos "`nend:`t" nm.EndPos "`nlen:`t" nm.len
						. "`nparent:`t" nm.parentName " [" nm.parentPos "]`npath:`t" nm.path "`npathV:`t" nm.pathVal "`nDepth:`t" nm.Depth()
						. "`nPList:`t" nm.parentList "`nChilds:`t" nm.getChildren() "`n"
		}
		return reportStr
	}

	; PUBLIC - builds a position map of all classes and functions found in script
	;	also identifies relationship between nodes
	static BuildNodeMap(code)
	{
		NodeMap.Reset()		; each build requires a fresh MapList

		; map all classes - including nested ones, from top to bottom
		pos := 0
		while(pos := RegExMatch(code, gClassPtn, &m, pos+1)) {
			NodeMap._add(NodeMap(m.cname, "CLS", m[], pos, m.len))
		}

		; map all functions - including nested ones, from top to bottom
		pos := 0
		while(pos := RegExMatch(code, gFuncPtn, &m, pos+1)) {
			if (m[]="")
				continue	; bypass IF/WHILE/LOOP
			NodeMap._add(NodeMap(m.fname, "FUNC", m[], pos, m.len))
		}

		; identify parents and children for each node in maplist
		NodeMap._setKin()
		return
	}

	; PUBLIC - mask and convert classes and functions
	static MaskAndConvertNodes(&code)
	{
		; prep for tagging - get list of node positions
		nodeDepthStr := ""
		for key, node in NodeMap.mapList
			nodeDepthStr .= ((nodeDepthStr="") ? "" : "`n") . (key ":" node._depth() ":" node.name)

		; mask/tag each class and function, FROM BOTTOM TO TOP - REVERSE ORDER!
		reversedDepthStr := Sort(nodeDepthStr,"NR")
		Loop parse, reversedDepthStr, "`n", "`r"
		{
			; [pos] serves two purposes...
			;	1. starting char position of node [class,func,etc] within code body
			;	2. used as unique key for mapList[] (ensures map sort order is same as order found in code)
			pos		:= RegExReplace(A_LoopField, "^(\d+).+", "$1")	; extract pos/Key of current node
			node	:= nodeMap.mapList[number(pos)]

			; if node is a class
			if (node.cType='CLS')
			{
				tag := ("tag_CLS_" pos), node.tagId := tag
				if ((p:=RegExMatch(code, gClassPtn, &m, pos))=pos)			; node position is known and specific
				{
					mCode := m[], doPreMask_remove(&mCode)					; remove premask of comments and strings
					;node.taggedCode	:= mCode						 	; (not used)
					node.ConvCode	:= _convertLines(mCode,finalize:=1)		; now convert code to v2
					code := RegExReplace(code, "\Q" mCode "\E", tag,,1,pos)
				}
			}

			; if node is a function
			else if (node.cType='FUNC')
			{
				tag := ("tag_FUNC_" pos), node.tagId := tag
				if ((p:=RegExMatch(code, gFuncPtn, &m, pos))=pos)			; node position is known and specific
				{
					mCode := m[], doPreMask_remove(&mCode)					; remove premask of comments and strings
					;node.taggedCode	:= mCode						 	; (not used)
					node.ConvCode	:= _convertLines(mCode,finalize:=1)		; now convert code to v2
					code := RegExReplace(code, "\Q" mCode "\E", tag,,1,pos)
				}
			}
		}
		return
	}

	; PUBLIC - replaces class/func code with tags (indirectly)
	; converts original code in the process, stores it to be retrieved by RestoreBlocks()
	static MaskBlocks(&code)
	{
		; pre-mask comments and strings
		doPreMask(&code)
		; mask classes and functions
		NodeMap.BuildNodeMap(code)		; prep for masking/conversion
		NodeMap.maskAndConvertNodes(&code)
		; remove premask from main/global code that will be converted normally
		doPreMask_remove(&code)
		return
	}

	; PUBLIC - replaces class/func code with v2 converted version
	static RestoreBlocks(&code)
	{
		for key, node in nodeMap.mapList {
			tag := node.tagId, convCode := node.convCode	; this code is already converted to v2 (see MaskAndConvertNodes)
			code := StrReplace(code, tag, convCode)
		}
		return
	}

	; PRIVATE - identifies all parents/children for each node in nodelist
	static _setKin() {
		for key, node in NodeMap.mapList {
			node.ParentPos := NodeMap._findParents(node.name, node.pos, node.len)
		}
	}

	; PRIVATE - find all parents/children for passed block, return immediate parent
	static _findParents(name, pos, len)
	{
		cp := -1, parentList := map()
		; find parent via brute force (by comparing code positions)
		for key, node in NodeMap.mapList {
			if ((pos>node.pos) && ((pos+len)<node.EndPos)) {
				offset				:= pos-node.pos				; looking for lowest offset (closest parent)
				parentList[offset]	:= node.pos					; add current parent id to list
				node.AddChild(pos)								; add this node to the ChildList of parent
				cp := ((cp < 0 || offset < cp) ? offset : cp)	; identify immediate (closest) parent
			}
		}
		; if no parent found, root is the parent
		if (cp<0) {
			NodeMap.mapList[pos].parentList := "r"				; add root as only parent
			return -1											; -1 indicates root as only parent
		}
		; has at least 1 parent, save parent list, return immediate parent (pos)
		pList := parentList[cp] . ""
		for idx, parent in parentList {
			if (!InStr(pList, parent))
				pList .= ";" parent
		}
		pList .= ";r"				; add root
		NodeMap.mapList[pos].parentList := pList
		return parentList[cp]		; pos is used as mapList [key]
	}

	; PUBLIC - clears maplist
	static Reset()
	{
		nodeMap.mapList := Map()
	}
}
;################################################################################
class PreMask
{
; handles masking of block/line comments and strings, and other general masking

	codePtn		:= ''
	mType		:= ''
	origcode	:= ''
	tag			:= ''

	__new(code, tag, mType, pattern)
	{
		this.origCode	:= code
		this.tag		:= tag
		this.mType		:= mType
		this.codePtn	:= pattern
	}

	;################################################################################

	static masklist		:= map()			; holds all premask objects, origCode/tags
	static uniqueIdList	:= map()			; ensures tags have unique ID

	; generates a unique 4bit hex value
	Static GenUniqueID()
	{
		while(true) {
			rnd	:= Random(1, 16**4)						; max := 65536
			rHx	:= format("{:04}",Format("{:X}", rnd))	; 4 char hex
			if (!PreMask.uniqueIdList.has(rHx)) {
				PreMask.uniqueIdList[rHx] := true
				break
			}
		}
		return rHx
	}

	; PUBLIC - convenience/proxy method - mask block comments
	static MaskBC(&code) {
		PreMask.MaskAll(&code, 'BC', gBCPtn)
	}
	; PUBLIC - convenience/proxy method - mask line comments
	static MaskLC(&code) {
		PreMask.MaskAll(&code, 'LC', gLCPtn)
	}
	; PUBLIC - convenience/proxy method - mask quoted strings
	static MaskQS(&code) {
		PreMask.MaskAll(&code, 'QS', gQSPtn)
	}
	; PUBLIC - convenience/proxy method - restore block comments
	static RestoreBC(&code) {
		PreMask.RestoreAll(&code, 'BC')
	}
	; PUBLIC - convenience/proxy method - restore line comments
	static RestoreLC(&code) {
		PreMask.RestoreAll(&code, 'LC')
	}
	; PUBLIC - convenience/proxy method - restore quoted strings
	static RestoreQS(&code) {
		PreMask.RestoreAll(&code, 'QS')
	}

	; PUBLIC - searches for pattern in code and masks the code
	; used for block/line comments and strings (not for classes and functions)
	static MaskAll(&code, mType, pattern)
	{
		; setup unique tag id
		tagChar := (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
		pref	:= '#TAG' . tagChar . mType . '_' PreMask.GenUniqueID() '_'
		trail	:= tagChar . '#'
		; search/replace code with tags, save original code
		pos := 1
		while (pos := RegExMatch(code, pattern, &m, pos))
		{
			mCode					:= m[]
			tag						:= pref . A_Index . trail				; tag to be used for masking
			PreMask.masklist[tag]	:= PreMask(mCode, tag, mType, pattern)	; mask code and add to mask list
			code					:= StrReplace(code, mCode, tag,,,1)		; replace only first occurence
			pos						+= StrLen(tag)							; set position for next search
		}
	}

	; PUBLIC - finds tags within code and replaces the tags with original code
	static RestoreAll(&code, mType)
	{
		; setup unique tag id
		tagChar := (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
		pref	:= '#TAG' . tagChar . mType . "\w+"
		trail	:= tagChar . '#'
		pattern	:= pref . trail
		; search/replace tags with original code
		while (pos := RegExMatch(code, pattern, &m)) ;, pos))
		{
			mCode	:= m[]
			oCode	:= PreMask.masklist[mCode].origCode		; get original code from mask object
			code	:= StrReplace(code, mcode, oCode)		; replace - should only be 1 occurence
		}
	}

	; override in sub-classes (for custom conversions)
	static _convertCode(&code)
	{
	}

}
;################################################################################
class MLSTR extends PreMask
{
; for multi-line strings (non expression equals)

;	convCode := ''

	; PUBLIC - finds tags within code and replaces the tags with converted code
	static RestoreAll(&code, mType)
	{
		; setup unique tag id
		tagChar := (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
		pref	:= '#TAG' . tagChar . mType . "\w+"
		trail	:= tagChar . '#'
		pattern	:= pref . trail
		; search/replace tags with original code
		while (pos := RegExMatch(code, pattern, &m)) ;, pos))
		{
			mCode	:= m[]
			oCode	:= MLSTR.masklist[mCode].origCode		; get original code from mask object
			MLSTR._convertCode(&oCode)						; THIS IS THE LINE THAT IS DIFFERENT FROM PreMask class
			code	:= StrReplace(code, mcode, oCode)		; replace - should only be 1 occurence
		}
	}

	; 2024-07-01, ADDED, AMB - fix for Issue #74
	Static _convertCode(&code)
	{
		if(RegExMatch(code, gMQSPtn, &m)) ;, pos))	; should only be 1 occurence (pos not needed)
		{
			blk := m[], doPreMask_remove(&blk)
			; if block has no variable, convert normally
			if (!(blk~='im)%[a-z]\w*%')) {
				code := trim(_convertLines(blk), "`r`n")
			}
			; block has a variable - convert each line separately
			else
			{
				blkLines		:= StrSplit(blk, "`n", "`r")
				nDeclare		:= '^(?i)(\h*[_a-z]\w*\h*=)'	; non-expression equals
				varEquals		:= RegExReplace(blk, '(?s)' nDeclare '.*$', '$1')
				ExpVarEquals	:= RegExReplace(varEquals, '=', ':=',,1)
				newStr			:= ''
				for idx, line in blkLines
				{
					; if var declaration line
					if (idx=1 && (line~=nDeclare)) {
						newStr := ExpVarEquals								; replace legacy equals with expression equals
						continue
					}
					; if no variable on this line, convert normally
					if (!(line~='im)%[a-z]\w*%')) {
						newStr	.= '`r`n' . trim(_convertLines(line), "`r`n")
						continue
					}
					; has a variable on this line - make adj and let _convertLines() handle it
					RegExMatch(line, '^(?<LWS>\h*)(?<EXP>.*)$', &lineParts)	; preserve leading whitespce
					tempExp		:= varEquals . lineParts.EXP				; add var declaration for pass to _convertLines()
					convLine	:= trim(_convertLines(tempExp), '`r`n')		; convert
					; restore any leading whitespace, and remove var declaration
					convLine	:= lineParts.LWS . RegExReplace(convLine, '\Q' ExpVarEquals '\E(.*)', '$1')
					newStr		.= '`r`n' . convLine						; save results
				}
				code := newStr
			}
		}
	}
}
;################################################################################
															 maskMLStrings(&code)
;################################################################################
{
; 2024-06-30 ADDED, AMB
; masks multiline strings
; MLSTR class is custom masking and convert class for multiline strings

	doPreMask(&code)	; restore is handled in Convert() of ConvertFuncs.ahk
	MLSTR.MaskAll(&code, 'MQS', gMQSPtn)
	return
}
;################################################################################
														  restoreMLStrings(&code)
;################################################################################
{
; 2024-06-30 ADDED, AMB
; restore multiline strings
; called from Convert() of ConvertFuncs.ahk

	MLSTR.RestoreAll(&code, 'MQS')	; converts multiline string code as part of restore
	return
}
;################################################################################
															   maskStrings(&code)
;################################################################################
{
; 2024-04-08 ADDED andymbody
; 2024-06-02 UPDATED
; 2024-06-26 MOVED from ConvertFuncs.ahk. Just a proxy now
; masks quoted-strings
	PreMask.MaskQS(&code)
	return
}
;################################################################################
															restoreStrings(&code)
;################################################################################
{
; 2024-04-08 ADDED, andymbody
; 2024-06-26 MOVED from ConvertFuncs.ahk. Just a proxy now
; restores orig strings that were masked by maskStrings()
	PreMask.RestoreQS(&code)
	return
}
;################################################################################
																maskBlocks(&code)
;################################################################################
{
; proxy to mask classes and functions
	NodeMap.MaskBlocks(&code)
	return
}
;################################################################################
															 restoreBlocks(&code)
;################################################################################
{
; proxy to restore classes and functions
	NodeMap.RestoreBlocks(&code)
	return
}
;################################################################################
																 doPreMask(&code)
;################################################################################
{
; pre-mask block/line comments and strings
; necessary to remove characters that can interfere with...
;	detection of blocked code (classes, functions, etc)

	; ORDER MATTERS!
	PreMask.MaskBC(&code)		; mask block comments
	PreMask.MaskLC(&code)		; mask line comments
	PreMask.MaskQS(&code)		; mask quoted strings
	return
}
;################################################################################
														  doPreMask_remove(&code)
;################################################################################
{
; restore comments and strings that were premasked

	; ORDER MATTERS!			(must be in reverse of masking)
	PreMask.RestoreQS(&code)	; restore quoted strings
	PreMask.RestoreLC(&code)	; restore line comments
	PreMask.RestoreBC(&code)	; restore block comments
	return
}
;################################################################################
																   buildPtn_CLS()
;################################################################################
{
; CLASS-BLOCK pattern of my own design

	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:(?<=\s|);[^\v]*)'								; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'					; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*'							; optional line comment OR tag
	TCT			:= '(?>\s*' . CT . ')*'									; optional trailing comment or tag (MUST BE ATOMIC)
	cName		:= '(?<cName>[_a-z]\w*)'								; cName		- captures class name
	cExtends	:= '(?:(\h+EXTENDS\h+[_a-z]\w*)?)'						; cExtends	- support extends keyword
	declare		:= '^\h*\bCLASS\b\h+' . cName . cExtends				; declare	- class declaration
	brcBlk		:= '\s*(?<brcBlk>\{(?<BBC>(?>[^{}]|\{(?&BBC)})*+)})'	; brcBlk	- braces block, BBC - block contents (allows multiline span)
	pattern		:= opt . '(?<declare>' declare . TCT . ')' . brcBlk
;	A_Clipboard := pattern
	return		pattern
}
;################################################################################
																  buildPtn_FUNC()
;################################################################################
{
; FUNCTION-BLOCK pattern of my own design
; supports class methods also (can begin with underscore)

	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:(?<=\s|);[^\v]*)'								; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'					; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*'							; optional line comment OR tag
	TCT			:= '(?>\s*' . CT . ')*'									; optional trailing comment or tag (MUST BE ATOMIC)
	exclude		:= '(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|'					; \K|		- cool trick I made to prevent If/While/Loop from being captured
	fName		:= '(?<fName>[_a-z]\w*)'								; fName		- captures function/method name
	fArgG		:= '(?<fArgG>\((?<Args>(?>[^()]|\((?&Args)\))*+)\))'	; fArgG		- argument group (in parenth), Args - indv args (allows multiline span)
	declare		:= fName . fArgG . TCT									; declare	- function declaration
	brcBlk		:= '\s*(?<brcBlk>\{(?<BBC>(?>[^{}]|\{(?&BBC)})*+)}))'	; brcBlk	- braces block, BBC - block contents (allows multiline span)
	pattern		:= opt . '^\h*(?:' . exclude . declare . brcBlk
;	A_Clipboard := pattern
	return		pattern
}
;################################################################################
																  buildPtn_MSTR()
;################################################################################
{
; Multi-line string block
; non-expression version [ = ], not [ := ]
; does not support block comments between declaration and opening parenthesis
;	can using masking to support them, or update needle to support raw block comments

	; 2024-07-06, UPDATED for better performance
	opt 		:= '(*UCP)(?ims)'												; pattern options
	LC			:= '(?:(?<=\s);[^\v]*)'											; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'							; mask tags
	CT			:= '(?<CT>(?:\s*+(?:' LC '|' TG '))*)'							; optional line comment OR tag
	var			:= '(?<var>[_a-z]\w*)\h*=\h*'									; var	- variable name
	body		:= '\h*\R+(?<blk>\h*\((?<guts>(?:\R*(?>[^\v]*))*?)\R+\h*+\))'	; body	- block body with parentheses and guts
	pattern		:= opt . var . CT . body
	; changed to line-at-a-time vs character-at-a-time -> 4-5 times faster, only fooled if original code syntax is incorrect
	; (*UCP)(?ims)(?<var>[_a-z]\w*)\h*=\h*(?<CT>(?:\s*+(?:(?:(?<=\s);[^\v]*)|(?:#TAG★\w+★#)))*+)\h*\R+(?<blk>\h*\((?<guts>(?:\R*(?>[^\v]*))*?)\R+\h*+\))
;	A_Clipboard := pattern
;	ExitApp
	return pattern
}