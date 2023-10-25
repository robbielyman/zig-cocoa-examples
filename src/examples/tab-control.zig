const objc = @import("zig-objc");
const cocoa = @import("cocoa");
const std = @import("std");

fn setup() void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    defer objc.registerClassPair(Window);
    std.debug.assert(Window.addIvar("tabPage1"));
    std.debug.assert(Window.addIvar("tabPage2"));
    std.debug.assert(Window.addIvar("tabPage3"));
    std.debug.assert(Window.addIvar("tabControl"));
    const inner = struct {
        fn initFn(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const NSTabViewItem = objc.getClass("NSTabViewItem").?;

            const tabPage1 = cocoa.alloc(NSTabViewItem)
                .msgSend(objc.Object, "init", .{});
            tabPage1.setProperty("label", .{cocoa.NSString("tabPage1")});
            self.setInstanceVariable("tabPage1", tabPage1);

            const tabPage2 = cocoa.alloc(NSTabViewItem)
                .msgSend(objc.Object, "init", .{});
            tabPage2.setProperty("label", .{cocoa.NSString("tabPage2")});
            self.setInstanceVariable("tabPage2", tabPage2);

            const tabPage3 = cocoa.alloc(NSTabViewItem)
                .msgSend(objc.Object, "init", .{});
            tabPage3.setProperty("label", .{cocoa.NSString("tabPage3")});
            self.setInstanceVariable("tabPage3", tabPage3);

            const tabControl = cocoa.alloc(objc.getClass("NSTabView").?)
                .msgSend(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(0, 0, 370, 245)});
            tabControl.msgSend(void, "insertTabViewItem:atIndex:", .{
                tabPage1,
                @as(i64, 0),
            });
            tabControl.msgSend(void, "insertTabViewItem:atIndex:", .{
                tabPage2,
                @as(i64, 1),
            });
            tabControl.msgSend(void, "insertTabViewItem:atIndex:", .{
                tabPage3,
                @as(i64, 2),
            });
            self.setInstanceVariable("tabControl", tabControl);

            const stylemask = cocoa.NSWindow.StyleMask.default;
            self.msgSendSuper(objc.getClass("NSWindow").?, void, "initWithContentRect:styleMask:backing:defer:", .{
                cocoa.NSRect.make(100, 100, 390, 270),
                stylemask,
                .Buffered,
                .NO,
            });
            self.setProperty("title", .{cocoa.NSString("TabControl example")});
            self.msgSend(objc.Object, "contentView", .{})
                .msgSend(void, "addSubview:", .{tabControl});
            self.setProperty("isVisible", .{.YES});
            return self.value;
        }
        fn shouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) bool {
            _ = sel;
            _ = target;
            cocoa.NSApp().msgSend(void, "terminate:", .{sender});
            return true;
        }
    };
    Window.replaceMethod("init", inner.initFn);
    Window.replaceMethod("windowShouldClose:", inner.shouldClose);
}

pub fn main() void {
    setup();
    const NSApp = cocoa.NSApp();
    const Window = objc.getClass("Window").?;
    cocoa.alloc(Window).msgSend(objc.Object, "init", .{})
        .msgSend(objc.Object, "autorelease", .{})
        .msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
