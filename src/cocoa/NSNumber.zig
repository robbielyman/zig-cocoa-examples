const cocoa = @import("../cocoa.zig");
const objc = @import("zig-objc");

pub fn from(comptime T: type, value: T) objc.Object {
    const number = objc.getClass("NSNumber").?;
    if (T == bool) return number.msgSend(objc.Object, "numberWithBool:", .{if (value) cocoa.YES else cocoa.NO});
    if (T == i8) return number.msgSend(objc.Object, "numberWithChar:", .{value});
    if (T == u8) return number.msgSend(objc.Object, "numberWithUnsignedChar:", .{value});
    if (T == i16) return number.msgSend(objc.Object, "numberWithShort:", .{value});
    if (T == u16) return number.msgSend(objc.Object, "numberWithUnsignedShort:", .{value});
    if (T == u32) return number.msgSend(objc.Object, "numberWithUnsignedInt:", .{value});
    if (T == i32) return number.msgSend(objc.Object, "numberWithInt:", .{value});
    if (T == u64) return number.msgSend(objc.Object, "numberWithUnsignedLongLong:", .{value});
    if (T == i64) return number.msgSend(objc.Object, "numberWithLongLong:", .{value});
    if (T == f32) return number.msgSend(objc.Object, "numberWithFloat:", .{value});
    if (T == f64) return number.msgSend(objc.Object, "numberWithDouble:", .{value});
    @compileError("unsupported type!");
}

pub fn to(comptime T: type, self: objc.Object) T {
    if (T == bool) return self.getProperty(bool, "boolValue");
    if (T == i8) return self.getProperty(i8, "charValue");
    if (T == u8) return self.getProperty(u8, "unsignedCharValue");
    if (T == i16) return self.getProperty(i16, "shortValue");
    if (T == u16) return self.getProperty(u16, "unsignedShortValue");
    if (T == u32) return self.getProperty(u32, "unsignedIntValue");
    if (T == i32) return self.getProperty(i32, "intValue");
    if (T == u64) return self.getProperty(u64, "unsignedLongLongValue");
    if (T == i64) return self.getProperty(i64, "longLongValue");
    if (T == f32) return self.getProperty(f32, "floatValue");
    if (T == f64) return self.getProperty(f64, "doubleValue");
    @compileError("unsupported type!");
}
