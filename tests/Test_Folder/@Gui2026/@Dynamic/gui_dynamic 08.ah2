; V1toV2: Must place v2DynGui.ahk in library folder
#Include <v2DynGui>
#Warn Unreachable, Off

global ColorList := ["000000","7F7F7F","880015","ED1C24","FF7F27","FFF200","22B14C","00A2E8","3F48CC","A349A4","FFFFFF","C3C3C3","B97A57","FFAEC9","FFC90E","EFE4B0","B5E61D","99D9EA","7092BE","C8BFE7"]
global ALED,Thickness

ft := 0
if(1) { ;showgui:=!showgui){
  if(!ft){
    ft:=1
    If (!HasV2Gui("99")) {
      mV2Gui["99"] := NewV2Gui("99")
    }
    mV2Gui["99"].Opt("+AlwaysOnTop +ToolWindow")
    mV2Gui["99"].BackColor := ColorList[1] ;, 333333
    mV2Gui["99"].SetFont("s8","Segoe UI")
    y:=0,x:=m:=20,w:=m,C:="00ffff"
    mV2Gui["99"].MarginX := 20, mV2Gui["99"].MarginY := 20
    Loop ColorList.Length  {
      if(A_Index=11)
        x:=m+w,y:=0
      y+=m
      mV2GC[["99","c1_" a_index]] := mV2Gui["99"].Add("Text","x" x " y" y " w" m " h" m " vc1_" a_index,"x")
      f_hwnd := mV2GC[["99","c1_" a_index]].hwnd
      mV2GC[["99","c1_" a_index]].OnEvent("Click",ChangeColor.Bind("Normal"))
      mV2GC[["99","c2_" a_index]] := mV2Gui["99"].Add("Progress","x" x " y" y " w" m " h" m " c" ColorList[A_Index] " Background" C " vc2_" a_index,"100")
      b_hwnd := mV2GC[["99","c2_" a_index]].hwnd
      C:="555555"
    }
    mV2GC[["99","ALED"]] := mV2Gui["99"].Add("Edit","xm y+1 w40 r1 Limit2 Center","98")
    ALED := mV2GC[["99","ALED"]].hwnd
    mV2GC[["99","ALED"]].OnEvent("Change",ChangeBrush.Bind("Normal"))
    mV2GC[["99","Thickness"]] := mV2Gui["99"].Add("Edit","xm y+1 w40 r1 Limit2 Center","1")
    Thickness := mV2GC[["99","Thickness"]].hwnd
    mV2GC[["99","Thickness"]].OnEvent("Change",ChangeBrush.Bind("Normal"))
    mV2GC[["99","apply"]] := mV2Gui["99"].Add("button","xm y+2 w40 vapply","APPLY")
    mV2GC[["99","apply"]].OnEvent("Click",handle_apply.Bind("Normal"))
    mV2GC[["99","apply"]].Focus()
  }
  mV2Gui["99"].Title := "Color"
  mV2Gui["99"].Show("x" (A_ScreenWidth//2)+150 " y" (A_ScreenHeight//2)-200)
}

MsgBox("click a color in the palette")

return
ChangeColor:
ChangeColor()
return

ChangeBrush:
ChangeBrush()
return

handle_apply:
handle_apply()
return

;###############  V1toV2 FUNCS  ###############
ChangeColor(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
ci := RegExReplace(A_GuiControl, "^.+_(\d+)$", "$1")
MsgBox("color index := " ci "`ncolor value := [" ColorList[ci] "]")
return
}
;##############################################
ChangeBrush(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("[" "Change Brush to " A_GuiControl "]")
return
}
;##############################################
handle_apply(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
global
A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
MsgBox("[" "Apply" "]")
return
}