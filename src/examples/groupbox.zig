const objc = @import("zig-objc");
const cocoa = @import("cocoa");
const std = @import("std");

fn setup() void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    std.debug.assert(Window.addIvar("groupBox1"));
    std.debug.assert(Window.addIvar("groupBox2"));
    defer objc.registerClassPair(Window);
    const inner = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const NSBox = objc.getClass("NSBox").?;
            const groupBox1 = cocoa.alloc(NSBox)
                .msgSend(objc.Object, "initWithFrame:", .{
                cocoa.NSRect.make(10, 10, 305, 460),
            });
            groupBox1.setProperty("title", .{cocoa.NSString("GroupBox1")});
            self.setInstanceVariable("groupBox1", groupBox1);

            const groupBox2 = cocoa.alloc(NSBox)
                .msgSend(objc.Object, "initWithFrame:", .{
                cocoa.NSRect.make(325, 10, 305, 460),
            });
            groupBox2.setProperty("title", .{cocoa.NSString("")});
            self.setInstanceVariable("groupBox2", groupBox2);

            self.msgSendSuper(objc.getClass("NSWindow").?, void, "initWithContentRect:styleMask:backing:defer:", .{
                cocoa.NSRect.make(100, 100, 640, 505),
                cocoa.NSWindow.StyleMask.default,
                .Buffered,
                .NO,
            });
            self.setProperty("title", .{cocoa.NSString("GroupBox example")});
            const contentView = self.msgSend(objc.Object, "contentView", .{});
            contentView.msgSend(void, "addSubview:", .{groupBox1});
            contentView.msgSend(void, "addSubview:", .{groupBox2});
            self.setProperty("isVisible", .{.YES});
            return self.value;
        }
        fn shouldClose(
            target: objc.c.id,
            sel: objc.c.SEL,
            sender: objc.c.id,
        ) callconv(.C) bool {
            _ = sel;
            _ = target;
            cocoa.NSApp().msgSend(void, "terminate:", .{sender});
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
        .msgSend(objc.Object, "init", .{})
        .msgSend(objc.Object, "autorelease", .{})
        .msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
