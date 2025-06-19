#Requires AutoHotkey v2.0

startTick := A_TickCount

; Create GUI
myGui := Gui("-Caption +ToolWindow +AlwaysOnTop")
myGui.BackColor := "222222"
myGui.SetFont("s12 Bold cLime", "Segoe UI") ; Counter: bright green
counterText := myGui.AddText("w130 h35 Center", "00:00:00")
myGui.SetFont("s10 cGray", "Segoe UI") ; Clock: smaller, gray
clockText := myGui.AddText("w130 h20 Center", "00:00")
; Replace the break button with a styled Text control
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

; Remove invalid MouseEnter event
; Add a timer to check mouse position
SetTimer(updateTimer, 1000)
SetTimer(AutoHideBreakText, 500)

; Make the GUI draggable
counterText.OnEvent("Click", GuiStartDrag)

; Remove invalid MouseOver events
; Add a timer to check mouse position over timer/clock
SetTimer(CheckMouseOverControls, 100)

updateTimer(*) {
    global startTick, counterText, clockText, breakText, breakActive, breakStart, flashTimer, pausedElapsed, pauseTick, breakTextLastShown, breakTextAutoHide
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
        if (elapsed >= 3600000) {
            if ((A_TickCount // 500) mod 2) {
                breakText.Opt("BackgroundFF0000") ; Red
                breakText.SetFont("cFFFFFF") ; White text
            } else {
                breakText.Opt("Background00FF00") ; Green
                breakText.SetFont("c222222") ; Dark text
            }
            breakText.Text := "On Break"
            breakText.Visible := true
            breakTextAutoHide := false
        } else {
            breakText.Text := "Take Break"
            breakText.Opt("Background808080") ; Gray
            breakText.SetFont("cFFFFFF") ; White text
        }
    }
    hours := elapsed // 3600000
    mins := Mod(elapsed // 60000, 60)
    secs := Mod(elapsed // 1000, 60)
    counterText.Text := (hours < 10 ? "0" : "") . hours . ":" . (mins < 10 ? "0" : "") . mins . ":" . (secs < 10 ? "0" : "") . secs
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
}

BreakTextHandler(txt, *) {
    global breakActive, breakStart, pauseTick, pausedElapsed, breakTextAutoHide
    breakTextAutoHide := false
    if (!breakActive) {
        breakActive := true
        breakStart := A_TickCount
        pauseTick := A_TickCount
    } else {
        breakActive := false
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
