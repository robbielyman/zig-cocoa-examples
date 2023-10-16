const std = @import("std");
const objc = @import("zig-objc");
pub usingnamespace @import("cocoa/NSGeometry.zig");
pub const NSWindow = @import("cocoa/NSWindow.zig");
pub const NSFont = @import("cocoa/NSFont.zig");
pub const NSColor = @import("cocoa/NSColor.zig");

pub fn NSString(string: [:0]const u8) objc.Object {
    const nsstring = objc.getClass("NSString").?;
    return nsstring.message(objc.Object, "stringWithUTF8String:", .{string.ptr});
}

pub const YES: i8 = 1;
pub const NO: i8 = 0;
