const cocoa = @import("cocoa");
const objc = @import("zig-objc");
const std = @import("std");

pub fn main() !void {
    const window1 = cocoa.NSWindow.initWith(
        cocoa.alloc(objc.getClass("NSWindow").?),
        cocoa.NSRect.make(100, 100, 300, 300),
        .{ .closable = true, .fullscreen = false, .fullsize_content_view = true, .miniaturizable = true, .resizable = true, .titled = true },
        .Buffered,
        false,
    ).msgSend(objc.Object, "autorelease", .{});
    window1.setProperty("isVisible", .{.YES});
    const NSApp = cocoa.NSApp();
    const NSAutoReleasePool = objc.getClass("NSAutoreleasePool").?;
    var pool = cocoa.alloc(NSAutoReleasePool).msgSend(objc.Object, "init", .{});
    NSApp.msgSend(void, "finishLaunching", .{});
    var timer = try std.time.Timer.start();
    var elapsed: u64 = 0;
    var counter: u32 = 0;
    while (true) {
        pool.msgSend(void, "release", .{});
        pool = cocoa.alloc(objc.getClass("NSAutoreleasePool").?).msgSend(objc.Object, "init", .{});

        const event = NSApp.msgSend(objc.Object, "nextEventMatchingMask:untilDate:inMode:dequeue:", .{
            cocoa.NSEvent.Mask.any,
            objc.getClass("NSDate").?.msgSend(objc.Object, "distantPast", .{}).value,
            cocoa.NSRunLoop.Mode(.default).value,
            .YES,
        });
        if (event.value != null) {
            NSApp.msgSend(void, "sendEvent:", .{event});
            NSApp.msgSend(void, "updateWindows", .{});
        } else {
            elapsed += timer.lap();
            if (elapsed > std.time.ns_per_s) {
                counter += 1;
                elapsed -= std.time.ns_per_s;
                var buf: [128]u8 = undefined;
                var buf_heap: std.heap.FixedBufferAllocator = .{
                    .buffer = &buf,
                    .end_index = 0,
                };
                const allocator = buf_heap.allocator();
                const title = std.fmt.allocPrintZ(allocator, "{d}", .{counter}) catch @panic("OOM!");
                defer allocator.free(title);
                window1.msgSend(void, "setTitle:", .{
                    cocoa.NSString(title),
                });
            }
        }
    }
    pool.msgSend(void, "release", .{});
}
