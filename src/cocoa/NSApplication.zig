const objc = @import("zig-objc");

pub fn NSApp() objc.Object {
    const NSApplication = objc.getClass("NSApplication").?;
    return NSApplication.message(objc.Object, "sharedApplication", .{});
}
