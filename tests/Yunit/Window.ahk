class YunitWindow
{
    __new(instance)
    {
        global YunitWindowTitle, YunitWindowEntries, YunitWindowStatusBar
        Gui, Yunit:Font, s16, Arial
        Gui, Yunit:Add, Text, x0 y0 h30 vYunitWindowTitle Center, Test Results
        
        hImageList := IL_Create()
        IL_Add(hImageList,"shell32.dll",132) ;red X
        IL_Add(hImageList,"shell32.dll",78) ;yellow triangle with exclamation mark
        IL_Add(hImageList,"shell32.dll",147) ;green up arrow
        IL_Add(hImageList,"shell32.dll",135) ;two sheets of paper
        this.icons := {fail: "Icon1", issue: "Icon2", pass: "Icon3", detail: "Icon4"}
        
        Gui, Yunit:Font, s10
        Gui, Yunit:Add, TreeView, x10 y30 vYunitWindowEntries ImageList%hImageList%
        
        Gui, Yunit:Font, s8
        Gui, Yunit:Add, StatusBar, vYunitWindowStatusBar -Theme BackgroundGreen
        Gui, Yunit:+Resize +MinSize320x200
        Gui, Yunit:Show, w500 h400, Yunit Testing
        Gui, Yunit:+LastFound
        
        this.Categories := {}
        Return this
        
        YunitGuiSize:
        GuiControl, Yunit:Move, YunitWindowTitle, w%A_GuiWidth%
        GuiControl, Yunit:Move, YunitWindowEntries, % "w" . (A_GuiWidth - 20) . " h" . (A_GuiHeight - 60)
        Gui, Yunit:+LastFound
        DllCall("user32.dll\InvalidateRect", "uInt", WinExist(), "uInt", 0, "uInt", 1)
        Return
        
        YunitGuiClose:
        ExitApp
    }
    
    Update(Category, TestName, Result)
    {
        Gui, Yunit:Default
        If !this.Categories.HasKey(Category)
            this.AddCategories(Category)
        Parent := this.Categories[Category]
        If IsObject(result)
        {
            hChildNode := TV_Add(TestName,Parent,this.icons.fail)
            TV_Add("Line #" result.line ": " result.message,hChildNode,this.icons.detail)
            GuiControl, Yunit: +BackgroundRed, YunitWindowStatusBar
            key := category
            pos := 1
            while (pos)
            {
                TV_Modify(this.Categories[key], this.icons.issue)
                pos := InStr(key, ".", false, (A_AhkVersion < "2") ? 0 : -1, 1)
                key := SubStr(key, 1, pos-1)
            }
        }
        Else
            TV_Add(TestName,Parent,this.icons.pass)
        TV_Modify(Parent, "Expand")
        TV_Modify(TV_GetNext(), "VisFirst")   ;// scroll the treeview back to the top
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
                this.Categories[Category] := TV_Add(v, Parent, this.icons.pass)
            Parent := this.Categories[Category]
        }
    }
}
