#Requires AutoHotkey v2.0

; Parse command line arguments
sessionTime := 1800000 ; Default: 30 minutes
breakTime := 600000 ; Default: 10 minutes
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

updateTimer(*) {
    global finished, startTick, counterText, clockText, breakText, breakActive, breakStart, flashTimer, pausedSessionTime, pauseTick, breakTextLastShown, breakTextAutoHide, myGui, currentTotalTime, lastTotalTick, totalTimeText, sessionTime, isFirstTick
    if (finished) {
        return
    }
    if (isFirstTick) {
        currentSessionTime := 0
        isFirstTick := false
    }
    if breakActive {
        currentSessionTime := pausedSessionTime
        ; Flash after 10 minutes on break
        if (A_TickCount - breakStart >= breakTime) {
            flashTimer := !flashTimer
            breakText.Visible := flashTimer
        } else {
            breakText.Visible := true
        }
        breakText.Text := "On Break"
        breakText.Opt("Background00FF00") ; Green
        breakText.SetFont("c222222") ; Dark text
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
        } else {
            breakText.Text := "Take Break"
            breakText.Opt("Background808080") ; Gray
            breakText.SetFont("cFFFFFF") ; White text
            if (!breakText.Visible) {
                ; Only show if hover logic triggers
            }
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
    nowTick := A_TickCount
    currentTotalTime += (nowTick - lastTotalTick)
    lastTotalTick := nowTick
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
    } else if (currentTotalTime >= totalTime - 300000) { ; Check if it's 5 minutes before the limit
        totalTimeText.SetFont("cFFFF00") ; Yellow
    } else {
        totalTimeText.SetFont("c3399FF") ; Default blue
    }
}

BreakTextHandler(txt, *) {
    global finished, breakActive, breakStart, pauseTick, pausedSessionTime, breakTextAutoHide, startTick, breakText, currentTotalTime, lastTotalTick, sessionTime, counterText, totalTimeText

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
        breakText.Text := "On Break"
        breakText.Opt("Background00FF00") ; Green
        breakText.SetFont("c222222") ; Dark text
        ; Pause total time (do not update totalTime while on break)
    } else {
        breakActive := false
        startTick := A_TickCount ; Reset timer when break ends
        lastTotalTick := A_TickCount ; Resume total time
        pausedSessionTime := 0 ; Reset pausedSessionTime so timer starts from zero
        pauseTick := 0 ; Prevent startTick from being incremented again
        breakText.Text := "Take Break"
        breakText.Opt("Background808080") ; Gray
        breakText.SetFont("cFFFFFF") ; White text
        ; Do not reset totalTime
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
