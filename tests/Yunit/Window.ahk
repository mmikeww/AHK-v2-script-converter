class YunitWindow
{
	__new(instance)
	{
		global YunitWindowTitle, YunitWindowEntries, YunitWindowStatusBar
		width := 500
		height := 400
		MyGui := GuiCreate(,"YUnit Output")
		MyGui.SetFont("s16, Arial")
		MyGui.Add("Text", "x0 y0 h30 vYunitWindowTitle Center", "Test Results")
		
		hImageList := IL_Create()
		IL_Add(hImageList,"shell32.dll",132) ;red X
		IL_Add(hImageList,"shell32.dll",78) ;yellow triangle with exclamation mark
		IL_Add(hImageList,"shell32.dll",147) ;green up arrow
		IL_Add(hImageList,"shell32.dll",135) ;two sheets of paper
		this.icons := {fail: "Icon1", issue: "Icon2", pass: "Icon3", detail: "Icon4"}
		
		MyGui.SetFont("s10")
		this.tv := MyGui.Add("TreeView","x10 y30 w" . (width-20) . " h" . (height-60) . " vYunitWindowEntries")
		this.tv.SetImageList(hImageList)
		
		MyGui.SetFont("s8")
		MyGui.Add("StatusBar","vYunitWindowStatusBar -Theme BackgroundGreen")
		MyGui.Options("+Resize +MinSize320x200")
		MyGui.Show("w" . width . " h" . height, "Yunit Testing")
		MyGui.Options("+LastFound")
		
		MyGui.OnEvent("Close", "YUnit_OnClose") 
		MyGui.OnEvent("Size", "YUnit_OnSize") 
		
		this.gui := MyGui
		
		this.Categories := {}
		this.tests := {}
		this.tests.pass := 0
		this.tests.fail := 0
		Return this
	}
	
	Update(Category, TestName, Result)
	{
		If !this.Categories.HasKey(Category)
			this.AddCategories(Category)
		Parent := this.Categories[Category]
		If IsObject(result)
		{
			this.tests.fail := this.tests.fail + 1
			hChildNode := this.tv.Add(TestName,Parent,this.icons.fail)
			str := "Line #" result.line ": " result.message " (" result.file ")"
			this.tv.Add(str,hChildNode,this.icons.detail)
			this.gui.Control["YunitWindowStatusBar"].Opt("+BackgroundRed")
			key := category
			pos := 1
			while (pos)
			{
				this.tv.Modify(this.Categories[key], "Expand " this.icons.issue)
				pos := InStr(key, ".", false, (A_AhkVersion < "2") ? 0 : -1, 1)
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
		this.gui.Control["YunitWindowStatusBar"].text := str
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
			If (!this.Categories.HasKey(Category))
				this.Categories[Category] := this.tv.Add(v, Parent, this.icons.pass)
			Parent := this.Categories[Category]
		}
	}
}

YUnit_OnClose(Gui) {
  ExitApp
}

YUnit_OnSize(MyGui, EventInfo, Width, Height) {
  MyGui.Control["YunitWindowTitle"].Move("w" . Width)
  MyGui.Control["YunitWindowEntries"].Move("w" . (Width - 20) . " h" . (Height - 60))
  MyGui.Options("+LastFound")
  DllCall("user32.dll\InvalidateRect", "uInt", WinExist(), "uInt", 0, "uInt", 1)
  Return
}

