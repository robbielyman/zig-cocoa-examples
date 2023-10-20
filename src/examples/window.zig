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
                .message(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(10, 143, 90, 32)})
                .message(objc.Object, "autorelease", .{});
            button.setProperty("title", .{cocoa.NSString("Close")});
            button.setProperty("bezelStyle", .{.Push});
            button.setProperty("action", .{objc.sel("performClose:")});
            var mask = cocoa.NSView.AutoresizingMask.not_sizable;
            mask.max_x_margin = true;
            mask.min_y_margin = true;
            button.setProperty("AutoresizingMask", .{mask});
            self.setInstanceVariable("button", button);

            self.message_super(
                objc.getClass("NSWindow").?,
                void,
                "initWithContentRect:styleMask:backing:defer:",
                .{
                    cocoa.NSRect.make(320, 200, 300, 300),
                    cocoa.NSWindow.StyleMask.default,
                    .Buffered,
                    .NO,
                },
            );
            self.setProperty("title", .{cocoa.NSString("Window example")});
            self.message(objc.Object, "contentView", .{})
                .message(void, "addSubview:", .{button});
            self.setProperty("isVisible", .{cocoa.YES});
            return self.value;
        }
        fn shouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) i8 {
            _ = sel;
            return @intFromEnum(shouldCloseInner(objc.Object.fromId(target), objc.Object.fromId(sender)));
        }
    };
    Window.replaceMethod("init", window.init);
    Window.replaceMethod("windowShouldClose:", window.shouldClose);
}

fn shouldCloseInner(self: objc.Object, sender: objc.Object) cocoa.BOOL {
    const Captures = struct {
        sender: objc.c.id,
    };
    const Block = objc.Block(Captures, fn (blk: *anyopaque, returnCode: i64) void);
    const captures: Captures = .{
        .sender = sender.value,
    };
    const inner = struct {
        fn invokeFn(blk: *anyopaque, returnCode: i64) callconv(.C) void {
            const block: *Block = @ptrCast(@alignCast(blk));
            if (returnCode == 1000) {
                objc.Object.fromId(block.sender).message(void, "close", .{});
                cocoa.NSApp().message(void, "stop:", .{block.sender});
            }
        }
    };
    var block = objc.initBlock(Block, captures, inner.invokeFn);
    const alert = cocoa.alloc(objc.getClass("NSAlert").?)
        .message(objc.Object, "init", .{});
    alert.setProperty("messageText", .{cocoa.NSString("Close Window")});
    alert.setProperty("informativeText", .{cocoa.NSString("Are you sure you want to exit?")});
    alert.setProperty("alertStyle", .{@as(u64, 0)});
    alert.message(void, "addButtonWithTitle:", .{cocoa.NSString("YES")});
    alert.message(void, "addButtonWithTitle:", .{cocoa.NSString("NO")});
    alert.message(void, "beginSheetModalForWindow:completionHandler:", .{
        self,
        block,
    });
    return .NO;
}

pub fn main() void {
    setup();
    const NSApp = cocoa.NSApp();
    const Window = objc.getClass("Window").?;
    cocoa.alloc(Window)
        .message(objc.Object, "init", .{})
        .message(objc.Object, "autorelease", .{})
        .message(void, "makeMainWindow", .{});
    NSApp.message(void, "run", .{});
}
