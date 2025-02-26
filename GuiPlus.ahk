#Requires AutoHotkey v2.0

real_xywh(gui) {
    rect := Buffer(16)
    DllCall("GetWindowRect", "Ptr", gui.Hwnd, "Ptr", rect)

    x := NumGet(rect, 0, "Int")
    y := NumGet(rect, 4, "Int")
    width := NumGet(rect, 8, "Int") - x
    height := NumGet(rect, 12, "Int") - y
    return [x, y, width, height]
}

Show_inScreen(gui, x, y) {
    xywh := real_xywh(gui)
    width := xywh[3]
    height := xywh[4]
    x := min(x, A_ScreenWidth - width)
    y := min(y, A_ScreenHeight - height)
    gui.show("x" x " y" y)
}

Move_inScreen(gui, x, y) {
    xywh := real_xywh(gui)
    width := xywh[3]
    height := xywh[4]
    x := min(x, A_ScreenWidth - width)
    y := min(y, A_ScreenHeight - height)
    gui.Move(x, y)
}

twinkle_downup(gui, transparent_min, transparent_max, times := 2, delay := 500) {
    if (Type(gui) == 'Array') {
        for gui_ in gui {
            twinkle(0, gui_, transparent_min, transparent_max, times * 2, delay)
        }
        return
    }
    twinkle(0, gui, transparent_min, transparent_max, times * 2, delay)
}
twinkle_updown(gui, transparent_min, transparent_max, times := 2, delay := 500) {
    if (Type(gui) == 'Array') {
        for gui_ in gui {
            twinkle(1, gui_, transparent_min, transparent_max, times * 2, delay)
        }
        return
    }
    twinkle(1, gui, transparent_min, transparent_max, times * 2, delay)
}
twinkle(status, gui, transparent_min, transparent_max, times, delay) {
    if (times != 1) {
        next := () => twinkle(!status, gui, transparent_min, transparent_max, times - 1, delay)
        SetTimer(next, -delay)
    }
    if (status) {
        WinSetTransparent(transparent_max, gui)
    } else {
        WinSetTransparent(transparent_min, gui)
    }
}

; Move_multi_screen(gui,x,y,w:='None',h:='None',OnTop:=false,Activate:=false){ ; 半成品
;     option:=0x0000

;     if (!IsNumber(w) or !IsNumber(h)){
;         w:=0
;         h:=0
;         option |= 0x0001
;     }
;     if (Activate){
;         option |= 0x0010
;     }
;     if(!OnTop){
;         option |= 0x0004
;     }
;     DllCall("SetWindowPos", "Ptr", gui.Hwnd, "Ptr", 1, "Int", x, "Int", y, "Int", 32, "Int", 32, "UInt", 0x0010)
;     gui.GetPos(&x2,&y2,&w2,&h2)
;     scale_x:= x/x2
;     scale_y:= y/y2
;     scale_w:= 32/w2
;     scale_h:= 32/h2
;     x:=x*scale_x
;     y:=y*scale_y
;     w:=w*scale_w
;     h:=h*scale_h
;     DllCall("SetWindowPos", "Ptr", gui.Hwnd, "Ptr", 0, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", option)

; }

MoveTop_DllCall(gui, x, y, w, h) {    ; 半成品
    ; OutputDebug("MoveTop_DllCall")
    ; OutputDebug("x: " x " y: " y " w: " w " h: " h)
    DllCall("SetWindowPos", "Int", gui.Hwnd, "Int", 0, "Int", x, "Int", y, "Int", w, "Int", h, "UInt", 0x0010)
}

Resize_DllCall(gui, w, h) {
    DllCall("SetWindowPos", "Int", gui.Hwnd, "Int", 0, "Int", 0, "Int", 0, "Int", w, "Int", h, "UInt", 0x0002 | 0x0004)
}

GetCaretPosEx(&x?, &y?, &w?, &h?) {
    ; 用于获取光标位置，在“指令模式”中使用，使得指令框能够跟随光标位置。
    ; 这段代码不是我写的，但是已找不到作者
    #Requires AutoHotkey v2.0-rc.1 64-bit
    try {
        x := y := w := h := 0
        static iUIAutomation := 0, hOleacc := 0, IID_IAccessible, guiThreadInfo, _ := init()
        if CaretGetPos(&x, &y) {
            hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, 16, "ptr") || WinExist()
            return hwndFocus
        }
        if !iUIAutomation || ComCall(8, iUIAutomation, "ptr*", eleFocus := ComValue(13, 0), "int") || !eleFocus.Ptr {
            goto useAccLocation
        }

        if !ComCall(16, eleFocus, "int", 10002, "ptr*", valuePattern := ComValue(13, 0), "int") && valuePattern.Ptr
            if !ComCall(5, valuePattern, "int*", &isReadOnly := 0) && isReadOnly
                return 0


useAccLocation:
        ; use IAccessible::accLocation
        hwndFocus := DllCall("GetGUIThreadInfo", "uint", DllCall("GetWindowThreadProcessId", "ptr", WinExist("A"), "ptr", 0, "uint"), "ptr", guiThreadInfo) && NumGet(guiThreadInfo, 16, "ptr") || WinExist()
        if hOleacc && !DllCall("Oleacc\AccessibleObjectFromWindow", "ptr", hwndFocus, "uint", 0xFFFFFFF8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") && accCaret.Ptr {
            NumPut("ushort", 3, varChild := Buffer(24, 0))

            if !ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int") {
                dpi := DllCall("GetDpiForWindow", "Ptr", hwndFocus)
                if (!dpi) {
                    return 0
                }
                x := x * A_ScreenDPI / dpi
                y := y * A_ScreenDPI / dpi
                w := w * A_ScreenDPI / dpi
                h := h * A_ScreenDPI / dpi
                return hwndFocus
            }
        }
        if iUIAutomation && eleFocus {
            ; use IUIAutomationTextPattern2::GetCaretRange
            if ComCall(16, eleFocus, "int", 10024, "ptr*", textPattern2 := ComValue(13, 0), "int") || !textPattern2.Ptr
                goto useGetSelection
            if ComCall(10, textPattern2, "int*", &isActive := 0, "ptr*", caretTextRange := ComValue(13, 0), "int") || !caretTextRange.Ptr || !isActive
                goto useGetSelection
            if !ComCall(10, caretTextRange, "ptr*", &rects := 0, "int") && rects && (rects := ComValue(0x2005, rects, 1)).MaxIndex() >= 3 {
                x := rects[0], y := rects[1], w := rects[2], h := rects[3]
                return hwndFocus
            }
useGetSelection:
            ; use IUIAutomationTextPattern::GetSelection
            if textPattern2.Ptr
                textPattern := textPattern2
            else if ComCall(16, eleFocus, "int", 10014, "ptr*", textPattern := ComValue(13, 0), "int") || !textPattern.Ptr
                goto useGUITHREADINFO
            if ComCall(5, textPattern, "ptr*", selectionRangeArray := ComValue(13, 0), "int") || !selectionRangeArray.Ptr
                goto useGUITHREADINFO
            if ComCall(3, selectionRangeArray, "int*", &length := 0, "int") || length <= 0
                goto useGUITHREADINFO
            if ComCall(4, selectionRangeArray, "int", 0, "ptr*", selectionRange := ComValue(13, 0), "int") || !selectionRange.Ptr
                goto useGUITHREADINFO
            if ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
                goto useGUITHREADINFO
            rects := ComValue(0x2005, rects, 1)
            if rects.MaxIndex() < 3 {
                if ComCall(6, selectionRange, "int", 0, "int") || ComCall(10, selectionRange, "ptr*", &rects := 0, "int") || !rects
                    goto useGUITHREADINFO
                rects := ComValue(0x2005, rects, 1)
                if rects.MaxIndex() < 3
                    goto useGUITHREADINFO
            }
            x := rects[0], y := rects[1], w := rects[2], h := rects[3]
            return hwndFocus
        }
useGUITHREADINFO:
        if hwndCaret := NumGet(guiThreadInfo, 48, "ptr") {
            if DllCall("GetWindowRect", "ptr", hwndCaret, "ptr", clientRect := Buffer(16)) {
                w := NumGet(guiThreadInfo, 64, "int") - NumGet(guiThreadInfo, 56, "int")
                h := NumGet(guiThreadInfo, 68, "int") - NumGet(guiThreadInfo, 60, "int")
                DllCall("ClientToScreen", "ptr", hwndCaret, "ptr", guiThreadInfo.Ptr + 56)
                x := NumGet(guiThreadInfo, 56, "int")
                y := NumGet(guiThreadInfo, 60, "int")
                return hwndCaret
            }
        }
        return 0
    } catch {
        return 0
    }
    static init() {
        try
            iUIAutomation := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
        hOleacc := DllCall("LoadLibraryW", "str", "Oleacc.dll", "ptr")
        NumPut("int64", 0x11CF3C3D618736E0, "int64", 0x719B3800AA000C81, IID_IAccessible := Buffer(16))
        guiThreadInfo := Buffer(72), NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    }

}