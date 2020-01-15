; PROTOTYPE HUD FROM USER: "AGEEK"
; https://autohotkey.com/board/topic/77219-prototype-for-on-screen-hud-display/
; See also: https://autohotkey.com/docs/commands/Progress.htm



#NoEnv
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Window
; SendMode Input  ; disabling this makes it work better in Microsoft Edge for some reason...
#SingleInstance Force
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1 ; has no effect on SendMode Input
SetWinDelay 1
SetKeyDelay 10 ; has no effect on SendMode Input
SetMouseDelay 1
SetBatchLines 1 ; has no effect on SendMode Input
BlockInput, Send ; keeps user error from modifying input during a send event (doesn't really get a chance to act when SendMode is "Input")

; variables
barcodeURLp1 := "https://go.cin7.com/cloud/docs/barcode.ashx?code="
barcodeURLp2 := "&h=50&s=1&f=0&bf="


; #########################################################################
; ##########   DEFINE THE PARAMETERS FOR THE PROGRESS BAR WINDOW ##########
; #########################################################################
; "b1" in the options below means borderless. 
; "b2" would have a regular border
; "M" means moveable (M1 is resizeable and M2 has min/max/close buttons), but it has to have a title StatusBar
; "fs" denotes "subtext" font size (put "0" to use sysdefault)
Progress, 1: M1 CW334477 CTaqua x10 y137 h50 w300 fs12 zh0,,,HUD,
; SetTimer, UpdateHUD, 170
; WinActivate Program Manager
Return


; ######################################
; ########## MACROS BY HOTKEY ##########
; ######################################



^+c:: ; Ctrl + Shift + c
	Gosub, CopySelected
Return

F5:: ; OPENS THE INPUT BOX TO STORE SOMETHING TO COLD STORAGE
InputBox, extraClipboard, , Please enter contents for extra clipboard`n(ESC to exit)
; MsgBox,4,,Clear clipboard? 
	; IfMsgBox, Yes
		clipboard := "✔✔✔ New Cold Storage Cycle ✔✔✔" ; 
		xtrClip := extraClipboard
		; EnvAdd, xtrClip, 24
		; clipboard = %extraClipboard%

Return

; #########################################################################################
; ### RESTORES "Print Screen" key functionality while hiding and then restoring the HUD ###
; UPDATE LATER WITH PROPER FUNCTIONS INSTEAD!
; #########################################################################################
PrintScreen::
	Progress Hide
	Sleep, 200
	SendEvent, {PrintScreen}
	Progress,1: SHOW ; by itself, this will simply throw a default progress bar
	; You must completely re-instanciate the HUD for it to look right
	Progress,1: M1 CW334477 CTaqua x10 y137 h50 w300 fs12 zh0,%extraClipboard%`n%clipboard%,,HUD,
Return

/*
; #########################################################################################
; ties the HUD progress bar to the toggle function.
; #########################################################################################
Ins:: 
	; Gosub, ToggleProgressBar ; You need to write this function first!

*/

; ###########################################
; Make hotkey to insert em-dash (or you could just type "Alt + 0151")
!NumpadSub::
	SendRaw — ;
	ToolTip,Alt + 0151,,,
	SetTimer, RemoveToolTip, -3000
Return ;

!NumpadMult::
	SendRaw ×
	ToolTip,Alt + 0215,,,
	SetTimer, RemoveToolTip, -3000
Return ;
; #########################################################################################
; ############################ SEND CONTENTS OF EXTRA CLIPBOARD ###########################
; #########################################################################################
^+Space:: ; (That's ctrl + Shift + Space)
	BlockInput, MouseMove
	extraClipboard := RegExReplace(extraClipboard, "\r\n?|\n\r?", "`n")
	SendRaw, %extraClipboard% ; You MUST use "SendRaw" in this instance instead of "Send" because otherwise special characters (like #) can't be sent
	; SendInput, %extraClipboard%
	Send, {Enter}
	BlockInput, MouseMoveOff
	
	gosub, stuckKeyCheck

Return

; #########################################################################################
; Generates an alpha-numeric barcode from the contents of the extra clipboard
; Currently uses Cin7's barcode image generator
; #########################################################################################
^+x:: ; (Ctrl + Shift + x)
	gosub, stuckKeyCheck
	SendRaw, %barcodeURLp1%
	SendRaw, %extraClipboard%
	SendRaw, %barcodeURLp2%
	Send {Enter}

	gosub, stuckKeyCheck

Return


; #########################################################################################
; CIN7 CARTONIZATION MINI-SCRIPT FROM CONTENTS OF EXTRA CLIPBOARD
; #########################################################################################
^+d:: ; (That's ctrl + Shift + d)(REQUIRES THAT YOU CLICK IN THE CORRECT CELL)

	; Send, {LButton} ; Sends a left-click at the cursor's present position ; disable to manually send the left click (less efficient, but more accurate)

	; SplashTextOn,,,Line item being assigned to carton %extraClipboard%
	ToolTip Line item being assigned to carton %extraClipboard%

	; Sleep, 400 ;
	; Send, {Tab 4}
	Loop, 4
	{
		Send, {Tab}
		Sleep 30
	}
	Sleep, 100

	Send, %xtrClip%


	Tooltip ; Turn off the tip
	
	Sleep, 300
	Send, +{Tab 2}
	Sleep, 100
	Send, {Enter}

	gosub, stuckKeyCheck

Return

; #########################################################################################
; SHIP AND ETA DATES
; #########################################################################################

F2::

	myVarCurrentDateTime := A_Now 
	EnvAdd, myVarCurrentDateTime, -6, hours ; for those after-midnight entries... Note, "EnvSub" doesn't work in this context.
	oneWkLater := myVarCurrentDateTime ; 
	EnvAdd, oneWkLater, 7, days

	myDispatchDt := ;
	myArrivalDt := ;


	FormatTime, myDispatchDt, %myVarCurrentDateTime%, M/d/yyyy
	FormatTime, myArrivalDt, %oneWkLater%, M/d/yyyy

	; Send, {LButton}
	Sleep, 30
	Send, ^a
	Sleep, 50
	Send, {Backspace}

	Send, %myDispatchDt%
	Sleep, 100
	Send, {Backspace}
	Sleep, 50
	TabSleep(2)
	Send, %myArrivalDt%
	TabSleep(8)
	Send, ^a ;
	Sleep, 50
	Send, {BackSpace}
	Send, %clipboard% ; Is only useful if you've saved the tracking info to the clipboard...

	gosub, stuckKeyCheck

Return

::rdt::
	myVarCurrentDateTime := A_Now 
	EnvAdd, myVarCurrentDateTime, -6, hours
	EnvAdd, myVarCurrentDateTime, 1, Days ; sets date to tomorrow for submitting ARNs
	myDispatchDt :=
	FormatTime, myDispatchDt, %myVarCurrentDateTime%, M/d/yyyy

	Send, %myDispatchDt%
	Send, {Tab}
Return

::tdt::
	SendInput %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%
Return

; #########################################################################################
; #########################################################################################


; ##############################################################################
; ################ DEBUG TOOLS AND THINGS THAT NEED TO BE PERSISTENT ###########
; ##############################################################################

#Persistent ; YOU SHOULD PROBABLY READ MORE ABOUT WHAT THIS DOES

/*
ToggleProgressBar:
if SplashTextFlag = 0 ; respond to the current flag value
{

}
else
{

}
Return
*/

stuckKeyCheck: 
	If GetKeyState("Ctrl")           ; If the OS believes the key to be in (logical state),
	{
	    If !GetKeyState("Ctrl","P")  ; but  the user isn't physically holding it down (physical state)
	    {
	        Send {Blind}{Ctrl Up}
	        ; MsgBox,,, Ctrl force-released
	        ToolTip,Ctrl force-released,,,
	        SetTimer, RemoveToolTip, -5000
	        ; KeyHistory
	    }
	}
	If GetKeyState("Shift")           ; If the OS believes the key to be in (logical state),
	{
	    If !GetKeyState("Shift","P")  ; but  the user isn't physically holding it down (physical state)
	    {
	        Send {Blind}{Shift Up}
	        ; MsgBox,,, Shift force-released
	        ToolTip,Shift force-released,,,
	        SetTimer, RemoveToolTip, -5000
	        ; KeyHistory
	    }
	}
Return

OnClipboardChange:
	Progress,1:,%extraClipboard%`n%clipboard%
Return

+esc::
	Reload
Return





; +esc:: ; Shift + esc
	Send, {Esc}
; Return
; test text: 1l0Oo

; ########## LOCK COMPUTER ##########
Break::
	; Send #l
	DllCall("LockWorkStation")
Return


CopySelected: ; copy selected to cold storage
	KeyWait Ctrl
	KeyWait c ; by chaining both of these, the rest of the script waits for both "Ctrl" and "c" to be released before attempting to execute
	Send, {Ctrl DOWN}
	Sleep, 10
	Send, {c DOWN}
	Sleep, 10
	Send, {c UP}
	Sleep, 10
	Send, {Ctrl UP}
	ClipWait, 3, 1
	if ErrorLevel
	{
	    MsgBox, The attempt to copy text onto the clipboard failed.
	    ; Reload
	    Gosub EndScript
	    return
	}
	extraClipboard := clipboard
	clipboard := "✔✔✔ New Cold Storage Cycle ✔✔✔" ; 
	ClipWait, 3, 1
	if ErrorLevel
	{
	    MsgBox, The attempt to copy text onto the clipboard failed.
	    ; Reload
	    Gosub EndScript
	    return
	}
	xtrClip := extraClipboard
Return

RemoveToolTip:
	ToolTip
return

; ##########################################################
; SIMPLE FUNCTION ALLOWING YOU TO SET THE SLEEP INTERVAL
; AFTER EACH TAB ENTRY INSTEAD OF TYPING IT OUT EACH TIME
; ##########################################################
TabSleep(myCtr)
{
	Loop %myCtr%
	{	
		Send, {Tab}
		Sleep, 10
	}
} ;

EndScript:
	MsgBox, Script walked through %loopCount% rows. `n %remainingRows% rows remaining.`n Last SKU was %orderedSKU%`nSee "Clipboard" field in HUD after closing this.
	Clipboard = %orderedSKU%

	Reload
Return
