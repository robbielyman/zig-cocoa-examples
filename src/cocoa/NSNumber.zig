const cocoa = @import("../cocoa.zig");
const objc = @import("zig-objc");

pub fn from(comptime T: type, value: T) objc.Object {
    const number = objc.getClass("NSNumber").?;
    if (T == bool) return number.message(objc.Object, "numberWithBool:", .{if (value) .YES else .NO});
    if (T == cocoa.BOOL) return number.message(objc.Object, "numberWithBool:", .{value});
    if (T == i8) return number.message(objc.Object, "numberWithChar:", .{value});
    if (T == u8) return number.message(objc.Object, "numberWithUnsignedChar:", .{value});
    if (T == i16) return number.message(objc.Object, "numberWithShort:", .{value});
    if (T == u16) return number.message(objc.Object, "numberWithUnsignedShort:", .{value});
    if (T == u32) return number.message(objc.Object, "numberWithUnsignedInt:", .{value});
    if (T == i32) return number.message(objc.Object, "numberWithInt:", .{value});
    if (T == u64) return number.message(objc.Object, "numberWithUnsignedLongLong:", .{value});
    if (T == i64) return number.message(objc.Object, "numberWithLongLong:", .{value});
    if (T == f32) return number.message(objc.Object, "numberWithFloat:", .{value});
    if (T == f64) return number.message(objc.Object, "numberWithDouble:", .{value});
    @compileError("unsupported type!");
}

pub fn to(comptime T: type, self: objc.Object) T {
    if (T == bool) return self.getProperty(bool, "boolValue");
    if (T == cocoa.BOOL) @as(cocoa.BOOL, @enumFromInt(return self.getProperty(i8, "boolValue")));
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
