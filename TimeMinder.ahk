#Requires AutoHotkey v2.0

; --- AppData Paths ---
appDataDir := A_AppData "\TimeMinder"
if (!DirExist(appDataDir)) {
    DirCreate(appDataDir)
}
configFile := appDataDir . "\TimeMinder.ini"
soundsDir := appDataDir . "\sounds"
if (!DirExist(soundsDir)) {
    DirCreate(soundsDir)
}

; --- Migration Logic ---
oldConfigFile := A_ScriptDir . "\TimeMinder.ini"
oldSoundsDir := A_ScriptDir . "\sounds"

; Migrate config file if it exists in old location and not in new
if (FileExist(oldConfigFile) && !FileExist(configFile)) {
    try FileMove(oldConfigFile, configFile, true)
}
; Migrate sound files if old sounds dir exists and new is empty
if (DirExist(oldSoundsDir)) {
    loop files, oldSoundsDir . "\*.*" {
        dest := soundsDir . "\" . A_LoopFileName
        if (!FileExist(dest)) {
            try FileMove(A_LoopFileFullPath, dest, true)
        }
    }
}

; Load custom sound path from config file
customSoundPath := LoadCustomSoundPath()

; Parse command line arguments
sessionTime := 3600000 ; Default: 60 minutes
breakTime := 1800000 ; Default: 30 minutes
totalTime := 10800000 ; Default: 180 minutes (3 hours)

; Check for command line arguments
if (A_Args.Length >= 1) {
    sessionTime := A_Args[1] * 60000 ; Convert minutes to milliseconds
}
if (A_Args.Length >= 2) {
    breakTime := A_Args[2] * 60000 ; Convert minutes to milliseconds
}
if (A_Args.Length >= 3) {
    totalTime := A_Args[3] * 60000 ; Convert minutes to milliseconds
}

startTick := A_TickCount
currentTotalTime := 0
currentSessionTime := 0
pausedSessionTime := 0
pauseTick := 0
isFirstTick := true
; --- Activity / pause-on-activity settings ---
activityIdleThreshold := 5000 ; ms since last input to consider "activity" (5 seconds)
breakPaused := false
breakPauseStart := 0
lastShakeTime := 0  ; Track last time we shook the GUI (absolute tick)
lastShakeMinute := -1 ; Track which minute index we last shook at (minutes since flash start)

; Create GUI
myGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
myGui.BackColor := "222222"

myGui.AddText("y+2")

; Session Time
myGui.SetFont("s10 Bold cLime", "Segoe UI")
sessionTitle := myGui.AddText("w130 h18 Center", "Session Time")
myGui.SetFont("s18 Bold cLime", "Segoe UI")
counterText := myGui.AddText("w130 h28 Center y+0", "00:00:00")

myGui.AddText("y+2")

; Clock
myGui.SetFont("s10 cGray", "Segoe UI")
clockTitle := myGui.AddText("w130 h18 Center", "Current Time")
myGui.SetFont("s18 cGray", "Segoe UI")
clockText := myGui.AddText("w130 h28 Center y+0", "00:00:00")

myGui.AddText("y+2")

; Total Time
myGui.SetFont("s10 Bold c3399FF", "Segoe UI")
totalTitle := myGui.AddText("w130 h18 Center", "Total Time")
myGui.SetFont("s18 c3399FF Bold", "Segoe UI")
totalTimeText := myGui.AddText("w130 h28 Center y+0", "00:00:00")

myGui.AddText("y+2")

lastTotalTick := A_TickCount

myGui.SetFont("s12 Bold", "Segoe UI")
breakText := myGui.AddText("w130 h35 Center +Border Background808080 0x200 Hidden", "Take Break") ; 0x200 = SS_NOTIFY for click
breakText.OnEvent("Click", BreakTextHandler)
breakTextLastShown := 0
breakTextAutoHide := false
breakTextMouseOver := false
breakActive := false
breakStart := 0
flashTimer := 0

myGui.Show("x20 y20 NoActivate")

; Add a timer to check mouse position
SetTimer(updateTimer, 500)

; Make the GUI draggable
counterText.OnEvent("Click", GuiStartDrag)
clockText.OnEvent("Click", GuiStartDrag)
totalTimeText.OnEvent("Click", GuiStartDrag)
sessionTitle.OnEvent("Click", GuiStartDrag)
clockTitle.OnEvent("Click", GuiStartDrag)
totalTitle.OnEvent("Click", GuiStartDrag)

; Add a timer to check mouse position over timer/clock
SetTimer(CheckMouseOverControls, 100)

finished := false

; --- Beep Notification Flags ---
sessionBeepActive := false
totalBeepActive := false

; --- Configuration Functions ---
LoadCustomSoundPath() {
    global configFile
    try {
        return IniRead(configFile, "Settings", "CustomSoundPath", "")
    } catch {
        return ""
    }
}

SaveCustomSoundPath(path) {
    global configFile
    try {
        IniWrite(path, configFile, "Settings", "CustomSoundPath")
        return true
    } catch {
        return false
    }
}

; --- Sound File Management Functions ---
DownloadSoundFile(url, filename := "") {
    global soundsDir
    
    ; Generate filename if not provided
    if (filename = "") {
        ; Extract filename from URL
        filename := RegExReplace(url, ".*/", "")
        if (filename = "" || !RegExMatch(filename, "\.(wav|mp3|wma|aac|m4a|flac)$")) {
            filename := "custom_sound_" . A_Now . ".mp3"
        }
    }
    
    ; Ensure filename has proper extension
    if (!RegExMatch(filename, "\.(wav|mp3|wma|aac|m4a|flac)$")) {
        filename .= ".mp3"
    }
    
    localPath := soundsDir . "\" . filename
    
    try {
        ; Download the file
        Download(url, localPath)
        
        ; Verify file was downloaded successfully
        if (FileExist(localPath) && FileGetSize(localPath) > 0) {
            return localPath
        } else {
            return ""
        }
    } catch {
        return ""
    }
}

GetAvailableSoundFiles() {
    global soundsDir
    soundFiles := []
    
    try {
        loop files, soundsDir . "\*.*" {
            if (RegExMatch(A_LoopFileName, "\.(wav|mp3|wma|aac|m4a|flac)$")) {
                soundFiles.Push(A_LoopFileFullPath)
            }
        }
    } catch {
        ; Directory might not exist yet
    }
    
    return soundFiles
}

; --- Beep Notification Function ---
BeepNotification(*) {
    global customSoundPath
    if (customSoundPath != "" && FileExist(customSoundPath)) {
        try {
            SoundPlay customSoundPath
        } catch {
            SoundBeep 1500, 500 ; fallback if sound file fails
        }
    } else {
        SoundBeep 1500, 500 ; 1500 Hz, 500 ms
    }
}

updateTimer(*) {
    global finished, startTick, counterText, clockText, breakText, breakActive, breakStart, flashTimer, pausedSessionTime, pauseTick, breakTextLastShown, breakTextAutoHide, myGui, currentTotalTime, lastTotalTick, totalTimeText, sessionTime, isFirstTick, breakPaused, breakPauseStart, activityIdleThreshold, currentSessionTime, breakTime, lastShakeTime, lastShakeMinute
    global sessionBeepActive, totalBeepActive
    if (finished) {
        return
    }
    if (isFirstTick) {
        currentSessionTime := 0
        isFirstTick := false
        sessionBeepActive := false
        totalBeepActive := false
        SetTimer(BeepNotification, 0) ; Stop any beep
    }
    if breakActive {
        currentSessionTime := pausedSessionTime
        ; If user activity (keyboard/mouse) is detected via A_TimeIdle, pause the break timer
        if (A_TimeIdle < activityIdleThreshold) {
            if (!breakPaused) {
                breakPaused := true
                breakPauseStart := A_TickCount
                ; Indicate paused state and silence beeps
                SetTimer(BeepNotification, 0)
                sessionBeepActive := false
                totalBeepActive := false
            }
        } else {
            if (breakPaused) {
                ; Resume break: account for paused duration so elapsed freezes while paused
                breakStart += (A_TickCount - breakPauseStart)
                breakPaused := false
            }
        }
        ; Flash after break time reached (only when not paused)
        if (!breakPaused && (A_TickCount - breakStart >= breakTime)) {
            flashTimer := !flashTimer
            breakText.Visible := flashTimer
        } else {
            breakText.Visible := true
        }
        ; Show break countdown timer (freeze elapsed when paused)
        if (breakPaused) {
            breakElapsed := Max(breakPauseStart - breakStart, 0)
        } else {
            breakElapsed := Max(A_TickCount - breakStart, 0)
        }
        breakMins := breakElapsed // 60000
        breakSecs := Mod(breakElapsed // 1000, 60)
        if (breakPaused) {
            breakText.Text := Format("Paused: {:02}:{:02}", breakMins, breakSecs)
            breakText.Opt("BackgroundFFFF00") ; Yellow background when paused
            breakText.SetFont("c222222") ; Dark text
        } else {
            breakText.Text := Format("Break: {:02}:{:02}", breakMins, breakSecs)
            breakText.Opt("Background00FF00") ; Green
            breakText.SetFont("c222222") ; Dark text
        }
        breakTextAutoHide := false
    } else {
        if (pauseTick) {
            startTick += (A_TickCount - pauseTick)
            pauseTick := 0
        }
        currentSessionTime := Max(A_TickCount - startTick, 0)
        pausedSessionTime := currentSessionTime
        if (currentSessionTime >= sessionTime) {
            ; Flash 'Take Break' in red
            if (Mod(A_TickCount // 500, 2)) {
                breakText.Opt("BackgroundFF0000") ; Red
                breakText.SetFont("cFFFFFF") ; White text
            } else {
                breakText.Opt("Background808080") ; Gray
                breakText.SetFont("cFFFFFF") ; White text
            }
            breakText.Text := "Take Break"
            breakText.Visible := true
            breakTextAutoHide := false
            
            ; Shake every minute after "Take Break" has been flashing for more than 1 minute
            timeSinceSessionTime := currentSessionTime - sessionTime
            if (timeSinceSessionTime >= 60000) {
                currentMinute := timeSinceSessionTime // 60000  ; 1 == first full minute after flashing started
                if (currentMinute > lastShakeMinute) {
                    ; Move to top-right of the other display then shake
                    MoveGuiToOtherTopRight(myGui, 10)
                    Sleep(150)
                    ShakeGui(myGui, 10, 15)
                    lastShakeMinute := currentMinute
                    lastShakeTime := A_TickCount
                }
            }
            
            ; --- Start session beep if not already active ---
            if (!sessionBeepActive) {
                SetTimer(BeepNotification, 15000) ; Every 15 seconds
                BeepNotification() ; Immediate beep
                sessionBeepActive := true
            }
        } else {
            breakText.Text := "Take Break"
            breakText.Opt("Background808080") ; Gray
            breakText.SetFont("cFFFFFF") ; White text
            if (!breakText.Visible) {
                ; Only show if hover logic triggers
            }
            ; --- Stop session beep if timer is reset ---
            if (sessionBeepActive) {
                SetTimer(BeepNotification, 0)
                sessionBeepActive := false
            }
            ; Reset shake tracking when session not yet at sessionTime
            lastShakeMinute := -1
            lastShakeTime := 0
        }
    }
    ; Only clamp display, not elapsed
    displaySessionTime := Max(currentSessionTime, 0)
    hours := displaySessionTime // 3600000
    mins := Mod(displaySessionTime // 60000, 60)
    secs := Mod(displaySessionTime // 1000, 60)
    if (hours > 0) {
        counterText.Text := Format("{:02}:{:02}:{:02}", hours, mins, secs)
    } else {
        counterText.Text := Format("{:02}:{:02}", mins, secs)
    }
    
    ; 12-hour clock with AM/PM
    hour := SubStr(A_Now, 9, 2) + 0
    min := SubStr(A_Now, 11, 2)
    ampm := "AM"
    if (hour >= 12) {
        ampm := "PM"
        if (hour > 12)
            hour -= 12
    } else if (hour = 0) {
        hour := 12
    }
    clock := (hour < 10 ? "0" : "") . hour . ":" . min . " " . ampm
    clockText.Text := clock
    ; Timer color logic
    if (!breakActive) {
        if (mins == 0 && secs == 0) {
            ; Flash the timer text at 00:00 (invisible)
            if (Mod(A_TickCount // 500, 2)) {
                counterText.SetFont("c222222") ; Invisible (background color)
            } else {
                counterText.SetFont("cLime") ; Visible (default green)
            }
        } else if (currentSessionTime >= sessionTime) { ; Default: 30 minutes
            ; Red and flashing
            if (Mod(A_TickCount // 500, 2)) {
                counterText.SetFont("cFF0000") ; Red
            } else {
                counterText.SetFont("c222222") ; Default/dark
            }
        } else if (currentSessionTime >= sessionTime - 300000) { ; Default: 25 minutes
            counterText.SetFont("cFFFF00") ; Yellow
        } else {
            counterText.SetFont("cLime") ; Default green
        }
    } else {
        counterText.SetFont("cLime") ; Default green during break
    }
    ; Total time logic
    if (!breakActive) {
        nowTick := A_TickCount
        currentTotalTime += (nowTick - lastTotalTick)
        lastTotalTick := nowTick
    }
    ; Display total time in hh:mm:ss or mm:ss
    totalSecs := currentTotalTime // 1000
    totalHours := totalSecs // 3600
    totalMins := Mod(totalSecs // 60, 60)
    totalSecs := Mod(totalSecs, 60)
    if (totalHours > 0) {
        totalTimeText.Text := Format("{:02}:{:02}:{:02}", totalHours, totalMins, totalSecs)
    } else {
        totalTimeText.Text := Format("{:02}:{:02}", totalMins, totalSecs)
    }
    ; Total time color logic
    if (currentTotalTime >= totalTime) { ; Check if current time has reached the 3-hour limit
        ; Flash red
        if (Mod(A_TickCount // 500, 2)) {
            totalTimeText.SetFont("cFF0000") ; Red
        } else {
            totalTimeText.SetFont("c222222") ; Invisible
        }
        breakText.Text := "Finish Up"
        if (Mod(A_TickCount // 500, 2)) {
            breakText.Opt("BackgroundFF0000") ; Red
            breakText.SetFont("cFFFFFF") ; White text
        } else {
            breakText.Opt("Background808080") ; Gray
            breakText.SetFont("cFFFFFF") ; White text
        }
        breakText.Visible := true
        breakTextAutoHide := false
        ; --- Start total beep if not already active ---
        if (!totalBeepActive) {
            SetTimer(BeepNotification, 15000) ; Every 15 seconds
            BeepNotification() ; Immediate beep
            totalBeepActive := true
        }
    } else if (currentTotalTime >= totalTime - 300000) { ; Check if it's 5 minutes before the limit
        totalTimeText.SetFont("cFFFF00") ; Yellow
        ; --- Stop total beep if timer is reset ---
        if (totalBeepActive) {
            SetTimer(BeepNotification, 0)
            totalBeepActive := false
        }
    } else {
        totalTimeText.SetFont("c3399FF") ; Default blue
        if (totalBeepActive) {
            SetTimer(BeepNotification, 0)
            totalBeepActive := false
        }
    }
}

BreakTextHandler(txt, *) {
    global finished, breakActive, breakStart, pauseTick, pausedSessionTime, breakTextAutoHide, startTick, breakText, currentTotalTime, lastTotalTick, sessionTime, counterText, totalTimeText
    global sessionBeepActive, totalBeepActive

    if (breakText.Text = "Finished") {
        return ; Ignore clicks if already finished
    }

    if (breakText.Text = "Finish Up") {
        ; Stop all timers immediately
        SetTimer(updateTimer, 0)
        SetTimer(CheckMouseOverControls, 0)

        ; Set the finished flag
        finished := true

        ; Perform one final update of time values
        if (!breakActive) {
             currentSessionTime := Max(A_TickCount - startTick, 0)
             currentTotalTime += (A_TickCount - lastTotalTick)
        }

        ; Format and display final session time
        local displaySessionTime := Max(currentSessionTime, 0)
        local mins := displaySessionTime // 60000
        local secs := Mod(displaySessionTime // 1000, 60)
        counterText.Text := Format("{:02}:{:02}", mins, secs)
        counterText.SetFont("cFF0000") ; Final color: Red

        ; Format and display final total time
        local totalSecs := currentTotalTime // 1000
        local totalHours := totalSecs // 3600
        local totalMins := Mod(totalSecs // 60, 60)
        local totalSecs := Mod(totalSecs, 60)
        if (totalHours > 0) {
            totalTimeText.Text := Format("{:02}:{:02}:{:02}", totalHours, totalMins, totalSecs)
        } else {
            totalTimeText.Text := Format("{:02}:{:02}", totalMins, totalSecs)
        }
        totalTimeText.SetFont("cFF0000") ; Final color: Red

        ; Update the break button
        breakText.Text := "Finished"
        breakText.Opt("Background00FF00") ; Green
        breakText.SetFont("c222222") ; Dark text

        ; Set auto-close timer
        SetTimer(CloseIfFinished, 300000) ; Close after 5 minutes
        return
    }

    if (!breakActive) {
        breakActive := true
        breakStart := A_TickCount
        pauseTick := A_TickCount
        breakPaused := false
        breakText.Text := "On Break"
        breakText.Opt("Background00FF00") ; Green
        breakText.SetFont("c222222") ; Dark text
        ; Pause total time (do not update totalTime while on break)
    } else {
        breakActive := false
        breakPaused := false
        startTick := A_TickCount ; Reset timer when break ends
        lastTotalTick := A_TickCount ; Resume total time
        pausedSessionTime := 0 ; Reset pausedSessionTime so timer starts from zero
        pauseTick := 0 ; Prevent startTick from being incremented again
        breakText.Text := "Take Break"
        breakText.Opt("Background808080") ; Gray
        breakText.SetFont("cFFFFFF") ; White text
        ; Do not reset totalTime
    }

    ; --- Stop beep when button is clicked ---
    if (sessionBeepActive || totalBeepActive) {
        SetTimer(BeepNotification, 0)
        sessionBeepActive := false
        totalBeepActive := false
    }
}

GuiStartDrag(btn, *) {
    global myGui
    PostMessage(0xA1, 2) ; WM_NCLBUTTONDOWN, HTCAPTION
    ; Clamp position after drag
    SetTimer(() => ClampGuiToScreen(myGui), -10)
}

ClampGuiToScreen(gui) {
    screenW := SysGet(78)
    screenH := SysGet(79)
    x := y := w := h := 0
    WinGetPos(&x, &y, &w, &h, gui.Hwnd)
    newX := x, newY := y
    if (x < 0)
        newX := 0
    else if (x + w > screenW)
        newX := screenW - w
    if (y < 0)
        newY := 0
    else if (y + h > screenH)
        newY := screenH - h
    if (newX != x || newY != y)
        gui.Move(newX, newY)
}

ShowBreakText() {
    global breakText, breakTextLastShown, breakTextAutoHide
    breakText.Visible := true
    breakTextLastShown := A_TickCount
    breakTextAutoHide := true
}

ShakeGui(gui, iterations := 10, distance := 15) {
    ; Get current position
    gui.GetPos(&origX, &origY)
    
    Loop iterations {
        if (Mod(A_Index, 2) = 1) {
            gui.Move(origX + distance, origY)  ; Move right
        } else {
            gui.Move(origX - distance, origY)  ; Move left
        }
        Sleep(75)
    }
    gui.Move(origX, origY)  ; Reset to original position
}

MoveGuiToOtherTopRight(gui, margin := 10) {
    ; Heuristic: use primary screen width to pick the other monitor's approximate top-right.
    ; This assumes monitors are arranged horizontally (common case). If monitors differ in
    ; size or arrangement the result may need manual adjustment.
    gui.GetPos(&x, &y, &w, &h)
    primaryW := A_ScreenWidth

    if (x + w/2 < primaryW) {
        ; Move to the right of the primary screen (other monitor's right area)
        targetX := primaryW + (primaryW - w) - margin
    } else {
        ; Move to top-right of the left/other monitor (approximate)
        targetX := margin
    }
    targetY := margin
    gui.Move(targetX, targetY)
}

CheckMouseOverControls() {
    global myGui, breakActive, startTick, breakText, breakTextLastShown, breakTextAutoHide, breakTextMouseOver
    if breakActive
        return
    currentSessionTime := A_TickCount - startTick
    if (currentSessionTime >= 3600000)
        return
    ; Get position and size of the GUI
    x := y := w := h := 0
    WinGetPos(&x, &y, &w, &h, myGui.Hwnd)
    MouseGetPos(&mx, &my)
    over := (mx >= x && mx <= x + w && my >= y && my <= y + h)
    if (over && !breakTextMouseOver) {
        breakTextMouseOver := true
        ShowBreakText()
    } else if (!over && breakTextMouseOver) {
        breakTextMouseOver := false
        breakText.Visible := false
        breakTextAutoHide := false
    }
    ; If mouse is over and 3 seconds have passed, hide
    if (breakTextMouseOver && breakText.Visible && (A_TickCount - breakTextLastShown > 3000)) {
        breakText.Visible := false
        breakTextAutoHide := false
        breakTextMouseOver := false
    }
}

^q::ExitApp

^Right::AddFiveMinutes()

AddFiveMinutes() {
    global startTick, currentTotalTime, lastTotalTick
    startTick -= 300000
    currentTotalTime += 300000
    lastTotalTick := A_TickCount
}

^Left::SubtractFiveMinutes()

SubtractFiveMinutes() {
    global startTick, currentTotalTime
    newStartTick := startTick + 300000 ; Add 5 minutes (in ms) to startTick to decrement timer
    currentSessionTime := A_TickCount - newStartTick
    if (currentSessionTime < 0) {
        startTick := A_TickCount ; Clamp so timer shows 00:00
        ; Clamp currentTotalTime so it doesn't go below zero
        currentTotalTime := Max(currentTotalTime - (A_TickCount - startTick), 0)
    } else {
        startTick := newStartTick
        currentTotalTime := Max(currentTotalTime - 300000, 0)
    }
}

^.::AddOneMinute()

AddOneMinute() {
    global startTick, currentTotalTime
    startTick -= 60000 ; Subtract 1 minute (in ms) from startTick to increment timer
    currentTotalTime += 60000
}

^,::SubtractOneMinute()

SubtractOneMinute() {
    global startTick, currentTotalTime
    newStartTick := startTick + 60000 ; Add 1 minute (in ms) to startTick to decrement timer
    currentSessionTime := A_TickCount - newStartTick
    if (currentSessionTime < 0) {
        startTick := A_TickCount ; Clamp so timer shows 00:00
        currentTotalTime := Max(currentTotalTime - (A_TickCount - startTick), 0)
    } else {
        startTick := newStartTick
        currentTotalTime := Max(currentTotalTime - 60000, 0)
    }
}

CloseIfFinished() {
    global finished
    if (finished) {
        ExitApp
    }
}

^End::SetTotalToLimit()
^Home::ResetTotalToZero()

SetTotalToLimit() {
    global currentTotalTime, totalTime
    currentTotalTime := totalTime
}

ResetTotalToZero() {
    global currentTotalTime
    currentTotalTime := 0
}

^PgDn::SetSessionToLimit()
^PgUp::ResetSessionToZero()

SetSessionToLimit() {
    global startTick, sessionTime
    startTick := A_TickCount - sessionTime
}

ResetSessionToZero() {
    global startTick
    startTick := A_TickCount
}

^]::IncrementBreakElapsed()
^[::DecrementBreakElapsed()

IncrementBreakElapsed() {
    global breakActive, breakStart
    if (breakActive) {
        breakStart -= 60000 ; Subtract 1 minute from breakStart (so elapsed increases by 1 min)
    }
}

DecrementBreakElapsed() {
    global breakActive, breakStart
    if (breakActive) {
        newBreakStart := breakStart + 60000 ; Add 1 minute to breakStart (so elapsed decreases by 1 min)
        elapsed := A_TickCount - newBreakStart
        if (elapsed < 0) {
            breakStart := A_TickCount ; Clamp so timer shows 00:00
        } else {
            breakStart := newBreakStart
        }
    }
}

^+s::SetCustomSound()
^+i::ShowSoundInfo()
^+k::{
    MoveGuiToOtherTopRight(myGui, 10)
    Sleep(150)
    ShakeGui(myGui, 10, 15)
}

SetCustomSound() {
    global customSoundPath, soundsDir
    
    ; Create a menu for sound options
    soundMenu := Menu()
    soundMenu.Add("Select Local File", SelectLocalSoundFile)
    soundMenu.Add("Download from URL", DownloadSoundFromURL)
    soundMenu.Add("Select from Downloaded", SelectFromDownloaded)
    soundMenu.Add("Clear Custom Sound", ClearCustomSound)
    soundMenu.Add() ; Separator
    soundMenu.Add("Open Sounds Folder", OpenSoundsFolder)
    
    ; Show the menu at cursor position
    soundMenu.Show()
}

SelectLocalSoundFile(*) {
    global customSoundPath, soundsDir
    file := FileSelect(1, , "Select a sound file", "Audio Files (*.wav;*.mp3;*.wma;*.aac;*.m4a;*.flac)")
    if (file != "") {
        ; Check if file is outside the sounds directory
        if (!InStr(file, soundsDir)) {
            ; Ask if user wants to copy the file to sounds directory
            result := MsgBox("The selected file is outside the sounds directory.`n`nWould you like to copy it to the sounds directory for better organization?`n`nThis ensures the sound file will be available even if the original is moved or deleted.", "Copy Sound File", "YesNo")
            
            if (result = "Yes") {
                ; Copy file to sounds directory
                filename := RegExReplace(file, ".*\\", "")
                newPath := soundsDir . "\" . filename
                
                ; Handle filename conflicts
                counter := 1
                while (FileExist(newPath)) {
                    name := RegExReplace(filename, "\.([^.]+)$", "")
                    ext := RegExReplace(filename, ".*\.", "")
                    newPath := soundsDir . "\" . name . "_" . counter . "." . ext
                    counter++
                }
                
                try {
                    FileCopy(file, newPath)
                    customSoundPath := newPath
                    if (SaveCustomSoundPath(newPath)) {
                        MsgBox "Sound file copied to sounds directory and set as custom sound!"
                    } else {
                        MsgBox "Sound file copied but failed to save to config file."
                    }
                } catch {
                    MsgBox "Failed to copy sound file. Using original location."
                    customSoundPath := file
                    if (SaveCustomSoundPath(file)) {
                        MsgBox "Custom sound set and saved!"
                    } else {
                        MsgBox "Custom sound set but failed to save to config file."
                    }
                }
            } else {
                ; Use original file location
                customSoundPath := file
                if (SaveCustomSoundPath(file)) {
                    MsgBox "Custom sound set and saved!"
                } else {
                    MsgBox "Custom sound set but failed to save to config file."
                }
            }
        } else {
            ; File is already in sounds directory
            customSoundPath := file
            if (SaveCustomSoundPath(file)) {
                MsgBox "Custom sound set and saved!"
            } else {
                MsgBox "Custom sound set but failed to save to config file."
            }
        }
    }
}

DownloadSoundFromURL(*) {
    global customSoundPath, soundsDir
    
    ; Prompt for URL
    url := InputBox("Enter the URL of the sound file to download:", "Download Sound File", "w400")
    if (url.Result = "OK" && url.Value != "") {
        ; Show download progress
        progressGui := Gui("+ToolWindow", "Downloading...")
        progressGui.AddText("w300", "Downloading sound file...")
        progressGui.AddProgress("w300 h20 vProgressBar", 0)
        progressGui.Show("NoActivate")
        
        ; Download the file
        localPath := DownloadSoundFile(url.Value)
        
        ; Hide progress
        progressGui.Destroy()
        
        if (localPath != "") {
            customSoundPath := localPath
            if (SaveCustomSoundPath(localPath)) {
                MsgBox "Sound file downloaded and set as custom sound!"
            } else {
                MsgBox "Sound file downloaded but failed to save to config file."
            }
        } else {
            MsgBox "Failed to download sound file. Please check the URL and try again."
        }
    }
}

SelectFromDownloaded(*) {
    global customSoundPath, soundsDir
    
    ; Get available sound files
    soundFiles := GetAvailableSoundFiles()
    
    if (soundFiles.Length = 0) {
        MsgBox "No sound files found in the sounds directory.`n`nUse 'Download from URL' or 'Select Local File' to add sound files."
        return
    }
    
    ; Create selection dialog
    selectionGui := Gui("+ToolWindow", "Select Sound File")
    selectionGui.AddText("w400", "Select a sound file from the downloaded files:")
    
    ; Create listbox with sound files
    listBox := selectionGui.AddListBox("w400 h200 vSelectedFile")
    for soundFile in soundFiles {
        ; Show just the filename, not the full path
        filename := RegExReplace(soundFile, ".*\\\\", "")
        listBox.Add([filename])
    }
    
    ; Add buttons
    buttonGui := Gui()
    buttonGui.AddButton("w80 h30 vSelectBtn", "Select").OnEvent("Click", SelectSoundFile)
    buttonGui.AddButton("x+10 w80 h30 vCancelBtn", "Cancel").OnEvent("Click", CloseSelectionGui)
    
    ; Show both GUIs
    selectionGui.Show("NoActivate")
    buttonGui.Show("NoActivate")
    
    ; Position button GUI below selection GUI
    WinGetPos(&x, &y, &w, &h, selectionGui.Hwnd)
    buttonGui.Move(x, y + h + 10)
    
    ; Store references for event handlers
    global selectionGuiRef := selectionGui
    global buttonGuiRef := buttonGui
    global soundFilesRef := soundFiles
}

SelectSoundFile(*) {
    global customSoundPath, selectionGuiRef, buttonGuiRef, soundFilesRef
    
    ; Get selected file
    selectedIndex := selectionGuiRef["SelectedFile"].Value
    if (selectedIndex > 0) {
        selectedFile := soundFilesRef[selectedIndex]
        customSoundPath := selectedFile
        if (SaveCustomSoundPath(selectedFile)) {
            MsgBox "Custom sound set and saved!"
        } else {
            MsgBox "Custom sound set but failed to save to config file."
        }
    }
    
    ; Close GUIs
    selectionGuiRef.Destroy()
    buttonGuiRef.Destroy()
}

CloseSelectionGui(*) {
    global selectionGuiRef, buttonGuiRef
    selectionGuiRef.Destroy()
    buttonGuiRef.Destroy()
}

ClearCustomSound(*) {
    global customSoundPath
    customSoundPath := ""
    if (SaveCustomSoundPath("")) {
        MsgBox "Custom sound cleared. Default beep will be used."
    } else {
        MsgBox "Custom sound cleared but failed to save to config file."
    }
}

OpenSoundsFolder(*) {
    global soundsDir
    try {
        Run soundsDir
    } catch {
        MsgBox "Failed to open sounds folder."
    }
}

ShowSoundInfo() {
    global customSoundPath, soundsDir
    
    info := "Sound Configuration:`n`n"
    
    if (customSoundPath != "") {
        if (FileExist(customSoundPath)) {
            info .= "✓ Custom sound is set and file exists:`n"
            info .= customSoundPath . "`n`n"
            
            ; Show file size
            try {
                fileSize := FileGetSize(customSoundPath)
                if (fileSize > 1024 * 1024) {
                    info .= "File size: " . Round(fileSize / (1024 * 1024), 2) . " MB`n"
                } else {
                    info .= "File size: " . Round(fileSize / 1024, 2) . " KB`n"
                }
            } catch {
                info .= "File size: Unknown`n"
            }
        } else {
            info .= "✗ Custom sound is set but file not found:`n"
            info .= customSoundPath . "`n`n"
            info .= "The file may have been moved or deleted.`n"
        }
    } else {
        info .= "No custom sound set. Using default beep.`n`n"
    }
    
    ; Show sounds directory info
    info .= "`nSounds directory: " . soundsDir . "`n"
    
    if (DirExist(soundsDir)) {
        soundFiles := GetAvailableSoundFiles()
        info .= "Downloaded sound files: " . soundFiles.Length . "`n"
        
        if (soundFiles.Length > 0) {
            info .= "`nAvailable files:`n"
            for soundFile in soundFiles {
                filename := RegExReplace(soundFile, ".*\\", "")
                info .= "• " . filename . "`n"
            }
        }
    } else {
        info .= "Sounds directory does not exist.`n"
    }
    
    MsgBox(info, "Sound Information", "T300")
}
