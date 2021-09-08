class YunitWindow
{
	__new(instance)
	{
		global YunitWindowTitle, YunitWindowEntries, YunitWindowStatusBar
		width := 500
		height := 400
		MyGui := Gui(,"YUnit Output")
		MyGui.SetFont("s16", "Arial")
		MyGui.Add("Text", "x10 y1 h30 vYunitWindowTitle Center", "Test Results")
		
		hImageList := IL_Create()
		IL_Add(hImageList,"shell32.dll",132) ;red X
		IL_Add(hImageList,"shell32.dll",78) ;yellow triangle with exclamation mark
		IL_Add(hImageList,"shell32.dll",147) ;green up arrow
		IL_Add(hImageList,"shell32.dll",135) ;two sheets of paper
		this.icons := {fail: "Icon1", issue: "Icon2", pass: "Icon3", detail: "Icon4"}
		
		MyGui.SetFont("s10")
		this.tv := MyGui.Add("TreeView","x10 y30 w" . (width-20) . " h" . (height-60) . " vYunitWindowEntries")
		this.tv.SetImageList(hImageList)
		this.tv.OnEvent("ContextMenu", TV_ContextMenu)
		MyGui.SetFont("s8")
		MyGui.Add("StatusBar","vYunitWindowStatusBar -Theme BackgroundGreen")
		MyGui.Opt("+Resize +MinSize320x200")
                MyGui.Title := "Yunit Testing"
		MyGui.Show("w" . width . " h" . height)
		MyGui.Opt("+LastFound")
		
		MyGui.OnEvent("Close", YUnit_OnClose) 
		MyGui.OnEvent("Size", YUnit_OnSize) 
		
		this.gui := MyGui
		
		this.Categories := Map()
		this.tests := {}
		this.tests.pass := 0
		this.tests.fail := 0
		Return this
	}
	
	Update(Category, TestName, Result)
	{
		If !this.Categories.Has(Category)
			this.AddCategories(Category)
		Parent := this.Categories[Category]
		if Result is Error
		{
			this.tests.fail := this.tests.fail + 1
			hChildNode := this.tv.Add(TestName,Parent,this.icons.fail)
			str := "Line #" result.line ": " result.message " (" result.file ")"
			this.tv.Add(str,hChildNode,this.icons.detail)
			this.gui["YunitWindowStatusBar"].Opt("+BackgroundRed")
			key := category
			pos := 1
			while (pos)
			{
				this.tv.Modify(this.Categories[key], "Expand " this.icons.issue)
				pos := InStr(key, ".", false, (VerCompare(A_AhkVersion, "2.0-a033") < 0) ? 0 : -1)
				key := SubStr(key, 1, pos-1)
			}
			this.tv.Modify(Parent, "Expand")
		}
		Else 
		{
			this.tests.pass := this.tests.pass + 1
			this.tv.Add(TestName,Parent,this.icons.pass)
		}
		str := "Number of tests: " . this.tests.fail + this.tests.pass . " ( " . this.tests.fail . " failed / " . this.tests.pass . " passed)"
		this.gui["YunitWindowStatusBar"].text := str
		this.tv.Modify(this.tv.GetNext(), "VisFirst")   ;// scroll the treeview back to the top
	}
	
	AddCategories(Categories)
	{
		Parent := 0
		Category := ""
		Categories_Array := StrSplit(Categories, ".")
		for k,v in Categories_Array
		{
			Category .= (Category == "" ? "" : ".") v
			If (!this.Categories.Has(Category))
				this.Categories[Category] := this.tv.Add(v, Parent, this.icons.pass)
			Parent := this.Categories[Category]
		}
	}

}

TV_ContextMenu(thisCtrl,Item,*){
	Text := thisCtrl.GetText(Item)
	TVMenu := Menu()
	BoundFunc := SetClipboard.Bind(Text)
    TVMenu.Add("Copy [" Text "]" , BoundFunc)
	TVMenu.Show
}

YUnit_OnClose(Gui) {
  ExitApp
}

YUnit_OnSize(MyGui, EventInfo, Width, Height) {
  MyGui["YunitWindowTitle"].Move(,, Width, )
  MyGui["YunitWindowEntries"].Move(,, Width - 20, Height - 60)
  MyGui.Opt("+LastFound")
  DllCall("user32.dll\InvalidateRect", "uInt", WinExist(), "uInt", 0, "uInt", 1)
  Return
}

SetClipboard(Clipboard,*){
	A_Clipboard := Clipboard
	Return
}
