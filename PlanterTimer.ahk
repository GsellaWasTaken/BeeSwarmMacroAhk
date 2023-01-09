#NoEnv
SetWorkingDir %A_ScriptDir%
;Change the values at your own risk

Toggle = 1
While Toggle
{
    Counter = 0
    Loop
    {
        Counter ++
        PlantWaitDone := "Log `nPlanterDone"
        If (Counter = 240) ;240 minutes
            {
            If FileExist("PlanterLog.txt")
            {
                FileDelete, PlanterLog.txt
            }
            Sleep 250
            FileAppend, %PlantWaitDone%, PlanterLog.txt
            Counter = 0
            }
        Sleep 60000 ;60 seconds
    }
}

^p::Pause
^e::ExitApp