const std = @import("std");
const objc = @import("zig-objc");
pub usingnamespace @import("cocoa/NSGeometry.zig");
pub usingnamespace @import("cocoa/NSApplication.zig");
pub const NSWindow = @import("cocoa/NSWindow.zig");
pub const NSFont = @import("cocoa/NSFont.zig");
pub const NSColor = @import("cocoa/NSColor.zig");
pub const NSEvent = @import("cocoa/NSEvent.zig");
pub const NSRunLoop = @import("cocoa/NSRunLoop.zig");
pub const NSNotification = @import("cocoa/NSNotification.zig");

pub fn NSString(string: [:0]const u8) objc.Object {
    const nsstring = objc.getClass("NSString").?;
    return nsstring.message(objc.Object, "stringWithUTF8String:", .{string.ptr});
}

pub fn descriptionToOwnedSlice(allocator: std.mem.Allocator, object: objc.Object) ![:0]const u8 {
    const str = object.message(objc.Object, "description", .{});
    const slice = std.mem.sliceTo(str.getProperty([*:0]const u8, "UTF8String"), 0);
    return allocator.dupeZ(u8, slice);
}

pub const YES: i8 = 1;
pub const NO: i8 = 0;

pub fn alloc(class: objc.Class) objc.Object {
    return class.message(objc.Object, "alloc", .{});
}

pub extern "C" fn NSLog(format: objc.c.id, ...) void;
