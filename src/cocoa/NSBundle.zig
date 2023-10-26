const objc = @import("zig-objc");
const cocoa = @import("../cocoa.zig");
const std = @import("std");

pub fn mainBundle() objc.Object {
    const NSBundle = objc.getClass("NSBundle").?;
    return NSBundle.msgSend(objc.Object, "mainBundle", .{});
}

pub fn localizedString(self: objc.Object, key: objc.Object, value: objc.Object, table: objc.Object) objc.Object {
    return self.msgSend(objc.Object, "localizedStringForKey:value:table:", .{
        key, value, table,
    });
}
