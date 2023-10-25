const std = @import("std");
const objc = @import("zig-objc");
const cocoa = @import("cocoa");

pub fn main() void {
    setup();
    const NSApp = objc.getClass("NSApplication").?.msgSend(objc.Object, "sharedApplication", .{});
    const Window = objc.getClass("Window").?;
    Window.msgSend(objc.Object, "alloc", .{}).msgSend(objc.Object, "init", .{}).msgSend(objc.Object, "autorelease", .{}).msgSend(void, "makeMainWindow", .{});
    NSApp.msgSend(void, "run", .{});
}

fn setup() void {
    const NSWindow = objc.getClass("NSWindow").?;
    const Window = objc.allocateClassPair(NSWindow, "Window").?;
    const ok = Window.addIvar("label");
    std.debug.assert(ok);
    const WindowStruct = struct {
        fn init(target: objc.c.id, sel: objc.c.SEL) callconv(.C) objc.c.id {
            _ = sel;
            var self = objc.Object.fromId(target);
            const NSTextField = objc.getClass("NSTextField").?;
            const label = NSTextField.msgSend(objc.Object, "alloc", .{}).msgSend(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(5, 100, 290, 100)}).msgSend(objc.Object, "autorelease", .{});
            const NSFontManager = objc.getClass("NSFontManager").?;
            const sharedFontManager = NSFontManager.msgSend(objc.Object, "sharedFontManager", .{});
            const fontname = cocoa.NSString("Avenir");
            const NSFont = objc.getClass("NSFont").?;
            var font = sharedFontManager.msgSend(objc.Object, "convertFont:toHaveTrait:", .{
                NSFont.msgSend(objc.Object, "fontWithName:size:", .{ fontname, @as(f64, 30) }).value,
                @as(u64, 1),
            });
            font = sharedFontManager.msgSend(objc.Object, "convertFont:toHaveTrait:", .{
                font.value,
                @as(u64, 2),
            });
            label.setProperty("font", .{font.value});
            label.setProperty("textColor", .{cocoa.NSColor.colorWithSRGB(0.5, 0.85, 0.7, 1.0).value});
            label.setProperty("stringValue", .{cocoa.NSString("Take off every Zig!").value});
            label.msgSend(void, "setBordered:", .{.NO});
            label.msgSend(void, "setBezeled:", .{.NO});
            label.setProperty("editable", .{.NO});
            label.msgSend(void, "setSelectable:", .{.NO});
            label.msgSend(void, "setDrawsBackground:", .{.NO});
            const ns_window = .{ .value = self.msgSend(objc.c.Class, "superclass", .{}) };
            const stylemask: cocoa.NSWindow.StyleMask = .{
                .closable = true,
                .fullscreen = false,
                .fullsize_content_view = true,
                .miniaturizable = true,
                .resizable = true,
                .titled = true,
            };
            const backing: cocoa.NSWindow.BackingStore = .Buffered;
            self = self.msgSendSuper(ns_window, objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
                cocoa.NSRect.make(0, 0, 300, 300),
                stylemask,
                backing,
                false,
            });
            self.setProperty("title", .{cocoa.NSString("Hello world (label)").value});
            self.msgSend(objc.Object, "contentView", .{}).msgSend(void, "addSubview:", .{label});
            self.msgSend(void, "center", .{});
            self.setProperty("isVisible", .{.YES});
            self.setInstanceVariable("label", label);
            return self.value;
        }
        fn windowShouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) bool {
            _ = sel;
            _ = target;
            const NSApp = objc.getClass("NSApplication").?.msgSend(objc.Object, "sharedApplication", .{});
            NSApp.msgSend(void, "terminate:", .{sender});
            return true;
        }
    };
    Window.replaceMethod("init", WindowStruct.init);
    Window.replaceMethod("windowShouldClose:", WindowStruct.windowShouldClose);
    objc.registerClassPair(Window);
}
