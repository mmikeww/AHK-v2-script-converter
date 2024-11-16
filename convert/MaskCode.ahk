; 2026-06-26 ADDED by andymbody to support code block masking
; supports nested classes and functions (as wells as block/line comments and quoted strings for v1 or v2)
; will add more support for other code blocks, AHK funcs, etc as needed
; 2024-07-07 ADDED support for masking multi-line string blocks, removal of block/line comments, string blocks
; All regex needles were designed to support masking tags. Feel free to contact me on AHK forum if I can assist with edits

global	  gTagChar		:= chr(0x2605)
		, gFuncPtn		:= buildPtn_FUNC()																		; function block (supports nesting)
		, gClassPtn		:= buildPtn_CLS()																		; class	   block (supports nesting)
		, gMQSPtn		:= buildPtn_MStr()																		; v1 multi-line string-block (non expression)
		, gIFPtn		:= buildPtn_IF()																		; 2024-08-06 AMB, ADDED
		, gLblPtn		:= buildPtn_Label()																		; 2024-08-06 AMB, ADDED
		, gHotkeyPtn	:= buildPtn_Hotkey()																	; 2024-08-06 AMB, ADDED
		, gHotStrPtn	:= '^:(?<Opts>[^:]+)*:(?<Trig>[^:]+)::'													; 2024-08-06 AMB, ADDED
		; 2024-07-07 AMB, CHANGED to bypass escaped semicolon
		, gLCPtn		:= '(*UCP)(?m)(?<=\s|)(?<!``);[^\v]*'													; line comment (allows lead ws to be consumed already)
		, gBCPtn		:= '(*UCP)(?m)^\h*(/\*((?>[^*/]+|\*[^/]|/[^*])*)(?>(?-2)(?-1))*(?:\*/|\Z))'				; block comments
		, gQSPtn		:= '(*UCP)(?m)(?:`'`'|`'(?>[^`'\v]+(?:(?<=``)`')?)+`'|""|"(?>[^"\v]+(?:(?<=``)")?)+")'	; quoted string	(UPDATED 2024-06-17)
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
				tagChar	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
				tag		:= '#TAG' tagChar '_CLS_' pos tagChar '#', node.tagId := tag
				if ((p:=RegExMatch(code, gClassPtn, &m, pos))=pos)			; node position is known and specific
				{
					mCode := m[], doPreMask_remove(&mCode)					; remove premask of comments and strings
					;node.taggedCode	:= mCode						 	; (not used)
					node.ConvCode := _convertLines(mCode,finalize:=1)		; now convert code to v2
					code := RegExReplace(code, "\Q" m[] "\E", tag,,1,pos)
				}
			}

			; if node is a function
			else if (node.cType='FUNC')
			{
				tagChar	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
				tag		:= '#TAG' tagChar '_FUNC_' pos tagChar '#', node.tagId := tag
				if ((p:=RegExMatch(code, gFuncPtn, &m, pos))=pos)			; node position is known and specific
				{
					mCode := m[], doPreMask_remove(&mCode)					; remove premask of comments and strings
					;node.taggedCode	:= mCode						 	; (not used)
					node.ConvCode	:= _convertLines(mCode,finalize:=1)		; now convert code to v2
					code := RegExReplace(code, "\Q" m[] "\E", tag,,1,pos)
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
	; PUBLIC - convenience/proxy method - mask function calls
	static MaskFC(&code) {
		PreMask.MaskCalls(&code)
	}
	; PUBLIC - convenience/proxy method - mask function calls
	static RestoreFC(&code) {
		PreMask.RestoreAll(&code, 'FC')
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

	; PUBLIC - Mask function calls
	static MaskCalls(&code) {
		if !RegExMatch(code, "\w\(")
			return code

		maskStrings(&code)
		codeSplit        := StrSplit(code)
		codeArray        := [] ; functions, strings and params broken into chunks
		functions        := 0  ; functions found so far
		tempCode         := "" ; store chunk before pushing to codeArray
		index            := 1  ; amount of chunks found including tempCode
		validFunc        := 0  ; tracks if chars before func are valid
		lastBracketValid := [] ; tracks if last bracket was a function
		for , char in codeSplit {
			If RegExMatch(char, "\w") {
				if !validFunc {
					codeArray.Push(tempCode)
					tempCode := ""
					index++
				}
				tempCode .= char
				validFunc := 1
			} else if (char = "(") {
				tempCode .= char
				validFunc ? lastBracketValid.Push(1) : lastBracketValid.Push(0)
				validFunc := 0
			} else if (char = ")" and lastBracketValid[lastBracketValid.Length]) {
				if (codeSplit[A_Index - 1] = "(") {
					codeArray.Push(tempCode)
					index++
					tempCode := ""
				}
				tempCode .= char
				lastBracketValid.Pop()
				codeArray.Push(tempCode) ; index currently equals length
				foundFunc := 0
				chunkedFunc := []
				finishedFunc := ""
				while !foundFunc {
					searchBack := index - A_Index
					elemToCheck := codeArray[searchBack]
					;MsgBox "elemToCheck: " elemToCheck
					If RegExMatch(elemToCheck, "\w\(")
						foundFunc := 1
					chunkedFunc.Push(elemToCheck)
				}
				chunkedFunc.InsertAt(1, codeArray[index])
				index := searchBack + 1
				codeArray.RemoveAt(searchBack, codeArray.Length - searchBack + 1)
				for , chunk in chunkedFunc {
					finishedFunc := chunk finishedFunc ; chunkedFunc is stored backwards
					;MsgBox "finishedFunc: " finishedFunc
				}
				restoreStrings(&finishedFunc)
				functions++
				tagChar := (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
				pref	:= '#TAG' . tagChar . 'FC' . '_' PreMask.GenUniqueID() '_'
				trail	:= tagChar . '#'
				tag     := pref . functions . trail
				PreMask.masklist[tag]	:= PreMask(finishedFunc, tag, 'FC', '')
				codeArray.InsertAt(searchBack, tag)
				tempCode := ""
			} else {
				tempCode .= char
				if (char = ")")
					lastBracketValid.Pop()
				validFunc := 0
			}
			;MsgBox "index: " index "`nvf: " validFunc "`nchar: " char "`ntempCode: " tempCode "`ncode: " code
		}
		codeArray.Push(tempCode)
		code := ""
		for , chunk in codeArray {
			code .= chunk
		}
		restoreStrings(&code)
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
											  getClassNames(code, parentName:="")
;################################################################################
{
; 2024-07-07 AMB, ADDED
; returns an comma-delim stringList of CLASS NAMES extracted from passed code
; parentName can be specified to return only names of children of that parent
;	use  1 or "root" to return only top level class names
;	use -1 to return class names that are not top level (only child-class names)

	return _getNodeNameList(code, "CLS", parentName)
}
;################################################################################
											   getFuncNames(code, parentName:="")
;################################################################################
{
; 2024-07-07 AMB, ADDED
; returns an comma-delim stringList of FUNCTION NAMES extracted from passed code
; parentName can be specified to return only names of children of that parent
;	use  1 or "root" to return only top level functions
;	use -1 to return func names that are not top level (only child-func names)

	return _getNodeNameList(code, "FUNC", parentName)
}
;################################################################################
								 _getNodeNameList(code, nodeType, parentName:="")
;################################################################################
{
; 2024-07-07 AMB, ADDED
; intended to be used internally by this .ahk only
; returns an comma-delim stringList of node names extracted from passed code
; nodeType can be "FUNC" for function names or "CLS" for class names
; parentName can be specified to return only names of children of that parent
;	use  1 or "root" to return only top level nodes names
;	use -1 to return nodes that are not top level (only child-node names)

	parentName := (parentName=1) ? "root" : parentName

	retList := "" ;[]
	nodeList := _getNodeList(code, nodeType)
	for idx, node in nodeList {
		if (!parentName) {
			retList .= node.name . ","
			;retList.Push(node.name)
		}
		else if (parentName=-1 && node.ParentName!="root") {
			retList .= node.name . ","
			;retList.Push(node.name)
		}
		else if (parentName && node.ParentName=parentName) {
			retList .= node.name . ","
			;retList.Push(node.name)
		}
	}
	return retList
}
;################################################################################
													 _getNodeList(code, nodeType)
;################################################################################
{
; 2024-07-07 AMB, ADDED
; returns a list of block nodes of requested type (FUNC, CLS, MQS, etc)
; Those nodes contain the details of the particualr block
; 	additional details can then be extracted from those nodes

	; pre-mask comments and strings
	doPreMask(&code)
	; build node map
	NodeMap.BuildNodeMap(code)

	; go thru node list and extract function names
	nodeList := []
	for key, node in NodeMap.mapList {
		if (node.cType=nodeType) {
			nodeList.Push(node)
		}
	}
	return nodeList
}
;################################################################################
															 maskMLStrings(&code)
;################################################################################
{
; 2024-06-30 ADDED, AMB
; masks multiline strings
; MLSTR class is custom masking and convert class for multiline strings
; called from Before_LineConverts() of ConvertFuncs.ahk

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
; called from After_LineConverts() of ConvertFuncs.ahk

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
; proxy func to mask classes and functions

	NodeMap.MaskBlocks(&code)
	return
}
;################################################################################
															 maskFuncCalls(&code)
;################################################################################
{
; proxy func to mask function calls

	PreMask.MaskFC(&code)
	return
}
;################################################################################
															 restoreFuncCalls(&code)
;################################################################################
{
; proxy func to restore function calls

	PreMask.RestoreFC(&code)
	return
}
;################################################################################
															 restoreBlocks(&code)
;################################################################################
{
; proxy func to restore classes and functions

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
																  removeBCs(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove block comments from passed code

	return RegExReplace(code,gBCPtn)	; remove block comments
}
;################################################################################
																  removeLCs(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove line comments from passed code

	return RegExReplace(code,gLCPtn)	; remove line  comments
}
;################################################################################
															 removeComments(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove block and line comments from passed code

	code := removeBCs(code)				; remove block comments
	return	removeLCs(code)				; remove line  comments
}
;################################################################################
																removeMLStr(code)
;################################################################################
{
; 2024-07-07 AMB, ADDED - remove multi-line strings from passed code

	return RegExReplace(code, gMQSPtn)
}
;################################################################################
														   IsValidV1Label(srcStr)
;################################################################################
{
; returns extracted label if it resembles a valid v1 label
; does not verify that it is a valid v2 label (see validV2Label for that)

	removeLCs(&srcStr), srcStr := trim(srcStr)   ; remove line comments and trim ws
	; return just the label if it resembles a valid v1 label
	if ((srcStr ~= '(?<!:):$') && !(srcStr~='(?:,|\h|``(?!;)(?!%))'))
		return srcStr
	return ''			; not a valid v1 label
}
;################################################################################
																 buildPtn_Label()
;################################################################################
{
; Label
; 2024-08-06 AMB, ADDED

;	opt 		:= '(*UCP)(?im)'										; pattern options
	opt 		:= '(*UCP)(?i)'										; pattern options
	LC			:= '(?:(?<=\s)(?<!``);[^\v]*)'							; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'					; mask tags
	CT			:= '(?<CT>(?:\h*+(?>' LC '|' TG ')))'					; line-comment OR tag
	trail		:= '(?<trail>' . CT . '|\h*(?=\v|$))'					; line-comment, tag, or end of line
	declare		:= '^\h*(?<name>[^;,\s``]+)(?<!:):(?!:)'				; label declaration
	pattern		:= opt . declare . trail
;	A_Clipboard := pattern
	return pattern
}
;################################################################################
																buildPtn_HotKey()
;################################################################################
{
; hotkey
; 2024-08-06, ADDED

	opt 	:= '(?i)'														; pattern options
	k01		:= '(?:[$~]?\*?)'												; special commands
	k02		:= '(?:[<>]?[!^+#]*)*'											; modifiers - short
	k03		:= '[a-z0-9]'													; alpha-numeric
	k04		:= "[.?)(\][}{$|+*^:\\'``-]"									; symbols 1 (regex special)
	k05		:= '(?:``;|[/<>,"~!@#%&=_])'									; symbols 2
	k06		:= '(?:[lrm]?(?:alt|c(?:on)?tro?l|shift|win|button)(?:\h+up)?)'	; modifiers - long
	k07		:= 'numpad(?:\d|end|add)'										; numpad special
	k08		:= 'wheel(?:up|down)'											; mouse
	k09		:= '(?:f|joy)\d+'												; func keys or joystick button
	k10		:= '(?:(?:appskey|bkspc|(?:back)?space|del|delete|'				; named keys
			   . 'end|enter|esc(?:ape)?|home|pgdn|pgdn|pause|tab|'
			   . 'up|dn|down|left|right|(?:caps|scroll)lock)(?:\h+up)?)'
	repeat	:= '(?:\h+(?:&\h+)?(?1))*'										; allow repeated keys
	pattern	:= opt '^\s*' k01 '(' k02 '(?:' k03 '|' k04 '|' k05 '|' k06
			. '|' k07 '|' k08 '|' k09 '|' k10 '))' . repeat . '::' ;.*'
;	A_Clipboard := pattern
;	pattern := '(*UCP)(?im)^\h*(?:[$~]?\*?)((?:[<>]?[!^+#]*)*(?:[a-z0-9]|[.?)(\][}{$|+*^:\\'`-]'
;		. '|(?:`;|[/<>,"~!@#%&=_])|(?:[lrm]?(?:alt|c(?:on)?tro?l|shift|win|button)(?:\h+up)?)|numpad(?:\d|end)|wheel(?:up|down)|(?:f|joy)\d+'
;		. '|(?:(?:appskey|bkspc|backspace|del|delete|end|enter|esc(?:ape)?|home|pgdn|pgdn|pause|tab|up|dn|down|left|right|(?:caps|scroll)lock)'
;		. '(?:\h+up)?)))(?:\h+(&\h+)?(?1))*::'
	return pattern
}
;################################################################################
																   buildPtn_CLS()
;################################################################################
{
; CLASS-BLOCK pattern

	; 2024-07-07 UPDATED comment needle to bypass escaped semicolon
	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:(?<=\s|)(?<!``);[^\v]*)'							; line comment (allows lead ws to be consumed already)
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
; FUNCTION-BLOCK pattern - supports class methods also

	; 2024-07-07 UPDATED comment needle to bypass escaped semicolon
	opt 		:= '(*UCP)(?im)'										; pattern options
	LC			:= '(?:(?<=\s|)(?<!``);[^\v]*)'							; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'					; mask tags
	CT			:= '(?:' . LC . '|' . TG . ')*'							; optional line comment OR tag
	TCT			:= '(?>\s*' . CT . ')*'									; optional trailing comment or tag (MUST BE ATOMIC)
	exclude		:= '(?:\b(?:IF|WHILE|LOOP)\b)(?=\()\K|'					; \K|		- added to prevent If/While/Loop from being captured
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
; does not currently support block comments between declaration and opening parenthesis
;	can using masking to support them, or update needle to support raw block comments

	; 2024-07-07, UPDATED for better performance, updated comment needle to bypass escaped semicolon
	opt 		:= '(*UCP)(?ims)'												; pattern options
	LC			:= '(?:(?<=\s)(?<!``);[^\v]*)'									; line comment (allows lead ws to be consumed already)
	tagChar 	:= (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG			:= '(?:#TAG' tagChar '\w+' tagChar '#)'							; mask tags
;	CT			:= '(?<CT>(?:\s*+(?:' LC '|' TG '))*)'							; optional line comment OR tag
	CT			:= '(?<CT>(?:\s*+(?>' LC '|' TG '))*)'							; optional line comment OR tag
	var			:= '(?<var>[_a-z]\w*)\h*=\h*'									; var	- variable name
	body		:= '\h*\R+(?<blk>\h*\((?<guts>(?:\R*(?>[^\v]*))*?)\R+\h*+\))'	; body	- block body with parentheses and guts
	pattern		:= opt . var . CT . body
	; changed to line-at-a-time rather than char-at-a-time -> 4-5 times faster, only fooled if original code syntax is incorrect
	; (*UCP)(?ims)(?<var>[_a-z]\w*)\h*=\h*(?<CT>(?:\s*+(?:(?:(?<=\s)(?<!``);[^\v]*)|(?:#TAG★\w+★#)))*+)\h*\R+(?<blk>\h*\((?<guts>(?:\R*(?>[^\v]*))*?)\R+\h*+\))
;	A_Clipboard := pattern
	return pattern
}
;################################################################################
																	buildPtn_IF()
;################################################################################
{
; IF block
; 2024-08-06 AMB, ADDED - WORK IN PROGRESS

	opt 	:= '(*UCP)(?im)'												; pattern options
	noPth	:= '(?:.*)'														; no parentheses
	noBB	:= noPth														; no braces block
	LC		:= '(?:(?<=\s)(?<!``);[^\v]*)'									; line comment (allows lead space to be consumed already
	tagChar := (IsSet(gTagChar)) ? gTagChar : chr(0x2605)
	TG		:= '(?:#TAG' tagChar '\w+' tagChar '#)'							; mask tags
	CT		:= '(?:' . LC . '|' . TG . ')*'									; optional line comment OR tag
	TCT		:= '(?>\s*' . CT . ')*'											; optional trailing comment or tag (MUST BE ATOMIC)

	; IF portion
	ifPth	:= '(?<ifPth>(?:!*\s*)*\((?<ifPC>(?>[^()]|\((?&ifPC)\))*+)\))'	; ifPth		- (optional) parentheses, ifPC - parentheses contents (allows multiline span)
	ifArg	:= '(?<ifArg>(?:\h*' . ifPth . ')|(?:\h+' . noPth . '))' . TCT	; ifArg		- arguments (conditions and optional trailing comments/tags)
	ifBB	:= '(?<ifBB>\{(?<ifBBC>(?>[^{}]|\{(?&ifBBC)})*+)})'				; ifBB		- (optional) block with braces, ifBBC - brace block contents
	ifBlk	:= '(?<ifBlk>\s+(?:' . ifBB . '|' . noBB . '))'					; ifBlk		- block (either brace block or single line)
	ifStr	:= '(?<ifStr>\h*\bIF\b' . ifArg . ifBlk . ')'					; ifStr		- IF block string
	ifBLCT	:= '(?<ifBLCT>' . TCT . ')'										; ifBLCT	- (optional) trailing blank lines, comments and tags
	; ELSEIF portion
	efPth	:= '(?<efPth>(?:!*\s*)*\((?<efPC>(?>[^()]|\((?&efPC)\))*+)\))'	; efPth		- (optional) parentheses, efPC - parentheses contents (allows multiline span)
	efArg	:= '(?<efArg>(?:\h*' . efPth . ')|(?:\h+' . noPth . '))' . TCT	; efArg		- arguments (conditions and optional trailing comments/tags)
	efBB	:= '(?<efBB>\{(?<efBBC>(?>[^{}]|\{(?&efBBC)})*+)})'				; efBB		- (optional) block with braces (only captures last ELSEIF), efBBC - brace block contents
	efBlk	:= '(?<efBlk>\s+(?:' . efBB . '|' . noBB . '))'					; efBlk		- block (either brace block or single line)
	efStr	:= '(?<efStr>\bELSE\h+IF\b' . efArg . efBlk . ')'				; efStr		- ELSEIF block string
	efBLCT	:= '(?<efBLCT>' . TCT . ')'										; efBLCT	- (optional) trailing blank lines, comments and tags
	; ELSE portion
	eBB		:= '(?<eBB>\{(?<eBBC>(?>[^{}]|\{(?&eBBC)})*+)})'				; eBB		- (optional) block with braces, eBBC - brace block contents
	eBlk	:= '(?<eBlk>\s+(?:(?:' . eBB . ')|(?:' . noBB . ')))'			; eBlk		- block (either brace block or single line)
	eStr	:= '(?<eStr>\s*\bELSE\b' . eBLK . ')'							; eStr		- ELSE block string
;	pattern := opt . ifStr . ifBLCT . '(' . efStr . efBLCT . '|' . eStr . ')*'

;	A_Clipboard := pattern

	; 2024-06-18 - simplified version - work in progress
	pattern := '(?im)^\h*\bIF\b(?<all>(?>(?>\h*(!?\((?>[^)(]+|(?-1))*\))|[^;&|{\v]+|\s*(?>and|or|&&|\|\|))+)(?<brc>\s*\{(?>[^}{]+|(?-1))*\}))((\s*\bELSE IF\b(?&all))*)((\s*\bELSE\b(?&brc))*)'
	return pattern
}
