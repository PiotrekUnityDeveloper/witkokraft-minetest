local private = ...



-- gdi type ids
private.GDI_TERM    = 1
private.GDI_MONITOR = 2
private.GDI_PRINTER = 4

-- window.move, z positioning
win.WND_TOP     = 0
win.WND_BOTTOM  = 100000

-- window.hitTest, return values
win.HT_NOWHERE     = 0
win.HT_CLIENT      = 1
win.HT_LINEUP      = 2
win.HT_LINEDOWN    = 3
win.HT_PAGEUP      = 4
win.HT_PAGEDOWN    = 5
win.HT_LINELEFT    = 6
win.HT_LINERIGHT   = 7
win.HT_PAGELEFT    = 8
win.HT_PAGERIGHT   = 9

-- internal window ids
private.ID_DESKTOP     = 65536
private.ID_FRAME       = 65537
private.ID_TASKBAR     = 65538
private.ID_MENULIST    = 65539
private.ID_APPLIST     = 65540
private.ID_MENUFRAME   = 65541
private.ID_APPFRAME    = 65542
private.ID_KEYBOARD    = 65543
private.ID_DIALOG      = 65544
private.ID_MSGBOX_MSG  = 65545
private.ID_LOCKSCRN    = 65546
private.ID_LOCKPW      = 65547
private.ID_LOCKOK      = 65548
private.ID_HOMELOCK    = 65549
private.ID_SYSMSGBOX   = 65550

-- window/frame class ids
private.FRAME_CLASS_WINDOW      = 70000
private.FRAME_CLASS_SYSTEM      = 70001
private.FRAME_CLASS_APPLICATION = 70002
private.FRAME_CLASS_DIALOG      = 70003

-- close button and title text id on dressed frames/popups
win.ID_TITLEBAR = 80000
win.ID_CLOSE    = 80001

-- clipboard type types
win.CB_EMPTY    = 0
win.CB_TEXT     = 1

-- wantKeyInput(), on screen keyboard
win.KEYINPUT_NONE     = 0
win.KEYINPUT_LINE     = 1
win.KEYINPUT_EDIT     = 2


-- the work space object
private.workspace = nil
