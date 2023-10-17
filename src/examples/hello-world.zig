const std = @import("std");
const objc = @import("zig-objc");
const cocoa = @import("cocoa");

pub fn main() void {
    setup();
    const NSApp = objc.getClass("NSApplication").?.message(objc.Object, "sharedApplication", .{});
    const Window = objc.getClass("Window").?;
    Window.message(objc.Object, "alloc", .{}).message(objc.Object, "init", .{}).message(objc.Object, "autorelease", .{}).message(void, "makeMainWindow", .{});
    NSApp.message(void, "run", .{});
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
            const label = NSTextField.message(objc.Object, "alloc", .{}).message(objc.Object, "initWithFrame:", .{cocoa.NSRect.make(5, 100, 290, 100)}).message(objc.Object, "autorelease", .{});
            const NSFontManager = objc.getClass("NSFontManager").?;
            const sharedFontManager = NSFontManager.message(objc.Object, "sharedFontManager", .{});
            const fontname = cocoa.NSString("Avenir");
            const NSFont = objc.getClass("NSFont").?;
            var font = sharedFontManager.message(objc.Object, "convertFont:toHaveTrait:", .{
                NSFont.message(objc.Object, "fontWithName:size:", .{ fontname, @as(f64, 30) }).value,
                @as(u64, 1),
            });
            font = sharedFontManager.message(objc.Object, "convertFont:toHaveTrait:", .{
                font.value,
                @as(u64, 2),
            });
            label.setProperty("font", .{font.value});
            label.setProperty("textColor", .{cocoa.NSColor.colorWithSRGB(0.5, 0.85, 0.7, 1.0).value});
            label.setProperty("stringValue", .{cocoa.NSString("Take off every Zig!").value});
            label.message(void, "setBordered:", .{cocoa.NO});
            label.message(void, "setBezeled:", .{cocoa.NO});
            label.setProperty("editable", .{cocoa.NO});
            label.message(void, "setSelectable:", .{cocoa.NO});
            label.message(void, "setDrawsBackground:", .{cocoa.NO});
            const ns_window = .{ .value = self.message(objc.c.Class, "superclass", .{}) };
            const stylemask: cocoa.NSWindow.StyleMask = .{
                .closable = true,
                .fullscreen = false,
                .fullsize_content_view = true,
                .miniaturizable = true,
                .resizable = true,
                .titled = true,
            };
            const backing: cocoa.NSWindow.BackingStore = .Buffered;
            self = self.message_super(ns_window, objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
                cocoa.NSRect.make(0, 0, 300, 300),
                stylemask,
                backing,
                false,
            });
            self.setProperty("title", .{cocoa.NSString("Hello world (label)").value});
            self.message(objc.Object, "contentView", .{}).message(void, "addSubview:", .{label});
            self.message(void, "center", .{});
            self.setProperty("isVisible", .{cocoa.YES});
            self.setInstanceVariable("label", label);
            return self.value;
        }
        fn windowShouldClose(target: objc.c.id, sel: objc.c.SEL, sender: objc.c.id) callconv(.C) bool {
            _ = sel;
            _ = target;
            const NSApp = objc.getClass("NSApplication").?.message(objc.Object, "sharedApplication", .{});
            NSApp.message(void, "terminate:", .{sender});
            return true;
        }
    };
    Window.replaceMethod("init", WindowStruct.init);
    Window.replaceMethod("windowShouldClose:", WindowStruct.windowShouldClose);
    objc.registerClassPair(Window);
}
