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
    const window1 = NSWindow.msgSend(objc.Object, "alloc", .{}).msgSend(objc.Object, "initWithContentRect:styleMask:backing:defer:", .{
        cocoa.NSRect.make(100, 100, 300, 300),
        styleMask,
        backing,
        .NO,
    }).msgSend(objc.Object, "autorelease", .{});
    window1.setProperty("isVisible", .{.YES});
    const NSApp = objc.getClass("NSApplication").?.msgSend(objc.Object, "sharedApplication", .{});
    NSApp.msgSend(void, "run", .{});
}
