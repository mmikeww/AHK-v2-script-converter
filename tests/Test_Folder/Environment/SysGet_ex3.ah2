MonitorCount := MonitorGetCount()
MonitorPrimary := MonitorGetPrimary()
MsgBox("Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary)
Loop MonitorCount
{
    MonitorName := MonitorGetName(A_Index)
    MonitorGet(A_Index, &MonitorLeft, &MonitorTop, &MonitorRight, &MonitorBottom)
    MonitorGetWorkArea(A_Index, &MonitorWorkAreaLeft, &MonitorWorkAreaTop, &MonitorWorkAreaRight, &MonitorWorkAreaBottom)
    MsgBox("Monitor:`t#" A_Index "`nName:`t" MonitorName "`nLeft:`t" MonitorLeft " (" MonitorWorkAreaLeft " work)`nTop:`t" MonitorTop " (" MonitorWorkAreaTop " work)`nRight:`t" MonitorRight " (" MonitorWorkAreaRight " work)`nBottom:`t" MonitorBottom " (" MonitorWorkAreaBottom " work)")
}