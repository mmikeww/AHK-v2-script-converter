; ==================================================================
; GuiControl_Ex
; ==================================================================

class ListComboBox_Ext {
    Static __New() {
        For prop in this.Prototype.OwnProps() {
            Gui.ListBox.Prototype.%prop% := this.prototype.%prop%
            Gui.ComboBox.Prototype.%prop% := this.prototype.%prop%
        }
    }
    
    GetCount() {
        If (this.Type = "ListBox")
            return SendMessage(0x018B, 0, 0, this.hwnd) ; LB_GETCOUNT
        Else If (this.Type = "ComboBox")
            return SendMessage(0x146, 0, 0, this.hwnd)  ; CB_GETCOUNT
    }
    
    GetText(row) {
        If (this.Type = "ListBox")
            return this._GetString(0x18A,0x189,row) ; 0x18A > LB_GETTEXTLEN // 0x189 > LB_GETTEXT
        Else if (this.Type = "ComboBox")
            return this._GetString(0x149,0x148,row) ; 0x149 > CB_GETLBTEXTLEN // 0x148 > CB_GETLBTEXT
    }
    
    GetItems() {
        result := []
        Loop this.GetCount()
            result.Push(this.GetText(A_Index))
        return result
    }
    
    _GetString(getLen_msg,get_msg,row) {
        size := SendMessage(getLen_msg, row-1, 0, this.hwnd) ; GETTEXTLEN
        buf := Buffer( (size+1) * (StrLen(Chr(0xFFFF))?2:1), 0 )
        SendMessage(get_msg, row-1, buf.ptr, this.hwnd) ; GETTEXT
        return StrGet(buf)
    }
}

class ListView_Ext extends Gui.ListView { ; Technically no need to extend classes unless
    Static __New() { ; you are attaching new base on control creation.
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.Prototype.%prop%
    }
    Checked(row) { ; This was taken directly from the AutoHotkey help files.
        return (SendMessage(4140,row-1,0xF000,, "ahk_id " this.hwnd) >> 12) - 1 ; VM_GETITEMSTATE = 4140 / LVIS_STATEIMAGEMASK = 0xF000
    }
    IconIndex(row,col:=1) { ; from "just me" LV_EX ; Link: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=69262&p=298308#p299057
        LVITEM := Buffer((A_PtrSize=8)?56:40, 0)                   ; create variable/structure
        NumPut("UInt", 0x2, "Int", row-1, "Int", col-1, LVITEM.ptr, 0)  ; LVIF_IMAGE := 0x2 / iItem (row) / column num
        NumPut("Int", 0, LVITEM.ptr, (A_PtrSize=8)?36:28)               ; iImage
        SendMessage(StrLen(Chr(0xFFFF))?0x104B:0x1005, 0, LVITEM.ptr,, "ahk_id " this.hwnd) ; LVM_GETITEMA/W := 0x1005 / 0x104B
        return NumGet(LVITEM.ptr, (A_PtrSize=8)?36:28, "Int")+1 ;iImage
    }
    GetColWidth(n) {
        return SendMessage(0x101D, n-1, 0, this.hwnd)
    }
}

class StatusBar_Ext extends Gui.StatusBar {
    Static __New() {
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.Prototype.%prop%
    }
    RemoveIcon(part:=1) {
        hIcon := SendMessage(0x414, part-1, 0, this.hwnd)
        If hIcon
            SendMessage(0x40F, part-1, 0, this.hwnd)
        return DllCall("DestroyIcon","UPtr",hIcon)
    }
}

class PicButton extends Gui.Button {
    Static __New() {
        Gui.Prototype.AddPicButton := this.AddPicButton
    }
    Static AddPicButton(sOptions:="",sPicFile:="",sPicFileOpt:="") {
        ctl := this.Add("Button",sOptions)
        ctl.base := PicButton.Prototype
        ctl.SetImg(sPicFile, sPicFileOpt)
        return ctl
    }
    SetImg(sFile, sOptions:="") { ; input params exact same as first 2 params of LoadPicture()
        Static ImgType := 0       ; thanks to teadrinker: https://www.autohotkey.com/boards/viewtopic.php?p=299834#p299834
        Static BS_ICON := 0x40, BS_BITMAP := 0x80, BM_SETIMAGE := 0xF7
        
        hImg := LoadPicture(sFile, sOptions, &_type)
        curStyle := ControlGetStyle(this.hwnd)
        ControlSetStyle (curStyle | (!_type?BS_BITMAP:BS_ICON)), this.hwnd
        hOldImg := SendMessage(BM_SETIMAGE, _type, hImg, this.hwnd)
        
        If (hOldImg)
            (ImgType) ? DllCall("DestroyIcon","UPtr",hOldImg) : DllCall("DeleteObject","UPtr",hOldImg)
        
        ImgType := _type ; store current img type for next call/release
    }
    Type {
        get => "PicButton"
    }
}

class SplitButton extends Gui.Button {
    Static __New() {
        super.Prototype.SetImg := PicButton.Prototype.SetImg
        Gui.Prototype.AddSplitButton := this.AddSplitButton
    }
    Static AddSplitButton(sOptions:="",sText:="",callback:="") {
        Static BS_SPLITBUTTON := 0xC
        
        ctl := this.Add("Button",sOptions,sText)
        ctl.base := SplitButton.Prototype
        
        ControlSetStyle (ControlGetStyle(ctl.hwnd) | BS_SPLITBUTTON), ctl.hwnd
        If callback
            ctl.callback := callback
          , ctl.OnNotify(-1248, ObjBindMethod(ctl,"DropCallback"))
            
        return ctl
    }
    Drop() {
        this.DropCallback(this,0)
    }
    DropCallback(ctl, lParam) {
        ctl.GetPos(&x,&y,,&h)
        f := this.callback, f(ctl,{x:x, y:y+h})
    }
    Type {
        get => "SplitButton"
    }
}

class ToggleButton extends Gui.Checkbox {
    Static __New() {
        super.Prototype.SetImg := PicButton.Prototype.SetImg
        Gui.Prototype.AddToggleButton := this.AddToggleButton
    }
    Static AddToggleButton(sOptions:="",sText:="") {
        ctl := this.Add("Checkbox",sOptions " +0x1000",sText)
        ctl.base := ToggleButton.Prototype
        return ctl
    }
    Type {
        get => "ToggleButton"
    }
}

class Edit_Ext extends Gui.Edit {
    Static __New() {
        For prop in this.Prototype.OwnProps()
            super.Prototype.%prop% := this.prototype.%prop%
    }
    Append(txt, top := false) {
        txtLen := SendMessage(0x000E, 0, 0,,this.hwnd)           ;WM_GETTEXTLENGTH
        pos := (!top) ? txtLen : 0
        SendMessage(0x00B1, pos, pos,,this.hwnd)           ;EM_SETSEL
        SendMessage(0x00C2, False, StrPtr(txt),,this.hwnd)    ;EM_REPLACESEL
    }
}
