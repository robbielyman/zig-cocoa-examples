const objc = @import("zig-objc");

pub fn NSApp() objc.Object {
    const NSApplication = objc.getClass("NSApplication").?;
    return NSApplication.msgSend(objc.Object, "sharedApplication", .{});
}
