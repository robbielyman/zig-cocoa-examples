const std = @import("std");

pub const Type = enum(u64) {
    LeftMouseDown = 1,
    LeftMouseUp = 2,
    RightMouseDown = 3,
    RightMouseUp = 4,
    MouseMoved = 5,
    LeftMouseDragged = 6,
    RightMouseDragged = 7,
    MouseEntered = 8,
    MouseExited = 9,
    KeyDown = 10,
    KeyUp = 11,
    FlagsChanged = 12,
    AppKitDefined = 13,
    SystemDefined = 14,
    ApplicationDefined = 15,
    Periodic = 16,
    CursorUpdate = 17,
    ScrollWheel = 22,
    TabletPoint = 23,
    TabletProximity = 24,
    OtherMouseDown = 25,
    OtherMouseUp = 26,
    OtherMouseDragged = 27,
    Gesture = 29,
    Magnify = 30,
    Swipe = 31,
    Rotate = 18,
    BeginGesture = 19,
    EndGesture = 20,
    SmartMagnify = 32,
    QuickLook = 33,
    Pressure = 34,
    DirectTouch = 37,
    ChangeMode = 38,
};

pub const Mask = packed struct {
    LeftMouseDown: bool,
    LeftMouseUp: bool,
    RightMouseDown: bool,
    RightMouseUp: bool,
    MouseMoved: bool,
    LeftMouseDragged: bool,
    RightMouseDragged: bool,
    MouseEntered: bool,
    MouseExited: bool,
    KeyDown: bool,
    KeyUp: bool,
    FlagsChanged: bool,
    AppKitDefined: bool,
    SystemDefined: bool,
    ApplicationDefined: bool,
    Periodic: bool,
    CursorUpdate: bool,
    Rotate: bool,
    BeginGesture: bool,
    EndGesture: bool,
    _unused: bool = false,
    ScrollWheel: bool,
    TabletPoint: bool,
    TabletProximity: bool,
    OtherMouseDown: bool,
    OtherMouseUp: bool,
    OtherMouseDragged: bool,
    _unused_2: bool = false,
    Gesture: bool,
    Magnify: bool,
    Swipe: bool,
    SmartMagnify: bool,
    QuickLook: bool,
    Pressure: bool,
    _unused_3: u2 = 0,
    DirectTouch: bool,
    ChangeMode: bool,
    _padding: u26 = 0,

    pub const any = @as(@This(), @bitCast(@as(u64, std.math.maxInt(u64))));

    comptime {
        std.debug.assert(@sizeOf(@This()) == @sizeOf(u64));
        std.debug.assert(@bitSizeOf(@This()) == @bitSizeOf(u64));
    }
};

pub const ModifierFlags = packed struct {
    _padding: u15 = 0,
    CapsLock: bool,
    Shift: bool,
    Control: bool,
    Option: bool,
    Command: bool,
    NumericPad: bool,
    Help: bool,
    Function: bool,
    _padding_2: u41 = 0,

    comptime {
        std.debug.assert(@sizeOf(@This()) == @sizeOf(u64));
        std.debug.assert(@bitSizeOf(@This()) == @bitSizeOf(u64));
    }
};
