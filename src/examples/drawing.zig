const std = @import("std");
const cocoa = @import("cocoa");
const objc = @import("zig-objc");

fn setupWindow() void {
    const View = objc.allocateClassPair(objc.getClass("NSView").?, "View").?;
    const view = struct {
        fn drawInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            rect: cocoa.NSRect,
        ) callconv(.C) void {
            _ = sel;
            draw(objc.Object.fromId(target), rect);
        }
    };
    View.replaceMethod("drawRect:", view.drawInner);
    objc.registerClassPair(View);
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    _ = Window.addIvar("view");
    const window = struct {
        fn initWithInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            contentRect: cocoa.NSRect,
            styleMask: cocoa.NSWindow.StyleMask,
            backing: cocoa.NSWindow.BackingStore,
            deferred: i8,
        ) callconv(.C) objc.c.id {
            _ = sel;
            var self = objc.Object.fromId(target);
            self = initWith(self, contentRect, styleMask, backing, if (deferred == 1) true else false);
            return self.value;
        }
        fn windowShouldCloseInner(
            target: objc.c.id,
            sel: objc.c.SEL,
            sender: objc.c.id,
        ) callconv(.C) objc.c.BOOL {
            _ = sel;
            return if (windowShouldClose(objc.Object.fromId(target), sender)) cocoa.YES else cocoa.NO;
        }
    };
    Window.replaceMethod("initWithContentRect:styleMask:backing:defer:", window.initWithInner);
    Window.replaceMethod("windowShouldClose:", window.windowShouldCloseInner);
    objc.registerClassPair(Window);
}

fn draw(self: objc.Object, rect: cocoa.NSRect) void {
    _ = self;
    const green = cocoa.NSColor.colorWithSRGB(0.2, 1.0, 0.6, 1.0);
    green.msgSend(void, "set", .{});
    rect.fill();
}

fn initWith(
    self: objc.Object,
    contentRect: cocoa.NSRect,
    styleMask: cocoa.NSWindow.StyleMask,
    backing: cocoa.NSWindow.BackingStore,
    deferred: bool,
) objc.Object {
    self.msgSendSuper(objc.getClass("NSWindow").?, void, "initWithContentRect:styleMask:backing:defer:", .{
        contentRect,
        styleMask,
        backing,
        deferred,
    });
    const view = cocoa.alloc(objc.getClass("View").?).msgSend(objc.Object, "init", .{});
    _ = self.setInstanceVariable("view", view);
    self.msgSend(objc.Object, "contentView", .{}).msgSend(void, "addSubview:", .{view});
    return self;
}

fn windowShouldClose(self: objc.Object, sender: objc.c.id) bool {
    _ = self;
    cocoa.NSApp().msgSend(void, "terminate:", .{sender});
    return false;
}

pub fn main() void {
    setupWindow();
    const Window = objc.getClass("Window").?;
    const stylemask: cocoa.NSWindow.StyleMask = .{
        .closable = true,
        .fullscreen = false,
        .fullsize_content_view = true,
        .miniaturizable = true,
        .resizable = true,
        .titled = true,
    };
    const window1 = cocoa.alloc(Window).msgSend(objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
        cocoa.NSRect.make(0, 0, 300, 300),
        stylemask,
        .Buffered,
        .NO,
    });
    window1.msgSend(void, "setTitle:", .{cocoa.NSString("Drawing Example")});
    window1.setProperty("isVisible", .{.YES});

    const NSApp = cocoa.NSApp();
    window1.msgSend(void, "makeMainWindow", .{});
    window1.msgSend(void, "makeKeyWindow", .{});

    const NSAutoreleasePool = objc.getClass("NSAutoreleasePool").?;
    var pool = cocoa.alloc(NSAutoreleasePool).msgSend(objc.Object, "init", .{});
    const hasIdle = false;
    while (true) {
        pool.msgSend(void, "release", .{});
        pool = cocoa.alloc(NSAutoreleasePool).msgSend(objc.Object, "init", .{});
        const date = objc.getClass("NSDate").?.msgSend(objc.Object, if (hasIdle) "distantPast" else "distantFuture", .{});
        const event = NSApp.msgSend(
            objc.Object,
            "nextEventMatchingMask:untilDate:inMode:dequeue:",
            .{
                cocoa.NSEvent.Mask.any,
                date,
                cocoa.NSRunLoop.Mode(.default),
                .YES,
            },
        );
        if (event.value != null) {
            // run your own dispatcher...
            NSApp.msgSend(void, "sendEvent:", .{event});
            NSApp.msgSend(void, "updateWindows", .{});
        } else if (hasIdle) {
            // run idle method...
        }
    }
    pool.msgSend(void, "release", .{});
}
