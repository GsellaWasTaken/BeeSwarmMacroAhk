#NoEnv
;Trash Old Files:
FileDelete, %A_ScriptDir%\PlanterLog.txt
FileDelete, %A_ScriptDir%\Choices.txt


MsgBox, 4096, Before you start, keep in mind: `n`n
-A gifted bee in the 3rd lowest spot on the right most column! `n
-No Gifted Hasty Bee If Walking To Convert `n
-Play In Fullscreen Mode `n
-Close The Script = Cntrl E `n
-Reload The Script = Cntrl R `n
-Pause = Cntrl P`n
-Graphics Set to 1 `n
-Player Speed 28`n
-Sprinkler In Slot 1`n
-Planter In Slot 7, With All Three 5, 6, 7,`n
-All hives are supported `n
-If You Are On Laptop Use 100 Precent Screen Scale! `n
-Monitor resolution set to 1920 1080p `n
-Rejoining can be a bit buggy `n
-v.1.3.1

Gui, Color, 4181B2
Gui, Font, s17 Bahnschrift
Gui, +AlwaysOnTop
Gui, Show, Center w300 h150, Wealth Clock,
Gui, Add, Button, x50 y20 w200 h50 gClose_Button, Collect
Gui, Add, Button, x50 y80 w200 h50 gClose_Button, Don't
Return

Close_Button:
Gui, Submit
Wealth_State = %A_GuiControl%

Sleep 250

Gui, Two: Color, 4181B2
Gui, Two: Font, s17 Bahnschrift
Gui, Two: +AlwaysOnTop
Gui, Two: Show, Center w300 h150, Convert
Gui, Two: Add, Button, x50 y20 w200 h50 gClose_Button2, Walk
Gui, Two: Add, Button, x50 y80 w200 h50 gClose_Button2, Reset
return

Close_Button2:
Gui, Two: Submit
Convert_State = %A_GuiControl%

Sleep 250

Gui, Three: Color, 4181B2
Gui, Three: Font, s17 Bahnschrift
Gui, Three: +AlwaysOnTop
Gui, Three: Show, Center w300 h150, Sprinkler Count
Gui, Three: Add, Button, x30 y20 w110 h50 gClose_Button3, 1
Gui, Three: Add, Button, x30 y80 w110 h50 gClose_Button3, 2
Gui, Three: Add, Button, x160 y20 w110 h50 gClose_Button3, 3
Gui, Three: Add, Button, x160 y80 w110 h50 gClose_Button3, 4
return

Close_Button3:
Gui, Three: Submit
Sprinkler_State = %A_GuiControl%

Sleep 250

Gui, Four: Color, 4181B2
Gui, Four: Font, s17 Bahnschrift
Gui, Four: +AlwaysOnTop
Gui, Four: Show, Center w300 h150, All 3 Planters
Gui, Four: Add, Button, x50 y20 w200 h50 gClose_Button4, Use
Gui, Four: Add, Button, x50 y80 w200 h50 gClose_Button4, Don't Use
return

Close_Button4:
Gui, Four: Submit
Planter_State = %A_GuiControl%

Sleep 250

If Not FileExist(FileName := "Choices.txt")
FileAppend,
(
Wealth`tConvert`tSprinkler`tPlanter
%Wealth_State%`t%Convert_State%`t%Sprinkler_State%`t%Planter_State%
), %FileName%

Sleep 2000

Run, Bee-Swarm_Pine-Forest_Macro.Ahk

If (Planter_State = "Use")
{
    Run, PlanterTimer.Ahk
}

ExitApp

^e::
ExitApp

GuiClose:
ExitApp