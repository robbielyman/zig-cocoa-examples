const cocoa = @import("cocoa");
const objc = @import("zig-objc");

pub fn main() void {
    const window1 = cocoa.NSWindow.initWith(
        cocoa.alloc(objc.getClass("NSWindow").?),
        cocoa.NSRect.make(100, 100, 300, 300),
        .{
            .closable = true,
            .fullscreen = false,
            .fullsize_content_view = true,
            .miniaturizable = true,
            .resizable = true,
            .titled = true,
        },
        .Buffered,
        false,
    ).msgSend(objc.Object, "autorelease", .{});
    window1.setProperty("isVisible", .{.YES});
    const NSApp = cocoa.NSApp();
    const NSAutoReleasePool = objc.getClass("NSAutoreleasePool").?;
    var pool = cocoa.alloc(NSAutoReleasePool).msgSend(objc.Object, "init", .{});
    NSApp.msgSend(void, "finishLaunching", .{});
    while (true) {
        pool.msgSend(void, "release", .{});
        pool = cocoa.alloc(NSAutoReleasePool).msgSend(objc.Object, "init", .{});
        const event = NSApp.msgSend(objc.Object, "nextEventMatchingMask:untilDate:inMode:dequeue:", .{
            cocoa.NSEvent.Mask.any,
            objc.getClass("NSDate").?.msgSend(objc.Object, "distantFuture", .{}).value,
            cocoa.NSRunLoop.Mode(.default).value,
            .YES,
        });
        // --> run your own dispatcher ...
        const point = event.msgSend(cocoa.NSPoint, "locationInWindow", .{});
        cocoa.NSLog(
            cocoa.NSString("Event [type=%@ location={%f, %f} modifierFlags]={%@}").value,
            eventTypeToString(@enumFromInt(event.msgSend(u64, "type", .{}))).value,
            point.x,
            point.y,
            eventFlagsToString(@bitCast(event.msgSend(u64, "modifierFlags", .{}))).value,
        );
        // <--
        NSApp.msgSend(void, "sendEvent:", .{event});
        NSApp.msgSend(void, "updateWindows", .{});
    }
    pool.msgSend(void, "release", .{});
}

fn eventTypeToString(event_type: cocoa.NSEvent.Type) objc.Object {
    const str = switch (event_type) {
        .LeftMouseDown => "LeftMouseDown",
        .LeftMouseUp => "LeftMouseUp",
        .RightMouseDown => "RightMouseDown",
        .RightMouseUp => "RightMouseUp",
        .MouseMoved => "MouseMoved",
        .LeftMouseDragged => "LeftMouseDragged",
        .RightMouseDragged => "RightMouseDragged",
        .MouseEntered => "MouseEntered",
        .MouseExited => "MouseExited",
        .KeyDown => "KeyDown",
        .KeyUp => "KeyUp",
        .FlagsChanged => "FlagsChanged",
        .AppKitDefined => "AppKitDefined",
        .SystemDefined => "SystemDefined",
        .ApplicationDefined => "ApplicationDefined",
        .Periodic => "Periodic",
        .CursorUpdate => "CursorUpdate",
        .ScrollWheel => "ScrollWheel",
        .TabletPoint => "TabletPoint",
        .TabletProximity => "TabletProximity",
        .OtherMouseDown => "OtherMouseDown",
        .OtherMouseUp => "OtherMouseUp",
        .OtherMouseDragged => "OtherMouseDragged",
        .Gesture => "Gesture",
        .Magnify => "Magnify",
        .Swipe => "Swipe",
        .Rotate => "Rotate",
        .BeginGesture => "BeginGesture",
        .EndGesture => "EndGesture",
        .SmartMagnify => "SmartMagnify",
        .QuickLook => "QuickLook",
        .Pressure => "Pressure",
        .DirectTouch => "DirectTouch",
        .ChangeMode => "ChangeMode",
    };
    return cocoa.NSString(str);
}

fn eventFlagsToString(flags: cocoa.NSEvent.ModifierFlags) objc.Object {
    var ret = cocoa.NSString("");
    if (flags.CapsLock) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("CapsLock, ")});
    }
    if (flags.Shift) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("Shift, ")});
    }
    if (flags.Control) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("Control, ")});
    }
    if (flags.Option) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("Option, ")});
    }
    if (flags.Command) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("Command, ")});
    }
    if (flags.NumericPad) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("NumericPad, ")});
    }
    if (flags.Help) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{cocoa.NSString("Help, ")});
    }
    if (flags.Function) {
        ret = ret.msgSend(objc.Object, "stringByAppendingString:", .{"Function, "});
    }
    return ret;
}
