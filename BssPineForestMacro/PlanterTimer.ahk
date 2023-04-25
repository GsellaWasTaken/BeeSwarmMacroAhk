#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%

CounterFile := "TillCollection.txt"
FileName := "PlanterLog.txt"

If Not FileExist(CounterFile)
{
    FileAppend, ,%CounterFile%
}
Sleep 100
If Not FileExist(FileName)
{
    FileAppend,Log1`tLog2`tLog3`nPlanter1Wait`tPlanter2Wait`tPlanter3Wait, %FileName%
}

start:
Toggle = 1
While Toggle
{
    Loop
    {
        Sleep 60000
        FileAppend,i, %CounterFile%
        FileRead, Count, %CounterFile%
        Sleep 500
        If (Count = "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
        {
            goto, fileNew
        }
    }
}

fileNew:
If (Count = "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
{
    Sleep 500
    FileDelete, %FileName%
    Sleep 500
    FileDelete, %CounterFile%
    Count := ""
    Sleep 250
    FileAppend,Log1`tLog2`tLog3`nPlanter1Done`tPlanter2Done`tPlanter3Done, %FileName%
}
Sleep 250
goto, start

F5::ExitApp