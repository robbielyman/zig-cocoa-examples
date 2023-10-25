const cocoa = @import("cocoa");
const std = @import("std");
const objc = @import("zig-objc");

var allocator: std.mem.Allocator = undefined;

fn setup() !void {
    const Window = objc.allocateClassPair(objc.getClass("NSWindow").?, "Window").?;
    defer objc.registerClassPair(Window);
    std.debug.assert(Window.addIvar("label"));
    std.debug.assert(Window.addIvar("button"));
    std.debug.assert(Window.addIvar("timer"));
    std.debug.assert(Window.addIvar("counter"));
    const window = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            return initInner(objc.Object.fromId(target)).value;
        }
        fn onButtonClick(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) void {
            _ = sel;
            onButtonClickInner(objc.Object.fromId(target), objc.Object.fromId(sender));
        }
        fn onTimerTick(target: objc.c.id, sel: objc.c.SEL, timer: objc.c.id) callconv(.C) void {
            _ = sel;
            onTimerTickInner(objc.Object.fromId(target), objc.Object.fromId(timer));
        }
        fn windowShouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) objc.c.BOOL {
            _ = sel;
            _ = target;
            cocoa.NSApp().msgSend(void, "terminate:", .{sender});
            return cocoa.YES;
        }
    };
    Window.replaceMethod("init", window.init);
    _ = try Window.addMethod("onButtonClick:", window.onButtonClick);
    _ = try Window.addMethod("onTimerTick:", window.onTimerTick);
    Window.replaceMethod("windowShouldClose:", window.windowShouldClose);
}

fn onTimerTickInner(self: objc.Object, timer: objc.Object) void {
    _ = timer;
    const label = self.getInstanceVariable("label");
    const counter: u64 = cocoa.NSNumber.to(u64, self.getInstanceVariable("counter")) + 1;
    defer self.setInstanceVariable("counter", cocoa.NSNumber.from(u64, counter));
    const str = std.fmt.allocPrintZ(allocator, "{d}", .{@as(f64, @floatFromInt(counter)) / 10.0}) catch @panic("OOM!");
    defer allocator.free(str);
    label.setProperty("stringValue", .{cocoa.NSString(str)});
}

fn onButtonClickInner(self: objc.Object, sender: objc.Object) void {
    _ = sender;
    const button = self.getInstanceVariable("button");
    const is_equal = button.getProperty(objc.Object, "title")
        .msgSend(objc.c.BOOL, "isEqual:", .{cocoa.NSString("Start")}) == cocoa.YES;
    if (is_equal) {
        const timer = objc.getClass("NSTimer").?
            .msgSend(objc.Object, "timerWithTimeInterval:target:selector:userInfo:repeats:", .{
            @as(f64, 0.1),
            self,
            objc.sel("onTimerTick:").value,
            self,
            true,
        });
        objc.getClass("NSRunLoop").?.msgSend(objc.Object, "mainRunLoop", .{})
            .msgSend(void, "addTimer:forMode:", .{
            timer,
            cocoa.NSRunLoop.Mode(.default),
        });
        self.setInstanceVariable("timer", timer);
        button.setProperty("title", .{cocoa.NSString("Stop")});
    } else {
        const timer = self.getInstanceVariable("timer");
        timer.msgSend(void, "invalidate", .{});
        button.setProperty("title", .{cocoa.NSString("Start")});
    }
}

fn initInner(self: objc.Object) objc.Object {
    var counter: u64 = 0;
    self.setInstanceVariable("counter", cocoa.NSNumber.from(u64, counter));

    const label = cocoa.alloc(objc.getClass("NSTextField").?)
        .msgSend(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(10, 50, 210, 70)})
        .msgSend(objc.Object, "autorelease", .{});
    const str = std.fmt.allocPrintZ(allocator, "{d}", .{@as(f64, @floatFromInt(counter)) / 10.0}) catch @panic("OOM!");
    defer allocator.free(str);
    label.setProperty("stringValue", .{cocoa.NSString(str)});
    label.msgSend(void, "setBezeled:", .{false});
    label.msgSend(void, "setDrawsBackground:", .{false});
    label.setProperty("editable", .{false});
    label.msgSend(void, "setSelectable:", .{false});
    label.setProperty("textColor", .{cocoa.NSColor.colorWithSRGB(0.117, 0.565, 1.0, 1.0)});
    var font = objc.getClass("NSFont").?.msgSend(objc.Object, "fontWithName:size:", .{
        cocoa.NSString("Avenir"),
        @as(f64, 64),
    });
    const sharedFontManager = objc.getClass("NSFontManager").?.msgSend(objc.Object, "sharedFontManager", .{});
    font = sharedFontManager.msgSend(objc.Object, "convertFont:toHaveTrait:", .{
        font,
        @as(u64, 1),
    });
    font = sharedFontManager.msgSend(objc.Object, "convertFont:toHaveTrait:", .{
        font,
        @as(u64, 2),
    });
    label.setProperty("font", .{font});
    self.setInstanceVariable("label", label);

    const button = cocoa.alloc(objc.getClass("NSButton").?)
        .msgSend(objc.Object, "initWithFrame:", .{
        cocoa.NSRect.make(10, 10, 90, 32),
    })
        .msgSend(objc.Object, "autorelease", .{});
    button.setProperty("action", .{objc.sel("onButtonClick:")});
    button.setProperty("bezelStyle", .{.Push});
    button.setProperty("title", .{cocoa.NSString("Start")});
    self.setInstanceVariable("button", button);

    self.msgSendSuper(
        objc.getClass("NSWindow").?,
        void,
        "initWithContentRect:styleMask:backing:defer:",
        .{
            cocoa.NSRect.make(100, 100, 230, 130),
            cocoa.NSWindow.StyleMask.default,
            .Buffered,
            .NO,
        },
    );
    self.setProperty("title", .{cocoa.NSString("Label Example")});
    const contentView = self.msgSend(objc.Object, "contentView", .{});
    contentView.msgSend(void, "addSubview:", .{label});
    contentView.msgSend(void, "addSubview:", .{button});
    self.msgSend(void, "setIsVisible:", .{.YES});
    return self;
}

pub fn main() !void {
    var buf: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    allocator = fba.allocator();
    try setup();
    const NSApp = cocoa.NSApp();
    const window1 = cocoa.alloc(objc.getClass("Window").?)
        .msgSend(objc.Object, "init", .{})
        .msgSend(objc.Object, "autorelease", .{});
    window1.msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}
