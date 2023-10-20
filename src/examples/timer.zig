const cocoa = @import("cocoa");
const std = @import("std");
const objc = @import("zig-objc");

var allocator: std.mem.Allocator = undefined;

fn setup() void {
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
        fn windowShouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) i8 {
            _ = sel;
            _ = target;
            cocoa.NSApp().message(void, "terminate:", .{sender});
            return cocoa.YES;
        }
    };
    Window.replaceMethod("init", window.init);
    var onbuttonptr = &window.onButtonClick;
    var ontimerptr = &window.onTimerTick;
    std.debug.assert(objc.c.class_addMethod(Window.value, objc.sel("onButtonClick:").value, @ptrCast(onbuttonptr), "v@:@"));
    std.debug.assert(objc.c.class_addMethod(Window.value, objc.sel("onTimerTick:").value, @ptrCast(ontimerptr), "v@:@"));
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
        .message(i8, "isEqual:", .{cocoa.NSString("Start")}) == cocoa.YES;
    if (is_equal) {
        const timer = objc.getClass("NSTimer").?
            .message(objc.Object, "timerWithTimeInterval:target:selector:userInfo:repeats:", .{
            @as(f64, 0.1),
            self,
            objc.sel("onTimerTick:").value,
            self,
            true,
        });
        objc.getClass("NSRunLoop").?.message(objc.Object, "mainRunLoop", .{})
            .message(void, "addTimer:forMode:", .{
            timer,
            cocoa.NSRunLoop.Mode(.default),
        });
        self.setInstanceVariable("timer", timer);
        button.setProperty("title", .{cocoa.NSString("Stop")});
    } else {
        const timer = self.getInstanceVariable("timer");
        timer.message(void, "invalidate", .{});
        button.setProperty("title", .{cocoa.NSString("Start")});
    }
}

fn initInner(self: objc.Object) objc.Object {
    var counter: u64 = 0;
    self.setInstanceVariable("counter", cocoa.NSNumber.from(u64, counter));

    const label = cocoa.alloc(objc.getClass("NSTextField").?)
        .message(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(10, 50, 210, 70)})
        .message(objc.Object, "autorelease", .{});
    const str = std.fmt.allocPrintZ(allocator, "{d}", .{@as(f64, @floatFromInt(counter)) / 10.0}) catch @panic("OOM!");
    defer allocator.free(str);
    label.setProperty("stringValue", .{cocoa.NSString(str)});
    label.message(void, "setBezeled:", .{cocoa.NO});
    label.message(void, "setDrawsBackground:", .{cocoa.NO});
    label.setProperty("editable", .{cocoa.NO});
    label.message(void, "setSelectable:", .{cocoa.NO});
    label.setProperty("textColor", .{cocoa.NSColor.colorWithSRGB(0.117, 0.565, 1.0, 1.0)});
    var font = objc.getClass("NSFont").?.message(objc.Object, "fontWithName:size:", .{
        cocoa.NSString("Avenir"),
        @as(f64, 64),
    });
    const sharedFontManager = objc.getClass("NSFontManager").?.message(objc.Object, "sharedFontManager", .{});
    font = sharedFontManager.message(objc.Object, "convertFont:toHaveTrait:", .{
        font,
        @as(u64, 1),
    });
    font = sharedFontManager.message(objc.Object, "convertFont:toHaveTrait:", .{
        font,
        @as(u64, 2),
    });
    label.setProperty("font", .{font});
    self.setInstanceVariable("label", label);

    const button = cocoa.alloc(objc.getClass("NSButton").?)
        .message(objc.Object, "initWithFrame:", .{
        cocoa.NSRect.make(10, 10, 90, 32),
    })
        .message(objc.Object, "autorelease", .{});
    button.setProperty("action", .{objc.sel("onButtonClick:")});
    button.setProperty("bezelStyle", .{.Push});
    button.setProperty("title", .{cocoa.NSString("Start")});
    self.setInstanceVariable("button", button);

    self.message_super(
        objc.getClass("NSWindow").?,
        void,
        "initWithContentRect:styleMask:backing:defer:",
        .{
            cocoa.NSRect.make(100, 100, 230, 130),
            cocoa.NSWindow.StyleMask.default,
            .Buffered,
            cocoa.NO,
        },
    );
    self.setProperty("title", .{cocoa.NSString("Label Example")});
    const contentView = self.message(objc.Object, "contentView", .{});
    contentView.message(void, "addSubview:", .{label});
    contentView.message(void, "addSubview:", .{button});
    self.message(void, "setIsVisible:", .{cocoa.YES});
    return self;
}

pub fn main() void {
    var buf: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    allocator = fba.allocator();
    setup();
    const NSApp = cocoa.NSApp();
    const window1 = cocoa.alloc(objc.getClass("Window").?)
        .message(objc.Object, "init", .{})
        .message(objc.Object, "autorelease", .{});
    window1.message(void, "makeMainWindow", .{});
    NSApp.message(void, "run", .{});
}
