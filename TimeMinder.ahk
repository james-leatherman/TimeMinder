#Requires AutoHotkey v2.0

startTick := A_TickCount

; Create GUI
myGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
myGui.BackColor := "222222"

myGui.AddText("y+2")

; Session Time
myGui.SetFont("s10 Bold cLime", "Segoe UI")
sessionTitle := myGui.AddText("w130 h18 Center", "Session Time")
myGui.SetFont("s18 Bold cLime", "Segoe UI")
counterText := myGui.AddText("w130 h28 Center y+0", "00:00")

myGui.AddText("y+2")

; Clock
myGui.SetFont("s10 cGray", "Segoe UI")
clockTitle := myGui.AddText("w130 h18 Center", "Current Time")
myGui.SetFont("s18 cGray", "Segoe UI")
clockText := myGui.AddText("w130 h28 Center y+0", "00:00")

myGui.AddText("y+2")

; Total Time
myGui.SetFont("s10 Bold c3399FF", "Segoe UI")
totalTitle := myGui.AddText("w130 h18 Center", "Total Time")
myGui.SetFont("s18 c3399FF Bold", "Segoe UI")
totalTimeText := myGui.AddText("w130 h28 Center y+0", "00:00")

totalTime := 0
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
pausedElapsed := 0
pauseTick := 0
myGui.Show("x20 y20 NoActivate")

; Add a timer to check mouse position
SetTimer(updateTimer, 500)
SetTimer(AutoHideBreakText, 500)

; Make the GUI draggable
counterText.OnEvent("Click", GuiStartDrag)
clockText.OnEvent("Click", GuiStartDrag)
totalTimeText.OnEvent("Click", GuiStartDrag)
sessionTitle.OnEvent("Click", GuiStartDrag)
clockTitle.OnEvent("Click", GuiStartDrag)
totalTitle.OnEvent("Click", GuiStartDrag)

; Add a timer to check mouse position over timer/clock
SetTimer(CheckMouseOverControls, 100)

; When script starts, initialize totalTime to match timer
initElapsed := A_TickCount - startTick
if (initElapsed > 0) {
    totalTime := initElapsed
}

finished := false

updateTimer(*) {
    global finished, startTick, counterText, clockText, breakText, breakActive, breakStart, flashTimer, pausedElapsed, pauseTick, breakTextLastShown, breakTextAutoHide, myGui, totalTime, lastTotalTick, totalTimeText
    if (finished) {
        return
    }
    if breakActive {
        elapsed := pausedElapsed
        ; Flash after 10 minutes on break
        if (A_TickCount - breakStart >= 600000) {
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
        elapsed := A_TickCount - startTick
        pausedElapsed := elapsed
        if (elapsed >= 1800000) {
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
    displayElapsed := Max(elapsed, 0)
    mins := displayElapsed // 60000
    secs := Mod(displayElapsed // 1000, 60)
    counterText.Text := (mins < 10 ? "0" : "") . mins . ":" . (secs < 10 ? "0" : "") . secs
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
        } else if (elapsed >= 1800000) { ; 30 minutes
            ; Red and flashing
            if (Mod(A_TickCount // 500, 2)) {
                counterText.SetFont("cFF0000") ; Red
            } else {
                counterText.SetFont("c222222") ; Default/dark
            }
        } else if (elapsed >= 1500000) { ; 25 minutes
            counterText.SetFont("cFFFF00") ; Yellow
        } else {
            counterText.SetFont("cLime") ; Default green
        }
    } else {
        counterText.SetFont("cLime") ; Default green during break
    }
    ; Total time logic
    nowTick := A_TickCount
    if (!breakActive) {
        totalTime += (nowTick - lastTotalTick)
    }
    lastTotalTick := nowTick
    ; Display total time in hh:mm
    totalMins := totalTime // 60000
    totalHours := totalMins // 60
    totalMins := Mod(totalMins, 60)
    totalTimeText.Text := (totalHours < 10 ? "0" : "") . totalHours . ":" . (totalMins < 10 ? "0" : "") . totalMins
    ; Total time color logic
    totalElapsed := totalHours * 3600000 + totalMins * 60000
    if (totalTime >= 10800000) { ; 3 hours
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
    } else if (totalTime >= 10500000) { ; 2:55
        totalTimeText.SetFont("cFFFF00") ; Yellow
    } else {
        totalTimeText.SetFont("c3399FF") ; Default blue
    }
}

BreakTextHandler(txt, *) {
    global finished, breakActive, breakStart, pauseTick, pausedElapsed, breakTextAutoHide, startTick, breakText, totalTime, lastTotalTick, displayElapsed
    if (finished)
        return
    breakTextAutoHide := false
    if (breakText.Text = "Finish Up") {
        ; Stop all timers and blinking
        SetTimer(updateTimer, 0)
        SetTimer(AutoHideBreakText, 0)
        SetTimer(CheckMouseOverControls, 0)
        finished := true
        breakText.Text := "Finished"
        breakText.Opt("Background00FF00") ; Green
        breakText.SetFont("c222222") ; Dark text
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
        pausedElapsed := 0 ; Reset pausedElapsed so timer starts from zero
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

AutoHideBreakText() {
    ; No longer needed, logic moved to CheckMouseOverControls
}

CheckMouseOverControls() {
    global myGui, breakActive, startTick, breakText, breakTextLastShown, breakTextAutoHide, breakTextMouseOver
    if breakActive
        return
    elapsed := A_TickCount - startTick
    if (elapsed >= 3600000)
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
    global startTick, totalTime, lastTotalTick
    startTick -= 300000
    totalTime += 300000
    lastTotalTick := A_TickCount
}

^Left::SubtractFiveMinutes()

SubtractFiveMinutes() {
    global startTick, totalTime
    newStartTick := startTick + 300000 ; Add 5 minutes (in ms) to startTick to decrement timer
    elapsed := A_TickCount - newStartTick
    if (elapsed < 0) {
        startTick := A_TickCount ; Clamp so timer shows 00:00
        ; Clamp totalTime so it doesn't go below zero
        totalTime := Max(totalTime - (A_TickCount - startTick), 0)
    } else {
        startTick := newStartTick
        totalTime := Max(totalTime - 300000, 0)
    }
}

^.::AddOneMinute()

AddOneMinute() {
    global startTick, totalTime
    startTick -= 60000 ; Subtract 1 minute (in ms) from startTick to increment timer
    totalTime += 60000
}

^,::SubtractOneMinute()

SubtractOneMinute() {
    global startTick, totalTime
    newStartTick := startTick + 60000 ; Add 1 minute (in ms) to startTick to decrement timer
    elapsed := A_TickCount - newStartTick
    if (elapsed < 0) {
        startTick := A_TickCount ; Clamp so timer shows 00:00
        totalTime := Max(totalTime - (A_TickCount - startTick), 0)
    } else {
        startTick := newStartTick
        totalTime := Max(totalTime - 60000, 0)
    }
}

CloseIfFinished() {
    global finished
    if (finished) {
        ExitApp
    }
}
