#Include <v2DynGui> ; V1toV2: v2DynGui.ahk in library folder
#Warn Unreachable, Off
mV2Gui[""] := NewV2Gui("",1)
guiHwnd := mV2Gui[""].Hwnd
mV2GC[["","CWindowsSysWOW64SecurityAndMaintenancepng"]] := mV2Gui[""].add("pic",,"C:\Windows\SysWOW64\SecurityAndMaintenance.png")
V2EH("","CWindowsSysWOW64SecurityAndMaintenancepng","Click",BH1.Bind("Normal"))
mV2GC[["","btn1"]] := mV2Gui[""].add("button","x100 w50 h50","btn1")
V2EH("","btn1","Click",BH1.Bind("Normal"))
mV2Gui[""].Title := guiHwnd
mV2Gui[""].show("w275 h325")
MsgBox("Click the PICTURE or BUTTON")

return
BH1:
BH1()
  return

BH2(*) { ; will need params added, or at least (*)
  static c := 0, disabled := false
  c++
  MsgBox("BH2 at your service!`nVisit: " c)
  if (c > 3 && !disabled) {
    disabled := true
    ; either of these will disable eh for PICTURE only
    ;GuiControl,  -g, static1, % f
    V2EH("","static1","",f,0) ; V1toV2: Event disabled
    ;GuiControl, +g, static1
    MsgBox("Event handler for PICTURE is now DISABLED")
  }
}

;###############  V1toV2 FUNCS  ###############
BH1(A_GuiEvent:="", A_GuiControl:="", Info:="", *) { ; V1toV2: Lbl->Func
  global
  (IsSet(A_GuiControl)) && SetDefaultGui(A_GuiControl)
  A_GuiControl := (A_GuiControl.Name) ? A_GuiControl.Name : (HasProp(A_GuiControl, "Text") ? A_GuiControl.Text : A_GuiControl)
  hdlr2 := "BH2", f := %hdlr2%
  if (A_GuiControl = "btn1") {
    ctrl := "BUTTON"
    ;GuiControl, +g, btn1, % f
    V2EH("","btn1","",f) ; V1toV2: Must MANUALLY ADD params or trailing * to CB func!
  } else {
    ctrl := "PICTURE"
    ;GuiControl, +g, static1, % f
    V2EH("","static1","",f) ; V1toV2: Must MANUALLY ADD params or trailing * to CB func!
  }
  msg := "Click 1 on " ctrl " handled by BH1..."
      . "`n`nClick it again to change handlers!"
  MsgBox(msg)
  return
}