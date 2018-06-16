#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; variables
F2=%A_scriptdir%\test12_checked.txt ;ini to save tasks

;create task editor GUI
Gui Add, Edit, Section vTask w200						
Gui Add , ListView, -Multi vTasks w200 r15 , Task name	
Gui Add, Button, ys x+5 h21 gAddTask, Add task			
Gui Add, Button, h21 gDelTask, Delete task              
Gui Add, Button, h21 gOverlay, Overlay					
Gui, -MaximizeBox -MinimizeBox +ToolWindow

 ; Populate listview with tasks from ini
  Loop, Read, %F2%
    {
	LV_Add("", A_LoopReadLine)
	 }
prevCount := LV_GetCount()                             ; variable to see if ini needs to be updated or not

; window set and get last position block
;~ read the saved positions or center if not previously saved
IniRead, gui_position, settings.ini, window position, gui_position, Center
;~ get the window's ID so you can get its position later
Gui, +Hwndgui_id
;~ show the window at the saved position
Gui, Show, %gui_position%, ToDo
return
;~ when you close the window, get its position and save it
GuiClose:
WinGetPos, gui_x, gui_y,,, ahk_id %gui_id%
IniWrite, x%gui_x% y%gui_y%, settings.ini, window position, gui_position
ExitApp									
Return

AddTask:												; This Sub (Label) is called each time you click on the Add button
	Gui Submit, Nohide									; Submit the Gui without hiding it
	If Task												; If a Task is described
		Lv_Add("", Task)								; Add the Task
	GuiControl , , Task									; Clear the Task
Return
DelTask:												; This Sub (Label) is called each time you click on the Delete button
	If Next := LV_GetNext(0)							; If a row is selected
		LV_Delete(Next)									; Delete the current row
Return


Overlay:
WinGetPos, gui_x, gui_y,,, ahk_id %gui_id%                                   ; setting window position here
IniWrite, x%gui_x% y%gui_y%, settings.ini, window position, gui_position
if (prevCount != LV_GetCount()){											 ; deleting and creating new task ini if necessary
	ifexist,%F2%
	   filedelete,%F2%
	LV_Modify(0, "check")
	Loop
    {
    RNM := LV_GetNext(RNM,"checked")
    if not RNM
        break
    LV_GetText(B1,RNM,1)
    Fileappend,%B1%`r`n,%F2%
    }
}
	Gui, 2:Font, s16; Set a large font size (32-point).
	Loop % LV_GetCount() 													 ; Loop and create overlay gui
		{
		    LV_GetText(RetrievedText, A_Index)
		    if InStr(RetrievedText, "some filter text")
		        LV_Modify(A_Index, "Select")  ; Select each row whose first field contains the filter-text.
				Array.Push(RetreivedText)
		
				Gui, 2:Add, Text, +wrap w300 cWhite, %RetrievedText%
		}
		Gui, 2:-MaximizeBox -MinimizeBox +ToolWindow
				
		CustomColor = Black ; Can be any RGB color (it will be made transparent below).
		Gui 2:+LastFound +AlwaysOnTop -Caption +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
		Gui, 2:Color, %CustomColor%
		Gui, 2:Font, s22  ; Set a large font size (32-point).
		;WinSet, TransColor, %CustomColor% 250
		Winset, Transparent, 120
		Winset, ExStyle, +0x20                            ;click through window attribute

		WinGetPos, X, Y, Width, Height, ToDo
		xOffset := X+50
		Gui, 2:Show, X%X% Y%Y% NoActivate  ; NoActivate avoids deactivating the currently active window.
		
		Gui, Submit
Return	

; hotkeys

F12::
gosub Overlay
Return	

Return
!s::suspend
!r::
Suspend Off
Reload  ; Assign Alt-R as a hotkey to restart the script.
Return
F11::consoleLog()


consoleLog() {
	msgbox, console logged
}
Return
#IfWinActive,ToDo    							 ; only while ToDo window is open to disable hotkeys
	GuiControlGet, control                           ; if enter is pressed and edit field is active, adds written task
	If(control="task") {
		Enter::
		gosub AddTask
		Return
	} else if(control="tasks") { 					 ; delete selected task w delete key
		delete::
		gosub DelTask
		Return
	}

Return