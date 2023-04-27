#NoEnv
#SingleInstance Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

CoordMode, Pixel, Screen
TimeLineFile = %A_ScriptDir%\Webpage\Timeline.txt
GuiFile := GuiData.txt
PlanterFileName := "PlanterLog.txt"
FieldFile := "Fields.txt"
GuiFile := "GuiChoices.txt"
sprinkList :="1||2|3|4|"
convList :="Walk||Reset|"
gpList :="Standard||"
fieldList :="PineForest||"
attemptfail := 0
collectFail := 0
tillClock := 0
pictureBee = %A_ScriptDir%\Webpage\Images\bee.png
FileInstall, bee.png, %A_ScriptDir%\Webpage\Images
FormatTime, TimeRn,, Time ;Omits time
Run, PlanterTimer.Ahk
goto, start

Guii:
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% In start up Gui`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 250
    Gui Destroy
    Gui, Show, w500 h300
    Gui, Font, s10
    Gui, Add, GroupBox, x25 y0 w450 h275
    Gui, Add, GroupBox, x25 y0 w225 h190
    Gui, Add, GroupBox, x25 y180 w450 h95
    Gui, Add, GroupBox, x154 y201 w302 h37
    Gui, Add, Button, x195 y251 w100 h40 gcloseButton, Confirm
    Gui, Add, Text, y25 x95, Convert route
    Gui, Add, Text, y115 x81, Sprinklers amount
    Gui, Add, Text, y25 x308, Gathering pattern
    Gui, Add, Text, y115 x343, Field
    Gui, Add, Text, y215 x37, Private Server Link:
    Gui, font, s8 cBlue
    Gui, Add, Text, y280 x20, F2=Pause F3=Stop F4=Return Gui
    Gui, Add, Text, y280 x390, Macro version: 1.4
    Gui, Font, s10 cBlack
    Gui, Add, DropDownList, w100 h10 y50 x85 r2 vConvert_State, %convList%
    Gui, Add, DropDownList, w100 h10 y140 x85 r4 vSprinkler_State, %sprinkList%
    Gui, Add, DropDownList, w100 h10 y50 x310 r2 vGather_Style, %gpList%
    Gui, Add, DropDownList, w100 h10 y140 x310 r3 vField, %fieldList%
    Gui, Add, Edit, y210 x155 w300 h25 vpServer_State, %pServer_State%
    Gui, +AlwaysOnTop
    return ;Basic gui

closeButton:
    Gui Submit
    FileDelete, %GuiFile%
    FileAppend,1Choice`n%pServer_State%,%GuiFile%
    If pServer_State =
    {
        pServer_State = https://www.roblox.com/games/4189852503?privateServerLinkCode=79206701614713356673660100749569 ;If no private server this will become the join link
    }
    goto, graphicsDown

graphicsDown:
    Sleep 1000
    Click, Left
    Sleep 250
    PixelGetColor, color, 14, 12 ;Lines 77-84 checks if game is in bordered fullscreen and corrects it to borderless
    MouseMove, 14, 12
	Sleep 250
	IfEqual, color, 0xB9AC9D
    {
        Sleep 750
        Send {F11}
    }
    Sleep 250
    send {w}
    send {a}
    send {s}
    send {d}
    Sleep 50
    Send {shift down} ;Lines 91-97 Sets Graphics quality to lowest
    Sleep 50
    loop 10
    {
    Send {F10}
    Sleep 100
    }
    Send {shift up}
    Sleep 100
    Send {shift}
    Sleep 250
    goto, beginning

beginning: ;Resets player position
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Resetting player`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 250
    Loop 2
    {
        Sleep 250
        send {esc}
        sleep 200
        Send {r}
        Sleep 200
        Send {enter}
        Sleep 9500
        If (attemptFail != 0)
            break
    }
    goto, hiveCheck

hiveCheck: ;Checks to make sure that camera is in correct angle
    FileAppend,At Hive`n, %CounterFile%
    Loop 6
    {
        Send {pgup}
        Sleep 35
        Send {o}
    }
    loopCount = 0
    Loop 16
    {
        loopCount ++
        Loop 4
        {
            Send {,}
            Sleep 35
        }
		Sleep 100
		PixelGetColor, color, 1118, 828
        MouseMove, 1118, 828
		Sleep 100
		IfEqual, color, 0x00FFFF
            break
        PixelGetColor, color, 818, 824
        MouseMove, 818, 824
		Sleep 100
		IfEqual, color, 0x00FFFF
            break
        PixelGetColor, color, 960, 818
        MouseMove, 960, 818
        Sleep 100
        IfEqual, color, 0x00FFFF
            break
    }
    Sleep 250
    If (loopCount = 16)
    {
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Couldn't find hive`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        Sleep 100
        goTo, checkRun
    }
    Sleep 100
    Loop 4
    {
        Send {pgdn}
        Send {,}
    }
    Sleep 100
    goto, convert

convert: ;Converts backbag/balloon and stops after they are converted
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% At hive/Converting`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 250
    Send {e}
    gettingColor := True
    gccount = 0
    While GettingColor ;Wait until converting is done
    {
        PixelGetColor, color, 818, 45
        If (color != 0xF2EEEE)
            gettingColor := False
        Sleep 3000
        gccount ++
        if gccount = 100
        {
            Sleep 250
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Stuck converting, Player resetted`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            Sleep 250
            goto, beginning
        }
    }

walkToCannon: ;Simple route to cannon
    If (tillClock = 4)
    {
        goto, wealthRun
    }
    FileRead, Content, %FieldFile% ;Gets data from a file called Fields.txt and saves the data into variables
    Loop, Parse, Content, `n, `r
        RegExMatch(A_LoopField, "(?<Field1>.+)\t(?<Field2>.+)", $)
        Field1 := $Field1
        Field2 := $Field2
    FileRead, Content, %PlanterFileName% ;Gets data from a file called PlanterLog.txt and saves the data into variables
    Loop, Parse, Content, `n, `r
        RegExMatch(A_LoopField, "(?<Log1>.+)\t(?<Log2>.+)\t(?<Log3>.+)", $)
        Planter1 := $Log1
        Planter2 := $Log2
        Planter3 := $Log3
    Sleep 100
    If (Planter1 = "Planter1Done" or Planter1 = "Planter1Wait") ;Checks if planter1 needs to be collected
    {
        goto, planterRuns
    }
    If (Planter2 = "Planter2Done" or Planter2 = "Planter2Wait") ;Checks if planter2 needs to be collected
    {
        goto, planterRuns
    }
    If (Planter3 = "Planter3Done" or Planter3 = "Planter3Wait") ;Checks if planter3 needs to be collected
    {
        goto, planterRuns
    }
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Walking to cannon`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 150
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
	Sleep 100
	Send {d down}
	Sleep 1250
	Send {d up}
	Sleep 250
	Send {e}

PineForest: ;Simple route to gathering field
    attemptFail = 0
    Sleep 1000
    Send {d down}
    Send {s down}
    Send {space down}
    Sleep 25
    Send {space up}
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 4500
    Send {space down}
    Send {space up}
    Send {d up}
    Send {s up}
    Sleep 1000
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Checking for field`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 100
    Loop 3
    {
        Send {.}
    }
    Sleep 50
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 333
    Send {space down}
    Send {space up}
    Send {w down}
    Sleep 5500
    Send {w Up}
    Loop 3
    {
        Send {i}
        Sleep 50
    }
    MouseMove, 1900,10
    Sleep 750
    loopCount = 0
	pineList := "0x000000,0x000100,0x010200,0x000200" ;color needed in order for the check to work
	Loop 25
	{
		PixelGetColor, color, 1900, 10 ;Checks if player made it into the field
        Sleep 50
		If color in %pineList%
			break
		loopCount ++
		Sleep 100
	}
	If (loopCount = 25) ;Field check failed too many times and rturns player back to hive and adds +1 into a variable that controls the players need to rejoin after too many fails
	{
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Failed to find field`n
        FileAppend, %TimelineAdd%, %TimelineFile%
		Sleep 100
		GoTo, checkRun
	}
    Send {s down}
	Sleep 1500
	Send {s up}
    Sleep 150
	Send {,}
    Sleep 150
    Loop 5
    {
        Send {o}
        Sleep 50
    }
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Gathering`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    goto, gathering

gathering: ;Simple gathering loop
    Sleep 250
    Loop %sprinkler_State%
    {
        Send {space down}
        Sleep 50
        Send {space up}
        Sleep 100
        Send {1}
        Sleep 1100
    }
    Sleep 50
    Loop 8
    {
        click, down
        Loop 15
        {
            Send {a down}
            Sleep 899
            PixelGetColor, Color, 1222, 7 ;Checks if backbag is full and returns player to the hive
            IfEqual, Color, 0x1700F7
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Gathering has ended backbag full`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                If (convertState = "Reset") ;Runs if player chose to convert via resetting
                {
                    Sleep 250
                    FormatTime, TimeRn,, Time ;Omits time
                    TimelineAdd = %TimeRn% Converting pollen`n
                    FileAppend, %TimelineAdd%, %TimelineFile%
                    Sleep 250
                    goto, beginning
                }
                goto, backToHiveWalk ;Runs if player chose to convert via walking
            }
            Send {a up}
            Loop 4
            {
                Send {s down}
                Sleep 625
                Send {s up}
                Send {d down}
                Sleep 100
                Send {d up}
                Send {w down}
                Sleep 625
                Send {w up}
                Send {d down}
                Sleep 100
                Send {d up}
            }
        }
        Send {w down}
        Sleep 1000
        Send {w up}
        Send {d down}
        Sleep 2500
        Send {d up}
        Sleep 50
        Send {a down}
        Sleep 250
        Send {a up}
        Sleep 100
        click, up
        Sleep 150
    }

backToHiveWalk: ;Returns player to the hive if the loop has ended
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Gathering has ended`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 100
    tillClock ++
    If (convertState = "Reset") ;Returns player to the hive via resetting
    {
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Converting pollen`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        Sleep 250
        goto, beginning
    }
    Sleep 50 ;Returns player to the hive via walking
    Send {.}
    Send {.}
    Sleep 50
    Send {w down}
    Sleep 1750
    Send {w up}
    Send {d down}
	Sleep 12000
	Send {d up}
	Send {s down}
	Sleep 7750
	Send {s up}
    Sleep 200
    Loop 4
    {
        Send {.}
        Sleep 50
    }
    Sleep 250
    Send {d down}
    Sleep 150
    Send {d up}
    Sleep 250
    Send {shift down}
    Send {shift up}
    Sleep 150
    Send {s down}
    Sleep 100
    Send {s up}
    Sleep 250
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 100
    Send {w down}
    Sleep 333
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 100
    Send {shift down}
    Send {shift up}
    Sleep 3900
    Send {d down}
    Sleep 500
    Send {d up}
    Sleep 2750
    Send {w up}
    Send {d down}
    Sleep 4000
    Send {d up}
    Send {w down}
    Sleep 250
    Send {w up}
    Send {s down}
    Sleep 700
    Send {s up}
    Send {a down}
    Sleep 300
    Send {a up}
    Sleep 333
    hiveNotFound = 0
    Loop 3
    {
        hiveNotFound ++
        Loop 5
        {	
            PixelGetColor, color, 818, 45 ;Checks for own hive
            IfEqual, color, 0xF2EEEE
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Converting pollen`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                goto, convert 
            }
            Send {a down}
            Sleep 1200
            Send {a up}
            Sleep 555
            PixelGetColor, color, 818, 45
            IfEqual, color, 0xF2EEEE
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Converting pollen`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                goto, convert 
            }
        }
        Sleep 50
        Send {w down}
        Sleep 1250
        Send {w up}
        Sleep 50
        Send {d down}
        Sleep 8000
        Send {d up}
        Send {w down}
        Sleep 1000
        Send {w up}
        Send {s down}
        Sleep 700
        Send {s up}
        Send {a down}
        Sleep 300
        Send {a up}
        Sleep 500
    }
    If (hiveNotFound = 3) ;Failed to locate hive
    {
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Error hive not found`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        Sleep 100
        goto, beginning
    }
    Sleep 1000
    goto, beginning

planterRuns: ;These are run in order from top to bottom
    Sleep 250
    attemptFail = 0
    Sleep 250
    If (Planter1 = "Planter1Done" or Planter1 = "Planter1Wait")
        {
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Going to PineTree Field`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, pRun1
        }
    If (Planter2 = "Planter2Done" or Planter2 = "Planter2Wait")
        {
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Going to %Field1% Field`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, pRun%Field1%
        }
    If (Planter3 = "Planter3Done" or Planter3 = "Planter3Wait")
        {
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Going to %Field2% Field`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, pRun%Field2%
        }

pRun1:
    Sleep 250
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
    Sleep 100
    Send {d down}
    Sleep 1250
    Send {d up}
    Sleep 250
    Send {e}
    Sleep 1000
    Send {d down}
    Send {s down}
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 25
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 4500
    Send {space down}
    Sleep 25
    Send {space up}
    Send {d up}
    Send {s up}
    Sleep 1000
    Loop 3
    {
        Send {.}
        Sleep 50
    }
    Sleep 50
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 333
    Send {space down}
    Sleep 25
    Send {space up}
    Send {w down}
    Sleep 5500
    Send {w Up}
    Sleep 100
    Send {,}
    Sleep 100
    Send {a down}
    Sleep 1000
    Send {a up}
    Sleep 1000
    If (Planter1 = "Planter1Wait")
    {
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`tPlanter2Done`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Placing planter [PineForest]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, placePlanter1
    }
    Else
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Collecting planter [PineForest]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        PixelGetColor, color, 818, 45
        Sleep 250
        MouseMove, 818, 45
        Sleep 250
        While (color != 0xF2EEEE)
        {
            collectFail ++
            Sleep 1000
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Failed to find planter [PineForest] %collectFail%`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            If collectFail = 2
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Couldn't find planter with %collectFail% attempts Ignoring planter`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                    break 1
            }
            goto, beginning
        }
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`nPlanter1Wait`tPlanter2Done`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        Sleep 250
        goto, collectPlanter

pRunRose:
    Sleep 250
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
    Sleep 100
    Send {d down}
    Sleep 1250
    Send {d up}
    Sleep 250
    Send {shift down}
    Send {shift up}
    Loop 4
    {
        Send {,}
        Sleep 50
    }
    Send {e}
    Send {shift down}
    Send {shift up}
    Send {a down}
    Sleep 675
    Send {space down}
    Sleep 35
    Send {space up}
    Sleep 35
    Send {space down}
    Sleep 25
    Send {space up}
    Send {a up}
    Sleep 2500
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 333
    Send {w down}
    Send {d down}
    Sleep 2100
    Send {w up}
    Send {d up}
    Send {s down}
    Sleep 200
    Send {s up}
    Sleep 1000
    If (Planter2 = "Planter2Wait")
    {
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Placing planter [Rose]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, placePlanter2
    }
    Else
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Collecting planter [Rose]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        PixelGetColor, color, 818, 45
        Sleep 250
        MouseMove, 818, 45
        Sleep 250
        While (color != 0xF2EEEE)
        {
            collectFail ++
            Sleep 1000
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Failed to find planter [Rose] %collectFail%`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            If collectFail = 2
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Couldn't find planter with %collectFail% attempts Ignoring planter`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                    break 1
            }
            goto, beginning
        }
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`tPlanter2Wait`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FileRead, Contents, %FieldFile%
        Replace := RegExReplace("Field1`tField2`nSpider`tStrawberry", $) ;Rewrites data in a file called Fields.txt
        FileDelete, %FieldFile%
        FileAppend, %Replace%, %FieldFile%
        Sleep 250
        goto, collectPlanter

pRunSpider:
    Sleep 250
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
    Sleep 100
    Send {d down}
    Sleep 1250
    Send {d up}
    Sleep 250
    Send {shift down}
    Send {shift up}
    Loop 4
    {
        Send {,}
        Sleep 50
    }
    Send {e}
    Send {w down}
    Sleep 1000
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 25
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 250
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 4000
    Send {shift down}
    Send {shift up}
    Send {w up}
    Send {a down}
    Sleep 1750
    Send {a up}
    Sleep 1000
    If (Planter2 = "Planter2Wait")
    {
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Placing planter [Spider]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, placePlanter2 
    }
    Else
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Collecting planter [Spider]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        PixelGetColor, color, 818, 45
        Sleep 250
        MouseMove, 818, 45
        Sleep 250
        While (color != 0xF2EEEE)
        {
            collectFail ++
            Sleep 1000
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Failed to find planter [Spider] %collectFail%`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            If collectFail = 2
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Couldn't find planter with %collectFail% attempts Ignoring planter`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                    break 1
            }
            goto, beginning
        }
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`tPlanter2Wait`tPlanter3Done", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FileRead, Contents, %FieldFile%
        Replace := RegExReplace("Field1`tField2`nRose`tPumpkin", $) ;Rewrites data in a file called Fields.txt
        FileDelete, %FieldFile%
        FileAppend, %Replace%, %FieldFile%
        Sleep 50
        goto, collectPlanter

pRunPumpkin:
    Sleep 250
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
    Sleep 100
    Send {d down}
    Sleep 1250
    Send {d up}
    Sleep 250
    Send {e}
    Sleep 1000
    Send {d down}
    Send {s down}
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 25
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 2750
    Send {space down}
    Sleep 25
    Send {space up}
    Send {d up}
    Sleep 4500
    Send {s up}
    Send {a down}
    Sleep 5000
    Send {a up}
    Sleep 50
    Send {d down}
    Sleep 1000
    Send {d up}
    Sleep 1000
    If (Planter3 = "Planter3Wait")
    {
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`t0", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Placing planter [Pumpkin]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
            goto, placePlanter3
    }
    Else
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Collecting planter [Pumpkin]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        PixelGetColor, color, 818, 45
        Sleep 250
        MouseMove, 818, 45
        Sleep 250
        While (color != 0xF2EEEE)
        {
            collectFail ++
            Sleep 1000
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Failed to find planter [Pumpkin] %collectFail%`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            If collectFail = 2
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Couldn't find planter with %collectFail% attempts Ignoring planter`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                    break 1
            }
            goto, beginning
        }
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`tPlanter3Wait", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FileRead, Contents, %FieldFile%
        Replace := RegExReplace("Field1`tField2`nRose`tStrawberry", $) ;Rewrites data in a file called Fields.txt
        FileDelete, %FieldFile%
        FileAppend, %Replace%, %FieldFile%
        Sleep 250
        goto, collectPlanter

pRunStrawberry:
    Sleep 250
    Send {w down}
    Sleep 1800
    Send {w up}
    Send {d down}
    Sleep 8000
    Send {d up}
    Sleep 50
    Send {space down}
    Sleep 100
    Send {space up}
    Sleep 100
    Send {d down}
    Sleep 1250
    Send {d up}
    Sleep 250
    Send {shift down}
    Send {shift up}
    Loop 4
    {
        Send {,}
        SLeep 50
    }
    Send {e}
    Send {shift down}
    Send {shift up}
    Send {w down}
    Sleep 750
    Send {space down}
    Sleep 25
    Send {space up}
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 250
    Send {a down}
    Sleep 1000
    Send {space down}
    Sleep 25
    Send {space up}
    Sleep 4000
    Send {a up}
    Sleep 3000
    Send {w up}
    Sleep 1000
    If (Planter3 = "Planter3Wait")
    {
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`t0", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Placing planter [Strawberry]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        goto, placePlanter3
    }
    Else
        Sleep 250
        FormatTime, TimeRn,, Time ;Omits time
        TimelineAdd = %TimeRn% Collecting planter [Strawberry]`n
        FileAppend, %TimelineAdd%, %TimelineFile%
        PixelGetColor, color, 818, 45
        Sleep 250
        MouseMove, 818, 45
        Sleep 250
        While (color != 0xF2EEEE)
        {
            collectFail ++
            Sleep 1000
            FormatTime, TimeRn,, Time ;Omits time
            TimelineAdd = %TimeRn% Failed to find planter [Strawberry] %collectFail%`n
            FileAppend, %TimelineAdd%, %TimelineFile%
            If collectFail = 2
            {
                Sleep 250
                FormatTime, TimeRn,, Time ;Omits time
                TimelineAdd = %TimeRn% Couldn't find planter with %collectFail% attempts Ignoring planter`n
                FileAppend, %TimelineAdd%, %TimelineFile%
                Sleep 250
                    break 1
            }
            goto, beginning
        }
        Sleep 250
        FileRead, Contents, %PlanterFileName%
        Replace := RegExReplace("Log1`tLog2`tLog3`n0`t0`tPlanter3Wait", $) ;Rewrites data in a file called PlanterLog.txt so the macro doesn't go back to that same field
        FileDelete, %PlanterFileName%
        FileAppend, %Replace%, %PlanterFileName%
        FileRead, Contents, %FieldFile%
        Replace := RegExReplace("Field1`tField2`nSpider`tPumpkin", $) ;Rewrites data in a file called Fields.txt
        FileDelete, %FieldFile%
        FileAppend, %Replace%, %FieldFile%
        Sleep 250
        goto, collectPlanter

wealthRun: ;Simple run that Collects Wealth clock and Stockings
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Collecting Wealth clock`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Loop 4
    {
        Send {,}
    }
	Send {s down}
	Sleep 1000
	Send {s up}
	Send {d down}
	Sleep 8000
    Send {space down}
    Sleep 50
    Send {space up}
    Sleep 500
	Send {d up}
	Sleep 100
	Send {w down}
	Sleep 3000
	Send {w up}
	Send {s down}
	Sleep 150
	Send {s up}
	Sleep 100
	Send {space down}
	Sleep 50
	Send {space up}
	Send {w down}
	Sleep 1000
	Send {w up}
	Sleep 100
	Send {d down}
	Sleep 1200
	Send {d up}
	Sleep 100
	Send {a down}
	Sleep 100
	Send {a up}
	Sleep 150
	Send {space down}
	Sleep 50
	Send {Space up}
	Send {d down}
	Sleep 1900
	Send {d up}
	Sleep 100
	Send {a down}
	Sleep 100
	Send {a up}
	Sleep 150
	Send {space down}
	Sleep 50
	Send {Space up}
	Send {d down}
	Sleep 6000
	Send {d up}
	Sleep 100
	Send {s down}
	Sleep 700
	Send {s up}
	Sleep 100
	Send {w down}
	Sleep 550
	Send {w up}
	Sleep 50
	Send {a down}
	Sleep 550
	Send {a up}
	Sleep 250
	Send {e down}
	Sleep 50
	Send {e up}
	Sleep 50
	Send {e down}
	Sleep 50
	Send {e up}
	Sleep 100
	Send {s down}
	Sleep 560
	Send {s up}
	Sleep 50
	Send {d down}
	Sleep 500
	Send {d up}
	Loop 2
	{
	Sleep 50
	Send {a down}
	Sleep 1350
	Send {a up}
	Send {w down}
	Sleep 150
	Send {w up}
	Send {d down}
	Sleep 1400
	Send {d up}
	Send {w down}
	Sleep 150
	Send {w up}
	}
	Send {w down}
	Sleep 1700
	Send {d down}
	Sleep 1950
	Send {d up}
	Send {w up}
	Sleep 100
	Send {d down}
	sleep 700
	Send {d up}
	Send {s down}
	Sleep 1000
	Send {s up}
	Send {w down}
	Sleep 50
	Send {w up}
	Sleep 100
	Send {space down}
	Sleep 50
	Send {space up}s
	Send {s down}
	Sleep 1500
	Send {s up}
	Sleep 50
	Send {d down}
	Sleep 2000
	Send {d up}
	Send {w down}
	Sleep 250
	Send {w up}
	Send {a down}
	Sleep 600
	Send {a up}
	Send {w down}
	Sleep 150
	Send {w up}
	Sleep 100
	Send {e down}
	Sleep 50
	Send {e up}
	Sleep 100
	Send {e down}
	Sleep 50
	Send {e up}
	Sleep 250
    tillClock = 0
	goto, beginning
	

collectPlanter: ;Simple planter collecting action
Sleep 100
collectFail := 0
Sleep 500
Send {e}
Sleep 50
Loop 5
{
    Mousemove, 866, 686
    Click, Left
    Sleep 150
    Mousemove, 865, 685
}
Sleep 50
Send {a down}
Sleep 750
Send {a up}
Loop 4
{
    Send {s down}
    Sleep 1500
    Send {s up}
    Send {d down}
    Sleep 150
    Send {d up}
    Send {w down}
    Sleep 1500
    Send {w up}
    Send {d down}
    Sleep 150
    Send {d up}
}
goto, beginning

placePlanter1: ;Simple planter placing action
    Sleep 250
    Send {5}
    Sleep 333
    goto, beginning

placePlanter2: ;Simple planter placing action
    Sleep 250
    Send {6}
    Sleep 333
    goto, beginning

placePlanter3: ;Simple planter placing action
    Sleep 250
    Send {7}
    Sleep 333
    goto, beginning
    
restart: ;If player had too many fails in a row with checks then the player rejoins
    Sleep 250
    FormatTime, TimeRn,, Time ;Omits time
    TimelineAdd = %TimeRn% Restarting game`n
    FileAppend, %TimelineAdd%, %TimelineFile%
    Sleep 250
    Run, %pServer_State%
    Sleep 20000
    colorNot := True
    countNot := 0
    Sleep 500
    While colorNot ;Waits until game loading screen opens
    {
        countNot ++
        PixelGetColor, color, 1750, 200
        MouseMove, 1750, 200
        If color = 0xA85722
            colorNot := False
        Sleep 1000
        If countNot = 120
        {
            goto, restart
        }
    }
    Sleep 250 ;Checks if game needs to be set into fullscreen
    PixelGetColor, color, 14, 12
    MouseMove, 14, 12
    Sleep 250
    IfEqual, color, 0xB9AC9D
    {
        Sleep 750
        Send {F11}
    }
    Sleep 1000
    loop ;Waits until game loading screen goes away
    {
        PixelGetColor, color, 1750, 200
        Sleep 500
        If color != 0xA85722
            break
    }
    Sleep 5000
    attamptFail = 0
    Sleep 250
    Loop 5
    {
        Send {o}
        Sleep 50
    }
    Sleep 100
    Send {w down}
    Sleep 3500
    Send {w up}
    Send {d down}
    Sleep 4250
    Send {d up}
    Send {w down}
    Sleep 250
    Send {w up}
    Send {s down}
    Sleep 700
    Send {s up}
    Send {a down}
    Sleep 300
    Send {a up}
    Sleep 333
    Loop 3 ;Looks for available hive and stops if it finds one
    {
        Loop 5
        {
            PixelGetColor, color, 818, 45
            Sleep 250
            Sleep 50
            Send {e}
            Sleep 400
            IfEqual, color, 0xF2EEEE
                goto, graphicsDown 
            Send {a down}
            Sleep 1200
            Send {a up}
            Sleep 400
            PixelGetColor, color, 818, 45
            Sleep 250
            Send {e}
            Sleep 250
            IfEqual, color, 0xF2EEEE
                goto, graphicsDown 
        }
        Send {d down}
        Sleep 7000
        Send {d up}
        Send {w down}
        Sleep 1000
        Send {w up}
        Send {s down}
        Sleep 700
        Send {s up}
        Send {a down}
        Sleep 300
        Send {a up}
        Sleep 500
    }
    goto, restart

checkRun: ;If attempt fails this strats counting the fails until 4 are made in row
    Sleep 250
    attemptFail ++
    If (attemptFail = 4)
        goto, restart
    Else
        goto, beginning

start:
FileDelete, %TimelineFile%
If Not FileExist(FieldFile)
{
    FileAppend,Field1`tField2`nSpider`tPumpkin, %FieldFile% 
}
Sleep 250
FileAppend, 
(
C:\Users\Bee Swarmer\Desktop\PineForestMacro.Ahk
>run TrackPastEvents.exe
TrackPastEvents.exe: [y] to continue [e] to exit
y
-----------------------------------------------------------
-----------------------PAST-EVENTS-------------------------
-----------------------------------------------------------
%TimeRn% Macro Started`n
), %TimelineFile%
FileRead, Content, %GuiFile% ;Gets data from a file called Fields.txt and saves the data into variables
Loop, Parse, Content, `n, `r
    RegExMatch(A_LoopField, "(?<1Choice>.+)", $)
pServer_State := $1Choice
Sleep 1250
goto, Guii
    
F2::Pause
F3::
FormatTime, TimeRn,, Time ;Omits time
TimelineAdd = %TimeRn% Macro Stopped`n
FileAppend, %TimelineAdd%, %TimelineFile%
Sleep 50
ExitApp
F4::Reload
GuiClose:
ExitApp