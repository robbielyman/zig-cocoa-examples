const objc = @import("zig-objc");
const cocoa = @import("cocoa");

pub fn main() void {
    const NSWindow = objc.getClass("NSWindow").?;
    const styleMask: cocoa.NSWindow.StyleMask = .{
        .closable = true,
        .fullscreen = false,
        .fullsize_content_view = true,
        .miniaturizable = true,
        .resizable = true,
        .titled = true,
    };
    const backing = .Buffered;
    const window1 = NSWindow.message(objc.Object, "alloc", .{}).message(objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
        cocoa.NSRect.make(100, 100, 300, 300),
        styleMask,
        backing,
        cocoa.NO,
    }).message(objc.Object, "autorelease", .{});
    window1.setProperty("isVisible", .{cocoa.YES});
    const NSApp = objc.getClass("NSApplication").?.message(objc.Object, "sharedApplication", .{});
    NSApp.message(void, "run", .{});
}
