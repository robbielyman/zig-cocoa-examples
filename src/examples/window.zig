const std = @import("std");
const objc = @import("zig-objc");
const cocoa = @import("cocoa");

fn setup() void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    defer objc.registerClassPair(Window);
    std.debug.assert(Window.addIvar("button"));
    const window = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            const self = objc.Object.fromId(target);
            const button = cocoa.alloc(objc.getClass("NSButton").?)
                .msgSend(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(10, 143, 90, 32)})
                .msgSend(objc.Object, "autorelease", .{});
            button.setProperty("title", .{cocoa.NSString("Close")});
            button.setProperty("bezelStyle", .{.Push});
            button.setProperty("action", .{objc.sel("performClose:")});
            var mask = cocoa.NSView.AutoresizingMask.not_sizable;
            mask.max_x_margin = true;
            mask.min_y_margin = true;
            button.setProperty("AutoresizingMask", .{mask});
            self.setInstanceVariable("button", button);

            self.msgSendSuper(
                objc.getClass("NSWindow").?,
                void,
                "initWithContentRect:styleMask:backing:defer:",
                .{
                    cocoa.NSRect.make(320, 200, 300, 300),
                    cocoa.NSWindow.StyleMask.default,
                    .Buffered,
                    cocoa.NO,
                },
            );
            self.setProperty("title", .{cocoa.NSString("Window example")});
            self.msgSend(objc.Object, "contentView", .{})
                .msgSend(void, "addSubview:", .{button});
            self.setProperty("isVisible", .{.YES});
            return self.value;
        }
        fn shouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) objc.c.BOOL {
            _ = sel;
            return shouldCloseInner(objc.Object.fromId(target), objc.Object.fromId(sender));
        }
    };
    Window.replaceMethod("init", window.init);
    Window.replaceMethod("windowShouldClose:", window.shouldClose);
}

fn shouldCloseInner(self: objc.Object, sender: objc.Object) objc.c.BOOL {
    const Block = objc.Block(struct { sender: objc.c.id }, .{i64}, void);
    const captures: Block.Captures = .{
        .sender = sender.value,
    };
    const inner = struct {
        fn invokeFn(blk: *const Block.Context, returnCode: i64) callconv(.C) void {
            if (returnCode == 1000) {
                objc.Object.fromId(blk.sender).msgSend(void, "close", .{});
                cocoa.NSApp().msgSend(void, "stop:", .{blk.sender});
            }
        }
    };
    var block = Block.init(captures, inner.invokeFn) catch @panic("OOM!");
    const alert = cocoa.alloc(objc.getClass("NSAlert").?)
        .msgSend(objc.Object, "init", .{});
    alert.setProperty("messageText", .{cocoa.NSString("Close Window")});
    alert.setProperty("informativeText", .{cocoa.NSString("Are you sure you want to exit?")});
    alert.setProperty("alertStyle", .{@as(u64, 0)});
    alert.msgSend(void, "addButtonWithTitle:", .{cocoa.NSString("YES")});
    alert.msgSend(void, "addButtonWithTitle:", .{cocoa.NSString("NO")});
    alert.msgSend(void, "beginSheetModalForWindow:completionHandler:", .{
        self,
        block,
    });
    return cocoa.NO;
}

pub fn main() void {
    setup();
    const NSApp = cocoa.NSApp();
    const Window = objc.getClass("Window").?;
    cocoa.alloc(Window)
        .msgSend(objc.Object, "init", .{})
        .msgSend(objc.Object, "autorelease", .{})
        .msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
