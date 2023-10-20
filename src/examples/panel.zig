const objc = @import("zig-objc");
const cocoa = @import("cocoa");
const std = @import("std");

fn setup() void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    defer objc.registerClassPair(Window);
    std.debug.assert(Window.addIvar("panel1"));
    std.debug.assert(Window.addIvar("panel2"));
    const inner = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const NSScrollView = objc.getClass("NSScrollView").?;

            const panel1 = cocoa.alloc(NSScrollView)
                .message(objc.Object, "initWithFrame:", .{
                cocoa.NSRect.make(10, 10, 305, 460),
            });
            panel1.setProperty("borderType", .{.LineBorder});
            self.setInstanceVariable("panel1", panel1);

            const panel2 = cocoa.alloc(NSScrollView)
                .message(objc.Object, "initWithFrame:", .{
                cocoa.NSRect.make(325, 10, 305, 460),
            });
            panel2.setProperty("borderType", .{.GroveBorder});
            self.setInstanceVariable("panel2", panel2);

            self.message_super(objc.getClass("NSWindow").?, void, "initWithContentRect:styleMask:backing:defer:", .{
                cocoa.NSRect.make(100, 100, 640, 505),
                cocoa.NSWindow.StyleMask.default,
                .Buffered,
                cocoa.NO,
            });
            self.setProperty("title", .{cocoa.NSString("Panel example")});
            const contentView = self.message(objc.Object, "contentView", .{});
            contentView.message(void, "addSubview:", .{panel1});
            contentView.message(void, "addSubview:", .{panel2});
            self.setProperty("isVisible", .{cocoa.YES});
            return self.value;
        }
        fn shouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) bool {
            _ = sel;
            _ = target;
            cocoa.NSApp().message(void, "terminate:", .{sender});
            return true;
        }
    };
    Window.replaceMethod("init", inner.init);
    Window.replaceMethod("windowShouldClose:", inner.shouldClose);
}

pub fn main() void {
    setup();
    const NSApp = cocoa.NSApp();
    cocoa.alloc(objc.getClass("Window").?)
        .message(objc.Object, "init", .{})
        .message(objc.Object, "autorelease", .{})
        .message(void, "makeMainWindow", .{});
    NSApp.message(void, "run", .{});
}
