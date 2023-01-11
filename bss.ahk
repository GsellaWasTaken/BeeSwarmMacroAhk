#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
;Change the values at your own risk
;1.3.1

LoopcountMain = 0 ;Base value 0 
CoordMode, Pixel, Screen

LogFileName := "PlanterLog.txt" 
ChoicesFileName := "Choices.txt"

FileRead, Content, %ChoicesFileName%
Loop, Parse, Content, `n, `r
	RegExMatch(A_LoopField, "(?<Wealth>.+)\t(?<Convert>.+)\t(?<Sprinkler>.+)\t(?<Planter>.+)", $) 
    ;Looking for the made choices during startup and converting them from the .txt file to variables
    ;The word in (?<Title>.+) is the title of the choice, and the choice it self is taken from the 1 line below of it in the .txt file
	Wealth_State := $Wealth
	Convert_State := $Convert
	Sprinkler_State := $Sprinkler
	Planter_State := $Planter

;Infinite loop that loops again and again.. if toggle is not changed to 0 or the script paused by the user
Toggle = 1
While Toggle {
	MainRun:
        ;Resets the characters position in game
		MouseMove, 1920, 1080
		Sleep 100
		send {esc down}
		sleep 100
		send {esc up}
		sleep 50
		Send {r down}
		Sleep 100
		Send {r up}
		Sleep 50
		Send {enter down}
		Sleep 100
		Send {enter up}
		Sleep 11000
		Send {o down}
		Sleep 100
		Send {o up}
		Send {e down}
		Sleep 50
		Send {e up}
		Sleep 150

		GettingColor := True
        ;Converts the inventory to honey and when converting is done continues the loop
		While GettingColor
		{
			PixelGetColor, color, 818, 45
			If (color != 0xF2EEEE)
				GettingColor := False
			Sleep 3000
		}
        ;This is how many times the camera is turned while checking until the character is reset
		LoopCount1 = 0
		Loop 16 ;Base value 16
		{
			LoopCount1 ++
			Send {, down}
			Sleep 50
			Send {, up}
			Sleep 50
			Send {, down}
			Sleep 50
			Send {, up}
			Sleep 50
            ;The first check of many meant to take the correct camera angle in game so the character won't start runing into random direction
            ;It will also reset the characters position if it doesn't find the correct pixel color
			PixelGetColor, color, 431, 922
			Sleep 750
			IfEqual, color, 0x00FFFF ;Color
				break
		}	
        ;This will run and reset the character if the script fails to find the correct pixel
		If (LoopCount1 = 16) ;Base value 16
		{
			Sleep 100
			GoTo, CheckRun
		}

		Sleep 1500
        ;This part of the script is run every 4 loops (line 480-)
		If (Wealth_State = "Collect")
			If (LoopcountMain = 4) ;Base value 4
				Goto WealthRun
		
        ;This variable is used to count the loops
		LoopcountMain ++

		;Walk Out Hive
		Send {s down}
		Sleep 2000
		Send {s up} 
		Send {a down}
		Sleep 8000
		Send {a up}

        ;This part of the script is run every time when PlanterLog.txt has the word PlanterDone
		If (Planter_State = "Use")
		{
			FileRead, Contents, %LogFileName% 
            ;Looking for PlanterDone in the .txt file, if its not present PlanterRun won't be ran
			Loop, Parse, Contents, `n, `r
				RegExMatch(A_LoopField, "(?<Log>.+)", $)
				PlanterRun := $Log
		}

        ;Executes the PlanterRun if the variable "PlanterRun" contains the word PlanterDone
		If (PlanterRun = "PlanterDone") ;Collects/Places the planters from/to spesific fields
		{
			Send {w down}
			Sleep 3500
			Send {w up}
			Send {s down}
			Sleep 150
			Send {s up}
			Sleep 100
			Send {space down}
			Sleep 50
			Send {space up}
			Send {w down}
			Sleep 1250
			Send {w up}
			Sleep 100
            ;If planter isn't ready yet (The planter is still growing) hud will be closed
			MouseMove, 1060, 677, 100
			Sleep 100
			MouseMove, 1063, 678, 100
			Send {e down}
			Sleep 50
			Send {e up}
			Loop 8
			{
				Click, Left
			}
			MouseMove, 1920, 1080
			Sleep 150
			Send {6 down}
			Sleep 50
			Send {6 up}
			Sleep 100
			Send {w down}
			Sleep 1000
			Send {d down}
			Sleep 2750
			Send {d up}
			Sleep 2500
			Send {space down}
			Sleep 50
			Send {space up}
			Sleep 2000
			Send {w up}
			Send {d down}
			Sleep 2000
			Send {d up}
			Sleep 100
            ;If planter isn't ready yet (The planter is still growing) hud will be closed
			MouseMove, 1060, 677, 100
			Sleep 100
			MouseMove, 1063, 678, 100
			Send {e down}
			Sleep 50
			Send {e up}
			Loop 8
			{
				Click, Left
			}
			MouseMove, 1920, 1080
			Sleep 150
			Send {5 down}
			Sleep 50
			Send {5 up}
			Sleep 50
			Loop 2
			{
			Send {d down}
			Sleep 1000
			Send {d up}
			Send {w down}
			Sleep 125
			Send {w up}
			Send {a down}
			Sleep 1000
			Send {a up}
			Send {w down}
			Sleep 125
			Send {w up}
			}
			Sleep 100
            ;Replaces the PlanterDone text in the .txt file to PlanterWait
			FileRead, Contents, %LogFileName%
			PlanterRun := RegExReplace("Log `nPlanterWait", $)
			FileDelete, %LogFileName%
			FileAppend, %PlanterRun%, %LogFileName%
			Goto MainRun
		}

		Sleep 250

        ;Jumps into the cannon in game
		Send {space down}
		Sleep 50
		Send {space up}
		Sleep 50
		Send {a down}
		Sleep 1600
		Send {a up}
		Sleep 250
		Send {e down}
		Sleep 50
		Send {e up}
		Send {e down}
		Sleep 50
		Send {e up}

		Sleep 400

        ;Glides to the field in game
		Send {, down}
		Sleep 25,  
		Send {, up}
		Sleep 425
		Send {Space down}
		Sleep 100
		Send {space up}
		Send {Space down}
		Send {space up}
		Sleep 10
		Send {w down}
		Sleep 500
		Send {w up}
		Sleep 5500
		Send {w down}
		Sleep 4500
		Send {w up}

		Sleep 1050

		;Field check, checks for certain color pixels on screen
		Loopcount2 = 0
		Pinelist := "0x000000,0x000100,0x010200,0x000200"
		Loop 13 ;Base value 13
		{
			PixelGetColor, color, 1900, 10
			If color in %Pinelist%
				break
			Loopcount2 ++
			Sleep 500
		}
			
        ;If the script cound't find any pixels this will reset the characters position
		If (Loopcount2 = 13) ;Base value 13
		{
			Sleep 100
			GoTo, CheckRun
		}
			
		;Goes to the correct position in the field
		LoopcountTillDeath = 0 ;Base value 0 (Resets the value of LoopcountTillDeath)
		Send {s down}
		Sleep 2500
		Send {s up}
		Sleep 150
		Sleep 100
		Send {e down}
		Sleep 100
		Send {e up}
		MouseMove, 1060, 677, 100
		Sleep 100
		MouseMove, 1063, 678, 100
		Loop 8 
		{
			Click, Left
		}
		Sleep 150
        ;Checks how many sprinklers the user has chosen during the startup and places the correct amount of them
		Loop, %Sprinkler_State%
		{
			Send {Space down}
			Sleep 50
			Send {Space up}
			Sleep 100
			Send {1 down}
			Sleep 150
			Send {1 up}
			Sleep 1100
		}
		Send {7 down}
		Sleep 100
		Send {7 up}
		MouseMove, 1920, 1080
		Sleep 700

        ;Zooms out the camera wow...
		Loop 4 ;Base value 4
		{
		Send {o down}
		Sleep 100
		Send {o up}
		}
		

		Sleep 250
		Click, down
		Sleep 100

        ;Runs around the field collecting pollen for x amount of loops
		Loop 111 ;Base value 111
		{
		Send {w down}
		Sleep 301
		Send {w up}
		Send {a down}
		Sleep 300
		Send {a up}
		Send {s down}
		Sleep 300
		Send {s up}
		Send {d down}
		Sleep 300
		Send {d up}
			
		Send {w down}
		Sleep 477
		Send {w up}
		Send {a down}
		Sleep 477
		Send {a up}
		Send {s down}
		Sleep 477
		Send {s up}
		Send {d down}
		Sleep 477
		Send {d up}

		Send {w down}
		Sleep 633
		Send {w up}
		Send {a down}
		Sleep 634
		Send {a up}
		Send {s down}
		Sleep 633
		Send {s up}
		Send {d down}
		Sleep 634
		Send {d up}

        ;If the inventory fills up this will break the loop
        PixelGetColor, Color, 1222, 7
        IfEqual, Color, 0x1700F7
            break
		}
		
        ;Executes if the user chose to convert by resetting during startup
		If (Convert_State = "Reset") 
		{
			Goto MainRun
		}
		
		Click, up
		Send {w down}
		Sleep 8000
		Send {w up}
		Sleep 100
		Send {. down}
		Sleep 100
		Send {. up}
		Send {d down}
		Sleep 13000
		Send {d up}
		Sleep 100
		Send {s down}
		Sleep 8500
		Send {s up}
		Sleep 275
		Send {a down}
		Sleep 1000
		Send {a up}
		Sleep 100
		Send {w down}
		Sleep 500
		Send {w up}
		Send {space down}
		Sleep 50
		Send {space up}
		Send {w down}
		Sleep 1025
		Send {w up}
		Sleep 1000
        ;Checks if winterfeast is available and collects it
		PixelGetColor, color, 818, 45
		If (color = 0xF2EEEE) ;Nam nam nam
		{
			Send {e down}
			Sleep 50
			Send {e up}
			Sleep 2500
			Send {, down}
			Sleep 50
			Send {, up}
			Sleep 100
			Send {s down}
			Sleep 200
			Send {s up}
			Sleep 10
			Send {d down}
			Sleep 425
			Send {d up}
			Sleep 10
			Send {w down}
			Sleep 425
			Send {w up}
			Sleep 10
			Send {a down}
			Sleep 415
			Send {a up}
		}
		Sleep 100
		Send {s down}
		Sleep 1666
		Send {s up}
		Sleep 50
		Send {space down}
		Sleep 50
		Send {space up}
		Send {s down}	
		Sleep 15500
		Send {s up}
		Send {w down}	
		Sleep 650
		Send {w up}
		Send {a down}
		Sleep 2500
		Send {a up}
		Sleep 200
        ;If the user chose to convert by walking, script will walk up to the hives get on the right position and checks
        ;wich hive is the users own one
		Loop 2
		{
			Send {. down}
			Send {. up}
			Send {shift down}
			Send {Shift up}
		}
		MouseMove, 1920, 1080
		Sleep 200
		Loop 3 ;Base value 3
		{
			Loop 6 ;Base value 6
			{	
				PixelGetColor, color, 818, 45
				IfEqual, color, 0xF2EEEE
					Break
				Send {w down}
				Sleep 1175
				Send {w up}
				Sleep 200
			}
		If color = 0xF2EEEE
			break
		Send {s down}
		Sleep 8000
		Send {s up}
		Send {w down}
		Sleep 500
		Send {w up}
		Sleep 200
		}

		Sleep 100
		Send {e down}
		Sleep 50
		Send {e up}
        ;Converts the inventory to honey and when converting is done starts the loop from the start
		GettingColor := True
		While GettingColor
		{
			PixelGetColor, color, 818, 45
			If (color != 0xF2EEEE)
				GettingColor := False
			Sleep 3000
		}
		Sleep 4000
		Goto MainRun

	;Wealth Clock Collect

	WealthRun:
	{
        ;If user chose to collect the wealth clock executes the following...
		If (Wealth_State = "Collect")
			Send {s down}
			Sleep 1000
			Send {s up}
			Send {d down}
			Sleep 9000
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
			Sleep 700
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

			;Stockings
			Loop 2 ;Base value 2
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
			
			;Wealth Clock
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
			LoopcountMain = 0 ;Base value 0
			GoTo, MainRun
			;End Of The Beginning
	}

	GoTo, MainRun ;If something bad happens this is here as a failsafe

	;After x amount of fails rejoins to the game
	Restart:
	If (LoopcountTillDeath = 3) ;Base value 3 (The amount of fails until attempts to rejoin)
	{
		Run, https://www.roblox.com/games/4189852503?privateServerLinkCode=79206701614713356673660100749569
		Sleep 60000
		LoopcountMain = 0
		LoopcountTillDeath = 0
		Send {w down} ;To claim hive
		Sleep 3000
		Send {w up}
		Send {s down} 
		Sleep 750
		Send {s up}
		Sleep 50
		Send {e down}
		Send {e up}
		Send {d down}
		Sleep 1300
		Send {e down}
		Send {e up}
		Sleep 1200
		Send {e down}
		Send {e up}
		Send {d up}
		Sleep 50
		Send {a down}
		Sleep 3725
		Send {e down}
		Send {e up}
		Sleep 1150
		Send {e down}
		Send {e up}
		Sleep 1150
		Send {e down}
		Send {e up}
		Send {a up}
		Goto, MainRun
	}

	TimesFailedMax = 3 ;Base value 3
	LoopcountTillDeath = 0 ;Base value 0

	;Checks if there needs to be a restart
	CheckRun:
	LoopcountTillDeath ++
    ;If this count reaches x the script attempts to rejoin
	If (LoopcountTillDeath = 3) ;Base value 3
		Goto, Restart

}

^p::Pause
^e::ExitApp
